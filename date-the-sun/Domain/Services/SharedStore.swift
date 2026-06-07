//
//  SharedStore.swift
//  date-the-sun
//
//  Single SwiftData container shared between the app process and the
//  Notification Content Extension via an App Group, so notification taps and
//  the in-app UI read and write the same store.
//

import Foundation
import SwiftData
import OSLog

enum SharedStore {
    /// App Group identifier shared by the app target and the notification extension.
    /// Must match the `com.apple.security.application-groups` entry in both
    /// targets' entitlements.
    static let appGroupID = "group.com.ujjawal.date-the-sun"

    /// The schema shared across processes. Only `DailySunSummary` is needed by
    /// the extension, but the full schema keeps the store identical to the app's.
    static let schema = Schema([
        LocationEntry.self,
        HMMObservation.self,
        DailySunSummary.self,
    ])

    /// The one container the whole app uses. Backed by the App Group container
    /// when available, falling back to the default location if the App Group
    /// capability isn't provisioned yet (so the app still launches).
    static let container: ModelContainer = {
        let configuration: ModelConfiguration
        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) {
            let storeURL = groupURL.appending(path: "DateTheSun.store")
            configuration = ModelConfiguration(schema: schema, url: storeURL)
            Logger.app.info("Using App Group SwiftData store at \(storeURL.path)")
        } else {
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            Logger.app.error("App Group container unavailable — falling back to default SwiftData store")
        }

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create shared ModelContainer: \(error)")
        }
    }()
}
