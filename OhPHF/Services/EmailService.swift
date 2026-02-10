import SwiftUI
import MessageUI

struct EmailComposerView: UIViewControllerRepresentable {
    let pdfData: Data
    let recipientEmail: String
    let patientName: String
    let onDismiss: () -> Void

    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }

    // MARK: - UIViewControllerRepresentable

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients([recipientEmail])
        composer.setSubject("Patient History Form - \(patientName)")
        composer.setMessageBody(
            "Please find the patient history form attached.",
            isHTML: false
        )

        let fileName = "PHF_\(sanitizedName)_\(dateString()).pdf"
        composer.addAttachmentData(pdfData, mimeType: "application/pdf", fileName: fileName)

        return composer
    }

    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: Context
    ) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDismiss: () -> Void

        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            controller.dismiss(animated: true) {
                self.onDismiss()
            }
        }
    }

    // MARK: - Helpers

    private var sanitizedName: String {
        patientName
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
    }

    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return formatter.string(from: Date())
    }
}
