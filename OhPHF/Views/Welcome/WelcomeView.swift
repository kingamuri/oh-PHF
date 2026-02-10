import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var formVM: FormViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Theme.sectionSpacing) {
                // MARK: - Clinic Logo
                clinicLogo
                    .onLongPressGesture(minimumDuration: 3) {
                        settingsVM.showPINEntry = true
                    }

                // MARK: - Clinic Name & Subtitle
                VStack(spacing: 6) {
                    Text(settingsVM.settings.clinicName)
                        .font(Theme.titleFont)
                        .foregroundStyle(Theme.deepBlue)
                        .multilineTextAlignment(.center)

                    Text(settingsVM.settings.clinicSubtitle)
                        .font(Theme.bodyFont)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                // MARK: - Patient Number
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(L("welcome.patientNumber"))
                            .font(Theme.headlineFont)
                            .foregroundStyle(Theme.deepBlue)

                        TextField(L("welcome.patientNumberPlaceholder"), text: $formVM.form.patientNumber)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.default)
                    }
                }

                // MARK: - Language Picker
                LanguagePicker()

                // MARK: - Start Button
                Button {
                    formVM.nextPage()
                } label: {
                    Text(L("welcome.start"))
                        .font(Theme.headlineFont)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.accentBlue, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: Theme.maxFormWidth)
            .padding(.horizontal)

            Spacer()
        }
        .sheet(isPresented: $settingsVM.showPINEntry) {
            PinEntryView()
        }
        .sheet(isPresented: $settingsVM.showSettings) {
            SettingsView()
        }
    }

    // MARK: - Clinic Logo View

    @ViewBuilder
    private var clinicLogo: some View {
        if let logoData = settingsVM.settings.logoData,
           let uiImage = UIImage(data: logoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        } else {
            Image("oh_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
    }
}

#Preview {
    ZStack {
        SkyBackground()
        WelcomeView()
    }
    .environmentObject(FormViewModel())
    .environmentObject(SettingsViewModel())
    .environmentObject(LocalizationManager.shared)
}
