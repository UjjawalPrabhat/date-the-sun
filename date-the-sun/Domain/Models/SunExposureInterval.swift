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
    /// A representative, balanced day used by previews and the mock data source:
    /// mostly indoors with a morning and a midday spell outside (~2h outdoors).
    static let sampleDay: [SunExposureInterval] = [
        .init(isOutdoor: false, startMinute: 0,    endMinute: 390),   // overnight
        .init(isOutdoor: true,  startMinute: 420,  endMinute: 480),   // morning walk
        .init(isOutdoor: false, startMinute: 510,  endMinute: 750),   // indoors
        .init(isOutdoor: true,  startMinute: 780,  endMinute: 840),   // midday outside
        .init(isOutdoor: false, startMinute: 870,  endMinute: 1440),  // evening / night
    ]
}
