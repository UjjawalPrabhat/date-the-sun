//
//  NotificationHandler.swift
//  date-the-sun
//
//  Created by I Gusti Ngurah Bagus Ferry Mahayudha on 07/06/26.
//

import Foundation
import SwiftData

// MARK: - Notification Data Logic Manager

class NotificationResponseManager {
    static func handleLazyTap(summary: DailySunSummary?, modelContext: ModelContext) {
        let targetSummary = summary ?? DailySunSummary(
            date: Date(), score: 0.0, wearSunscreen: true, wearProtectiveClothing: true,
            totalOutdoorMinutes: 0.0, peakUVIndex: 0, averageUVIndex: 0.0, observationCount: 0
        )
        if summary == nil { modelContext.insert(targetSummary) }
        
        targetSummary.wearSunscreen = false
        targetSummary.wearProtectiveClothing = false
        
        try? modelContext.save()
    }
    
    static func handleDoneTap(summary: DailySunSummary?, modelContext: ModelContext) {
        let targetSummary = summary ?? DailySunSummary(
            date: Date(), score: 0.0, wearSunscreen: false, wearProtectiveClothing: false,
            totalOutdoorMinutes: 0.0, peakUVIndex: 0, averageUVIndex: 0.0, observationCount: 0
        )
        if summary == nil { modelContext.insert(targetSummary) }
        
        targetSummary.wearSunscreen = true
        targetSummary.wearProtectiveClothing = true
        
        try? modelContext.save()
    }
}
