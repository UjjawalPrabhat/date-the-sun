import BackgroundTasks
import SwiftUI
import SwiftData
import CoreLocation
import OSLog

@main
struct date_the_sunApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Shared with the Notification Content Extension via App Group (see SharedStore).
    var sharedModelContainer: ModelContainer { SharedStore.container }
    
    init() {
        AppFont.registerBundledFonts()
        let container = sharedModelContainer
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "dev.heryan.date-the-sun.hmm-viterbi",
            using: nil
        ) { task in
            let work = Task {
                await HMMBackgroundRunner.run(modelContainer: container)
                await MainActor.run { BackgroundScheduler.scheduleHMMViterbi() }
                task.setTaskCompleted(success: true)
            }
            task.expirationHandler = {
                work.cancel()
                task.setTaskCompleted(success: false)
            }
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "dev.heryan.date-the-sun.daily-summary",
            using: nil
        ) { task in
            let work = Task {
                await DailySummaryBackgroundRunner.run(
                    modelContainer: container,
                    protection: .init(wearingSunscreen: false, wearingProtectiveClothing: false) // by default false first initiating
                )
                await MainActor.run { BackgroundScheduler.scheduleDailySummary() }
                task.setTaskCompleted(success: true)
            }
            task.expirationHandler = {
                work.cancel()
                task.setTaskCompleted(success: false)
            }
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "dev.heryan.date-the-sun.daily-sun-summary-init",
            using: nil
        ) { task in
            let work = Task {
                await DailySunSummaryInitBackgroundRunner.run(modelContainer: container)
                await MainActor.run { BackgroundScheduler.scheduleDailySunSummaryInit() }
                task.setTaskCompleted(success: true)
            }
            task.expirationHandler = {
                work.cancel()
                task.setTaskCompleted(success: false)
            }
        }
    }
    
    @State private var locationTracker: LocationTracker?
    
    var body: some Scene {
        WindowGroup {
            RootView(modelContainer: sharedModelContainer)
                .onAppear {
                    locationTracker = LocationTracker(modelContainer: sharedModelContainer)
                    locationTracker?.start()
                    Task { await locationTracker?.recover() }
                    BackgroundScheduler.scheduleHMMViterbi()
                    BackgroundScheduler.scheduleDailySummary()
                    BackgroundScheduler.scheduleDailySunSummaryInit()
#if DEBUG
                    preloadTestData(container: sharedModelContainer)
                    Task {
                        await HMMBackgroundRunner.run(modelContainer: sharedModelContainer)
                        await backfillTestSummaries(container: sharedModelContainer)
                        await DailySummaryBackgroundRunner.run(
                            modelContainer: sharedModelContainer,
                            protection: .init(wearingSunscreen: false, wearingProtectiveClothing: false)
                        )
                    }
#endif
                }
                .debugSheet(modelContainer: sharedModelContainer)
        }
        .modelContainer(sharedModelContainer)
    }
}


#if DEBUG
private func preloadTestData(container: ModelContainer) {
    let context = ModelContext(container)
    
    /// skip if exist
    let descriptor = FetchDescriptor<HMMObservation>()
    let existing = try? context.fetch(descriptor)
    guard existing?.isEmpty ?? true else {
        Logger.app.info("Test data already present, skipping insertion")
        return
    }
    
    Logger.app.info("Inserting test data")

    let calendar = Calendar.current
    let anchor = calendar.startOfDay(
        for: calendar.date(byAdding: .day, value: -7, to: Date())!
    )

    func ts(_ dayOffset: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(
            byAdding: .second,
            value: dayOffset * 86400 + hour * 3600 + minute * 60,
            to: anchor
        )!
    }

    let observations: [HMMObservation] = [

        // MARK: - Day 0 (anchor day) — mostly indoor, one midday outing
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.88, provider: "AG", aLabel: "indoor",  aConfidence: 0.88, gLabel: "indoor",  gConfidence: 0.87, speed: 0.0, horizontalAccuracy: 10.0, isMeasured: true, timestamp: ts(0, 8),    uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.87, provider: "AG", aLabel: "indoor",  aConfidence: 0.87, gLabel: "indoor",  gConfidence: 0.86, speed: 0.0, horizontalAccuracy: 9.0,  isMeasured: true, timestamp: ts(0, 10),   uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.86, provider: "AG", aLabel: "indoor",  aConfidence: 0.86, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 8.0,  isMeasured: true, timestamp: ts(0, 12),   uvIndex: 3), // window UV
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.89, provider: "AG", aLabel: "outdoor", aConfidence: 0.89, gLabel: "outdoor", gConfidence: 0.88, speed: 1.2, horizontalAccuracy: 4.0,  isMeasured: true, timestamp: ts(0, 13),   uvIndex: 6),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.91, provider: "AG", aLabel: "outdoor", aConfidence: 0.91, gLabel: "outdoor", gConfidence: 0.90, speed: 0.8, horizontalAccuracy: 3.5,  isMeasured: true, timestamp: ts(0, 13, 30), uvIndex: 7),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.85, provider: "AG", aLabel: "indoor",  aConfidence: 0.85, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 8.0,  isMeasured: true, timestamp: ts(0, 15, 30), uvIndex: 2),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.87, provider: "AG", aLabel: "indoor",  aConfidence: 0.87, gLabel: "indoor",  gConfidence: 0.86, speed: 0.0, horizontalAccuracy: 9.0,  isMeasured: true, timestamp: ts(0, 18),   uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.88, provider: "AG", aLabel: "indoor",  aConfidence: 0.88, gLabel: "indoor",  gConfidence: 0.87, speed: 0.0, horizontalAccuracy: 10.0, isMeasured: true, timestamp: ts(0, 22),   uvIndex: 0),

        // MARK: - Day 1 — longer outdoor stint around noon, high UV
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.87, provider: "AG", aLabel: "indoor",  aConfidence: 0.87, gLabel: "indoor",  gConfidence: 0.86, speed: 0.0, horizontalAccuracy: 9.0,  isMeasured: true, timestamp: ts(1, 7, 30), uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.86, provider: "AG", aLabel: "indoor",  aConfidence: 0.86, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 8.0,  isMeasured: true, timestamp: ts(1, 9),    uvIndex: 0),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.90, provider: "AG", aLabel: "outdoor", aConfidence: 0.90, gLabel: "outdoor", gConfidence: 0.89, speed: 1.5, horizontalAccuracy: 3.0,  isMeasured: true, timestamp: ts(1, 12),   uvIndex: 5),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.92, provider: "AG", aLabel: "outdoor", aConfidence: 0.92, gLabel: "outdoor", gConfidence: 0.91, speed: 1.1, horizontalAccuracy: 2.5,  isMeasured: true, timestamp: ts(1, 12, 30), uvIndex: 8),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.93, provider: "AG", aLabel: "outdoor", aConfidence: 0.93, gLabel: "outdoor", gConfidence: 0.92, speed: 0.9, horizontalAccuracy: 2.0,  isMeasured: true, timestamp: ts(1, 13),   uvIndex: 9),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.85, provider: "AG", aLabel: "indoor",  aConfidence: 0.85, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 7.0,  isMeasured: true, timestamp: ts(1, 14),   uvIndex: 4),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.87, provider: "AG", aLabel: "indoor",  aConfidence: 0.87, gLabel: "indoor",  gConfidence: 0.86, speed: 0.0, horizontalAccuracy: 9.0,  isMeasured: true, timestamp: ts(1, 17),   uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.88, provider: "AG", aLabel: "indoor",  aConfidence: 0.88, gLabel: "indoor",  gConfidence: 0.87, speed: 0.0, horizontalAccuracy: 10.0, isMeasured: true, timestamp: ts(1, 23),   uvIndex: 0),

        // MARK: - Day 2 — early outing, moderate UV, back inside quickly
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.86, provider: "AG", aLabel: "indoor",  aConfidence: 0.86, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 8.0,  isMeasured: true, timestamp: ts(2, 6),    uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.86, provider: "AG", aLabel: "indoor",  aConfidence: 0.86, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 8.0,  isMeasured: true, timestamp: ts(2, 9),    uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.85, provider: "AG", aLabel: "indoor",  aConfidence: 0.85, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 7.0,  isMeasured: true, timestamp: ts(2, 10),   uvIndex: 3),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.90, provider: "AG", aLabel: "outdoor", aConfidence: 0.90, gLabel: "outdoor", gConfidence: 0.89, speed: 1.3, horizontalAccuracy: 3.0,  isMeasured: true, timestamp: ts(2, 11),   uvIndex: 7),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.91, provider: "AG", aLabel: "outdoor", aConfidence: 0.91, gLabel: "outdoor", gConfidence: 0.90, speed: 1.0, horizontalAccuracy: 2.5,  isMeasured: true, timestamp: ts(2, 11, 30), uvIndex: 8),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.85, provider: "AG", aLabel: "indoor",  aConfidence: 0.85, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 7.5,  isMeasured: true, timestamp: ts(2, 12, 30), uvIndex: 5),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.87, provider: "AG", aLabel: "indoor",  aConfidence: 0.87, gLabel: "indoor",  gConfidence: 0.86, speed: 0.0, horizontalAccuracy: 9.0,  isMeasured: true, timestamp: ts(2, 16),   uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.88, provider: "AG", aLabel: "indoor",  aConfidence: 0.88, gLabel: "indoor",  gConfidence: 0.87, speed: 0.0, horizontalAccuracy: 10.0, isMeasured: true, timestamp: ts(2, 21),   uvIndex: 0),

        // MARK: - Day 3 — rest/indoor day, no meaningful outdoor exposure
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.88, provider: "AG", aLabel: "indoor",  aConfidence: 0.88, gLabel: "indoor",  gConfidence: 0.87, speed: 0.0, horizontalAccuracy: 10.0, isMeasured: true, timestamp: ts(3, 8),    uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.88, provider: "AG", aLabel: "indoor",  aConfidence: 0.88, gLabel: "indoor",  gConfidence: 0.87, speed: 0.0, horizontalAccuracy: 9.5,  isMeasured: true, timestamp: ts(3, 9),    uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.87, provider: "AG", aLabel: "indoor",  aConfidence: 0.87, gLabel: "indoor",  gConfidence: 0.86, speed: 0.0, horizontalAccuracy: 9.0,  isMeasured: true, timestamp: ts(3, 10),   uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.87, provider: "AG", aLabel: "indoor",  aConfidence: 0.87, gLabel: "indoor",  gConfidence: 0.86, speed: 0.0, horizontalAccuracy: 9.0,  isMeasured: true, timestamp: ts(3, 15),   uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.88, provider: "AG", aLabel: "indoor",  aConfidence: 0.88, gLabel: "indoor",  gConfidence: 0.87, speed: 0.0, horizontalAccuracy: 10.0, isMeasured: true, timestamp: ts(3, 20),   uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.88, provider: "AG", aLabel: "indoor",  aConfidence: 0.88, gLabel: "indoor",  gConfidence: 0.87, speed: 0.0, horizontalAccuracy: 10.0, isMeasured: true, timestamp: ts(3, 23, 30), uvIndex: 0),

        // MARK: - Day 4 — two outdoor windows, afternoon peak UV
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.87, provider: "AG", aLabel: "indoor",  aConfidence: 0.87, gLabel: "indoor",  gConfidence: 0.86, speed: 0.0, horizontalAccuracy: 9.0,  isMeasured: true, timestamp: ts(4, 7),    uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.86, provider: "AG", aLabel: "indoor",  aConfidence: 0.86, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 8.0,  isMeasured: true, timestamp: ts(4, 10),   uvIndex: 0),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.89, provider: "AG", aLabel: "outdoor", aConfidence: 0.89, gLabel: "outdoor", gConfidence: 0.88, speed: 1.4, horizontalAccuracy: 3.0,  isMeasured: true, timestamp: ts(4, 11),   uvIndex: 4),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.90, provider: "AG", aLabel: "outdoor", aConfidence: 0.90, gLabel: "outdoor", gConfidence: 0.89, speed: 1.1, horizontalAccuracy: 2.5,  isMeasured: true, timestamp: ts(4, 12),   uvIndex: 7),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.85, provider: "AG", aLabel: "indoor",  aConfidence: 0.85, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 8.0,  isMeasured: true, timestamp: ts(4, 13),   uvIndex: 3),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.91, provider: "AG", aLabel: "outdoor", aConfidence: 0.91, gLabel: "outdoor", gConfidence: 0.90, speed: 1.2, horizontalAccuracy: 3.0,  isMeasured: true, timestamp: ts(4, 15),   uvIndex: 8),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.92, provider: "AG", aLabel: "outdoor", aConfidence: 0.92, gLabel: "outdoor", gConfidence: 0.91, speed: 0.9, horizontalAccuracy: 2.5,  isMeasured: true, timestamp: ts(4, 15, 30), uvIndex: 9),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.86, provider: "AG", aLabel: "indoor",  aConfidence: 0.86, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 8.5,  isMeasured: true, timestamp: ts(4, 17),   uvIndex: 2),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.88, provider: "AG", aLabel: "indoor",  aConfidence: 0.88, gLabel: "indoor",  gConfidence: 0.87, speed: 0.0, horizontalAccuracy: 10.0, isMeasured: true, timestamp: ts(4, 22),   uvIndex: 0),

        // MARK: - Day 5 — most outdoor time, extended afternoon session
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.86, provider: "AG", aLabel: "indoor",  aConfidence: 0.86, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 8.0,  isMeasured: true, timestamp: ts(5, 9),    uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.86, provider: "AG", aLabel: "indoor",  aConfidence: 0.86, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 8.0,  isMeasured: true, timestamp: ts(5, 11),   uvIndex: 0),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.90, provider: "AG", aLabel: "outdoor", aConfidence: 0.90, gLabel: "outdoor", gConfidence: 0.89, speed: 1.6, horizontalAccuracy: 3.0,  isMeasured: true, timestamp: ts(5, 12),   uvIndex: 6),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.92, provider: "AG", aLabel: "outdoor", aConfidence: 0.92, gLabel: "outdoor", gConfidence: 0.91, speed: 1.3, horizontalAccuracy: 2.0,  isMeasured: true, timestamp: ts(5, 13),   uvIndex: 9),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.93, provider: "AG", aLabel: "outdoor", aConfidence: 0.93, gLabel: "outdoor", gConfidence: 0.92, speed: 1.1, horizontalAccuracy: 2.0,  isMeasured: true, timestamp: ts(5, 14),   uvIndex: 8),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.91, provider: "AG", aLabel: "outdoor", aConfidence: 0.91, gLabel: "outdoor", gConfidence: 0.90, speed: 0.8, horizontalAccuracy: 2.5,  isMeasured: true, timestamp: ts(5, 15),   uvIndex: 5),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.85, provider: "AG", aLabel: "indoor",  aConfidence: 0.85, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 7.0,  isMeasured: true, timestamp: ts(5, 17),   uvIndex: 2),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.88, provider: "AG", aLabel: "indoor",  aConfidence: 0.88, gLabel: "indoor",  gConfidence: 0.87, speed: 0.0, horizontalAccuracy: 10.0, isMeasured: true, timestamp: ts(5, 22),   uvIndex: 0),

        // MARK: - Day 6 — yesterday, moderate outing + window UV
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.87, provider: "AG", aLabel: "indoor",  aConfidence: 0.87, gLabel: "indoor",  gConfidence: 0.86, speed: 0.0, horizontalAccuracy: 9.0,  isMeasured: true, timestamp: ts(6, 8),    uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.86, provider: "AG", aLabel: "indoor",  aConfidence: 0.86, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 8.0,  isMeasured: true, timestamp: ts(6, 10),   uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.85, provider: "AG", aLabel: "indoor",  aConfidence: 0.85, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 7.0,  isMeasured: true, timestamp: ts(6, 11),   uvIndex: 3),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.90, provider: "AG", aLabel: "outdoor", aConfidence: 0.90, gLabel: "outdoor", gConfidence: 0.89, speed: 1.4, horizontalAccuracy: 3.0,  isMeasured: true, timestamp: ts(6, 12, 30), uvIndex: 7),
        HMMObservation(classifierLabel: "outdoor", classifierConfidence: 0.92, provider: "AG", aLabel: "outdoor", aConfidence: 0.92, gLabel: "outdoor", gConfidence: 0.91, speed: 1.0, horizontalAccuracy: 2.0,  isMeasured: true, timestamp: ts(6, 13, 30), uvIndex: 8),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.85, provider: "AG", aLabel: "indoor",  aConfidence: 0.85, gLabel: "indoor",  gConfidence: 0.85, speed: 0.0, horizontalAccuracy: 7.5,  isMeasured: true, timestamp: ts(6, 14, 30), uvIndex: 4),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.87, provider: "AG", aLabel: "indoor",  aConfidence: 0.87, gLabel: "indoor",  gConfidence: 0.86, speed: 0.0, horizontalAccuracy: 9.0,  isMeasured: true, timestamp: ts(6, 18),   uvIndex: 0),
        HMMObservation(classifierLabel: "indoor",  classifierConfidence: 0.88, provider: "AG", aLabel: "indoor",  aConfidence: 0.88, gLabel: "indoor",  gConfidence: 0.87, speed: 0.0, horizontalAccuracy: 10.0, isMeasured: true, timestamp: ts(6, 23),   uvIndex: 0),
    ]

    for observation in observations {
        context.insert(observation)
    }

    do {
        try context.save()
        Logger.app.info("Test data inserted: \(observations.count) HMMObservations")
    } catch {
        Logger.app.error("Failed to save test data: \(error)")
    }
}
#endif

#if DEBUG
private func backfillTestSummaries(container: ModelContainer) async {
    let context = ModelContext(container)
    let calendar = Calendar.current
    for offset in 1...7 {
        let date = calendar.date(byAdding: .day, value: -offset + 1, to: .now)!
        let isWearingSunscreen = Bool.random()
        let isWearingProtection = Bool.random()
        let protection = ProtectionProfile(wearingSunscreen: isWearingSunscreen, wearingProtectiveClothing: isWearingProtection)
        await DailySummaryBackgroundRunner.run(
            modelContainer: container,
            protection: protection,
            for: date
        )
    }
}
#endif
