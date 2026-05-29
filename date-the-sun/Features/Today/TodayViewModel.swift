import Foundation
import Combine

@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var greeting: String = ""
    @Published private(set) var userName: String = ""
    @Published private(set) var uvIndex: Int = 0
    @Published private(set) var mood: KiranMood = .neutral
    @Published private(set) var message: String = ""

    private let greetingProvider: GreetingProviding
    private let sunDataProvider: SunDataProviding

    init(
        greetingProvider: GreetingProviding = GreetingProvider(),
        sunDataProvider: SunDataProviding = MockSunDataProvider()
    ) {
        self.greetingProvider = greetingProvider
        self.sunDataProvider = sunDataProvider
        load()
    }

    func load(now: Date = Date()) {
        let summary = sunDataProvider.todaySummary()
        greeting = greetingProvider.greeting(at: now)
        userName = summary.userName
        uvIndex = summary.uvIndex
        mood = summary.mood
        message = summary.message
    }
}
