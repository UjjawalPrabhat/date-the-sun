import Foundation

/// A contiguous span of indoor or outdoor time within a single day,
/// expressed in absolute minutes (0–1440).
nonisolated struct SunExposureInterval: Identifiable {
    let id = UUID()
    let isOutdoor: Bool
    let startMinute: Double
    let endMinute: Double
}

nonisolated extension SunExposureInterval {
    /// A representative day used by previews and the mock data source.
    static let sampleDay: [SunExposureInterval] = [
        .init(isOutdoor: false, startMinute: 1 * 60,        endMinute: 4 * 60),
        .init(isOutdoor: true,  startMinute: 4 * 60,        endMinute: 4 * 60 + 30),
        .init(isOutdoor: false, startMinute: 4 * 60 + 30,   endMinute: 6 * 60 + 30),
        .init(isOutdoor: true,  startMinute: 6 * 60 + 30,   endMinute: 9 * 60 + 30),
        .init(isOutdoor: false, startMinute: 9 * 60 + 30,   endMinute: 11 * 60),
    ]
}
