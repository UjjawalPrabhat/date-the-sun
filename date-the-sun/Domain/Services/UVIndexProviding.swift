import Foundation

/// Supplies the current UV index (0–11+) for a coordinate.
nonisolated protocol UVIndexProviding {
    func currentUVIndex(latitude: Double, longitude: Double) async throws -> Int
    /// Returns the contiguous window (start/end minutes-of-day) where UV ≥ 6 on the given date, or nil if there is no such window.
    func uvPeakWindow(latitude: Double, longitude: Double, date: Date) async throws -> (startMinute: Double, endMinute: Double)?
    /// Returns the peak (maximum) UV index forecast for today.
    func maxUVIndexToday(latitude: Double, longitude: Double) async throws -> Int
}

/// A fixed UV index for previews, tests, and as an offline fallback.
nonisolated struct StaticUVIndexProvider: UVIndexProviding {
    var value: Int = 4
    func currentUVIndex(latitude: Double, longitude: Double) async throws -> Int { value }
    func uvPeakWindow(latitude: Double, longitude: Double, date: Date) async throws -> (startMinute: Double, endMinute: Double)? {
        // 10 am – 2 pm preview window
        return (startMinute: 600, endMinute: 840)
    }
    func maxUVIndexToday(latitude: Double, longitude: Double) async throws -> Int { value }
}
