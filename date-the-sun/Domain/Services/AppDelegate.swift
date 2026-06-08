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

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
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
        case NotificationManager.Action.no:
            // User didn't protect themselves — record both habits as not done.
            logNoProtection()
        case NotificationManager.Action.yes:
            // User did protect themselves — open the app (the action is
            // `.foreground`) and route to the protection log so they can record
            // exactly what they wore.
            NotificationRouter.shared.shouldShowProtectionLog = true
        default:
            break // plain tap / dismiss — nothing to record
        }

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    /// Records "no protection used" for today into the App-Group-shared store.
    @MainActor
    private func logNoProtection() {
        let context = ModelContext(SharedStore.container)
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        var descriptor = FetchDescriptor<DailySunSummary>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        descriptor.fetchLimit = 1
        let todays = try? context.fetch(descriptor).first

        NotificationResponseManager.handleNoProtectionTap(summary: todays, modelContext: context)
        Logger.notification.info("Evening check-in recorded: no protection")
    }
}
