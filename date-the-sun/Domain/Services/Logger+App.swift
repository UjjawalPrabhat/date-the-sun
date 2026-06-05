//
//  Logger+App.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "dev.heryan.date-the-sun"

    static let app          = Logger(subsystem: subsystem, category: "App")
    static let location     = Logger(subsystem: subsystem, category: "Location")
    static let solar        = Logger(subsystem: subsystem, category: "Solar")
    static let hmm          = Logger(subsystem: subsystem, category: "HMM")
    static let background   = Logger(subsystem: subsystem, category: "Background")
}
