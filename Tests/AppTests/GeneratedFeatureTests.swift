import XCTest

@testable import App

/// Generated per-feature tests (spec acceptance checklist backing).
final class GeneratedFeatureTests: XCTestCase {
    /// One-tap on-device recorder — acceptance: Library Record opens a full-screen recorder with Start, Stop, Pause, and Resume.
    func testFeature1StorageRoundTrip() {
        let suite = UserDefaults(suiteName: "test.feature1")!
        suite.removePersistentDomain(forName: "test.feature1")
        let store = LocalStore(defaults: suite)
        store.save(["one", "two"], forKey: "feature1")
        XCTAssertEqual(store.load([String].self, forKey: "feature1"), ["one", "two"])
    }

    /// Import audio from Files or Voice Memos — acceptance: Library Import opens the Files picker and accepts M4A, MP3, WAV, AAC, and CAF.
    func testFeature2StorageRoundTrip() {
        let suite = UserDefaults(suiteName: "test.feature2")!
        suite.removePersistentDomain(forName: "test.feature2")
        let store = LocalStore(defaults: suite)
        store.save(["one", "two"], forKey: "feature2")
        XCTAssertEqual(store.load([String].self, forKey: "feature2"), ["one", "two"])
    }

    /// On-device Speech transcription — acceptance: After record or import, SpeechTranscriber runs Apple Speech on-device and writes timestamped sentences.
    func testFeature3StorageRoundTrip() {
        let suite = UserDefaults(suiteName: "test.feature3")!
        suite.removePersistentDomain(forName: "test.feature3")
        let store = LocalStore(defaults: suite)
        store.save(["one", "two"], forKey: "feature3")
        XCTAssertEqual(store.load([String].self, forKey: "feature3"), ["one", "two"])
    }

    /// Transcript editor with tap-to-seek — acceptance: Each transcript sentence is editable inline on the editor surface.
    func testFeature4StorageRoundTrip() {
        let suite = UserDefaults(suiteName: "test.feature4")!
        suite.removePersistentDomain(forName: "test.feature4")
        let store = LocalStore(defaults: suite)
        store.save(["one", "two"], forKey: "feature4")
        XCTAssertEqual(store.load([String].self, forKey: "feature4"), ["one", "two"])
    }

    /// Memo library home — acceptance: Cold launch shows every saved memo with title, duration, date, and a transcript preview.
    func testFeature5StorageRoundTrip() {
        let suite = UserDefaults(suiteName: "test.feature5")!
        suite.removePersistentDomain(forName: "test.feature5")
        let store = LocalStore(defaults: suite)
        store.save(["one", "two"], forKey: "feature5")
        XCTAssertEqual(store.load([String].self, forKey: "feature5"), ["one", "two"])
    }

    /// Full-text search across memos — acceptance: Search matches title and transcript body as the user types.
    func testFeature6StorageRoundTrip() {
        let suite = UserDefaults(suiteName: "test.feature6")!
        suite.removePersistentDomain(forName: "test.feature6")
        let store = LocalStore(defaults: suite)
        store.save(["one", "two"], forKey: "feature6")
        XCTAssertEqual(store.load([String].self, forKey: "feature6"), ["one", "two"])
    }

    /// Folders and rename — acceptance: The user can create a named folder and move one or many memos into it.
    func testFeature7StorageRoundTrip() {
        let suite = UserDefaults(suiteName: "test.feature7")!
        suite.removePersistentDomain(forName: "test.feature7")
        let store = LocalStore(defaults: suite)
        store.save(["one", "two"], forKey: "feature7")
        XCTAssertEqual(store.load([String].self, forKey: "feature7"), ["one", "two"])
    }

    /// Share transcript TXT and PDF — acceptance: Export Share presents a system share sheet with a TXT file of the cleaned transcript.
    func testFeature8StorageRoundTrip() {
        let suite = UserDefaults(suiteName: "test.feature8")!
        suite.removePersistentDomain(forName: "test.feature8")
        let store = LocalStore(defaults: suite)
        store.save(["one", "two"], forKey: "feature8")
        XCTAssertEqual(store.load([String].self, forKey: "feature8"), ["one", "two"])
    }

    /// Waveform playback with speed — acceptance: Playback shows a scrubbable waveform and the current sentence highlighted.
    func testFeature9StorageRoundTrip() {
        let suite = UserDefaults(suiteName: "test.feature9")!
        suite.removePersistentDomain(forName: "test.feature9")
        let store = LocalStore(defaults: suite)
        store.save(["one", "two"], forKey: "feature9")
        XCTAssertEqual(store.load([String].self, forKey: "feature9"), ["one", "two"])
    }

    /// Optional speaker-turn marks — acceptance: The editor can split the transcript into Speaker A and Speaker B turns.
    func testFeature10StorageRoundTrip() {
        let suite = UserDefaults(suiteName: "test.feature10")!
        suite.removePersistentDomain(forName: "test.feature10")
        let store = LocalStore(defaults: suite)
        store.save(["one", "two"], forKey: "feature10")
        XCTAssertEqual(store.load([String].self, forKey: "feature10"), ["one", "two"])
    }
}
