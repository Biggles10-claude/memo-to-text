import Foundation

/// Streak arithmetic over calendar days (template t1). Pure logic —
/// Linux-testable — used by any habit/tracking-shaped generated app.
public enum StreakCalculator {
    /// Length of the consecutive-day run ending today (or yesterday, so an
    /// unbroken streak does not reset before the user logs today).
    public static func currentStreak(days: [Date], today: Date, calendar: Calendar = .init(identifier: .gregorian)) -> Int {
        let daySet = Set(days.map { calendar.startOfDay(for: $0) })
        var cursor = calendar.startOfDay(for: today)
        if !daySet.contains(cursor) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                return 0
            }
            cursor = yesterday
        }
        var streak = 0
        while daySet.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previous
        }
        return streak
    }
}

/// Locale-correct money formatting for price displays outside StoreKit
/// (StoreKit product prices always use `displayPrice`; this is for history
/// and summary rows).
public enum MoneyFormatter {
    public static func format(cents: Int, currencyCode: String, locale: Locale = Locale(identifier: "en_US")) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = locale
        let amount = Decimal(cents) / 100
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}

/// Input validation helpers for numeric quick-entry fields.
public enum InputValidator {
    /// Parse a user-typed decimal (both '.' and ',' separators) into cents.
    public static func cents(from text: String) -> Int? {
        let normalized = text
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ",", with: ".")
        guard !normalized.isEmpty, let value = Double(normalized), value >= 0, value.isFinite else {
            return nil
        }
        return Int((value * 100).rounded())
    }
}
