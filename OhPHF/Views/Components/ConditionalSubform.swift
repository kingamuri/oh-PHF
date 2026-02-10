import SwiftUI

/// Animated expand/collapse container for conditional form sections.
/// Smoothly reveals or hides child content based on the `isExpanded` flag.
struct ConditionalSubform<Content: View>: View {
    let isExpanded: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        if isExpanded {
            content()
                .transition(.opacity.combined(with: .move(edge: .top)))
                .padding(.leading, 16)
                .padding(.top, 4)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showDetails = true

        var body: some View {
            ZStack {
                SkyBackground()

                GlassCard {
                    VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showDetails.toggle()
                            }
                        } label: {
                            HStack {
                                Text("Show additional details")
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(Theme.deepBlue)
                                Spacer()
                                Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                                    .foregroundStyle(Theme.accentBlue)
                            }
                        }
                        .buttonStyle(.plain)

                        ConditionalSubform(isExpanded: showDetails) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Additional information goes here.")
                                    .font(Theme.captionFont)
                                    .foregroundStyle(.secondary)

                                TextField("Enter details", text: .constant(""))
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }

    return PreviewWrapper()
}
