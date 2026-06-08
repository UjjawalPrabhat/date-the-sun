//
//  NotificationResponseManager.swift
//  date-the-sun
//

import Foundation
import SwiftData
import OSLog

/// Applies the evening reminder's notification responses to the shared store.
enum NotificationResponseManager {
    /// Records that the user used no protection today: both habits unchecked.
    static func handleNoProtectionTap(summary: DailySunSummary?, modelContext: ModelContext) {
        let targetSummary = summary ?? DailySunSummary.empty(for: Date())
        if summary == nil { modelContext.insert(targetSummary) }

        targetSummary.wearSunscreen = false
        targetSummary.wearProtectiveClothing = false

        do {
            try modelContext.save()
        } catch {
            Logger.notification.error("Failed to record no-protection response: \(error)")
        }
    }
}
