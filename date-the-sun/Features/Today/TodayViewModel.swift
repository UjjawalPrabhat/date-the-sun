import Foundation
import Combine
import WeatherKit
import CoreLocation

// MARK: - Weather Service
class AppleWeatherService {
    /// Fetches the native Weather object from Apple WeatherKit
    func fetchAppleWeather(latitude: Double = -8.4095, longitude: Double = 115.1889) async throws -> WeatherKit.Weather {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        return try await WeatherService.shared.weather(for: location)
    }
}

// MARK: - View Model
@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var greeting: String = ""
    @Published private(set) var userName: String = ""
    @Published private(set) var uvIndex: Int = 0
    @Published private(set) var mood: KiranMood = .neutral
    @Published private(set) var message: String = ""
    @Published private(set) var isLoading: Bool = false

    private let greetingProvider: GreetingProviding
    private let sunDataProvider: SunDataProviding
    private let weatherService = AppleWeatherService()

    init(
        greetingProvider: GreetingProviding = GreetingProvider(),
        sunDataProvider: SunDataProviding = MockSunDataProvider()
    ) {
        self.greetingProvider = greetingProvider
        self.sunDataProvider = sunDataProvider
        
        // Load initial local content configurations
        loadLocalData()
        
        // Trigger the asynchronous live WeatherKit fetch
        Task {
            await fetchLiveWeather()
        }
    }

    /// Loads the standard user configurations and local greetings
    func loadLocalData(now: Date = Date()) {
        let summary = sunDataProvider.todaySummary()
        greeting = greetingProvider.greeting(at: now)
        userName = summary.userName
        mood = summary.mood
        message = summary.message
    }

    /// Safely handles fetching live UV data from WeatherKit
    private func fetchLiveWeather() async {
        isLoading = true
        do {
            // Using Bali coordinates by default
            let weatherData = try await weatherService.fetchAppleWeather(latitude: -8.4095, longitude: 115.1889)
            
            let currentHourDate = Date()
            let hourlyForecast = weatherData.hourlyForecast
            
            // Find the hour segment matching current time context
            let matchingHour = hourlyForecast.first { hourEntry in
                Calendar.current.isDate(hourEntry.date, equalTo: currentHourDate, toGranularity: .hour)
            }
            
            // Extract final integer UV reading
            let liveUV = matchingHour?.uvIndex.value ?? weatherData.currentWeather.uvIndex.value ?? 0
            
            // Update the UI publishing layer
            self.uvIndex = liveUV
            self.isLoading = false
        } catch {
            print("WeatherKit Fetch Error: \(error.localizedDescription)")
            self.isLoading = false
        }
    }

    func reactToTap() {
        let moods = KiranMood.allCases
        let next = moods.firstIndex(of: mood).map { ($0 + 1) % moods.count } ?? 0
        mood = moods[next]
        message = mood.line
    }
}
