import Foundation

/// Supplies the day's sun summary. The seam where a real UV / location /
/// HealthKit data source plugs in later.
nonisolated protocol SunDataProviding {
    func todaySummary() -> DailySunSummary
}

nonisolated struct MockSunDataProvider: SunDataProviding {
    func todaySummary() -> DailySunSummary {
        DailySunSummary(
            userName: "UJ",
            uvIndex: 4,
            mood: .neutral,
            message: "Sun's out, it's gentle today. Perfect weather for a light stroll.",
            intervals: SunExposureInterval.sampleDay
        )
    }
}
