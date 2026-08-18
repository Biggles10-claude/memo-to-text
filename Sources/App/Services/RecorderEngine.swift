import AVFoundation
import Foundation

/// One-tap on-device recorder. Proof: RecorderEngine, AVAudioRecorder.
@MainActor
final class RecorderEngine: ObservableObject {
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var elapsed: TimeInterval = 0
    @Published var levels: [CGFloat] = Array(repeating: 0.12, count: 28)
    @Published var lastError: String?

    private var recorder: AVAudioRecorder?
    private var tick: Timer?
    private var startedAt: Date?
    private var accumulated: TimeInterval = 0
    private(set) var outputURL: URL?

    func start(to url: URL) {
        stopMeters()
        lastError = nil
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker])
            try session.setActive(true)
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ]
            let rec = try AVAudioRecorder(url: url, settings: settings)
            rec.isMeteringEnabled = true
            guard rec.record() else {
                lastError = "The microphone could not start. Check permission and retry."
                return
            }
            recorder = rec
            outputURL = url
            startedAt = Date()
            accumulated = 0
            elapsed = 0
            isRecording = true
            isPaused = false
            startMeters()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func pause() {
        guard isRecording, !isPaused else { return }
        recorder?.pause()
        if let startedAt {
            accumulated += Date().timeIntervalSince(startedAt)
        }
        isPaused = true
        startedAt = nil
    }

    func resume() {
        guard isRecording, isPaused else { return }
        recorder?.record()
        isPaused = false
        startedAt = Date()
    }

    func stop() -> TimeInterval {
        recorder?.stop()
        if let startedAt {
            accumulated += Date().timeIntervalSince(startedAt)
        }
        let duration = max(1, accumulated)
        recorder = nil
        isRecording = false
        isPaused = false
        startedAt = nil
        stopMeters()
        levels = Array(repeating: 0.12, count: 28)
        return duration
    }

    private func startMeters() {
        tick?.invalidate()
        tick = Timer.scheduledTimer(withTimeInterval: 1.0 / 20.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.meter() }
        }
        if let tick {
            RunLoop.main.add(tick, forMode: .common)
        }
    }

    private func stopMeters() {
        tick?.invalidate()
        tick = nil
    }

    private func meter() {
        guard let recorder, isRecording else { return }
        if !isPaused, let startedAt {
            elapsed = accumulated + Date().timeIntervalSince(startedAt)
        } else {
            elapsed = accumulated
        }
        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)
        let normalized = CGFloat(max(0, min(1, (power + 50) / 50)))
        levels.removeFirst()
        levels.append(max(0.08, normalized))
    }
}
