import Foundation

/// Lightweight dependency container shared across the app. Defaults to mock
/// data sources; swap these for real implementations as features land.
nonisolated struct AppDependencies {
    let greetingProvider: GreetingProviding
    let sunDataProvider: SunDataProviding

    init(
        greetingProvider: GreetingProviding = GreetingProvider(),
        sunDataProvider: SunDataProviding = MockSunDataProvider()
    ) {
        self.greetingProvider = greetingProvider
        self.sunDataProvider = sunDataProvider
    }

    @MainActor
    func makeTodayViewModel() -> TodayViewModel {
        TodayViewModel(greetingProvider: greetingProvider, sunDataProvider: sunDataProvider)
    }

    @MainActor
    func makeSummaryViewModel() -> SummaryViewModel {
        SummaryViewModel(sunDataProvider: sunDataProvider)
    }
}
