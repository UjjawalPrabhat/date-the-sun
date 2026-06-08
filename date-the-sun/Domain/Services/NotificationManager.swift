//
//  NotificationManager.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 07/06/26.
//

import UserNotifications
import OSLog

struct NotificationManager {
    /// Identifiers shared with the Notification Content Extension. The extension's
    /// `Info.plist` declares `UNNotificationExtensionCategory = eveningReminder`,
    /// so any notification sent with this category renders the custom UI.
    enum Category {
        static let eveningReminder = "eveningReminder"
    }

    /// Action identifiers for the evening reminder's buttons. Handled in
    /// `AppDelegate.userNotificationCenter(_:didReceive:withCompletionHandler:)`.
    enum Action {
        static let lazy = "UV_EVENING_LAZY"
        static let done = "UV_EVENING_DONE"
    }

    /// Key under which the forecast UV value is stored in the notification's
    /// `userInfo`, so the content extension can render the matching mood.
    static let uvValueKey = "uvValue"

    static func requestAuthorization() {
        registerCategories()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            Logger.notification.info("Notification permission granted")
//            scheduleNotification()
//            scheduleMorningNotification(maxUvTodayForecast: 7)
        }
    }

    /// Registers the notification categories and their action buttons. Safe to
    /// call more than once. Call early (app launch + authorization request) so
    /// the buttons are available whenever a notification arrives.
    static func registerCategories() {
        let lazyAction = UNNotificationAction(
            identifier: Action.lazy,
            title: "lazy laa",
            options: []
        )
        let doneAction = UNNotificationAction(
            identifier: Action.done,
            title: "done!",
            options: []
        )
        let eveningCategory = UNNotificationCategory(
            identifier: Category.eveningReminder,
            actions: [lazyAction, doneAction],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([eveningCategory])
    }

    /// Schedule the evening check-in notification (default 8 PM). Uses the
    /// `eveningReminder` category so iOS shows the custom content extension UI
    /// with the "lazy laa" / "done!" action buttons.
    /// - Parameters:
    ///   - maxUvTodayForecast: forecast max UV from WeatherKit, drives the copy + mood.
    ///   - hourReminder: the hour this notification is delivered (24h clock).
    static func scheduleEveningNotification(maxUvTodayForecast: Int, hourReminder: Int = 20) {
        let content = UNMutableNotificationContent()
        content.title = "Evening check-in from Kiran"
        content.body = NotificationCopy.from(uvIndex: maxUvTodayForecast).eveningBody
        content.sound = .default
        content.categoryIdentifier = Category.eveningReminder
        content.userInfo = [uvValueKey: maxUvTodayForecast]

        var dateComponents = DateComponents()
        dateComponents.hour = hourReminder
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "evening-notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                Logger.notification.error("Failed to schedule evening notification: \(error)")
            } else {
                Logger.notification.info("Evening notification scheduled for \(hourReminder):00 daily")
            }
        }
    }
    
    static func scheduleNotification() {
        Logger.notification.info("Notification scheduled")
        
        let content = UNMutableNotificationContent()
        content.title = "Hello"
        content.body = "Notification"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Schedule notification for Morning
    /// - Parameters:
    ///   - maxUvTodayForecast: forecast from WeatherKit
    ///   - hourReminder: the hour this notification will be delivered
    static func scheduleMorningNotification(maxUvTodayForecast: Int, hourReminder: Int = 7) {
        let content = UNMutableNotificationContent()
        content.title = NotificationCopy.from(uvIndex: maxUvTodayForecast).morningTitle
        content.body = NotificationCopy.from(uvIndex: maxUvTodayForecast).morningBody
        content.sound = .default
        var dateComponents = DateComponents()
        dateComponents.hour = hourReminder
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "morning-notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                Logger.notification.error("Failed to schedule morning notification: \(error)")
            } else {
                Logger.notification.info("Morning notification scheduled for \(hourReminder):00 daily")
            }
        }
    }
    
    /// Schedule midday UV warning notification.
    /// - Parameters:
    ///   - maxUvTodayForecast: forecast max UV from WeatherKit
    ///   - minuteOfDay: minutes-of-day (0–1440) when the notification fires — pass `peakStartMinute - 30`
    static func scheduleMidDayNotification(maxUvTodayForecast: Int, minuteOfDay: Double) {
        let totalMinutes = max(0, Int(minuteOfDay))
        let content = UNMutableNotificationContent()
        content.title = "New Message from Kiran"
        content.body = NotificationCopy.from(uvIndex: maxUvTodayForecast).midDayBody
        content.sound = .default
        var dateComponents = DateComponents()
        dateComponents.hour = totalMinutes / 60
        dateComponents.minute = totalMinutes % 60
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "midday-notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                Logger.notification.error("Failed to schedule midday notification: \(error)")
            } else {
                Logger.notification.info("Midday notification scheduled for \(totalMinutes / 60):\(String(format: "%02d", totalMinutes % 60)) daily")
            }
        }
    }
}

enum NotificationCopy: String {
    case low
    case mid
    case high
    
    var morningTitle: String {
        switch self {
        case .low:
            "Morning lovely!🥰"
        case .mid:
            "I just woke up..."
        case .high:
            "YOU..."
        }
    }
    var morningBody: String {
        switch self {
        case .low:
            "Today’s gonna be warm, but don’t leave yourself uncovered! 🌻"
        case .mid:
            "Today’s gonna be hotter, you better cover yourself, okay? 🥵"
        case .high:
            "Today’s gonna be freaking hot because I’m bothered! 👹💥"
        }
    }
    var midDayBody: String {
        switch self {
        case .low:
            ""
        case .mid:
            Bool.random() ? "It’s getting hot, so you better put on some protection, you hear me?" : "PSA: it’s hot and you need to put on protection. Are you listening?"
        case .high:
            Bool.random() ? "WEAR SOME DAMN PROTECTION OR YOU’LL GET BURNED!" : "WHERE’S YOUR PROTECTION??"
        }
    }
    var eveningBody: String {
        switch self {
        case .low:
            "Did you take care of yourself today? Tell me honestly. 🌙"
        case .mid:
            "So… did you actually protect yourself today, or were you being lazy? 😒"
        case .high:
            "You better tell me you wore protection today. I’m waiting. 👀"
        }
    }
}

extension NotificationCopy {
    static func from(uvIndex: Int) -> NotificationCopy {
        switch uvIndex {
        case 0...5:
            return .low
        case 6...7:
            return .mid
        default:
            return .high
        }
    }
}
