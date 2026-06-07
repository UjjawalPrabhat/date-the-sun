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
    static func run(modelContainer: ModelContainer, protection: ProtectionProfile, for date: Date = .now) async {
        let context = ModelContext(modelContainer)
        
        let targetDay = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: -1, to: date)!
        )
        let nextDay = Calendar.current.startOfDay(for: date)
        
        let descriptor = FetchDescriptor<HMMObservation>(
            predicate: #Predicate {
                $0.timestamp >= targetDay &&
                $0.timestamp < nextDay &&
                $0.inferredState != nil
            },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        guard let observations = try? context.fetch(descriptor),
              !observations.isEmpty else {
            Logger.dailySummary.info("No processed observations for \(targetDay), skipping summary")
            return
        }
        
        let summaryDescriptor = FetchDescriptor<DailySunSummary>(
            predicate: #Predicate { $0.date >= targetDay && $0.date < nextDay }
        )
        var effectiveProtection = protection
        if let existing = try? context.fetch(summaryDescriptor).first {
            if existing.observationCount > 0 {
                Logger.dailySummary.info("Real summary already exists for \(targetDay), skipping")
                return
            }
            effectiveProtection = ProtectionProfile(
                wearingSunscreen: existing.wearSunscreen,
                wearingProtectiveClothing: existing.wearProtectiveClothing
            )
            context.delete(existing)
        }

        Logger.dailySummary.info("Computing daily summary for \(targetDay)...")
        let res = computeDailySummary(observations: observations, protection: effectiveProtection)

        let summary = DailySunSummary(
            date: targetDay,
            score: res.score,
            wearSunscreen: effectiveProtection.wearingSunscreen,
            wearProtectiveClothing: effectiveProtection.wearingProtectiveClothing,
            totalOutdoorMinutes: res.totalOutdoorMinutes,
            peakUVIndex: res.peakUVIndex,
            averageUVIndex: res.averageUVIndex,
            observationCount: observations.count,
        )
        context.insert(summary)
        
        do {
            try context.save()
            Logger.dailySummary.info("Daily summary saved for \(targetDay), score: \(res.score)")
        } catch {
            Logger.dailySummary.error("Daily summary save error: \(error)")
        }
    }
    
    /// Compute daily summary
    static func computeDailySummary(observations: [HMMObservation], protection: ProtectionProfile) ->  ComputedDailySummary {
        Logger.dailySummary.info("Computing daily summary on \(observations.count) observations with protection: \(protection.wearingSunscreen) \(protection.wearingProtectiveClothing)")
        let score = UVDose.dailyKiranScore(observations: observations, protection: protection)
        Logger.dailySummary.info("Calculated score: \(score)")
        
        // Weighted outdoor minutes — sum of (interval * posterior)
        var totalOutdoorMinutes = 0.0
        for i in 0..<(observations.count - 1) {
            let obs = observations[i]
            let next = observations[i + 1]
            guard let posterior = obs.outdoorPosterior else { continue }
            let intervalMinutes = min(next.timestamp.timeIntervalSince(obs.timestamp) / 60.0, 30.0) // get interval
            totalOutdoorMinutes += intervalMinutes * posterior
        }
        Logger.dailySummary.info("Calculated outdoor minutes: \(totalOutdoorMinutes)")
        
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
        Logger.dailySummary.info("Calculated peak UV: \(peakUVIndex), average UV: \(averageUVIndex)")
        
        return ComputedDailySummary(score: score, totalOutdoorMinutes: totalOutdoorMinutes, peakUVIndex: peakUVIndex, averageUVIndex: averageUVIndex)
    }
}

struct ComputedDailySummary {
    var score: Double
    var totalOutdoorMinutes: Double
    var peakUVIndex: Int
    var averageUVIndex: Double
}
