//
//  AppDelegate.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 07/06/26.
//

import Foundation
import OSLog
import UIKit
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        // Make the evening reminder's action buttons available before any
        // notification is delivered.
        NotificationManager.registerCategories()
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Logger.notification.info("User tapped notification: \(response.notification.request.identifier), action: \(response.actionIdentifier)")

        switch response.actionIdentifier {
        case NotificationManager.Action.lazy:
            applyEveningResponse(done: false)
        case NotificationManager.Action.done:
            applyEveningResponse(done: true)
        default:
            break // plain tap / dismiss — nothing to record
        }

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    /// Records the evening check-in answer into the App-Group-shared store.
    @MainActor
    private func applyEveningResponse(done: Bool) {
        let context = ModelContext(SharedStore.container)
        let todays = try? context.fetch(
            FetchDescriptor<DailySunSummary>()
        ).first(where: { Calendar.current.isDateInToday($0.date) })

        if done {
            NotificationResponseManager.handleDoneTap(summary: todays, modelContext: context)
        } else {
            NotificationResponseManager.handleLazyTap(summary: todays, modelContext: context)
        }
        Logger.notification.info("Evening check-in recorded: \(done ? "done" : "lazy")")
    }
}
