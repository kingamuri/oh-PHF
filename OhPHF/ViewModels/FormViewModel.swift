import SwiftUI

@MainActor
final class FormViewModel: ObservableObject {
    @Published var form = PatientForm()
    @Published var currentPage: Int = 0  // 0=Welcome, 1-8=form pages
    @Published var navigatingForward: Bool = true
    @Published var isSubmitting: Bool = false
    @Published var showThankYou: Bool = false
    @Published var generatedPDFData: Data?
    @Published var validationErrors: [String] = []

    let totalPages = 9  // 0=welcome + 8 form pages

    // Page titles for progress tracking
    var currentPageTitle: String {
        switch currentPage {
        case 0: return L("welcome.title")
        case 1: return L("personal.title")
        case 2: return L("medications.title")
        case 3: return L("allergies.title")
        case 4: return L("conditions.title")
        case 5: return L("womensHealth.title")
        case 6: return L("lifestyle.title")
        case 7: return L("dental.title")
        case 8: return L("consent.title")
        default: return ""
        }
    }

    // Compute actual page sequence accounting for conditional skip
    var shouldShowWomensHealth: Bool {
        form.personalInfo.gender == .female
    }

    func nextPage() {
        navigatingForward = true
        var next = currentPage + 1
        // Skip Women's Health (page 5) if not female
        if next == 5 && !shouldShowWomensHealth {
            next = 6
        }
        if next < totalPages {
            currentPage = next
        }
    }

    func previousPage() {
        navigatingForward = false
        var prev = currentPage - 1
        // Skip Women's Health (page 5) going backward if not female
        if prev == 5 && !shouldShowWomensHealth {
            prev = 4
        }
        if prev >= 0 {
            currentPage = prev
        }
    }

    // Progress from 0.0 to 1.0
    var progress: Double {
        guard currentPage > 0 else { return 0 }
        let effectivePages = shouldShowWomensHealth ? 8.0 : 7.0
        return min(Double(currentPage) / effectivePages, 1.0)
    }

    var effectivePageIndex: Int {
        // Page index for progress display, accounting for skip
        if !shouldShowWomensHealth && currentPage > 5 {
            return currentPage - 1
        }
        return currentPage
    }

    var effectiveTotalPages: Int {
        shouldShowWomensHealth ? 8 : 7
    }

    func validateCurrentPage() -> Bool {
        validationErrors = []
        switch currentPage {
        case 1:
            if form.personalInfo.firstName.trimmingCharacters(in: .whitespaces).isEmpty {
                validationErrors.append(L("validation.firstNameRequired"))
            }
            if form.personalInfo.lastName.trimmingCharacters(in: .whitespaces).isEmpty {
                validationErrors.append(L("validation.lastNameRequired"))
            }
        case 8:
            if !form.consentInfo.gdprConsent {
                validationErrors.append(L("validation.gdprRequired"))
            }
            if !form.consentInfo.drivingAcknowledgment {
                validationErrors.append(L("validation.drivingRequired"))
            }
            if !form.consentInfo.missedAppointmentConsent {
                validationErrors.append(L("validation.missedAppointmentRequired"))
            }
            if !form.consentInfo.photosInternal {
                validationErrors.append(L("validation.photosInternalRequired"))
            }
            if form.signatureData == nil {
                validationErrors.append(L("validation.signatureRequired"))
            }
        default:
            break
        }
        return validationErrors.isEmpty
    }

    func submit() async {
        guard validateCurrentPage() else { return }
        isSubmitting = true
        form.submissionDate = Date()
        form.language = LocalizationManager.shared.languageCode

        // Generate PDF
        let settings = ClinicSettings.load()
        let pdfData = PDFGeneratorService.generatePDF(form: form, settings: settings)
        generatedPDFData = pdfData

        // Store locally
        PDFStorageService.shared.store(
            pdfData: pdfData,
            patientName: "\(form.personalInfo.firstName) \(form.personalInfo.lastName)",
            bddScore: form.dentalHistoryInfo.visitReason == .aesthetic
                ? BDDScorer.calculateScore(from: form.dentalHistoryInfo.bddScreener)
                : nil
        )

        // Send email in the background (best-effort, fire-and-forget)
        let sanitizedName = "\(form.personalInfo.firstName) \(form.personalInfo.lastName)"
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        let fileName = "PHF_\(sanitizedName)_\(formatter.string(from: Date())).pdf"

        SMTPService.shared.sendInBackground(
            pdfData: pdfData,
            fileName: fileName,
            recipientEmail: settings.email,
            patientName: "\(form.personalInfo.firstName) \(form.personalInfo.lastName)",
            settings: settings
        )

        isSubmitting = false

        // Show thank you screen — auto-resets after delay
        showThankYou = true
        scheduleReset()
    }

    func reset() {
        form = PatientForm()
        currentPage = 0
        navigatingForward = true
        isSubmitting = false
        showThankYou = false
        generatedPDFData = nil
        validationErrors = []
    }

    private func scheduleReset() {
        Task {
            try? await Task.sleep(for: .seconds(5))
            reset()
        }
    }
}
