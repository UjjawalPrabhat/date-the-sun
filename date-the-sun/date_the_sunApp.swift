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
            HMMObservation.self,
            DailySunSummary.self,
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
        let container = sharedModelContainer
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "dev.heryan.date-the-sun.hmm-viterbi",
            using: nil
        ) { task in
            Task {
                await HMMBackgroundRunner.run(modelContainer: container)
                task.setTaskCompleted(success: true)
            }
        }
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "dev.heryan.date-the-sun.daily-summary",
            using: nil
        ) { task in
            Task {
                await DailySummaryBackgroundRunner.run(
                    modelContainer: container,
                    protection: .init(wearingSunscreen: false, wearingProtectiveClothing: false)
                )
                task.setTaskCompleted(success: true)
            }
        }
        date_the_sunApp.scheduleHMMViterbi()
        date_the_sunApp.scheduleDailySummary()
    }
    
    @State private var locationTracker: LocationTracker?
    
    var body: some Scene {
        WindowGroup {
            RootView(modelContainer: sharedModelContainer)
                .onAppear {
                    locationTracker = LocationTracker(modelContainer: sharedModelContainer)
                    locationTracker?.start()
#if DEBUG
                    preloadTestData(container: sharedModelContainer)
                    Task {
                        await HMMBackgroundRunner.run(modelContainer: sharedModelContainer)
                        await DailySummaryBackgroundRunner.run(
                            modelContainer: sharedModelContainer,
                            protection: .init(wearingSunscreen: false, wearingProtectiveClothing: false)
                        )
                    }
#endif
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
#if DEBUG
    private func preloadTestData(container: ModelContainer) {
        let context = ModelContext(container)
        
        // Guard on HMMObservation — if any exist, both tables are already seeded
        let descriptor = FetchDescriptor<HMMObservation>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else {
            Logger.app.debug("Test data already loaded, skipping")
            return
        }
        
        let generated = HMMTestDataGenerator.generate(observationDaysBack: 7)
        
        generated.observations.forEach { dto in
            let obs = HMMObservation(
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
                timestamp: dto.timestamp,
                uvIndex: dto.uvIndex
            )
            context.insert(obs)
        }
        
        generated.summaries.forEach { dto in
            let summary = DailySunSummary(
                date: dto.date,
                score: dto.score,
                wearSunscreen: dto.wearSunscreen,
                wearProtectiveClothing: dto.wearProtectiveClothing,
                rawUVDose: dto.rawUVDose,
                effectiveUVDose: dto.effectiveUVDose,
                totalOutdoorMinutes: dto.totalOutdoorMinutes,
                peakUVIndex: dto.peakUVIndex,
                averageUVIndex: dto.averageUVIndex,
                observationCount: dto.observationCount
            )
            context.insert(summary)
        }
        
        try? context.save()
        Logger.app.info("Generated \(generated.observations.count) observations, \(generated.summaries.count) daily summaries")
    }
#endif
    
    nonisolated static func scheduleHMMViterbi() {
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
    
    nonisolated static func scheduleDailySummary() {
        let request = BGAppRefreshTaskRequest(identifier: "dev.heryan.date-the-sun.daily-summary")
        request.earliestBeginDate = Calendar.current.nextDate(
            after: .now,
            matching: DateComponents(hour: 3, minute: 30),
            matchingPolicy: .nextTime
        )
        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.app.info("Daily summary scheduled")
        } catch {
            Logger.app.error("Failed to schedule daily summary: \(error)")
        }
    }
}
