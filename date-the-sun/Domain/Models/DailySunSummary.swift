import Foundation

/// The day's raw sun data. Mood is derived from these by `RelationshipScore`.
nonisolated struct DailySunSummary {
    let userName: String
    let uvIndex: Int
    let intervals: [SunExposureInterval]
    let protectionItems: [ProtectionItem]
}
