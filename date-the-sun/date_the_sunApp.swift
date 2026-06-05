import BackgroundTasks
import SwiftUI
import SwiftData
import CoreLocation
import OSLog

@main
struct date_the_sunApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LocationEntry.self,
            SunriseSunsetSchedule.self,
            HMMObservation.self,
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
            RootView(modelContainer: sharedModelContainer)
                .onAppear {
                    locationTracker = LocationTracker(modelContainer: sharedModelContainer)
                    locationTracker?.start()
                    scheduleHMMViterbi()
                    scheduleDailySummary()
#if DEBUG
                    preloadTestData(container: sharedModelContainer)
                    
                    Task {
                        await HMMBackgroundRunner.run(modelContainer: sharedModelContainer)
                    }
#endif
                }
        }
        .modelContainer(sharedModelContainer)
        .backgroundTask(.appRefresh("dev.heryan.date-the-sun.hmm-viterbi")) {
            await HMMBackgroundRunner.run(modelContainer: sharedModelContainer)
        }
        .backgroundTask(.appRefresh("dev.heryan.date-the-sun.daily-summary")) {
            /// TODO :  get latest use protection or no
            await DailySummaryBackgroundRunner.run(modelContainer: sharedModelContainer, protection: .init(wearingSunscreen: false, wearingProtectiveClothing: false))
        }
    }
    
#if DEBUG
    private func preloadTestData(container: ModelContainer) {
        let context = ModelContext(container)
        
        // Guard against double insert on every launch
        let descriptor = FetchDescriptor<HMMObservation>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else {
            Logger.app.debug("Test data already loaded, skipping")
            return
        }
        
        guard let url = Bundle.main.url(forResource: "hmm_test_data", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            Logger.app.error("hmm_test_data.json not found in bundle")
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let dtos = try? decoder.decode([HMMObservationDTO].self, from: data) else {
            Logger.app.error("Failed to decode hmm_test_data.json")
            return
        }
        
        dtos.forEach { dto in
            let obs = HMMObservation(from: dto)
            context.insert(obs)
        }
        
        try? context.save()
        Logger.app.info("Loaded \(dtos.count) test observations")
    }
#endif
}

#if DEBUG
struct HMMObservationDTO: Decodable {
    var classifierLabel: String
    var classifierConfidence: Double
    var provider: String
    var aLabel: String?
    var aConfidence: Double?
    var gLabel: String?
    var gConfidence: Double?
    var speed: Double
    var horizontalAccuracy: Double
    var isMeasured: Bool
    var timestamp: Date
    // ignored in HMMObservation, just for debug validation
    var trueState: String?  // mapped from "_trueState" in JSON
    
    enum CodingKeys: String, CodingKey {
        case classifierLabel, classifierConfidence, provider
        case aLabel, aConfidence, gLabel, gConfidence
        case speed, horizontalAccuracy, isMeasured, timestamp
        case trueState = "_trueState"
    }
}
#endif

#if DEBUG
extension HMMObservation {
    convenience init(from dto: HMMObservationDTO) {
        self.init(
            classifierLabel: dto.classifierLabel,
            classifierConfidence: dto.classifierConfidence,
            provider: dto.provider,
            aLabel: dto.aLabel,
            aConfidence: dto.aConfidence,
            gLabel: dto.gLabel,
            gConfidence: dto.gConfidence,
            speed: dto.speed,
            horizontalAccuracy: dto.horizontalAccuracy,
            isMeasured: dto.isMeasured,
            timestamp: dto.timestamp
        )
    }
}
#endif

nonisolated func scheduleHMMViterbi() {
    let request = BGAppRefreshTaskRequest(identifier: "dev.heryan.date-the-sun.hmm-viterbi")
    request.earliestBeginDate = Calendar.current.nextDate(
        after: .now,
        matching: DateComponents(hour: 3),
        matchingPolicy: .nextTime
    )
    do {
        try BGTaskScheduler.shared.submit(request)
        Logger.app.info("HMM Viterbi scheduled")
    } catch {
        Logger.app.error("Failed to schedule HMM Viterbi: \(error)")
    }
}

nonisolated func scheduleDailySummary() {
    let request = BGAppRefreshTaskRequest(identifier: "dev.heryan.date-the-sun.daily-summary")
    request.earliestBeginDate = Calendar.current.nextDate(
        after: .now,
        matching: DateComponents(hour: 3, minute: 30), // 3.30 after HMM
        matchingPolicy: .nextTime
    )
    do {
        try BGTaskScheduler.shared.submit(request)
        Logger.app.info("Daily summary scheduled")
    } catch {
        Logger.app.error("Failed to schedule daily summary: \(error)")
    }
}
