import SwiftUI

/// Full-screen gradient background with subtle animated floating cloud shapes.
/// Provides the soothing sky theme used throughout the form.
struct SkyBackground: View {
    @State private var animatePhase: CGFloat = 0

    var body: some View {
        ZStack {
            // Base gradient from sky blue to white
            LinearGradient(
                colors: [Theme.skyBlue.opacity(0.3), Theme.skyWhite],
                startPoint: .top,
                endPoint: .bottom
            )

            // Floating cloud shapes — subtle and decorative
            cloudLayer(
                xOffset: 60,
                yOffset: -200,
                width: 220,
                height: 70,
                opacity: 0.15,
                phaseMultiplier: 1.0
            )

            cloudLayer(
                xOffset: -90,
                yOffset: -80,
                width: 180,
                height: 55,
                opacity: 0.10,
                phaseMultiplier: -0.7
            )

            cloudLayer(
                xOffset: 120,
                yOffset: 60,
                width: 260,
                height: 80,
                opacity: 0.08,
                phaseMultiplier: 0.5
            )

            cloudLayer(
                xOffset: -50,
                yOffset: 200,
                width: 200,
                height: 60,
                opacity: 0.12,
                phaseMultiplier: -1.2
            )
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 8)
                .repeatForever(autoreverses: true)
            ) {
                animatePhase = 1
            }
        }
    }

    // MARK: - Cloud Layer

    private func cloudLayer(
        xOffset: CGFloat,
        yOffset: CGFloat,
        width: CGFloat,
        height: CGFloat,
        opacity: Double,
        phaseMultiplier: CGFloat
    ) -> some View {
        Ellipse()
            .fill(Color.white.opacity(opacity))
            .frame(width: width, height: height)
            .blur(radius: 20)
            .offset(
                x: xOffset + animatePhase * 30 * phaseMultiplier,
                y: yOffset + animatePhase * 15 * phaseMultiplier
            )
    }
}

#Preview {
    SkyBackground()
}
