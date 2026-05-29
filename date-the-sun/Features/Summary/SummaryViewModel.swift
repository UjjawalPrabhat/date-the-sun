import Foundation
import Combine

@MainActor
final class SummaryViewModel: ObservableObject {
    @Published var selectedPeriod: SummaryPeriod = .daily
    @Published private(set) var protectionItems: [ProtectionItem] = []

    let dateText: String
    let weekLabel: String
    private(set) var headline: String = ""
    private(set) var weeklyHeadline: String = ""
    private(set) var mood: KiranMood = .happy
    private(set) var weeklyMood: KiranMood = .calm
    private(set) var intervals: [SunExposureInterval] = []
    private(set) var weekDays: [DayExposureStat] = []
    private(set) var protectionWeek: [ProtectionWeekRow] = []

    private let sunDataProvider: SunDataProviding

    init(sunDataProvider: SunDataProviding = MockSunDataProvider(),
         calendar: Calendar = .current,
         now: Date = Date()) {
        self.sunDataProvider = sunDataProvider

        let daily = sunDataProvider.todaySummary()
        let weekly = sunDataProvider.weeklySummary()

        headline = daily.headline
        mood = daily.mood
        intervals = daily.intervals
        protectionItems = daily.protectionItems

        weeklyHeadline = weekly.headline
        weeklyMood = weekly.mood
        weekDays = weekly.days
        protectionWeek = weekly.protection

        dateText = Self.formattedDate(now, calendar: calendar)
        weekLabel = Self.formattedWeek(now, calendar: calendar)
    }

    func select(_ period: SummaryPeriod) {
        selectedPeriod = period
    }

    func toggleProtection(_ item: ProtectionItem) {
        guard let index = protectionItems.firstIndex(where: { $0.id == item.id }) else { return }
        protectionItems[index].isCompleted.toggle()
    }

    // MARK: - Date formatting

    private static func formattedDate(_ date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }

    private static func formattedWeek(_ date: Date, calendar: Calendar) -> String {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return "This Week"
        }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "d MMM"
        let start = formatter.string(from: interval.start)
        let end = formatter.string(from: interval.end.addingTimeInterval(-1))
        return "\(start) – \(end)"
    }
}
