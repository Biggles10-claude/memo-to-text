import SwiftUI
import Core

/// Full-screen capture. Proof: RecorderEngine, RecorderScreen.
struct RecorderScreen: View {
    @EnvironmentObject private var library: MemoLibrary
    @EnvironmentObject private var transcriber: SpeechTranscriber
    @StateObject private var engine = RecorderEngine()
    @State private var createdID: String?
    @State private var phase: Phase = .idle

    enum Phase { case idle, recording, saving, done }

    var body: some View {
        VStack(spacing: DT.spaceL) {
            Spacer(minLength: DT.spaceM)
            Text(DurationFormat.clock(engine.elapsed))
                .font(DT.timerFont())
                .foregroundStyle(DT.ink)
                .monospacedDigit()
            WaveformView(levels: engine.levels)
                .frame(height: 88)
                .padding(.horizontal, DT.spaceL)

            if let err = engine.lastError {
                ErrorStateView(message: LocalizedStringKey(err), retry: begin)
            } else if phase == .saving {
                LoadingStateView(message: "Saving the take and transcribing on this device.")
            } else if phase == .idle {
                EmptyStateView(
                    title: "Ready to record",
                    message: "Tap Start to capture a lecture or walking note. Audio stays on this phone.",
                    systemImage: "mic",
                    actionTitle: "Start",
                    action: begin
                )
            }

            Spacer()
            controls
        }
        .padding(DT.spaceM)
        .background(DT.screenBackground.ignoresSafeArea())
        .navigationTitle("Recorder")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: Binding(
            get: { createdID != nil },
            set: { if !$0 { createdID = nil } }
        )) {
            if let createdID {
                TranscriptScreen(memoID: createdID)
            }
        }
    }

    @ViewBuilder
    private var controls: some View {
        if engine.isRecording {
            HStack(spacing: DT.spaceM) {
                Button(engine.isPaused ? "Resume" : "Pause") {
                    if engine.isPaused { engine.resume() } else { engine.pause() }
                }
                .font(DT.headlineFont())
                .frame(width: 120, height: DT.tap)
                .foregroundStyle(DT.ink)
                .background(DT.cardBackground, in: Capsule())
                Button("Stop") { Task { await finish() } }
                    .font(DT.headlineFont())
                    .frame(width: 120, height: DT.tap)
                    .foregroundStyle(DT.paperElevated)
                    .background(DT.accent, in: Capsule())
            }
        } else if phase == .done {
            PrimaryCTA(title: "Record another", systemImage: "record.circle") { begin() }
        }
    }

    private func begin() {
        let dest = library.newAudioURL(ext: "m4a")
        engine.start(to: dest.url)
        if engine.isRecording { phase = .recording }
    }

    private func finish() async {
        phase = .saving
        let duration = engine.stop()
        guard let url = engine.outputURL else {
            phase = .idle
            return
        }
        let memo = Memo(
            id: UUID().uuidString,
            title: MemoTitle.recorded(),
            folder: library.selectedFolder ?? FolderCatalog.inbox,
            createdAt: Date(),
            duration: duration,
            audioFileName: url.lastPathComponent,
            segments: [],
            speakerNames: SpeakerBook.defaultNames(),
            waveform: engine.levels.map { Double($0) },
            status: .transcribing,
            lastError: nil
        )
        library.upsert(memo)
        let segments = await transcriber.transcribe(url: url)
        var done = memo
        if segments.isEmpty {
            done.status = transcriber.lastError == nil ? .ready : .failed
            done.lastError = transcriber.lastError
        } else {
            done.segments = segments
            done.status = .ready
        }
        library.upsert(done)
        createdID = done.id
        phase = .done
    }
}

