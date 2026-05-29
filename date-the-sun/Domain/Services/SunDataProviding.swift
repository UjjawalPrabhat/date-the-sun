import Foundation

/// Supplies the day's and week's sun summaries. The seam where a real UV /
/// location / HealthKit data source plugs in later.
nonisolated protocol SunDataProviding {
    func todaySummary() -> DailySunSummary
    func weeklySummary() -> WeeklySunSummary
}

nonisolated struct MockSunDataProvider: SunDataProviding {
    func todaySummary() -> DailySunSummary {
        DailySunSummary(
            userName: "UJ",
            uvIndex: 4,
            mood: .happy,
            message: "Sun's out, it's gentle today. Perfect weather for a light stroll.",
            headline: "What a happy day — especially with you",
            intervals: SunExposureInterval.sampleDay,
            protectionItems: [
                .init(title: "Sunscreen",
                      subtitle: "Apply when going outside",
                      systemImage: "drop.fill",
                      isCompleted: true),
                .init(title: "Protective Clothing",
                      subtitle: "Use hat and long-sleeved shirt",
                      systemImage: "tshirt.fill",
                      isCompleted: false),
            ]
        )
    }

    func weeklySummary() -> WeeklySunSummary {
        let labels = ["M", "T", "W", "T", "F", "S", "S"]
        let outdoor: [Double] = [90, 150, 60, 200, 120, 240, 80]
        let indoor: [Double]  = [330, 270, 360, 220, 300, 180, 340]

        let days = zip(labels, zip(outdoor, indoor)).map { label, mins in
            DayExposureStat(weekdayLabel: label, outdoorMinutes: mins.0, indoorMinutes: mins.1)
        }

        return WeeklySunSummary(
            weekLabel: "This Week",
            mood: .calm,
            headline: "A well-balanced week — keep it up",
            days: days,
            protection: [
                .init(title: "Sunscreen",
                      systemImage: "drop.fill",
                      completedDays: [true, true, false, true, true, true, false]),
                .init(title: "Protective Clothing",
                      systemImage: "tshirt.fill",
                      completedDays: [false, true, true, false, true, false, false]),
            ]
        )
    }
}
