import Foundation
import SwiftData

/// Daily Summary
/// Uses `HMMObservation` to determine user is outdoor or indoor range, uv index, and time.
@Model
class DailySunSummary {
    var date: Date
    var score: Double
    var wearSunscreen: Bool
    var wearProtectiveClothing: Bool
    var rawUVDose: Double
    var effectiveUVDose: Double
    var totalOutdoorMinutes: Double
    var peakUVIndex: Int
    var averageUVIndex: Double
    var observationCount: Int /// amount of data for HMMObservation of that day
    
    init(date: Date, score: Double, wearSunscreen: Bool, wearProtectiveClothing: Bool, rawUVDose: Double, effectiveUVDose: Double, totalOutdoorMinutes: Double, peakUVIndex: Int, averageUVIndex: Double, observationCount: Int) {
        self.date = date
        self.score = score
        self.wearSunscreen = wearSunscreen
        self.wearProtectiveClothing = wearProtectiveClothing
        self.rawUVDose = rawUVDose
        self.effectiveUVDose = effectiveUVDose
        self.totalOutdoorMinutes = totalOutdoorMinutes
        self.peakUVIndex = peakUVIndex
        self.averageUVIndex = averageUVIndex
        self.observationCount = observationCount
    }
}

