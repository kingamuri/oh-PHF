import SwiftUI

/// Step indicator showing progress through the multi-page form.
/// Displays a segmented horizontal bar with a page title below.
struct ProgressBarView: View {
    let currentPage: Int
    let totalPages: Int
    let pageTitle: String

    var body: some View {
        VStack(spacing: 8) {
            // Segmented progress bar
            HStack(spacing: 4) {
                ForEach(1...totalPages, id: \.self) { page in
                    segmentView(for: page)
                }
            }
            .frame(height: 6)

            // Page info
            HStack {
                Text(pageTitle)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.deepBlue)

                Spacer()

                Text("\(currentPage) / \(totalPages)")
                    .font(Theme.captionFont)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Segment

    @ViewBuilder
    private func segmentView(for page: Int) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(fillColor(for: page))
            .animation(.easeInOut(duration: 0.3), value: currentPage)
    }

    private func fillColor(for page: Int) -> Color {
        if page < currentPage {
            return Theme.accentBlue
        } else if page == currentPage {
            return Theme.deepBlue
        } else {
            return Theme.softGray
        }
    }
}

#Preview {
    ZStack {
        SkyBackground()

        VStack(spacing: 32) {
            GlassCard {
                ProgressBarView(
                    currentPage: 1,
                    totalPages: 8,
                    pageTitle: "Personal Information"
                )
            }

            GlassCard {
                ProgressBarView(
                    currentPage: 5,
                    totalPages: 8,
                    pageTitle: "Medical History"
                )
            }

            GlassCard {
                ProgressBarView(
                    currentPage: 8,
                    totalPages: 8,
                    pageTitle: "Signature & Consent"
                )
            }
        }
        .padding()
    }
}
