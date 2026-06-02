import SwiftUI
import Observation

/// Single source of truth for the day, shared by the Today and Summary screens.
/// Seeds from mock data, then refreshes from live UV (WeatherKit) and daylight
/// (HealthKit); Kiran's mood is always derived from the relationship score.
@MainActor
@Observable
final class SunModel {
    var selectedPeriod: SummaryPeriod = .daily

    private(set) var greeting: String
    private(set) var userName: String
    private(set) var uvIndex: Int
    private(set) var intervals: [SunExposureInterval]
    private(set) var protection: [ProtectionItem]
    private(set) var mood: KiranMood = .neutral

    let dateText: String
    let weekLabel: String
    let weekly: WeeklySunSummary

    var headline: String { mood.headline }
    var message: String { mood.line }

    private let uvProvider: UVIndexProviding
    private let locationProvider: LocationProviding
    private let daylightProvider: DaylightExposureProviding
    private let day: Date

    init(
        greetingProvider: GreetingProviding = GreetingProvider(),
        sunData: SunDataProviding = MockSunDataProvider(),
        uvProvider: UVIndexProviding = WeatherKitUVIndexProvider(),
        locationProvider: LocationProviding = DeviceLocationProvider(),
        daylightProvider: DaylightExposureProviding = HealthKitDaylightProvider(),
        now: Date = .now
    ) {
        let today = sunData.todaySummary()
        self.uvProvider = uvProvider
        self.locationProvider = locationProvider
        self.daylightProvider = daylightProvider
        self.day = now
        self.greeting = greetingProvider.greeting(at: now)
        self.userName = today.userName
        self.uvIndex = today.uvIndex
        self.intervals = today.intervals
        self.protection = today.protectionItems
        self.weekly = sunData.weeklySummary()
        self.dateText = now.formatted(.dateTime.day().month().year())
        self.weekLabel = Self.weekLabel(for: now)
        updateMood()
    }

    /// Pulls live outdoor/indoor intervals and UV for the user's location, then
    /// re-derives Kiran's mood. Anything unavailable keeps the seeded value.
    func refresh() async {
        if let live = await daylightProvider.intervals(on: day), !live.isEmpty {
            intervals = live
        }
        let coordinate = await locationProvider.currentLocation() ?? .fallback
        if let uv = try? await uvProvider.currentUVIndex(latitude: coordinate.latitude,
                                                         longitude: coordinate.longitude) {
            uvIndex = uv
        }
        withAnimation(.easeInOut(duration: 0.35)) { updateMood() }
    }

    func toggleProtection(_ item: ProtectionItem) {
        guard let index = protection.firstIndex(where: { $0.id == item.id }) else { return }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            protection[index].isCompleted.toggle()
            updateMood()
        }
    }

    private func updateMood() {
        mood = RelationshipScore.evaluate(uvIndex: uvIndex, intervals: intervals, protection: protection).mood
    }

    private static func weekLabel(for date: Date) -> String {
        guard let week = Calendar.current.dateInterval(of: .weekOfYear, for: date) else { return "This Week" }
        let start = week.start.formatted(.dateTime.day().month())
        let end = week.end.addingTimeInterval(-1).formatted(.dateTime.day().month())
        return "\(start) – \(end)"
    }
}
