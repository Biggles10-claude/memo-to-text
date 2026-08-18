import XCTest
@testable import Core

final class FolderCatalogTests: XCTestCase {
    func testDefaultFolders() {
        XCTAssertEqual(FolderCatalog.defaults, ["Inbox", "Lectures", "Interviews", "Ideas"])
    }

    func testSanitizeRejectsBlank() {
        XCTAssertNil(FolderCatalog.sanitized("   "))
    }

    func testSanitizeTrims() {
        XCTAssertEqual(FolderCatalog.sanitized("  Field notes  "), "Field notes")
    }
}

final class MemoSearchIndexTests: XCTestCase {
    func testFindsTranscriptBody() {
        let segments = [
            "m1": [
                TranscriptSegment(id: "s1", text: "The budget hearing starts at noon", start: 0, end: 4),
            ],
        ]
        let hits = MemoSearchIndex.hits(query: "hearing", titles: ["m1": "Council"], segments: segments)
        XCTAssertEqual(hits.count, 1)
        XCTAssertEqual(hits[0].sentence, "The budget hearing starts at noon")
    }

    func testShortQueryIsEmpty() {
        let hits = MemoSearchIndex.hits(query: "a", titles: ["m1": "A"], segments: [:])
        XCTAssertTrue(hits.isEmpty)
    }
}

final class TranscriptFormatterTests: XCTestCase {
    func testSpeakerLabels() {
        let text = TranscriptFormatter.plainText(
            title: "Interview",
            speakerNames: ["A": "Maya", "B": "Owen"],
            segments: [
                TranscriptSegment(text: "Hello", start: 0, end: 1, speaker: "A"),
                TranscriptSegment(text: "Hi", start: 1, end: 2, speaker: "B"),
            ]
        )
        XCTAssertTrue(text.contains("Maya: Hello"))
        XCTAssertTrue(text.contains("Owen: Hi"))
    }
}

final class SpeakerBookTests: XCTestCase {
    func testRenameAndMark() {
        let named = SpeakerBook.rename(names: SpeakerBook.defaultNames(), key: "A", to: "Riley")
        XCTAssertEqual(named["A"], "Riley")
        let marked = SpeakerBook.mark(
            segments: [TranscriptSegment(id: "x", text: "Hi", start: 0, end: 1)],
            id: "x",
            speaker: "A"
        )
        XCTAssertEqual(marked[0].speaker, "A")
    }
}

final class DurationFormatTests: XCTestCase {
    func testMinutes() {
        XCTAssertEqual(DurationFormat.clock(75), "1:15")
    }
}

final class MemoTitleTests: XCTestCase {
    func testEveningNote() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = cal.date(from: DateComponents(year: 2026, month: 8, day: 18, hour: 20))!
        let title = MemoTitle.recorded(at: date, calendar: cal)
        XCTAssertTrue(title.hasPrefix("Evening note"), title)
        XCTAssertTrue(title.contains("18"), title)
    }
}
