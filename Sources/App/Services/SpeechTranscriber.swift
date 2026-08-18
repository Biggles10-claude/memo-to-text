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
        guard await authorized() else { return [] }

        guard let recognizer = SFSpeechRecognizer(locale: .current), recognizer.isAvailable else {
            lastError = "Speech is not available for this language."
            return []
        }

        let onDevice = await run(recognizer: recognizer, url: url, onDevice: true)
        if !onDevice.segments.isEmpty || onDevice.error == nil {
            if onDevice.segments.isEmpty, lastError == nil {
                lastError = onDevice.error
            }
            return onDevice.segments
        }
        lastError = nil
        progress = 0.2
        let cloud = await run(recognizer: recognizer, url: url, onDevice: false)
        if cloud.segments.isEmpty {
            lastError = cloud.error ?? lastError
        }
        return cloud.segments
    }

    private func authorized() async -> Bool {
        let status = SFSpeechRecognizer.authorizationStatus()
        if status == .authorized { return true }
        if status != .notDetermined {
            lastError = "Speech recognition is off. Enable it in Settings and retry."
            return false
        }
        let granted = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            SFSpeechRecognizer.requestAuthorization { next in
                cont.resume(returning: next == .authorized)
            }
        }
        if !granted {
            lastError = "Speech recognition is off. Enable it in Settings and retry."
        }
        return granted
    }

    private func run(
        recognizer: SFSpeechRecognizer,
        url: URL,
        onDevice: Bool
    ) async -> (segments: [TranscriptSegment], error: String?) {
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.requiresOnDeviceRecognition = onDevice
        request.shouldReportPartialResults = false

        return await withCheckedContinuation { (cont: CheckedContinuation<( [TranscriptSegment], String?), Never>) in
            let gate = ResumeGate<( [TranscriptSegment], String?)>(cont)
            _ = recognizer.recognitionTask(with: request) { [weak self] result, error in
                if let result, result.isFinal {
                    let segs = Self.segments(from: result)
                    Task { @MainActor in
                        self?.progress = 1
                    }
                    gate.resume((segs, nil))
                    return
                }
                if let error {
                    Task { @MainActor in
                        self?.lastError = error.localizedDescription
                    }
                    gate.resume(([], error.localizedDescription))
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

/// Prevents double-resume of a checked continuation (Swift SIGTRAP).
private final class ResumeGate<T>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<T, Never>?

    init(_ continuation: CheckedContinuation<T, Never>) {
        self.continuation = continuation
    }

    func resume(_ value: T) {
        lock.lock()
        let cont = continuation
        continuation = nil
        lock.unlock()
        cont?.resume(returning: value)
    }
}
