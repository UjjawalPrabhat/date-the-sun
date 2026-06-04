import SwiftUI
import SwiftData

@main
struct date_the_sunApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LocationEntry.self,
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
    
    init() { AppFont.registerBundledFonts() }
    
    @State private var locationTracker: LocationTracker?
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    locationTracker = LocationTracker(modelContext: sharedModelContainer.mainContext)
                    locationTracker?.start()
                }
        }
        .modelContainer(sharedModelContainer)
        
    }
}
