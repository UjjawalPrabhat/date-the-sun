import BackgroundTasks
import SwiftUI
import SwiftData

@main
struct date_the_sunApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LocationEntry.self,
            IndoorOutdoorEntry.self,
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
                    scheduleBackgroundRefresh()
                }
        }
        .modelContainer(sharedModelContainer)
        .backgroundTask(.appRefresh("dev.heryan.date-the-sun.print")) {
            print("Background task fired at \(Date.now)")
            scheduleBackgroundRefresh()
        }
    }
}

func scheduleBackgroundRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "dev.heryan.date-the-sun.print")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 5)
    do {
        try BGTaskScheduler.shared.submit(request)
        print("✅ Background task scheduled")
    } catch {
        print("Could not schedule app refresh: \(error)")
    }
}
