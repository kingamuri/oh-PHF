import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case german = "de"
    case english = "en"
    case russian = "ru"
    case arabic = "ar"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .german: return "Deutsch"
        case .english: return "English"
        case .russian: return "Русский"
        case .arabic: return "العربية"
        }
    }

    var flag: String {
        switch self {
        case .german: return "🇩🇪"
        case .english: return "🇬🇧"
        case .russian: return "🇷🇺"
        case .arabic: return "🇸🇦"
        }
    }

    var isRTL: Bool {
        self == .arabic
    }
}

@MainActor
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var languageCode: String = UserDefaults.standard.string(forKey: "appLanguage") ?? "de" {
        didSet { UserDefaults.standard.set(languageCode, forKey: "appLanguage") }
    }

    var language: AppLanguage {
        get { AppLanguage(rawValue: languageCode) ?? .german }
        set { languageCode = newValue.rawValue }
    }

    var isRTL: Bool {
        language.isRTL
    }

    var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }

    private init() {}
}

@MainActor
func L(_ key: String) -> String {
    let bundle = LocalizationManager.shared.bundle
    let value = bundle.localizedString(forKey: key, value: nil, table: nil)
    if value == key {
        return Bundle.main.localizedString(forKey: key, value: key, table: nil)
    }
    return value
}

@MainActor
func L(_ key: String, _ args: CVarArg...) -> String {
    let format = L(key)
    return String(format: format, arguments: args)
}
