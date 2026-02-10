import SwiftUI

@main
struct OhPHFApp: App {
    @StateObject private var formViewModel = FormViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @ObservedObject private var localization = LocalizationManager.shared
    @Environment(\.scenePhase) private var scenePhase

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
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                let settings = ClinicSettings.load()
                if settings.kioskModeEnabled {
                    GuidedAccessManager.shared.enterGuidedAccess()
                }
            }
        }
    }
}
