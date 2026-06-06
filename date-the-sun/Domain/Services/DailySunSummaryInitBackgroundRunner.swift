import BackgroundTasks
import SwiftData
import OSLog

/// Inserts a blank DailySunSummary placeholder for the next day before the current day ends.
/// Runs nightly at 23:00 so downstream tasks and UI have a row to work with from midnight.
struct DailySunSummaryInitBackgroundRunner {
    static func run(modelContainer: ModelContainer) async {
        let context = ModelContext(modelContainer)
        let calendar = Calendar.current

        let tomorrow = calendar.startOfDay(
            for: calendar.date(byAdding: .day, value: 1, to: .now)!
        )
        let dayAfter = calendar.startOfDay(
            for: calendar.date(byAdding: .day, value: 2, to: .now)!
        )

        let descriptor = FetchDescriptor<DailySunSummary>(
            predicate: #Predicate { $0.date >= tomorrow && $0.date < dayAfter }
        )
        if (try? context.fetch(descriptor).first) != nil {
            Logger.dailySummary.info("Init summary already exists for \(tomorrow), skipping")
            return
        }

        Logger.dailySummary.info("Creating init summary placeholder for \(tomorrow)")
        let summary = DailySunSummary(
            date: tomorrow,
            score: 0.0,
            wearSunscreen: false,
            wearProtectiveClothing: false,
            totalOutdoorMinutes: 0.0,
            peakUVIndex: 0,
            averageUVIndex: 0.0,
            observationCount: 0
        )
        context.insert(summary)

        do {
            try context.save()
            Logger.dailySummary.info("Init summary placeholder saved for \(tomorrow)")
        } catch {
            Logger.dailySummary.error("Init summary save error: \(error)")
        }
    }
}
