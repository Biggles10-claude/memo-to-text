import Foundation
import Speech
import Core

/// On-device Apple Speech. Proof: SpeechTranscriber, SFSpeechRecognizer.
@MainActor
final class SpeechTranscriber: ObservableObject {
    @Published var progress: Double = 0
    @Published var lastError: String?

    func transcribe(url: URL) async -> [TranscriptSegment] {
        lastError = nil
        progress = 0.05
        let status = SFSpeechRecognizer.authorizationStatus()
        if status == .notDetermined {
            let granted = await withCheckedContinuation { cont in
                SFSpeechRecognizer.requestAuthorization { next in
                    cont.resume(returning: next == .authorized)
                }
            }
            if !granted {
                lastError = "Speech recognition is off. Enable it in Settings and retry."
                return []
            }
        } else if status != .authorized {
            lastError = "Speech recognition is off. Enable it in Settings and retry."
            return []
        }

        guard let recognizer = SFSpeechRecognizer(locale: .current), recognizer.isAvailable else {
            lastError = "On-device Speech is not available for this language."
            return []
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = true

        return await withCheckedContinuation { cont in
            var settled = false
            recognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in
                    if let result {
                        self?.progress = result.isFinal ? 1 : min(0.9, 0.1 + Double(result.bestTranscription.segments.count) * 0.04)
                        if result.isFinal, !settled {
                            settled = true
                            cont.resume(returning: Self.segments(from: result))
                        }
                    } else if let error, !settled {
                        settled = true
                        self?.lastError = error.localizedDescription
                        cont.resume(returning: [])
                    }
                }
            }
        }
    }

    static func segments(from result: SFSpeechRecognitionResult) -> [TranscriptSegment] {
        let pieces = result.bestTranscription.segments
        if pieces.isEmpty {
            let text = result.bestTranscription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)
            if text.isEmpty { return [] }
            return [TranscriptSegment(text: text, start: 0, end: 1)]
        }
        return pieces.map { piece in
            TranscriptSegment(
                text: piece.substring,
                start: piece.timestamp,
                end: piece.timestamp + max(0.2, piece.duration)
            )
        }
    }
}
