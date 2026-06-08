//
//  Logger+App.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

import OSLog

// Loggers are thread-safe, so they stay `nonisolated` and can be used from
// background actors and tasks under the project's MainActor default isolation.
extension Logger {
    nonisolated static let app          = Logger(subsystem: "dev.heryan.date-the-sun", category: "App")
    nonisolated static let location     = Logger(subsystem: "dev.heryan.date-the-sun", category: "Location")
    nonisolated static let hmm          = Logger(subsystem: "dev.heryan.date-the-sun", category: "HMM")
    nonisolated static let dailySummary = Logger(subsystem: "dev.heryan.date-the-sun", category: "DailySummary")
    nonisolated static let background   = Logger(subsystem: "dev.heryan.date-the-sun", category: "Background")
    nonisolated static let notification = Logger(subsystem: "dev.heryan.date-the-sun", category: "Notification")
}
