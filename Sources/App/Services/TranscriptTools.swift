import Foundation
import PDFKit
import UIKit
import Core

/// Inline edit + tap-to-seek. Proof: TranscriptEditor, seekToSegment.
enum TranscriptEditor {
    static func replace(segments: [TranscriptSegment], id: String, text: String) -> [TranscriptSegment] {
        segments.map { segment in
            var copy = segment
            if copy.id == id {
                copy.text = text
            }
            return copy
        }
    }

    @MainActor
    static func seekToSegment(_ segment: TranscriptSegment, player: WaveformPlayer) {
        player.seekToSegment(segment)
    }
}

/// Speaker A/B turns. Proof: SpeakerTurnEditor, markSpeakerTurn.
enum SpeakerTurnEditor {
    static func markSpeakerTurn(segments: [TranscriptSegment], id: String, speaker: String?) -> [TranscriptSegment] {
        SpeakerBook.mark(segments: segments, id: id, speaker: speaker)
    }
}

/// TXT + PDF share. Proof: TranscriptExporter, PDFKit.
enum TranscriptExporter {
    static func plainText(for memo: Memo) -> String {
        TranscriptFormatter.plainText(
            title: memo.title,
            speakerNames: memo.speakerNames,
            segments: memo.segments
        )
    }

    static func writeTXT(for memo: Memo, in directory: URL) throws -> URL {
        let url = directory.appendingPathComponent(safeName(memo.title) + ".txt")
        try plainText(for: memo).data(using: .utf8)?.write(to: url)
        return url
    }

    static func writePDF(for memo: Memo, in directory: URL) throws -> URL {
        let url = directory.appendingPathComponent(safeName(memo.title) + ".pdf")
        let page = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        let body = plainText(for: memo)
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let rect = page.insetBy(dx: 48, dy: 48)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor(red: 0.20, green: 0.15, blue: 0.12, alpha: 1),
            ]
            (body as NSString).draw(with: rect, options: [.usesLineFragmentOrigin], attributes: attrs, context: nil)
        }
        try data.write(to: url)
        if PDFDocument(url: url) == nil {
            throw CocoaError(.fileWriteUnknown)
        }
        return url
    }

    private static func safeName(_ title: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let ok = trimmed.isEmpty ? "transcript" : trimmed
        return ok.replacingOccurrences(of: "/", with: "-")
    }
}
