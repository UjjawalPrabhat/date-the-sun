import Foundation

/// A latitude/longitude pair.
nonisolated struct Coordinate {
    let latitude: Double
    let longitude: Double

    /// Default fallback used when the device location is unavailable (Bali).
    static let fallback = Coordinate(latitude: -8.4095, longitude: 115.1889)
}

/// Supplies the user's current coordinate, or `nil` if unavailable / denied.
nonisolated protocol LocationProviding {
    func currentLocation() async -> Coordinate?
}

/// A fixed coordinate for previews, tests, and as a fallback.
nonisolated struct StaticLocationProvider: LocationProviding {
    var coordinate: Coordinate = .fallback
    func currentLocation() async -> Coordinate? { coordinate }
}
