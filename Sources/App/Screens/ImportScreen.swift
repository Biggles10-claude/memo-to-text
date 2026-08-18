import SwiftUI
import UniformTypeIdentifiers
import Core

/// Import existing audio. Proof: AudioImporter, fileImporter, ImportScreen.
struct ImportScreen: View {
    @EnvironmentObject private var library: MemoLibrary
    @EnvironmentObject private var transcriber: SpeechTranscriber
    @State private var picking = false
    @State private var loading = false
    @State private var error: String?
    @State private var createdID: String?

    var body: some View {
        VStack(spacing: DT.spaceL) {
            if loading {
                LoadingStateView(message: "Copying the audio file into the app sandbox.")
            } else if let error {
                ErrorStateView(message: LocalizedStringKey(error), retry: { picking = true })
            } else {
                EmptyStateView(
                    title: "Import a lecture",
                    message: "Choose an M4A, MP3, WAV, AAC, or CAF file from Files or Voice Memos. Transcription stays on this device.",
                    systemImage: "square.and.arrow.down",
                    actionTitle: "Choose file",
                    action: { picking = true }
                )
            }
            Spacer()
        }
        .padding(DT.spaceM)
        .background(DT.screenBackground.ignoresSafeArea())
        .navigationTitle("Import")
        .fileImporter(
            isPresented: $picking,
            allowedContentTypes: AudioImporter.allowedTypes,
            allowsMultipleSelection: false
        ) { result in
            Task { await handle(result) }
        }
        .navigationDestination(isPresented: Binding(
            get: { createdID != nil },
            set: { if !$0 { createdID = nil } }
        )) {
            if let createdID {
                TranscriptScreen(memoID: createdID)
            }
        }
    }

    private func handle(_ result: Result<[URL], Error>) async {
        switch result {
        case .failure(let err):
            error = err.localizedDescription
        case .success(let urls):
            guard let source = urls.first else { return }
            loading = true
            error = nil
            let dest = library.newAudioURL(ext: AudioImporter.ext(for: source))
            do {
                try AudioImporter.copyIntoSandbox(from: source, destination: dest.url)
                let title = source.deletingPathExtension().lastPathComponent
                let memo = Memo(
                    id: UUID().uuidString,
                    title: title.isEmpty ? "Imported memo" : title,
                    folder: library.selectedFolder ?? FolderCatalog.inbox,
                    createdAt: Date(),
                    duration: 1,
                    audioFileName: dest.name,
                    segments: [],
                    speakerNames: SpeakerBook.defaultNames(),
                    waveform: Array(repeating: 0.3, count: 24),
                    status: .transcribing,
                    lastError: nil
                )
                library.upsert(memo)
                let segments = await transcriber.transcribe(url: dest.url)
                var done = memo
                done.segments = segments
                done.status = segments.isEmpty && transcriber.lastError != nil ? .failed : .ready
                done.lastError = transcriber.lastError
                library.upsert(done)
                createdID = done.id
            } catch {
                self.error = error.localizedDescription
            }
            loading = false
        }
    }
}
