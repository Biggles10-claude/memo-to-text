import XCTest
@testable import App
import Core

final class MemoLibraryTests: XCTestCase {
    func testRenameAndFolderMovePersist() {
        let suite = UserDefaults(suiteName: "test.memolibrary")!
        suite.removePersistentDomain(forName: "test.memolibrary")
        let library = MemoLibrary(store: LocalStore(defaults: suite))
        let memo = Memo(
            id: "m1",
            title: "Draft",
            folder: FolderCatalog.inbox,
            createdAt: Date(timeIntervalSince1970: 1_750_000_000),
            duration: 12,
            audioFileName: "m1.m4a",
            segments: [TranscriptSegment(id: "s1", text: "Hello council", start: 0, end: 2)],
            speakerNames: SpeakerBook.defaultNames(),
            waveform: [0.2, 0.4],
            status: .ready,
            lastError: nil
        )
        library.upsert(memo)
        library.renameMemo(id: "m1", to: "Budget hearing")
        library.move(ids: ["m1"], to: FolderCatalog.lectures)
        XCTAssertEqual(library.memo(id: "m1")?.title, "Budget hearing")
        XCTAssertEqual(library.memo(id: "m1")?.folder, FolderCatalog.lectures)

        let reloaded = MemoLibrary(store: LocalStore(defaults: suite))
        XCTAssertEqual(reloaded.memo(id: "m1")?.title, "Budget hearing")
        XCTAssertEqual(reloaded.folders.contains(FolderCatalog.lectures), true)
    }

    func testSearchHitsTranscript() {
        let titles = ["m1": "Walk"]
        let segs = ["m1": [TranscriptSegment(text: "Find the quote later", start: 0, end: 2)]]
        let hits = MemoSearchIndex.hits(query: "quote", titles: titles, segments: segs)
        XCTAssertEqual(hits.first?.memoID, "m1")
    }
}
