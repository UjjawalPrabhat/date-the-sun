import Foundation
import Combine

@MainActor
final class SummaryViewModel: ObservableObject {
    @Published private(set) var intervals: [SunExposureInterval] = []

    private let sunDataProvider: SunDataProviding

    init(sunDataProvider: SunDataProviding = MockSunDataProvider()) {
        self.sunDataProvider = sunDataProvider
        load()
    }

    func load() {
        intervals = sunDataProvider.todaySummary().intervals
    }
}
