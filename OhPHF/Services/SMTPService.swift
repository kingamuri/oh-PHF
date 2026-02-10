import Foundation
import Network

// MARK: - SMTPService

/// Lightweight SMTP client for sending PDF attachments silently in the background.
/// Uses NWConnection with implicit TLS (port 465).
/// Best-effort delivery — the PDF is always stored locally as the primary record.
final class SMTPService: @unchecked Sendable {
    static let shared = SMTPService()
    private init() {}

    /// Fire-and-forget: sends the PDF email on a background task.
    func sendInBackground(
        pdfData: Data,
        fileName: String,
        recipientEmail: String,
        patientName: String,
        settings: ClinicSettings
    ) {
        guard settings.smtpEnabled,
              !settings.smtpHost.isEmpty,
              !settings.smtpUsername.isEmpty,
              !settings.smtpPassword.isEmpty,
              !recipientEmail.isEmpty else {
            return
        }

        Task.detached(priority: .utility) {
            await self.performSend(
                pdfData: pdfData,
                fileName: fileName,
                recipientEmail: recipientEmail,
                patientName: patientName,
                settings: settings
            )
        }
    }

    // MARK: - Send Flow

    private func performSend(
        pdfData: Data,
        fileName: String,
        recipientEmail: String,
        patientName: String,
        settings: ClinicSettings
    ) async {
        do {
            let connection = try await connect(
                host: settings.smtpHost,
                port: UInt16(settings.smtpPort)
            )
            defer { connection.cancel() }

            // Server greeting
            let greeting = try await read(connection)
            guard greeting.hasPrefix("220") else { return }

            // EHLO
            try await write(connection, "EHLO localhost\r\n")
            _ = try await read(connection)

            // AUTH LOGIN
            try await write(connection, "AUTH LOGIN\r\n")
            _ = try await read(connection)

            // Username (base64)
            let user64 = Data(settings.smtpUsername.utf8).base64EncodedString()
            try await write(connection, user64 + "\r\n")
            _ = try await read(connection)

            // Password (base64)
            let pass64 = Data(settings.smtpPassword.utf8).base64EncodedString()
            try await write(connection, pass64 + "\r\n")
            let authResult = try await read(connection)
            guard authResult.hasPrefix("235") else { return }

            // MAIL FROM
            try await write(connection, "MAIL FROM:<\(settings.smtpUsername)>\r\n")
            _ = try await read(connection)

            // RCPT TO
            try await write(connection, "RCPT TO:<\(recipientEmail)>\r\n")
            _ = try await read(connection)

            // DATA
            try await write(connection, "DATA\r\n")
            _ = try await read(connection)

            // MIME message with PDF attachment
            let message = buildMIMEMessage(
                from: settings.smtpUsername,
                to: recipientEmail,
                subject: "Patient History Form - \(patientName)",
                body: "Please find the patient history form attached.",
                pdfData: pdfData,
                pdfFileName: fileName
            )
            try await write(connection, message + "\r\n.\r\n")
            _ = try await read(connection)

            // QUIT
            try await write(connection, "QUIT\r\n")
        } catch {
            // Best effort — PDF is stored locally as backup
        }
    }

    // MARK: - Network Helpers

    private func connect(host: String, port: UInt16) async throws -> NWConnection {
        let tls = NWProtocolTLS.Options()
        let tcp = NWProtocolTCP.Options()
        let params = NWParameters(tls: tls, tcp: tcp)

        let connection = NWConnection(
            host: .init(host),
            port: .init(rawValue: port)!,
            using: params
        )

        return try await withCheckedThrowingContinuation { continuation in
            var resumed = false
            connection.stateUpdateHandler = { state in
                guard !resumed else { return }
                switch state {
                case .ready:
                    resumed = true
                    continuation.resume(returning: connection)
                case .failed(let error):
                    resumed = true
                    continuation.resume(throwing: error)
                case .cancelled:
                    resumed = true
                    struct Cancelled: Error {}
                    continuation.resume(throwing: Cancelled())
                default:
                    break
                }
            }
            connection.start(queue: .global(qos: .utility))
        }
    }

    private func write(_ connection: NWConnection, _ string: String) async throws {
        let data = Data(string.utf8)
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            connection.send(content: data, completion: .contentProcessed { error in
                if let error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume()
                }
            })
        }
    }

    private func read(_ connection: NWConnection) async throws -> String {
        try await withCheckedThrowingContinuation { cont in
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, _, error in
                if let error {
                    cont.resume(throwing: error)
                } else if let data {
                    cont.resume(returning: String(data: data, encoding: .utf8) ?? "")
                } else {
                    cont.resume(returning: "")
                }
            }
        }
    }

    // MARK: - MIME Builder

    private func buildMIMEMessage(
        from: String,
        to: String,
        subject: String,
        body: String,
        pdfData: Data,
        pdfFileName: String
    ) -> String {
        let boundary = "Boundary-\(UUID().uuidString)"
        var msg = ""
        msg += "From: \(from)\r\n"
        msg += "To: \(to)\r\n"
        msg += "Subject: \(subject)\r\n"
        msg += "MIME-Version: 1.0\r\n"
        msg += "Content-Type: multipart/mixed; boundary=\"\(boundary)\"\r\n"
        msg += "\r\n"
        msg += "--\(boundary)\r\n"
        msg += "Content-Type: text/plain; charset=utf-8\r\n"
        msg += "Content-Transfer-Encoding: 7bit\r\n"
        msg += "\r\n"
        msg += body + "\r\n"
        msg += "--\(boundary)\r\n"
        msg += "Content-Type: application/pdf; name=\"\(pdfFileName)\"\r\n"
        msg += "Content-Transfer-Encoding: base64\r\n"
        msg += "Content-Disposition: attachment; filename=\"\(pdfFileName)\"\r\n"
        msg += "\r\n"
        msg += pdfData.base64EncodedString(options: .lineLength76Characters)
        msg += "\r\n"
        msg += "--\(boundary)--"
        return msg
    }
}
