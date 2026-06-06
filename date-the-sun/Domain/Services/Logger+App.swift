//
//  Logger+App.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

import OSLog

extension Logger {
    static let app        = Logger(subsystem: "dev.heryan.date-the-sun", category: "App")
    static let location   = Logger(subsystem: "dev.heryan.date-the-sun", category: "Location")
    static let hmm        = Logger(subsystem: "dev.heryan.date-the-sun", category: "HMM")
    static let dailySummary = Logger(subsystem: "dev.heryan.date-the-sun", category: "DailySummary")
    static let background = Logger(subsystem: "dev.heryan.date-the-sun", category: "Background")
}
