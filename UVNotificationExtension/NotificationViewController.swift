//
//  NotificationViewController.swift
//  UVNotificationExtension
//
//  Custom UI for the evening UV check-in notification. Renders Kiran's mood and
//  message; the "lazy laa" / "done!" buttons are notification actions (declared
//  on the `eveningReminder` category) handled by the app, since a content
//  extension's view cannot receive taps directly.
//

import UIKit
import SwiftUI
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    private var hosting: UIHostingController<EveningReminderView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        let host = UIHostingController(rootView: EveningReminderView(uvValue: 0, message: ""))
        host.view.backgroundColor = .clear
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        host.didMove(toParent: self)
        hosting = host
    }

    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        let uvValue = (content.userInfo["uvValue"] as? Int) ?? 0
        hosting?.rootView = EveningReminderView(uvValue: uvValue, message: content.body)
    }
}
