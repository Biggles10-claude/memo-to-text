import Foundation

/// Default archive folders. Proof: FolderStore.
public enum FolderCatalog {
    public static let inbox = "Inbox"
    public static let lectures = "Lectures"
    public static let interviews = "Interviews"
    public static let ideas = "Ideas"

    public static let defaults: [String] = [inbox, lectures, interviews, ideas]

    public static func sanitized(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        return String(trimmed.prefix(40))
    }
}

/// One timestamped sentence in a transcript.
public struct TranscriptSegment: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var text: String
    public var start: TimeInterval
    public var end: TimeInterval
    public var speaker: String?

    public init(
        id: String = UUID().uuidString,
        text: String,
        start: TimeInterval,
        end: TimeInterval,
        speaker: String? = nil
    ) {
        self.id = id
        self.text = text
        self.start = start
        self.end = max(end, start)
        self.speaker = speaker
    }
}

public struct SearchHit: Equatable, Sendable {
    public var memoID: String
    public var title: String
    public var sentence: String
    public var segmentID: String

    public init(memoID: String, title: String, sentence: String, segmentID: String) {
        self.memoID = memoID
        self.title = title
        self.sentence = sentence
        self.segmentID = segmentID
    }
}

/// Full-text search across titles and transcript bodies. Proof: MemoSearchIndex.
public enum MemoSearchIndex {
    public static func hits(
        query: String,
        titles: [String: String],
        segments: [String: [TranscriptSegment]]
    ) -> [SearchHit] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard needle.count >= 2 else { return [] }
        var out: [SearchHit] = []
        for (memoID, title) in titles {
            if title.lowercased().contains(needle) {
                let first = segments[memoID]?.first
                out.append(
                    SearchHit(
                        memoID: memoID,
                        title: title,
                        sentence: first?.text ?? title,
                        segmentID: first?.id ?? memoID
                    )
                )
                continue
            }
            if let match = segments[memoID]?.first(where: { $0.text.lowercased().contains(needle) }) {
                out.append(
                    SearchHit(
                        memoID: memoID,
                        title: title,
                        sentence: match.text,
                        segmentID: match.id
                    )
                )
            }
        }
        return out.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }
}

/// TXT / copy-all formatting. Proof: TranscriptExporter.
public enum TranscriptFormatter {
    public static func plainText(
        title: String,
        speakerNames: [String: String],
        segments: [TranscriptSegment]
    ) -> String {
        var lines: [String] = [title, ""]
        for segment in segments {
            let body = segment.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !body.isEmpty else { continue }
            if let key = segment.speaker {
                let label = speakerNames[key] ?? "Speaker \(key)"
                lines.append("\(label): \(body)")
            } else {
                lines.append(body)
            }
        }
        return lines.joined(separator: "\n")
    }
}

/// Speaker A / B labels. Proof: SpeakerTurnEditor.
public enum SpeakerBook {
    public static let a = "A"
    public static let b = "B"

    public static func defaultNames() -> [String: String] {
        [a: "Speaker A", b: "Speaker B"]
    }

    public static func rename(names: [String: String], key: String, to raw: String) -> [String: String] {
        var next = names
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        next[key] = trimmed.isEmpty ? "Speaker \(key)" : String(trimmed.prefix(32))
        return next
    }

    public static func mark(segments: [TranscriptSegment], id: String, speaker: String?) -> [TranscriptSegment] {
        segments.map { segment in
            var copy = segment
            if copy.id == id { copy.speaker = speaker }
            return copy
        }
    }
}

public enum DurationFormat {
    public static func clock(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded()))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }
}

public enum AudioImportTypes {
    public static let extensions = ["m4a", "mp3", "wav", "aac", "caf"]
}

/// Dated titles instead of "Take N".
public enum MemoTitle {
    public static func recorded(at date: Date = Date(), calendar: Calendar = .current) -> String {
        let hour = calendar.component(.hour, from: date)
        let period: String
        switch hour {
        case 5..<12: period = "Morning note"
        case 12..<17: period = "Afternoon note"
        case 17..<21: period = "Evening note"
        default: period = "Night note"
        }
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_GB")
        fmt.dateFormat = "d MMM"
        return "\(period) · \(fmt.string(from: date))"
    }
}
