import Foundation

/// The day's sun data shared by the Today and Summary screens.
nonisolated struct DailySunSummary {
    let userName: String
    let uvIndex: Int
    let mood: KiranMood
    let message: String          // contextual line shown on the Today screen
    let headline: String         // bold hero line shown on the Summary screen
    let intervals: [SunExposureInterval]
    let protectionItems: [ProtectionItem]
}
