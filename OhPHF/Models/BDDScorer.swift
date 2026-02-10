import SwiftUI

// MARK: - BDDRiskLevel

enum BDDRiskLevel: String {
    case green
    case yellow
    case orange
    case red

    var color: Color {
        switch self {
        case .green: return .green
        case .yellow: return .yellow
        case .orange: return .orange
        case .red: return .red
        }
    }

    var label: String {
        switch self {
        case .green: return "Low Risk"
        case .yellow: return "Moderate Risk"
        case .orange: return "Elevated Risk"
        case .red: return "High Risk"
        }
    }

    var range: String {
        switch self {
        case .green: return "0-4"
        case .yellow: return "5-9"
        case .orange: return "10-14"
        case .red: return "15-21"
        }
    }
}

// MARK: - BDDScorer

struct BDDScorer {
    /// Calculates the total BDD score from a screener.
    ///
    /// - Questions 1-6 (indices 0-5) are scored as answered (0-3).
    /// - Question 7 (index 6) is reverse-scored: 0 becomes 3, 1 becomes 2, 2 becomes 1, 3 becomes 0.
    /// - Unanswered questions (-1) contribute 0 to the total.
    /// - Returns a score in the range 0-21.
    static func calculateScore(from screener: BDDScreener) -> Int {
        var total = 0

        for (index, answer) in screener.questions.enumerated() {
            guard answer >= 0 && answer <= 3 else { continue }

            if index == 6 {
                // Reverse-score question 7
                total += (3 - answer)
            } else {
                total += answer
            }
        }

        return total
    }

    /// Determines the risk level for a given BDD score.
    ///
    /// - 0-4: Green (Low Risk)
    /// - 5-9: Yellow (Moderate Risk)
    /// - 10-14: Orange (Elevated Risk)
    /// - 15-21: Red (High Risk)
    static func riskLevel(for score: Int) -> BDDRiskLevel {
        switch score {
        case 0...4:
            return .green
        case 5...9:
            return .yellow
        case 10...14:
            return .orange
        default:
            return .red
        }
    }
}
