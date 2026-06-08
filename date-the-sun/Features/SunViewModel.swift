import SwiftUI
import SwiftData
import Observation

@MainActor
@Observable
final class SunViewModel {
    // MARK: - Main Screen
    private(set) var isMainScreenDataLoading: Bool = true
    /// Kiran's mood for the Today screen — reflects live UV index only, never changed by browsing history.
    private(set) var mood: KiranMood = .neutral
    private(set) var uvIndex: Int
    var message: String { mood.line }

    // MARK: - Summary Screen: Daily
    private(set) var selectedDailySummary: DailySunSummary?
    /// Kiran's mood for the selected historical date in the Summary screen.
    private(set) var selectedDateMood: KiranMood = .neutral
    var selectedDateHeadline: String { selectedDateMood.headline }

    private(set) var weeklyMood: KiranMood = .neutral
    var weeklyHeadline: String { weeklyMood.headline }

    var selectedDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: .now)! {
        didSet {
            try? fetchObservations(for: selectedDate)
            try? fetchDailySummary(for: selectedDate)
            try? fetchWeeklySummaries()
            updateSelectedDateMood()
            Task { await fetchUVPeakWindow(for: selectedDate) }
        }
    }

    var isSelectedDateToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var selectedDateLabel: String {
        let calendar = Calendar.current
        let today    = calendar.startOfDay(for: .now)
        let selected = calendar.startOfDay(for: selectedDate)
        let days     = calendar.dateComponents([.day], from: selected, to: today).day ?? 0
        switch days {
        case 0:  return "Today"
        case 1:  return "Yesterday"
        case 2:  return "2 days ago"
        case 3:  return "3 days ago"
        default: return selectedDate.formatted(.dateTime.day().month().year())
        }
    }

    // MARK: - Protection (driven purely by DailySunSummary)
    var protectionItems: [ProtectionItem] {
        [
            ProtectionItem(
                kind: .sunscreen,
                title: "Sunscreen",
                subtitle: "Apply when going outside",
                systemImage: "drop.fill",
                isCompleted: selectedDailySummary?.wearSunscreen ?? false
            ),
            ProtectionItem(
                kind: .protectiveClothing,
                title: "Protective Clothing",
                subtitle: "Use hat and long-sleeved shirt",
                systemImage: "tshirt.fill",
                isCompleted: selectedDailySummary?.wearProtectiveClothing ?? false
            ),
        ]
    }

    /// Prepares the protection log for today so the user can fill it in — used
    /// when they tap "Yes" on the evening reminder. Selects today and ensures a
    /// `DailySunSummary` exists to toggle against (the morning summary may not
    /// have been generated yet).
    func beginTodayProtectionLog() {
        let today = Calendar.current.startOfDay(for: .now)
        selectedDate = today // didSet fetches the summary for today

        if selectedDailySummary == nil {
            let summary = DailySunSummary.empty(for: today)
            modelContext.insert(summary)
            try? modelContext.save()
            try? fetchDailySummary(for: today)
        }
    }

    func toggleProtection(_ item: ProtectionItem) {
        // Lazily create today's summary if it doesn't exist yet, so protection
        // can be logged for today (e.g. from the evening reminder) before the
        // morning summary is generated.
        let summary: DailySunSummary
        if let existing = selectedDailySummary {
            summary = existing
        } else if isSelectedDateToday {
            let created = DailySunSummary.empty(for: Calendar.current.startOfDay(for: .now))
            modelContext.insert(created)
            selectedDailySummary = created
            summary = created
        } else {
            return
        }

        switch item.kind {
        case .sunscreen:          summary.wearSunscreen.toggle()
        case .protectiveClothing: summary.wearProtectiveClothing.toggle()
        }
        try? modelContext.save()
        try? fetchDailySummary(for: selectedDate)
    }

    // MARK: - UV Peak Window
    /// Start/end of the contiguous period where UV forecast ≥ 6, in minutes-of-day (0–1440).
    private(set) var uvPeakWindow: (startMinute: Double, endMinute: Double)? = nil

    // MARK: - Summary Screen: Weekly
    private(set) var selectedObservations: [HMMObservation] = []
    private(set) var dailySummaries: [DailySunSummary] = []

    /// All summaries keyed by startOfDay — passed to the calendar picker for mood indicators.
    private(set) var allSummaries: [Date: DailySunSummary] = [:]

    /// Shows the 7-day window ending the day before selectedDate.
    var weekLabel: String {
        let calendar    = Calendar.current
        let selectedDay = calendar.startOfDay(for: selectedDate)
        let endDay      = calendar.date(byAdding: .day, value: -1, to: selectedDay)!
        let startDay    = calendar.date(byAdding: .day, value: -7, to: selectedDay)!
        let start = startDay.formatted(.dateTime.day().month())
        let end   = endDay.formatted(.dateTime.day().month())
        return "\(start) – \(end)"
    }

    var selectedPeriod: SummaryPeriod = .daily

    // MARK: - Shared
    private(set) var greeting: String
    private(set) var userName: String

    private let uvProvider: UVIndexProviding
    private let locationProvider: LocationProviding
    private let modelContext: ModelContext

    // MARK: - Init
    init(
        modelContainer: ModelContainer,
        greetingProvider: GreetingProviding = GreetingProvider(),
        uvProvider: UVIndexProviding = RESTUVIndexProvider(),
        locationProvider: LocationProviding = DeviceLocationProvider(),
        now: Date = .now
    ) {
        self.modelContext      = ModelContext(modelContainer)
        self.userName          = "James"
        self.greeting          = greetingProvider.greeting(at: now)
        self.locationProvider  = locationProvider
        self.uvProvider        = uvProvider
        self.uvIndex           = 0
        self.selectedObservations = []
    }

    // MARK: - Refresh
    func refresh() async {
        isMainScreenDataLoading = true
        defer { isMainScreenDataLoading = false }

        let coordinate = await locationProvider.currentLocation() ?? .fallback
        if let uv = try? await uvProvider.currentUVIndex(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        ) {
            uvIndex = uv
        }

        uvPeakWindow = try? await uvProvider.uvPeakWindow(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            date: selectedDate
        )

        if let maxUV = try? await uvProvider.maxUVIndexToday(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        ) {
            NotificationManager.scheduleMorningNotification(maxUvTodayForecast: maxUV)
            if let peakWindow = uvPeakWindow {
                NotificationManager.scheduleMidDayNotification(
                    maxUvTodayForecast: maxUV,
                    minuteOfDay: peakWindow.startMinute - 30
                )
            }
            NotificationManager.scheduleEveningNotification(maxUvTodayForecast: maxUV)
        }

        try? fetchObservations(for: selectedDate)
        try? fetchDailySummary(for: selectedDate)
        try? fetchWeeklySummaries()
        try? fetchAllSummaries()

        withAnimation(.easeInOut(duration: 0.35)) {
            mood = .from(uvIndex: uvIndex)
            updateSelectedDateMood()
        }
    }

    // MARK: - Fetches
    func fetchObservations(for date: Date) throws {
        let calendar = Calendar.current
        let start    = calendar.startOfDay(for: date)
        let end      = calendar.date(byAdding: .day, value: 1, to: start)!
        let descriptor = FetchDescriptor<HMMObservation>(
            predicate: #Predicate { $0.timestamp >= start && $0.timestamp < end },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        selectedObservations = try modelContext.fetch(descriptor)
    }

    /// Fetches the single DailySunSummary for the given date.
    func fetchDailySummary(for date: Date) throws {
        let calendar = Calendar.current
        let start    = calendar.startOfDay(for: date)
        let end      = calendar.date(byAdding: .day, value: 1, to: start)!
        var descriptor = FetchDescriptor<DailySunSummary>(
            predicate: #Predicate { $0.date >= start && $0.date < end },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        selectedDailySummary = try modelContext.fetch(descriptor).first
    }

    /// Fetches the 7-day window ending the day before selectedDate.
    func fetchWeeklySummaries() throws {
        let calendar     = Calendar.current
        let selectedDay  = calendar.startOfDay(for: selectedDate)
        let yesterday    = calendar.date(byAdding: .day, value: -1, to: selectedDay)!
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: selectedDay)!

        let descriptor = FetchDescriptor<DailySunSummary>(
            predicate: #Predicate { $0.date >= sevenDaysAgo && $0.date <= yesterday },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        dailySummaries = try modelContext.fetch(descriptor)
        updateWeeklyMood()
    }

    /// Fetches DailySummaries for the calendar mood indicators, capped at 90 days.
    func fetchAllSummaries() throws {
        let cutoff = Calendar.current.date(byAdding: .day, value: -90, to: .now)!
        let descriptor = FetchDescriptor<DailySunSummary>(
            predicate: #Predicate { $0.date >= cutoff },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        let all = try modelContext.fetch(descriptor)
        allSummaries = Dictionary(
            all.map { (Calendar.current.startOfDay(for: $0.date), $0) },
            uniquingKeysWith: { _, latest in latest }
        )
    }

    private func fetchUVPeakWindow(for date: Date) async {
        let coordinate = await locationProvider.currentLocation() ?? .fallback
        uvPeakWindow = try? await uvProvider.uvPeakWindow(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            date: date
        )
    }

    // MARK: - Mood
    private func updateSelectedDateMood() {
        if let score = selectedDailySummary?.score {
            selectedDateMood = .from(score: score)
        } else {
            selectedDateMood = .neutral
        }
    }

    private func updateWeeklyMood() {
        let scores = dailySummaries.map(\.score)
        guard !scores.isEmpty else { weeklyMood = .neutral; return }
        let average = scores.reduce(0, +) / Double(scores.count)
        weeklyMood = .from(score: average)
    }
}
