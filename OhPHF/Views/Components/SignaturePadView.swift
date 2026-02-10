import SwiftUI
import PencilKit

/// PencilKit-based signature capture view.
/// Supports both finger and Apple Pencil input.
/// Renders the signature to PNG data via the binding.
struct SignaturePadView: View {
    @Binding var signatureData: Data?
    @Binding var isDrawing: Bool
    @State private var canvasView = PKCanvasView()
    @State private var hasDrawing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Canvas
            SignatureCanvas(
                canvasView: $canvasView,
                isDrawing: $isDrawing,
                onChanged: handleDrawingChanged
            )
            .frame(height: 200)
            .background(
                Color.white,
                in: RoundedRectangle(cornerRadius: Theme.cornerRadius)
            )
            .glassBackground(.regular, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))

            // Instruction + Clear
            HStack {
                Text(L("signature_instruction"))
                    .font(Theme.captionFont)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    clearSignature()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                        Text(L("clear"))
                            .font(Theme.captionFont)
                    }
                    .foregroundStyle(Theme.accentBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .glassBackground(.interactive, in: Capsule())
                }
                .buttonStyle(.plain)
                .opacity(hasDrawing ? 1 : 0.4)
                .disabled(!hasDrawing)
            }
        }
    }

    // MARK: - Actions

    private func handleDrawingChanged() {
        let drawing = canvasView.drawing
        hasDrawing = !drawing.strokes.isEmpty

        if hasDrawing {
            let bounds = drawing.bounds
            let image = drawing.image(
                from: bounds,
                scale: UIScreen.main.scale
            )
            signatureData = image.pngData()
        } else {
            signatureData = nil
        }
    }

    private func clearSignature() {
        canvasView.drawing = PKDrawing()
        hasDrawing = false
        signatureData = nil
    }
}

// MARK: - UIViewRepresentable Wrapper

private struct SignatureCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var isDrawing: Bool
    let onChanged: () -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .white
        canvasView.isOpaque = true
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 2)
        canvasView.delegate = context.coordinator
        canvasView.isScrollEnabled = false
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // No dynamic updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isDrawing: $isDrawing, onChanged: onChanged)
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var isDrawing: Bool
        let onChanged: () -> Void

        init(isDrawing: Binding<Bool>, onChanged: @escaping () -> Void) {
            self._isDrawing = isDrawing
            self.onChanged = onChanged
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            onChanged()
        }

        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
            isDrawing = true
        }

        func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
            isDrawing = false
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var signature: Data?

        var body: some View {
            ZStack {
                SkyBackground()

                GlassCard {
                        SignaturePadView(signatureData: $signature, isDrawing: .constant(false))
                }
                .padding()
            }
        }
    }

    return PreviewWrapper()
}
