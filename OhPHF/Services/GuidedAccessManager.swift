import UIKit

/// Manages Guided Access (kiosk lockdown) via the iOS Accessibility API.
/// Requires one-time setup: iPad Settings > Accessibility > Guided Access > ON.
@MainActor
final class GuidedAccessManager: ObservableObject {
    static let shared = GuidedAccessManager()

    @Published var isActive: Bool = UIAccessibility.isGuidedAccessEnabled

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(statusDidChange),
            name: UIAccessibility.guidedAccessStatusDidChangeNotification,
            object: nil
        )
    }

    @objc private func statusDidChange() {
        Task { @MainActor in
            self.isActive = UIAccessibility.isGuidedAccessEnabled
        }
    }

    /// Enter Guided Access. Completion returns `true` on success.
    func enterGuidedAccess(completion: ((Bool) -> Void)? = nil) {
        UIAccessibility.requestGuidedAccessSession(enabled: true) { success in
            Task { @MainActor in
                self.isActive = UIAccessibility.isGuidedAccessEnabled
                completion?(success)
            }
        }
    }

    /// Exit Guided Access. Completion returns `true` on success.
    func exitGuidedAccess(completion: ((Bool) -> Void)? = nil) {
        UIAccessibility.requestGuidedAccessSession(enabled: false) { success in
            Task { @MainActor in
                self.isActive = UIAccessibility.isGuidedAccessEnabled
                completion?(success)
            }
        }
    }
}
