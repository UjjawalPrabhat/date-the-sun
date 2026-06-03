import Foundation
import CoreLocation

/// Get UV Index from REST.
nonisolated struct RESTUVIndexProvider: UVIndexProviding {
    func currentUVIndex(latitude: Double, longitude: Double) async throws -> Int {
        let tz = TimeZone.current.identifier
        
        let token = try await TokenManager.shared.validToken()
        var components = URLComponents(
            string: "https://weatherkit.apple.com/api/v1/weather/en/\(latitude)/\(longitude)"
        )!
        components.queryItems = [
            .init(name: "dataSets", value: "currentWeather"),
            .init(name: "timezone", value: tz),
        ]
        
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoded = try JSONDecoder().decode(WeatherKitResponse.self, from: data)
        return decoded.currentWeather.uvIndex
    }
}

/// Response Model
private struct WeatherKitResponse: Decodable, Sendable {
    let currentWeather: CurrentWeather
}

private struct CurrentWeather: Decodable, Sendable {
    let uvIndex: Int
}
