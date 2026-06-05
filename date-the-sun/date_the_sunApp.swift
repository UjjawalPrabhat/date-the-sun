import BackgroundTasks
import SwiftUI
import SwiftData
import CoreLocation

@main
struct date_the_sunApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LocationEntry.self,
            SunriseSunsetSchedule.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        AppFont.registerBundledFonts()
    }
    
    @State private var locationTracker: LocationTracker?
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    locationTracker = LocationTracker(modelContainer: sharedModelContainer)
                    locationTracker?.start()
                    scheduleSunsetSunrise()
                }
        }
        .modelContainer(sharedModelContainer)
        .backgroundTask(.appRefresh("dev.heryan.date-the-sun.schedule-sunset-sunrise")) {
            scheduleSunsetSunrise() // reschedule for next day
            guard let location = await LocationProvider.fetchCurrentLocation() else { return }
            let service = SolarTimeService(modelContainer: sharedModelContainer)
            try? await service.fetchAndStore(for: .now, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        .backgroundTask(.appRefresh("dev.heryan.date-the-sun.hmm-viterbi")) {
            await HMMBackgroundRunner.run(modelContainer: sharedModelContainer)
        }
    }
}

nonisolated func scheduleSunsetSunrise() {
    let calendar = Calendar.current
    /// Target 4 AM to set today's sunset sunrise
    var components = calendar.dateComponents([.year, .month, .day], from: .now)
    components.hour = 4
    components.minute = 0
    components.second = 0
    
    guard let tomorrow = calendar.date(from: components).flatMap({
        calendar.date(byAdding: .day, value: 1, to: $0)
    }) else { return }
    
    let request = BGAppRefreshTaskRequest(identifier: "dev.heryan.date-the-sun.schedule-sunset-sunrise")
    request.earliestBeginDate = tomorrow
    do {
        try BGTaskScheduler.shared.submit(request)
        print("Sunset sunrise scheduled for tomorrow")
    } catch {
        print("Failed to schedule Sunset Sunrise: \(error)")
    }
}
