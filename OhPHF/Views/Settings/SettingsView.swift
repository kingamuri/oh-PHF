import SwiftUI
import PhotosUI

struct SettingsView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                clinicInfoSection
                logoSection
                feesSection
                securitySection
                archiveSection
            }
            .navigationTitle(L("settings_title"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("save")) {
                        settingsVM.saveSettings()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("cancel")) {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let newValue,
                       let data = try? await newValue.loadTransferable(type: Data.self) {
                        settingsVM.updateLogo(data)
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private var clinicInfoSection: some View {
        Section {
            TextField(L("clinic_name"), text: $settingsVM.settings.clinicName)
            TextField(L("subtitle"), text: $settingsVM.settings.clinicSubtitle)
            TextField(L("street"), text: $settingsVM.settings.street)
            TextField(L("postal_code"), text: $settingsVM.settings.postalCode)
            TextField(L("city"), text: $settingsVM.settings.city)
            TextField(L("country"), text: $settingsVM.settings.country)
            TextField(L("website"), text: $settingsVM.settings.website)
                .keyboardType(.URL)
                .textContentType(.URL)
                .autocapitalization(.none)
            TextField(L("email"), text: $settingsVM.settings.email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
        } header: {
            Text(L("clinic_information"))
        }
    }

    private var logoSection: some View {
        Section {
            if let data = settingsVM.settings.logoData,
               let uiImage = UIImage(data: data) {
                HStack {
                    Spacer()
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Spacer()
                }

                Button(role: .destructive) {
                    settingsVM.settings.logoData = nil
                    settingsVM.saveSettings()
                } label: {
                    Label(L("remove_logo"), systemImage: "trash")
                }
            }

            let logoLabel = settingsVM.settings.logoData == nil
                ? L("select_logo")
                : L("change_logo")
            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label(logoLabel, systemImage: "photo")
            }
        } header: {
            Text(L("logo"))
        }
    }

    private var feesSection: some View {
        Section {
            HStack {
                Text(L("missed_appointment_fee"))
                Spacer()
                TextField(
                    "\u{20AC}",
                    value: $settingsVM.settings.missedAppointmentFee,
                    format: .number
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            }
        } header: {
            Text(L("fees"))
        }
    }

    private var securitySection: some View {
        Section {
            SecureField(L("staff_pin"), text: $settingsVM.settings.staffPIN)
                .keyboardType(.numberPad)
        } header: {
            Text(L("security"))
        } footer: {
            Text(L("pin_footer"))
                .font(.caption)
        }
    }

    private var archiveSection: some View {
        Section {
            NavigationLink {
                PDFArchiveView()
            } label: {
                Label(L("pdf_archive"), systemImage: "archivebox")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
}
