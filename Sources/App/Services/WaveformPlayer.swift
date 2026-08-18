import AVFoundation
import Foundation
import Core

/// Scrubbable playback. Proof: WaveformPlayer, AVAudioPlayer.
@MainActor
final class WaveformPlayer: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var rate: Float = 1
    @Published var lastError: String?

    static let speeds: [Float] = [0.75, 1, 1.5, 2]

    private var player: AVAudioPlayer?
    private var tick: Timer?

    func load(url: URL) {
        stop()
        lastError = nil
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio)
            try session.setActive(true)
            let audio = try AVAudioPlayer(contentsOf: url)
            audio.enableRate = true
            audio.rate = rate
            audio.prepareToPlay()
            player = audio
            duration = audio.duration
            currentTime = 0
        } catch {
            lastError = error.localizedDescription
        }
    }

    func toggle() {
        guard let player else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
            stopTick()
        } else {
            player.rate = rate
            player.play()
            isPlaying = true
            startTick()
        }
    }

    func setRate(_ value: Float) {
        rate = value
        player?.enableRate = true
        player?.rate = value
    }

    func seek(to time: TimeInterval) {
        let clamped = max(0, min(time, duration))
        player?.currentTime = clamped
        currentTime = clamped
    }

    func seekToSegment(_ segment: TranscriptSegment) {
        seek(to: segment.start)
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentTime = 0
        stopTick()
    }

    private func startTick() {
        stopTick()
        tick = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let player = self.player else { return }
                self.currentTime = player.currentTime
                if !player.isPlaying {
                    self.isPlaying = false
                    self.stopTick()
                }
            }
        }
    }

    private func stopTick() {
        tick?.invalidate()
        tick = nil
    }
}
