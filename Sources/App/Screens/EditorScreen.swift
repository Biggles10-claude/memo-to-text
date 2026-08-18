import SwiftUI
import Core

/// Inline edit + speaker marks. Proof: TranscriptEditor, EditorScreen, SpeakerTurnEditor.
struct EditorScreen: View {
    @EnvironmentObject private var library: MemoLibrary
    @Environment(\.dismiss) private var dismiss
    @StateObject private var player = WaveformPlayer()
    let memoID: String
    @State private var draft: [String: String] = [:]

    var memo: Memo? { library.memo(id: memoID) }

    var body: some View {
        Group {
            if let memo {
                if memo.segments.isEmpty {
                    EmptyStateView(
                        title: "No sentences to edit",
                        message: "Run transcription first, then correct jargon here.",
                        systemImage: "pencil",
                        actionTitle: "Back to transcript",
                        action: { dismiss() }
                    )
                    .padding(DT.spaceM)
                } else {
                    list(memo)
                }
            } else {
                ErrorStateView(message: "This memo is no longer in the library.", retry: library.reload)
            }
        }
        .background(DT.screenBackground.ignoresSafeArea())
        .navigationTitle("Editor")
        .onAppear {
            if let memo {
                player.load(url: library.audioURL(for: memo))
                draft = Dictionary(uniqueKeysWithValues: memo.segments.map { ($0.id, $0.text) })
            }
        }
        .onDisappear { player.stop() }
    }

    private func list(_ memo: Memo) -> some View {
        List {
            ForEach(memo.segments) { segment in
                VStack(alignment: .leading, spacing: DT.spaceS) {
                    HStack {
                        Button {
                            seekToSegment(segment)
                        } label: {
                            Label(segment.clock, systemImage: "play.circle")
                                .font(DT.captionFont())
                                .foregroundStyle(DT.accent)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Menu {
                            Button("Speaker A") { markSpeakerTurn(id: segment.id, speaker: SpeakerBook.a) }
                            Button("Speaker B") { markSpeakerTurn(id: segment.id, speaker: SpeakerBook.b) }
                            Button("Clear speaker") { markSpeakerTurn(id: segment.id, speaker: nil) }
                        } label: {
                            Text(label(for: segment, memo: memo))
                                .font(DT.captionFont())
                                .foregroundStyle(DT.inkSecondary)
                        }
                    }
                    TextField("Sentence", text: Binding(
                        get: { draft[segment.id] ?? segment.text },
                        set: { draft[segment.id] = $0; commit(id: segment.id, text: $0) }
                    ), axis: .vertical)
                    .font(DT.bodyFont())
                    .foregroundStyle(DT.ink)
                }
                .listRowBackground(DT.cardBackground)
            }
            Section("Speaker names") {
                nameField(memo, key: SpeakerBook.a)
                nameField(memo, key: SpeakerBook.b)
            }
        }
        .scrollContentBackground(.hidden)
    }

    private func nameField(_ memo: Memo, key: String) -> some View {
        TextField("Speaker \(key)", text: Binding(
            get: { memo.speakerNames[key] ?? "Speaker \(key)" },
            set: { value in
                var next = memo
                next.speakerNames = SpeakerBook.rename(names: memo.speakerNames, key: key, to: value)
                library.upsert(next)
            }
        ))
    }

    private func label(for segment: TranscriptSegment, memo: Memo) -> String {
        if let key = segment.speaker {
            return memo.speakerNames[key] ?? "Speaker \(key)"
        }
        return "No speaker"
    }

    private func commit(id: String, text: String) {
        guard var memo else { return }
        memo.segments = TranscriptEditor.replace(segments: memo.segments, id: id, text: text)
        library.upsert(memo)
    }

    private func seekToSegment(_ segment: TranscriptSegment) {
        TranscriptEditor.seekToSegment(segment, player: player)
        if !player.isPlaying { player.toggle() }
    }

    private func markSpeakerTurn(id: String, speaker: String?) {
        guard var memo else { return }
        memo.segments = SpeakerTurnEditor.markSpeakerTurn(segments: memo.segments, id: id, speaker: speaker)
        library.upsert(memo)
    }
}
