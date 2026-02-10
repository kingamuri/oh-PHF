import Foundation

// MARK: - PDFManifestEntry

struct PDFManifestEntry: Codable, Identifiable {
    let id: String
    let fileName: String
    let patientName: String
    let date: Date
    let bddRiskLevel: String?
    let bddScore: Int?
}

// MARK: - PDFStorageService

final class PDFStorageService {
    static let shared = PDFStorageService()

    private let maxStoredPDFs = 50

    private init() {
        ensureDirectoryExists()
    }

    // MARK: - Directory Management

    private var storageDirectory: URL {
        let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        return documentsURL.appendingPathComponent("PDFArchive", isDirectory: true)
    }

    private var manifestURL: URL {
        storageDirectory.appendingPathComponent("manifest.json")
    }

    private func ensureDirectoryExists() {
        let fm = FileManager.default
        if !fm.fileExists(atPath: storageDirectory.path) {
            try? fm.createDirectory(
                at: storageDirectory,
                withIntermediateDirectories: true
            )
        }
    }

    // MARK: - Store

    func store(pdfData: Data, patientName: String, bddScore: Int?) {
        let entryID = UUID().uuidString
        let sanitizedName = patientName
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        let dateStamp = formatter.string(from: Date())

        let fileName = "PHF_\(sanitizedName)_\(dateStamp).pdf"

        let riskLevel: String?
        if let score = bddScore {
            riskLevel = BDDScorer.riskLevel(for: score).rawValue
        } else {
            riskLevel = nil
        }

        let entry = PDFManifestEntry(
            id: entryID,
            fileName: fileName,
            patientName: patientName,
            date: Date(),
            bddRiskLevel: riskLevel,
            bddScore: bddScore
        )

        // Write PDF file
        let fileURL = storageDirectory.appendingPathComponent(fileName)
        try? pdfData.write(to: fileURL, options: .atomic)

        // Update manifest
        var entries = loadManifest()
        entries.insert(entry, at: 0)
        saveManifest(entries)

        // Trim to rolling buffer limit
        trimToLimit()
    }

    // MARK: - Read

    func loadManifest() -> [PDFManifestEntry] {
        guard let data = try? Data(contentsOf: manifestURL) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([PDFManifestEntry].self, from: data)) ?? []
    }

    func getPDFData(for entry: PDFManifestEntry) -> Data? {
        let fileURL = storageDirectory.appendingPathComponent(entry.fileName)
        return try? Data(contentsOf: fileURL)
    }

    // MARK: - Delete

    func delete(entry: PDFManifestEntry) {
        let fileURL = storageDirectory.appendingPathComponent(entry.fileName)
        try? FileManager.default.removeItem(at: fileURL)

        var entries = loadManifest()
        entries.removeAll { $0.id == entry.id }
        saveManifest(entries)
    }

    // MARK: - Private Helpers

    private func trimToLimit() {
        var entries = loadManifest()
        guard entries.count > maxStoredPDFs else { return }

        let entriesToRemove = entries[maxStoredPDFs...]
        for entry in entriesToRemove {
            let fileURL = storageDirectory.appendingPathComponent(entry.fileName)
            try? FileManager.default.removeItem(at: fileURL)
        }

        entries = Array(entries.prefix(maxStoredPDFs))
        saveManifest(entries)
    }

    private func saveManifest(_ entries: [PDFManifestEntry]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        guard let data = try? encoder.encode(entries) else { return }
        try? data.write(to: manifestURL, options: .atomic)
    }
}
