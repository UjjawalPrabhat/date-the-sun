import Foundation
import SwiftData

/// Daily Summary
/// Uses `HMMObservation` to determine user is outdoor or indoor range, uv index, and time.
@Model
class DailySunSummary: Identifiable {
    var date: Date                      /// Date of this summary
    var score: Double                   /// Score from scoring UV Dose calculator
    var wearSunscreen: Bool             /// If in this day user wears sunscreen
    var wearProtectiveClothing: Bool    /// If in this day user wears sunscreen
    var totalOutdoorMinutes: Double     /// total of outdoor time
    var peakUVIndex: Int                /// peak index across alll observations that day
    var averageUVIndex: Double          /// average index across all observations that day
    var observationCount: Int           /// amount of data for HMMObservation of that day
    
    init(date: Date, score: Double, wearSunscreen: Bool, wearProtectiveClothing: Bool, totalOutdoorMinutes: Double, peakUVIndex: Int, averageUVIndex: Double, observationCount: Int) {
        self.date = date
        self.score = score
        self.wearSunscreen = wearSunscreen
        self.wearProtectiveClothing = wearProtectiveClothing
        self.totalOutdoorMinutes = totalOutdoorMinutes
        self.peakUVIndex = peakUVIndex
        self.averageUVIndex = averageUVIndex
        self.observationCount = observationCount
    }
}
