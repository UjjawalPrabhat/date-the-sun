//
//  BackgroundScheduler.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 06/06/26.
//

import BackgroundTasks
import OSLog

enum BackgroundScheduler {
    /// Schedule for running HMM Viterbi algorithm to determine true user's
    /// indoor/outdoor time
    @MainActor
    static func scheduleHMMViterbi() {
        let request = BGAppRefreshTaskRequest(identifier: "dev.heryan.date-the-sun.hmm-viterbi")
        request.earliestBeginDate = Calendar(identifier: .gregorian).nextDate(
            after: .now,
            matching: DateComponents(hour: 3),
            matchingPolicy: .nextTime
        )
        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.background.info("HMM Viterbi scheduled")
        } catch {
            Logger.background.error("Failed to schedule HMM Viterbi: \(error)")
        }
    }
    @MainActor
    static func scheduleDailySummary() {
        let request = BGAppRefreshTaskRequest(identifier: "dev.heryan.date-the-sun.daily-summary")
        request.earliestBeginDate = Calendar(identifier: .gregorian).nextDate(
            after: .now,
            matching: DateComponents(hour: 4, minute: 30),
            matchingPolicy: .nextTime
        )
        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.background.info("Daily summary scheduled")
        } catch {
            Logger.background.error("Failed to schedule daily summary: \(error)")
        }
    }
}
