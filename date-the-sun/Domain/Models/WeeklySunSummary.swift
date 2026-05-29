import Foundation

/// One day's exposure totals within a week, used by the weekly bar chart.
nonisolated struct DayExposureStat: Identifiable {
    let id = UUID()
    let weekdayLabel: String   // "M", "T", "W"…
    let outdoorMinutes: Double
    let indoorMinutes: Double

    var totalMinutes: Double { outdoorMinutes + indoorMinutes }
}

/// One protection habit's adherence across the seven days of a week.
nonisolated struct ProtectionWeekRow: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let completedDays: [Bool]   // 7 entries, Mon…Sun
}

/// The week's sun data shown on the Summary screen's Weekly tab.
nonisolated struct WeeklySunSummary {
    let weekLabel: String
    let mood: KiranMood
    let headline: String
    let days: [DayExposureStat]
    let protection: [ProtectionWeekRow]
}
