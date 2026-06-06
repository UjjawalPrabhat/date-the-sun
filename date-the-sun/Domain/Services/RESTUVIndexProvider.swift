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

    func uvPeakWindow(latitude: Double, longitude: Double, date: Date) async throws -> (startMinute: Double, endMinute: Double)? {
        let tz = TimeZone.current.identifier
        let token = try await TokenManager.shared.validToken()

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let formatter = ISO8601DateFormatter()
        var components = URLComponents(
            string: "https://weatherkit.apple.com/api/v1/weather/en/\(latitude)/\(longitude)"
        )!
        components.queryItems = [
            .init(name: "dataSets", value: "forecastHourly"),
            .init(name: "timezone", value: tz),
            .init(name: "hourlyStart", value: formatter.string(from: startOfDay)),
            .init(name: "hourlyEnd", value: formatter.string(from: endOfDay)),
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(HourlyWeatherKitResponse.self, from: data)

        let peakHours = decoded.forecastHourly.hours.filter { $0.uvIndex >= 6 }
        guard let first = peakHours.first, let last = peakHours.last else { return nil }

        let peakEnd = calendar.date(byAdding: .hour, value: 1, to: last.forecastStart)!
        return (startMinute: minuteOfDay(first.forecastStart), endMinute: minuteOfDay(peakEnd))
    }

    private func minuteOfDay(_ date: Date) -> Double {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return Double((comps.hour ?? 0) * 60 + (comps.minute ?? 0))
    }
}

// MARK: - Response Models

private struct WeatherKitResponse: Decodable, Sendable {
    let currentWeather: CurrentWeather
}

private struct CurrentWeather: Decodable, Sendable {
    let uvIndex: Int
}

private struct HourlyWeatherKitResponse: Decodable, Sendable {
    let forecastHourly: HourlyForecast
}

private struct HourlyForecast: Decodable, Sendable {
    let hours: [HourlyWeather]
}

private struct HourlyWeather: Decodable, Sendable {
    let forecastStart: Date
    let uvIndex: Int
}
