//
//  DailySunSummaryBackgroundRunner.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

import BackgroundTasks
import SwiftData
import OSLog

struct DailySummaryBackgroundRunner {
    
    static func schedule() {
        Logger.app.debug("Scheduling Daily Summary task")
        let request = BGAppRefreshTaskRequest(identifier: "dev.heryan.date-the-sun.daily-summary")
        request.earliestBeginDate = Calendar.current.nextDate(
            after: .now,
            matching: DateComponents(hour: 3, minute: 30), // 3.30 after HMM
            matchingPolicy: .nextTime
        )
        try? BGTaskScheduler.shared.submit(request)
    }
    
    static func run(modelContainer: ModelContainer, protection: ProtectionProfile) async {
        let context = ModelContext(modelContainer)
        
        // Fetch all observations from yesterday that have been HMM-processed
        let yesterday = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        )
        let today = Calendar.current.startOfDay(for: .now)
        
        let descriptor = FetchDescriptor<HMMObservation>(
            predicate: #Predicate {
                $0.timestamp >= yesterday &&
                $0.timestamp < today &&
                $0.inferredState != nil   // HMM already ran
            },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        
        guard let observations = try? context.fetch(descriptor),
              !observations.isEmpty else {
            Logger.app.info("No processed observations for yesterday, skipping summary")
            schedule()
            return
        }
        
        // Check if summary already exists for yesterday
        let summaryDescriptor = FetchDescriptor<DailySunSummary>(
            predicate: #Predicate { $0.date >= yesterday && $0.date < today }
        )
        if let existing = try? context.fetch(summaryDescriptor).first {
            Logger.app.info("Summary already exists for yesterday, skipping")
            schedule()
            return
        }
        
        Logger.app.info("Computing daily summary for \(yesterday)...")
        
        let rawDose = UVDose.computeUVDose(observations: observations, protection: .init(wearingSunscreen: false, wearingProtectiveClothing: false))
        let effectiveDose = UVDose.computeUVDose(observations: observations, protection: protection)
        let score = UVDose.computeSunScore(effectiveDose: effectiveDose)
        
        // Weighted outdoor minutes — sum of (interval * posterior)
        var totalOutdoorMinutes = 0.0
        for i in 0..<(observations.count - 1) {
            let obs = observations[i]
            let next = observations[i + 1]
            guard let posterior = obs.outdoorPosterior else { continue }
            let intervalMinutes = min(next.timestamp.timeIntervalSince(obs.timestamp) / 60.0, 30.0)
            totalOutdoorMinutes += intervalMinutes * posterior
        }
        
        // Peak and average UV — only from outdoor-leaning observations
        let outdoorObs = observations.filter { ($0.outdoorPosterior ?? 0) > 0.5 && $0.uvIndex != nil }
        let peakUVIndex = outdoorObs.compactMap { $0.uvIndex }.max() ?? 0
        let averageUVIndex: Double = outdoorObs.isEmpty ? 0.0 : {
            let weightedSum = outdoorObs.compactMap { obs -> Double? in
                guard let uv = obs.uvIndex, let p = obs.outdoorPosterior else { return nil }
                return Double(uv) * p
            }.reduce(0, +)
            let totalWeight = outdoorObs.compactMap { $0.outdoorPosterior }.reduce(0, +)
            return totalWeight > 0 ? weightedSum / totalWeight : 0
        }()
        
        let summary = DailySunSummary(
            date: yesterday,
            score: score,
            wearSunscreen: protection.wearingSunscreen,
            wearProtectiveClothing: protection.wearingProtectiveClothing,
            rawUVDose: rawDose,
            effectiveUVDose: effectiveDose,
            totalOutdoorMinutes: totalOutdoorMinutes,
            peakUVIndex: peakUVIndex,
            averageUVIndex: averageUVIndex,
            observationCount: observations.count,
        )
        context.insert(summary)
        
        do {
            try context.save()
            Logger.app.info("Daily summary saved, score: \(score)")
        } catch {
            Logger.app.error("Daily summary save error: \(error)")
        }
        
        schedule()
    }
}
