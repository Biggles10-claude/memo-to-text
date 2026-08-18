import XCTest

@testable import Core

final class StreakCalculatorTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    private func day(_ offset: Int, from base: Date) -> Date {
        calendar.date(byAdding: .day, value: offset, to: base)!
    }

    func testUnbrokenRunEndingTodayCounts() {
        let today = Date(timeIntervalSince1970: 1_750_000_000)
        let days = [day(0, from: today), day(-1, from: today), day(-2, from: today)]
        XCTAssertEqual(StreakCalculator.currentStreak(days: days, today: today), 3)
    }

    func testStreakSurvivesWhenTodayNotYetLogged() {
        let today = Date(timeIntervalSince1970: 1_750_000_000)
        let days = [day(-1, from: today), day(-2, from: today)]
        XCTAssertEqual(StreakCalculator.currentStreak(days: days, today: today), 2)
    }

    func testGapBreaksStreak() {
        let today = Date(timeIntervalSince1970: 1_750_000_000)
        let days = [day(0, from: today), day(-2, from: today), day(-3, from: today)]
        XCTAssertEqual(StreakCalculator.currentStreak(days: days, today: today), 1)
    }

    func testEmptyIsZero() {
        XCTAssertEqual(StreakCalculator.currentStreak(days: [], today: Date()), 0)
    }
}

final class MoneyFormatterTests: XCTestCase {
    func testFormatsUSDollars() {
        XCTAssertEqual(MoneyFormatter.format(cents: 299, currencyCode: "USD"), "$2.99")
    }

    func testZeroCents() {
        XCTAssertEqual(MoneyFormatter.format(cents: 0, currencyCode: "USD"), "$0.00")
    }
}

final class InputValidatorTests: XCTestCase {
    func testParsesDotDecimal() {
        XCTAssertEqual(InputValidator.cents(from: "2.99"), 299)
    }

    func testParsesCommaDecimal() {
        XCTAssertEqual(InputValidator.cents(from: "2,99"), 299)
    }

    func testRejectsGarbageAndNegatives() {
        XCTAssertNil(InputValidator.cents(from: "abc"))
        XCTAssertNil(InputValidator.cents(from: "-1"))
        XCTAssertNil(InputValidator.cents(from: ""))
    }
}
