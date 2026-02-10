import SwiftUI

/// Primary container for question groups and form sections.
/// Uses ultra-thin material for a frosted glass appearance with subtle shadow.
struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(Theme.cardPadding)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: Theme.cornerRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

#Preview {
    ZStack {
        SkyBackground()

        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Sample Question")
                    .font(Theme.headlineFont)
                    .foregroundStyle(Theme.deepBlue)

                Text("This is a sample card body with form content inside.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
