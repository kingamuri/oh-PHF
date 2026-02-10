import SwiftUI

// MARK: - Glass Style

/// Describes which Liquid Glass variant to use.
/// On iOS 26+ (Xcode 26 / Swift 6.2+), maps to real `.glassEffect()`;
/// on older iOS or older toolchains, falls back to materials.
enum GlassStyle {
    /// Static glass pane (non-interactive).
    case regular
    /// Pressable glass with no tint.
    case interactive
    /// Pressable glass with a solid/tinted color.
    case interactiveTinted(Color)
}

// MARK: - View Extension

extension View {

    /// Applies a glass-like background.
    ///
    /// - Xcode 26+ compiling for iOS 26+: Real Liquid Glass via `.glassEffect()`.
    /// - Everything else: Ultra-thin material with a subtle highlight stroke.
    @ViewBuilder
    func glassBackground(_ style: GlassStyle, in shape: some Shape) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            switch style {
            case .regular:
                self.glassEffect(.regular, in: shape)
            case .interactive:
                self.glassEffect(.regular.interactive(), in: shape)
            case .interactiveTinted(let color):
                self.glassEffect(.regular.interactive().tint(color), in: shape)
            }
        } else {
            _glassBackgroundFallback(style, in: shape)
        }
        #else
        _glassBackgroundFallback(style, in: shape)
        #endif
    }

    /// Material-based fallback used on older iOS / older toolchains.
    @ViewBuilder
    private func _glassBackgroundFallback(_ style: GlassStyle, in shape: some Shape) -> some View {
        switch style {
        case .regular:
            self
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.stroke(.white.opacity(0.4), lineWidth: 0.5))
        case .interactive:
            self
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.stroke(.white.opacity(0.4), lineWidth: 0.5))
        case .interactiveTinted(let color):
            self
                .background(color, in: shape)
        }
    }
}

// MARK: - Glass Effect Container Compat

/// Wraps `GlassEffectContainer` on iOS 26+; passes through on older iOS.
struct CompatGlassContainer<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) { content }
        } else {
            content
        }
        #else
        content
        #endif
    }
}
