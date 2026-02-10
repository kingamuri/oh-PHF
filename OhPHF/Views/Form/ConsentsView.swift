import SwiftUI

struct ConsentsView: View {
    @EnvironmentObject var formVM: FormViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @State private var isDrawingSignature = false

    private var consent: Binding<ConsentInfo> {
        $formVM.form.consentInfo
    }

    private var allAgreed: Bool {
        let c = formVM.form.consentInfo
        return c.gdprConsent && c.drivingAcknowledgment && c.missedAppointmentConsent
            && c.photosInternal && c.photosResearch && c.photosMarketing
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

                        // MARK: - All Consents (single card)
                        consentsSection

                        // MARK: - Signature
                        signatureSection
                    }
                    .frame(maxWidth: Theme.maxFormWidth)
                    .padding()
                }
                .scrollDisabled(isDrawingSignature)

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
                        .glassBackground(.regular, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    }
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: formVM.isSubmitting)
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
                        .foregroundStyle(Theme.deepBlue.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxHeight: 200)
            }
        }
    }

    // MARK: - All Consents in One Card

    private var consentsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                Text(L("consent.title"))
                    .font(Theme.headlineFont)
                    .foregroundStyle(Theme.deepBlue)

                // GDPR *
                consentToggle(
                    text: L("consent.gdpr"),
                    isOn: consent.gdprConsent,
                    isMandatory: true
                )

                Divider()

                // Driving *
                consentToggle(
                    text: L("consent.driving"),
                    isOn: consent.drivingAcknowledgment,
                    isMandatory: true
                )

                Divider()

                // Missed Appointment *
                consentToggle(
                    text: L("consent.missedAppointment", settingsVM.settings.missedAppointmentFee),
                    isOn: consent.missedAppointmentConsent,
                    isMandatory: true
                )

                Divider()

                // Photos: internal *
                consentToggle(
                    text: L("consent.photosInternal"),
                    isOn: consent.photosInternal,
                    isMandatory: true
                )

                Divider()

                // Photos: research
                consentToggle(
                    text: L("consent.photosResearch"),
                    isOn: consent.photosResearch
                )

                Divider()

                // Photos: marketing
                consentToggle(
                    text: L("consent.photosMarketing"),
                    isOn: consent.photosMarketing
                )

                Divider()

                // * Mandatory footnote
                Text(L("consent.mandatoryFootnote"))
                    .font(Theme.captionFont)
                    .foregroundStyle(.red)

                Divider()

                // Agree to all
                Toggle(isOn: Binding(
                    get: { allAgreed },
                    set: { newValue in
                        formVM.form.consentInfo.gdprConsent = newValue
                        formVM.form.consentInfo.drivingAcknowledgment = newValue
                        formVM.form.consentInfo.missedAppointmentConsent = newValue
                        formVM.form.consentInfo.photosInternal = newValue
                        formVM.form.consentInfo.photosResearch = newValue
                        formVM.form.consentInfo.photosMarketing = newValue
                    }
                )) {
                    Text(L("consent.agreeAll"))
                        .font(Theme.bodyFont.weight(.semibold))
                        .foregroundStyle(Theme.deepBlue)
                }
                .tint(Theme.accentBlue)
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

                SignaturePadView(signatureData: $formVM.form.signatureData, isDrawing: $isDrawingSignature)

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
        isMandatory: Bool = false
    ) -> some View {
        Toggle(isOn: isOn) {
            HStack(alignment: .top, spacing: 2) {
                if isMandatory {
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
