import SwiftUI

/// Binary yes/no question with optional expandable subform content.
/// Displays a question label with two pill-shaped toggle buttons.
/// When "Yes" is selected and a subform is provided, it animates into view.
struct YesNoToggle<Content: View>: View {
    let question: String
    @Binding var isYes: Bool
    let subform: Content?

    /// Initializer with an expandable subform shown when "Yes" is selected.
    init(
        question: String,
        isYes: Binding<Bool>,
        @ViewBuilder subform: () -> Content
    ) {
        self.question = question
        self._isYes = isYes
        self.subform = subform()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
            // Question text
            Text(question)
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.deepBlue)
                .fixedSize(horizontal: false, vertical: true)

            // Yes / No pill buttons
            CompatGlassContainer(spacing: 12) {
                HStack(spacing: 12) {
                    toggleButton(
                        title: L("yes"),
                        isSelected: isYes,
                        action: { withAnimation(.easeInOut(duration: 0.3)) { isYes = true } }
                    )

                    toggleButton(
                        title: L("no"),
                        isSelected: !isYes,
                        action: { withAnimation(.easeInOut(duration: 0.3)) { isYes = false } }
                    )
                }
            }

            // Expandable subform
            if let subform, isYes {
                subform
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .padding(.leading, 16)
            }
        }
    }

    // MARK: - Toggle Button

    private func toggleButton(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(Theme.bodyFont)
                .foregroundStyle(isSelected ? .white : Theme.deepBlue)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .glassBackground(
                    isSelected
                        ? .interactiveTinted(Theme.accentBlue)
                        : .interactive,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }
}

/// Convenience initializer when no subform is needed.
extension YesNoToggle where Content == EmptyView {
    init(
        question: String,
        isYes: Binding<Bool>
    ) {
        self.question = question
        self._isYes = isYes
        self.subform = nil
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var hasAllergy = false

        var body: some View {
            ZStack {
                SkyBackground()

                GlassCard {
                    YesNoToggle(
                        question: "Do you have any allergies?",
                        isYes: $hasAllergy
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Please specify:")
                                .font(Theme.captionFont)
                                .foregroundStyle(.secondary)
                            TextField("Allergy details", text: .constant(""))
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                .padding()
            }
        }
    }

    return PreviewWrapper()
}
