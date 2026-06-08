//
//  NotificationRouter.swift
//  date-the-sun
//
//  Bridges notification action taps (handled in `AppDelegate`, outside the
//  SwiftUI view tree) into the UI so taps can drive navigation — e.g. the
//  evening reminder's "Yes" action opening the protection log.
//

import Foundation
import Observation

@MainActor
@Observable
final class NotificationRouter {
    /// Shared instance so the `AppDelegate` and the SwiftUI view tree refer to
    /// the same routing state.
    static let shared = NotificationRouter()

    /// Set to `true` when the user taps "Yes" on the evening reminder. `RootView`
    /// observes this, switches to the Summary tab's daily view for today, then
    /// resets it.
    var shouldShowProtectionLog = false

    /// Set to `true` once the Summary tab should scroll its protection log card
    /// into view. `SummaryView` observes this and resets it after scrolling.
    var scrollToProtectionLog = false

    private init() {}
}
