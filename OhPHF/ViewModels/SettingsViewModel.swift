import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings: ClinicSettings
    @Published var showSettings: Bool = false
    @Published var showPINEntry: Bool = false
    @Published var pinInput: String = ""
    @Published var pinError: Bool = false

    init() {
        self.settings = ClinicSettings.load()
    }

    func verifyPIN() -> Bool {
        if pinInput == settings.staffPIN {
            pinInput = ""
            pinError = false
            showPINEntry = false
            showSettings = true
            return true
        } else {
            pinError = true
            pinInput = ""
            return false
        }
    }

    func saveSettings() {
        settings.save()
    }

    func updateLogo(_ imageData: Data) {
        settings.logoData = imageData
        saveSettings()
    }
}
