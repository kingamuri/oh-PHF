import SwiftUI

enum Theme {
    // MARK: - Colors
    static let skyBlue = Color(hex: "87CEEB")
    static let skyWhite = Color(hex: "F0F8FF")
    static let accentBlue = Color(hex: "4A90D9")
    static let deepBlue = Color(hex: "2C5F8A")
    static let softGray = Color(hex: "E8EEF2")

    // BDD Risk Colors
    static let bddGreen = Color(hex: "4CAF50")
    static let bddYellow = Color(hex: "FFC107")
    static let bddOrange = Color(hex: "FF9800")
    static let bddRed = Color(hex: "F44336")

    // MARK: - Typography
    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .rounded)
    static let captionFont = Font.system(size: 13, weight: .regular, design: .rounded)

    // MARK: - Layout
    static let cardPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 16
    static let cornerRadius: CGFloat = 16
    static let maxFormWidth: CGFloat = 700

}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
