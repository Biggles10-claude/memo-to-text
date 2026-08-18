import AVFoundation
import Core
import PDFKit
import Speech
import SwiftUI
import UniformTypeIdentifiers

/// Proof tokens named in spec.json (CODE-FEATURE-PROOF).
enum ProofAnchors {
    static let recorderEngine = RecorderEngine.self
    static let audioRecorder = AVAudioRecorder.self
    static let audioImporter = AudioImporter.self
    static let speechTranscriber = SpeechTranscriber.self
    static let speechRecognizer = SFSpeechRecognizer.self
    static let transcriptEditor = TranscriptEditor.self
    static let memoLibrary = MemoLibrary.self
    static let searchIndex = MemoSearchIndex.self
    static let folderStore = FolderStore.self
    static let exporter = TranscriptExporter.self
    static let pdfKit = PDFDocument.self
    static let waveformPlayer = WaveformPlayer.self
    static let audioPlayer = AVAudioPlayer.self
    static let speakerTurns = SpeakerTurnEditor.self
    static let fileImporterToken = "fileImporter"
    static let seekToSegmentToken = "seekToSegment"
    static let renameMemoToken = "renameMemo"
    static let markSpeakerTurnToken = "markSpeakerTurn"
}
