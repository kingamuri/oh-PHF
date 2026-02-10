import SwiftUI
import UIKit

struct PDFArchiveView: View {
    @State private var entries: [PDFManifestEntry] = []
    @State private var showShareSheet = false
    @State private var pdfToShare: Data?
    @State private var showDeleteConfirmation = false
    @State private var entryToDelete: PDFManifestEntry?

    var body: some View {
        Group {
            if entries.isEmpty {
                ContentUnavailableView(
                    L("no_pdfs"),
                    systemImage: "doc.text.magnifyingglass",
                    description: Text(L("no_pdfs_description"))
                )
            } else {
                List {
                    ForEach(entries) { entry in
                        entryRow(entry)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    entryToDelete = entry
                                    showDeleteConfirmation = true
                                } label: {
                                    Label(L("delete"), systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    shareEntry(entry)
                                } label: {
                                    Label(L("share"), systemImage: "square.and.arrow.up")
                                }
                                .tint(.blue)
                            }
                    }
                }
            }
        }
        .navigationTitle(L("pdf_archive"))
        .onAppear {
            entries = PDFStorageService.shared.loadManifest()
        }
        .sheet(isPresented: $showShareSheet) {
            if let data = pdfToShare {
                ShareSheet(items: [data])
            }
        }
        .alert(L("delete_pdf"), isPresented: $showDeleteConfirmation) {
            Button(L("cancel"), role: .cancel) {
                entryToDelete = nil
            }
            Button(L("delete"), role: .destructive) {
                if let entry = entryToDelete {
                    deleteEntry(entry)
                }
                entryToDelete = nil
            }
        } message: {
            Text(L("delete_pdf_message"))
        }
    }

    // MARK: - Row

    private func entryRow(_ entry: PDFManifestEntry) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.richtext")
                .font(.title2)
                .foregroundStyle(Theme.accentBlue)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.patientName)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.deepBlue)
                Text(entry.date, style: .date)
                    .font(Theme.captionFont)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let riskLevel = entry.bddRiskLevel {
                bddBadge(riskLevel: riskLevel, score: entry.bddScore)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - BDD Badge

    private func bddBadge(riskLevel: String, score: Int?) -> some View {
        let color: Color = {
            switch riskLevel {
            case "green": return Theme.bddGreen
            case "yellow": return Theme.bddYellow
            case "orange": return Theme.bddOrange
            case "red": return Theme.bddRed
            default: return Theme.softGray
            }
        }()

        let label: String = {
            if let score {
                return "\(score)/21"
            }
            return riskLevel.capitalized
        }()

        return Text(label)
            .font(.caption2.weight(.bold))
            .foregroundStyle(riskLevel == "yellow" ? .black : .white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color, in: Capsule())
    }

    // MARK: - Actions

    private func shareEntry(_ entry: PDFManifestEntry) {
        guard let data = PDFStorageService.shared.getPDFData(for: entry) else { return }
        pdfToShare = data
        showShareSheet = true
    }

    private func deleteEntry(_ entry: PDFManifestEntry) {
        PDFStorageService.shared.delete(entry: entry)
        withAnimation {
            entries.removeAll { $0.id == entry.id }
        }
    }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    var activities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: activities
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {
        // No updates needed
    }
}

#Preview {
    NavigationStack {
        PDFArchiveView()
    }
}
