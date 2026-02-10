import SwiftUI

struct ConsentsView: View {
    @EnvironmentObject var formVM: FormViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel

    private var consent: Binding<ConsentInfo> {
        $formVM.form.consentInfo
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: Theme.sectionSpacing) {
                        // MARK: - Validation Errors
                        if !formVM.validationErrors.isEmpty {
                            validationBanner
                        }

                        // MARK: - Privacy Notice
                        privacyNoticeSection

                        // MARK: - Mandatory Consents
                        mandatoryConsentsSection

                        // MARK: - Optional Photo Consents
                        photoConsentsSection

                        // MARK: - Signature
                        signatureSection
                    }
                    .frame(maxWidth: Theme.maxFormWidth)
                    .padding()
                }

                // MARK: - Navigation Bar (Last Page)
                FormNavigationBar(
                    currentPage: formVM.effectivePageIndex,
                    totalPages: formVM.effectiveTotalPages,
                    pageTitle: formVM.currentPageTitle,
                    canGoBack: formVM.currentPage > 0,
                    isLastPage: true,
                    isSubmitting: formVM.isSubmitting,
                    onBack: { formVM.previousPage() },
                    onNext: {},
                    onSubmit: {
                        Task {
                            await formVM.submit()
                        }
                    }
                )
            }

            // MARK: - Loading Overlay
            if formVM.isSubmitting {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text(L("consent.submitting"))
                                .font(Theme.bodyFont)
                                .foregroundStyle(.white)
                        }
                        .padding(32)
                        .background(
                            .ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        )
                    }
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: formVM.isSubmitting)
        .sheet(isPresented: $formVM.showMailComposer) {
            if let pdfData = formVM.generatedPDFData {
                EmailComposerView(
                    pdfData: pdfData,
                    recipientEmail: settingsVM.settings.email,
                    patientName: "\(formVM.form.personalInfo.firstName) \(formVM.form.personalInfo.lastName)",
                    onDismiss: {
                        formVM.reset()
                    }
                )
            }
        }
    }

    // MARK: - Privacy Notice Section

    private var privacyNoticeSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(L("consent.privacyTitle"))
                    .font(Theme.headlineFont)
                    .foregroundStyle(Theme.deepBlue)

                ScrollView {
                    Text(L("consent.privacyNotice"))
                        .font(Theme.captionFont)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxHeight: 200)
            }
        }
    }

    // MARK: - Mandatory Consents Section

    private var mandatoryConsentsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                Text(L("consent.mandatoryTitle"))
                    .font(Theme.headlineFont)
                    .foregroundStyle(Theme.deepBlue)

                // GDPR Consent
                consentToggle(
                    text: L("consent.gdpr"),
                    isOn: consent.gdprConsent,
                    isRequired: true
                )

                Divider()

                // Driving Acknowledgment
                consentToggle(
                    text: L("consent.driving"),
                    isOn: consent.drivingAcknowledgment,
                    isRequired: true
                )

                Divider()

                // Missed Appointment Fee
                consentToggle(
                    text: L("consent.missedAppointment", settingsVM.settings.missedAppointmentFee),
                    isOn: consent.missedAppointmentConsent,
                    isRequired: true
                )
            }
        }
    }

    // MARK: - Photo Consents Section

    private var photoConsentsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                Text(L("consent.photoTitle"))
                    .font(Theme.headlineFont)
                    .foregroundStyle(Theme.deepBlue)

                Text(L("consent.photoNote"))
                    .font(Theme.captionFont)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Internal documentation
                consentToggle(
                    text: L("consent.photosInternal"),
                    isOn: consent.photosInternal,
                    isRequired: false
                )

                Divider()

                // Research / publications
                consentToggle(
                    text: L("consent.photosResearch"),
                    isOn: consent.photosResearch,
                    isRequired: false
                )

                Divider()

                // Marketing
                consentToggle(
                    text: L("consent.photosMarketing"),
                    isOn: consent.photosMarketing,
                    isRequired: false
                )
            }
        }
    }

    // MARK: - Signature Section

    private var signatureSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(L("consent.signatureTitle"))
                    .font(Theme.headlineFont)
                    .foregroundStyle(Theme.deepBlue)

                SignaturePadView(signatureData: $formVM.form.signatureData)

                // Auto-date display
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(Theme.accentBlue)
                    Text(L("consent.date"))
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.deepBlue)
                    Spacer()
                    Text(Self.dateFormatter.string(from: Date()))
                        .font(Theme.bodyFont)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Consent Toggle

    private func consentToggle(
        text: String,
        isOn: Binding<Bool>,
        isRequired: Bool
    ) -> some View {
        Toggle(isOn: isOn) {
            HStack(alignment: .top, spacing: 4) {
                if isRequired {
                    Text("*")
                        .font(Theme.bodyFont)
                        .foregroundStyle(.red)
                }
                Text(text)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.deepBlue)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .tint(Theme.accentBlue)
    }

    // MARK: - Validation Banner

    private var validationBanner: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(formVM.validationErrors, id: \.self) { error in
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.red)
                            .font(.caption)
                        Text(error)
                            .font(Theme.captionFont)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }

    // MARK: - Date Formatter

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

// MARK: - Preview

#Preview {
    ZStack {
        SkyBackground()
        ConsentsView()
    }
    .environmentObject(FormViewModel())
    .environmentObject(SettingsViewModel())
    .environmentObject(LocalizationManager.shared)
}
