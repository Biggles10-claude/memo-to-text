import Foundation
import Core

enum MemoStatus: String, Codable, Equatable {
    case recorded
    case transcribing
    case ready
    case failed
}

struct Memo: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var folder: String
    var createdAt: Date
    var duration: TimeInterval
    var audioFileName: String
    var segments: [TranscriptSegment]
    var speakerNames: [String: String]
    var waveform: [Double]
    var status: MemoStatus
    var lastError: String?

    var preview: String {
        let joined = segments
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return String(joined.prefix(140))
    }
}

extension TranscriptSegment {
    var clock: String { DurationFormat.clock(start) }
}
