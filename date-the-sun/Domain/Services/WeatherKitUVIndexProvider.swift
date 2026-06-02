import Foundation
import CoreLocation
import WeatherKit

/// Live UV index from Apple WeatherKit.
///
/// Requires the **WeatherKit** capability/entitlement and the WeatherKit
/// service enabled for the App ID in the developer portal. Without it,
/// `WeatherService` throws and callers fall back to a default.
nonisolated struct WeatherKitUVIndexProvider: UVIndexProviding {
    func currentUVIndex(latitude: Double, longitude: Double) async throws -> Int {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let weather = try await WeatherService.shared.weather(for: location)
        return weather.currentWeather.uvIndex.value
    }
}
