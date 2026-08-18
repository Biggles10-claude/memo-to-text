import SwiftUI
import Core

/// Waveform playback with speed. Proof: WaveformPlayer, PlaybackScreen.
struct PlaybackScreen: View {
    @EnvironmentObject private var library: MemoLibrary
    @Environment(\.dismiss) private var dismiss
    @StateObject private var player = WaveformPlayer()
    let memoID: String

    var memo: Memo? { library.memo(id: memoID) }

    var body: some View {
        Group {
            if let memo {
                content(memo)
            } else {
                ErrorStateView(message: "This memo is no longer in the library.", retry: library.reload)
            }
        }
        .background(DT.screenBackground.ignoresSafeArea())
        .navigationTitle("Playback")
        .onAppear {
            if let memo { player.load(url: library.audioURL(for: memo)) }
        }
        .onDisappear { player.stop() }
    }

    @ViewBuilder
    private func content(_ memo: Memo) -> some View {
        if memo.audioFileName.isEmpty {
            EmptyStateView(
                title: "No audio to play",
                message: "Record or import a memo first.",
                systemImage: "play.slash",
                actionTitle: "Back to the memo",
                action: { dismiss() }
            )
            .padding(DT.spaceM)
        } else if let err = player.lastError {
            ErrorStateView(message: LocalizedStringKey(err)) {
                player.load(url: library.audioURL(for: memo))
            }
        } else {
            VStack(spacing: DT.spaceL) {
                WaveformView(
                    levels: memo.waveform.isEmpty ? Array(repeating: 0.35, count: 24).map { CGFloat($0) } : memo.waveform.map { CGFloat($0) },
                    progress: memo.duration == 0 ? 0 : CGFloat(player.currentTime / max(memo.duration, 0.1))
                )
                .frame(height: 96)
                .padding(.horizontal, DT.spaceM)

                Text("\(DurationFormat.clock(player.currentTime))  /  \(DurationFormat.clock(player.duration))")
                    .font(DT.monoFont())
                    .foregroundStyle(DT.inkSecondary)

                Slider(
                    value: Binding(
                        get: { player.currentTime },
                        set: { player.seek(to: $0) }
                    ),
                    in: 0...max(player.duration, 1)
                )
                .tint(DT.accent)
                .padding(.horizontal, DT.spaceL)

                HStack(spacing: DT.spaceS) {
                    ForEach(WaveformPlayer.speeds, id: \.self) { speed in
                        Button("\(speed.clean)x") { player.setRate(speed) }
                            .font(DT.captionFont())
                            .frame(maxWidth: .infinity, minHeight: DT.tap)
                            .foregroundStyle(player.rate == speed ? DT.paperElevated : DT.ink)
                            .background(
                                player.rate == speed ? DT.accent : DT.cardBackground,
                                in: Capsule()
                            )
                    }
                }
                .padding(.horizontal, DT.spaceM)

                Button {
                    player.toggle()
                } label: {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .frame(width: 72, height: 72)
                        .foregroundStyle(DT.paperElevated)
                        .background(DT.accent, in: Circle())
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel(player.isPlaying ? "Pause" : "Play")

                currentSentence(memo)
                Spacer()
            }
            .padding(.top, DT.spaceL)
        }
    }

    @ViewBuilder
    private func currentSentence(_ memo: Memo) -> some View {
        let active = memo.segments.last { $0.start <= player.currentTime + 0.05 }
        if let active {
            Text(active.text)
                .font(DT.bodyFont())
                .foregroundStyle(DT.ink)
                .padding(DT.spaceM)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DT.accentSoft, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
                .padding(.horizontal, DT.spaceM)
        }
    }
}

private extension Float {
    var clean: String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(Int(self)) : String(self)
    }
}
