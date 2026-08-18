import SwiftUI
import Core

/// Transcript hub. Proof: TranscriptScreen, SpeechTranscriber.
struct TranscriptScreen: View {
    @EnvironmentObject private var library: MemoLibrary
    @EnvironmentObject private var transcriber: SpeechTranscriber
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
        .navigationTitle(memo?.title ?? "Transcript")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func content(_ memo: Memo) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: DT.spaceS) {
                navChip("Edit", destination: EditorScreen(memoID: memo.id), icon: "pencil")
                navChip("Play", destination: PlaybackScreen(memoID: memo.id), icon: "play.fill")
                navChip("Share", destination: ExportScreen(memoID: memo.id), icon: "square.and.arrow.up")
            }
            .padding(DT.spaceM)

            if memo.status == .transcribing {
                LoadingStateView(message: "Transcribing on this device. Audio does not leave the phone.")
            } else if memo.status == .failed {
                ErrorStateView(message: LocalizedStringKey(memo.lastError ?? "Transcription failed.")) {
                    Task { await retry(memo) }
                }
            } else if memo.segments.isEmpty {
                EmptyStateView(
                    title: "No sentences yet",
                    message: "Run transcription or type the first sentence in the editor.",
                    systemImage: "text.alignleft",
                    actionTitle: "Transcribe",
                    action: { Task { await retry(memo) } }
                )
                .padding(DT.spaceM)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: DT.spaceM) {
                        ForEach(memo.segments) { segment in
                            VStack(alignment: .leading, spacing: DT.spaceXS) {
                                HStack {
                                    Text(segment.clock)
                                        .font(DT.captionFont())
                                        .foregroundStyle(DT.inkSecondary)
                                    if let key = segment.speaker {
                                        Text(memo.speakerNames[key] ?? "Speaker \(key)")
                                            .font(DT.captionFont())
                                            .foregroundStyle(DT.accent)
                                    }
                                }
                                Text(segment.text)
                                    .font(DT.bodyFont())
                                    .foregroundStyle(DT.ink)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(DT.spaceM)
                            .background(DT.cardBackground, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
                        }
                    }
                    .padding(.horizontal, DT.spaceM)
                    .padding(.bottom, DT.spaceXL)
                }
            }
        }
    }

    private func navChip<V: View>(_ title: String, destination: V, icon: String) -> some View {
        NavigationLink {
            destination
        } label: {
            Label(title, systemImage: icon)
                .font(DT.captionFont())
                .frame(maxWidth: .infinity, minHeight: DT.tap)
                .foregroundStyle(DT.ink)
                .background(DT.cardBackground, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func retry(_ memo: Memo) async {
        var next = memo
        next.status = .transcribing
        library.upsert(next)
        let segments = await transcriber.transcribe(url: library.audioURL(for: memo))
        next.segments = segments
        next.status = segments.isEmpty && transcriber.lastError != nil ? .failed : .ready
        next.lastError = transcriber.lastError
        library.upsert(next)
    }
}
