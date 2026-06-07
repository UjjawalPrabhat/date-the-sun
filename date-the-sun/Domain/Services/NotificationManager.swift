//
//  NotificationManager.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 07/06/26.
//

import UserNotifications
import OSLog

struct NotificationManager {
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            Logger.notification.info("Notification permission granted")
//            scheduleNotification()
//            scheduleMorningNotification(maxUvTodayForecast: 7)
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
