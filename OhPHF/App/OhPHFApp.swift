import SwiftUI

@main
struct OhPHFApp: App {
    @StateObject private var formViewModel = FormViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @ObservedObject private var localization = LocalizationManager.shared

    init() {
        UIApplication.shared.isIdleTimerDisabled = true
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(formViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(localization)
                .persistentSystemOverlays(.hidden)
                .statusBarHidden(true)
        }
    }
}
