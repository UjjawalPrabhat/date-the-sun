//
//  BackgroundScheduler.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 06/06/26.
//

import BackgroundTasks
import OSLog

enum BackgroundScheduler {
    /// Runs the HMM Viterbi pass that determines the user's true indoor/outdoor time.
    @MainActor
    static func scheduleHMMViterbi() {
        schedule("dev.heryan.date-the-sun.hmm-viterbi", at: DateComponents(hour: 3), label: "HMM Viterbi")
    }

    @MainActor
    static func scheduleDailySummary() {
        schedule("dev.heryan.date-the-sun.daily-summary", at: DateComponents(hour: 4, minute: 30), label: "Daily summary")
    }

    @MainActor
    static func scheduleDailySunSummaryInit() {
        schedule("dev.heryan.date-the-sun.daily-sun-summary-init", at: DateComponents(hour: 23), label: "Daily sun summary init")
    }

    @MainActor
    private static func schedule(_ identifier: String, at time: DateComponents, label: String) {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Calendar(identifier: .gregorian).nextDate(
            after: .now, matching: time, matchingPolicy: .nextTime
        )
        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.background.info("\(label) scheduled")
        } catch {
            Logger.background.error("Failed to schedule \(label): \(error)")
        }
    }
}
