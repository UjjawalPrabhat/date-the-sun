import Foundation

/// Supplies a day's indoor/outdoor intervals, where "outdoor" is time the
/// device measured as spent in daylight.
nonisolated protocol DaylightExposureProviding {
    /// Intervals for the given day, or `nil` if unavailable (no permission / no data).
    func intervals(on date: Date) async -> [SunExposureInterval]?
}

/// A fixed, balanced day for previews, tests, and as a fallback.
nonisolated struct MockDaylightProvider: DaylightExposureProviding {
    func intervals(on date: Date) async -> [SunExposureInterval]? { SunExposureInterval.sampleDay }
}
