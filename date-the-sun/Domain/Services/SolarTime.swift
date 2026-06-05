//
//  SolarTime.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

import Foundation
import CoreLocation
import SwiftData

class SolarTime {
    static func getSolarTimeToday(latitude: Double, longitude: Double) async throws -> SolarTimeResponse {
        let tz = TimeZone.current.identifier
        let token = try await TokenManager.shared.validToken()
        var components = URLComponents(
            string: "https://weatherkit.apple.com/api/v1/weather/en/\(latitude)/\(longitude)"
        )!
        /// Construct query
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        components.queryItems = [
            .init(name: "dataSets", value: "forecastDaily"),
            .init(name: "timezone", value: tz),
            URLQueryItem(name: "dailyStart", value: iso.string(from: today)), /// Specify only for today
            URLQueryItem(name: "dailyEnd", value: iso.string(from: tomorrow)), /// -
        ]
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(WeatherResponse.self, from: data)
        guard let day = decoded.forecastDaily.days.first else {
            throw URLError(.cannotParseResponse)
        }
        print("Getting Solar Time - Sunrise:\(day.sunrise)  Sunset:\(day.sunset)")
        return SolarTimeResponse(sunrise: day.sunrise, sunset: day.sunset)
    }
}

struct SolarTimeResponse {
    let sunrise: Date
    let sunset: Date
}

struct WeatherResponse: Decodable, Sendable {
    let forecastDaily: ForecastDaily
}

struct ForecastDaily: Decodable, Sendable {
    let days: [ForecastDay]
}

struct ForecastDay: Decodable, Sendable {
    let sunrise: Date
    let sunset: Date
}

@ModelActor
actor SolarTimeService {
    func fetchAndStore(for date: Date, latitude: Double, longitude: Double) async throws {
        /// Guard against double entry
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let descriptor = FetchDescriptor<SunriseSunsetSchedule>(
            predicate: #Predicate { $0.sunrise >= startOfDay && $0.sunrise < endOfDay }
        )
        let existing = try modelContext.fetch(descriptor)
        guard existing.isEmpty else {
            print("Solar Time already stored for today")
            return
        }
        let data = try await SolarTime.getSolarTimeToday(latitude: latitude, longitude: longitude)
        /// Insert data
        let entry = SunriseSunsetSchedule(sunrise: data.sunrise, sunset: data.sunset)
        modelContext.insert(entry)
        try modelContext.save()
    }
}
