import Foundation

/// Supplies the current UV index (0–11+) for a coordinate.
nonisolated protocol UVIndexProviding {
    func currentUVIndex(latitude: Double, longitude: Double) async throws -> Int
}

/// A fixed UV index for previews, tests, and as an offline fallback.
nonisolated struct StaticUVIndexProvider: UVIndexProviding {
    var value: Int = 4
    func currentUVIndex(latitude: Double, longitude: Double) async throws -> Int { value }
}
