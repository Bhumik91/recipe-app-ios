//
//  Date+NotificationLogFormat.swift
//  RecipeApp
//

import Foundation

/// Notification-log date labels: Today / Yesterday / weekday name / `dd-MM`.
extension Date {

    // Formatters are expensive to build, so the two fixed patterns are created once.
    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    private static let dayMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM"
        return formatter
    }()

    /// "Today" / "Yesterday" / "Tuesday" / "04-08", widening as the date recedes.
    func notificationLogLabel(relativeTo now: Date = Date(), calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(self) { return "Today" }
        if calendar.isDateInYesterday(self) { return "Yesterday" }

        // Within the last week the weekday name is more readable than a numeric date.
        let daysApart = calendar.dateComponents([.day], from: self, to: now).day ?? 0
        if (0...6).contains(daysApart) {
            return Self.weekdayFormatter.string(from: self)
        }
        return Self.dayMonthFormatter.string(from: self)
    }
}
