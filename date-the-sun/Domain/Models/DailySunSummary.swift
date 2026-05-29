import Foundation

/// The day's sun data shared by the Today and Summary screens.
nonisolated struct DailySunSummary {
    let userName: String
    let uvIndex: Int
    let mood: KiranMood
    let message: String
    let intervals: [SunExposureInterval]
}
