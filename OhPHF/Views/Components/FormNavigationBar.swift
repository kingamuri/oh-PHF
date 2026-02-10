import SwiftUI

/// Bottom navigation bar for multi-page forms.
/// Shows Back/Next buttons with an integrated progress indicator.
/// On the last page, Next becomes a Submit button with a loading state.
struct FormNavigationBar: View {
    let currentPage: Int
    let totalPages: Int
    let pageTitle: String
    let canGoBack: Bool
    let isLastPage: Bool
    let isSubmitting: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Progress indicator
            ProgressBarView(
                currentPage: currentPage,
                totalPages: totalPages,
                pageTitle: pageTitle
            )

            // Navigation buttons
            CompatGlassContainer(spacing: 16) {
                HStack(spacing: 16) {
                    // Back button
                    if canGoBack {
                        Button(action: onBack) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                Text(L("back"))
                            }
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.deepBlue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .glassBackground(.interactive, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    // Next or Submit button
                    if isLastPage {
                        submitButton
                    } else {
                        nextButton
                    }
                }
            }
        }
        .padding(Theme.cardPadding)
        .glassBackground(.regular, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }

    // MARK: - Next Button

    private var nextButton: some View {
        Button(action: onNext) {
            HStack(spacing: 6) {
                Text(L("next"))
                Image(systemName: "chevron.right")
            }
            .font(Theme.bodyFont.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .glassBackground(.interactiveTinted(Theme.accentBlue), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button(action: onSubmit) {
            HStack(spacing: 8) {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                }
                Text(isSubmitting ? L("submitting") : L("submit"))
            }
            .font(Theme.bodyFont.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .glassBackground(
                .interactiveTinted(isSubmitting ? Theme.accentBlue.opacity(0.6) : Theme.deepBlue),
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
        .disabled(isSubmitting)
    }
}

#Preview {
    ZStack {
        SkyBackground()

        VStack {
            Spacer()

            // Middle page example
            FormNavigationBar(
                currentPage: 3,
                totalPages: 8,
                pageTitle: "Medical History",
                canGoBack: true,
                isLastPage: false,
                isSubmitting: false,
                onBack: {},
                onNext: {},
                onSubmit: {}
            )

            Spacer().frame(height: 20)

            // Last page example
            FormNavigationBar(
                currentPage: 8,
                totalPages: 8,
                pageTitle: "Signature & Consent",
                canGoBack: true,
                isLastPage: true,
                isSubmitting: false,
                onBack: {},
                onNext: {},
                onSubmit: {}
            )
        }
        .padding()
    }
}
