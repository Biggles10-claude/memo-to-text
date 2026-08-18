import SwiftUI
import UIKit
import Core

/// Share TXT and PDF. Proof: TranscriptExporter, ExportScreen.
struct ExportScreen: View {
    @EnvironmentObject private var library: MemoLibrary
    @Environment(\.dismiss) private var dismiss
    let memoID: String
    @State private var shareURL: URL?
    @State private var error: String?
    @State private var copied = false

    var memo: Memo? { library.memo(id: memoID) }

    var body: some View {
        VStack(spacing: DT.spaceL) {
            if let memo {
                if memo.segments.isEmpty {
                    EmptyStateView(
                        title: "Nothing to share yet",
                        message: "Transcribe or edit a memo first.",
                        systemImage: "square.and.arrow.up",
                        actionTitle: "Back to transcript",
                        action: { dismiss() }
                    )
                } else if let error {
                    ErrorStateView(message: LocalizedStringKey(error), retry: { self.error = nil })
                } else {
                    VStack(alignment: .leading, spacing: DT.spaceS) {
                        Text(memo.title)
                            .font(DT.titleFont())
                            .foregroundStyle(DT.ink)
                        Text(TranscriptExporter.plainText(for: memo))
                            .font(DT.bodyFont())
                            .foregroundStyle(DT.inkSecondary)
                            .lineLimit(8)
                    }
                    .padding(DT.spaceM)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DT.cardBackground, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))

                    PrimaryCTA(title: "Share TXT", systemImage: "doc") {
                        export { try TranscriptExporter.writeTXT(for: memo, in: $0) }
                    }
                    GhostCTA(title: "Share PDF", systemImage: "doc.richtext") {
                        export { try TranscriptExporter.writePDF(for: memo, in: $0) }
                    }
                    Button("Copy all") {
                        UIPasteboard.general.string = TranscriptExporter.plainText(for: memo)
                        copied = true
                    }
                    .font(DT.headlineFont())
                    .foregroundStyle(DT.accent)
                    if copied {
                        Text("Copied to the pasteboard")
                            .font(DT.captionFont())
                            .foregroundStyle(DT.inkSecondary)
                    }
                }
            } else {
                ErrorStateView(message: "This memo is no longer in the library.", retry: library.reload)
            }
            Spacer()
        }
        .padding(DT.spaceM)
        .background(DT.screenBackground.ignoresSafeArea())
        .navigationTitle("Export")
        .sheet(item: Binding(
            get: { shareURL.map(IdentifiedURL.init) },
            set: { shareURL = $0?.url }
        )) { item in
            ShareSheet(items: [item.url])
        }
    }

    private func export(_ write: (URL) throws -> URL) {
        do {
            shareURL = try write(FileManager.default.temporaryDirectory)
            error = nil
        } catch {
            self.error = "The file could not be built. Retry TXT or PDF export."
        }
    }
}

private struct IdentifiedURL: Identifiable {
    let url: URL
    var id: String { url.path }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
