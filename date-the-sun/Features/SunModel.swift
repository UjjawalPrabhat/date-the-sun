import SwiftUI
import SwiftData
import Observation

/// Single source of truth for the day, shared by the Today and Summary screens.
/// Reads processed HMMObservations and DailySunSummary from SwiftData,
/// pulls live UV from WeatherKit, and derives Kiran's mood from the relationship score.
@MainActor
@Observable
final class SunModel {

    var selectedPeriod: SummaryPeriod = .daily

    private(set) var greeting: String
    private(set) var userName: String
    private(set) var uvIndex: Int
    private(set) var mood: KiranMood = .neutral
    private(set) var todaySummary: DailySunSummary?      // nil until HMM has run
    private(set) var protection: ProtectionProfile

    let dateText: String
    let weekLabel: String

    var headline: String { mood.headline }
    var message: String { mood.line }

    private let uvProvider: UVIndexProviding
    private let locationProvider: LocationProviding
    private let modelContext: ModelContext
    private let day: Date

    init(
        modelContainer: ModelContainer,
        greetingProvider: GreetingProviding = GreetingProvider(),
        uvProvider: UVIndexProviding = RESTUVIndexProvider(),
        locationProvider: LocationProviding = DeviceLocationProvider(),
        now: Date = .now
    ) {
        self.uvProvider = uvProvider
        self.locationProvider = locationProvider
        self.modelContext = ModelContext(modelContainer)
        self.day = now
        self.greeting = greetingProvider.greeting(at: now)
        self.userName = ""                               // loaded in refresh()
        self.uvIndex = 0
        self.protection = ProtectionProfile(
            wearingSunscreen: false,
            wearingProtectiveClothing: false
        )
        self.dateText = now.formatted(.dateTime.day().month().year())
        self.weekLabel = Self.weekLabel(for: now)
    }

    func refresh() async {
        let coordinate = await locationProvider.currentLocation() ?? .fallback
        if let uv = try? await uvProvider.currentUVIndex(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        ) {
            uvIndex = uv
        }

        let yesterday = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: -1, to: day)!
        )
        let today = Calendar.current.startOfDay(for: day)

        let summaryDescriptor = FetchDescriptor<DailySunSummary>(
            predicate: #Predicate { $0.date >= yesterday && $0.date < today }
        )
        todaySummary = try? modelContext.fetch(summaryDescriptor).first

        withAnimation(.easeInOut(duration: 0.35)) { updateMood() }
    }

    func toggleSunscreen() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            protection.wearingSunscreen.toggle()
            updateMood()
        }
    }

    func toggleProtectiveClothing() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            protection.wearingProtectiveClothing.toggle()
            updateMood()
        }
    }

    private func updateMood() {
        mood = KiranMood.from(uvIndex: uvIndex)
    }

    private static func weekLabel(for date: Date) -> String {
        guard let week = Calendar.current.dateInterval(of: .weekOfYear, for: date) else { return "This Week" }
        let start = week.start.formatted(.dateTime.day().month())
        let end = week.end.addingTimeInterval(-1).formatted(.dateTime.day().month())
        return "\(start) – \(end)"
    }
}
