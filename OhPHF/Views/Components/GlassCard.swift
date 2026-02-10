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
            .glassBackground(.regular, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
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
