import Foundation
import SwiftData

/// Daily Summary
/// Uses `HMMObservation` to determine user is outdoor or indoor range, uv index, and time.
@Model
class DailySunSummary: Identifiable {
    var date: Date                      /// Date of this summary
    var score: Double                   /// Score from scoring UV Dose calculator
    var wearSunscreen: Bool             /// If the user wore sunscreen this day
    var wearProtectiveClothing: Bool    /// If the user wore protective clothing this day
    var totalOutdoorMinutes: Double     /// total of outdoor time
    var peakUVIndex: Int                /// peak index across all observations that day
    var averageUVIndex: Double          /// average index across all observations that day
    var observationCount: Int           /// number of HMMObservations that day

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

    /// An all-zero summary for `date`, used when the user logs protection before
    /// the day's summary has been computed.
    static func empty(for date: Date) -> DailySunSummary {
        DailySunSummary(
            date: date, score: 0, wearSunscreen: false, wearProtectiveClothing: false,
            totalOutdoorMinutes: 0, peakUVIndex: 0, averageUVIndex: 0, observationCount: 0
        )
    }
}
