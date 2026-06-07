import Foundation

/// The explanatory copy shown by each dashboard card's "?" info sheet.
extension WidgetInfo {
    // MARK: - Daily

    static let sunExposureDaily = WidgetInfo(
        title: "Sun Exposure",
        systemImage: "sun.max.fill",
        summary: "A 24-hour clock of your day. It estimates when you were outdoors versus indoors and overlays the window when UV was at its strongest.",
        points: [
            .init(label: "Outdoor Time", detail: "Stretches of the day we think you spent under open sky, based on your movement and location."),
            .init(label: "Indoor Time", detail: "The rest of your day spent inside, where UV exposure is minimal."),
            .init(label: "UV Index Peak", detail: "The part of the day when the sun's UV was strongest — the riskiest window to be outside unprotected."),
        ]
    )

    static let protectionLogDaily = WidgetInfo(
        title: "Protection Log",
        systemImage: "checkmark.shield.fill",
        summary: "Your sun-protection habits for the day. Tap a row to mark whether you kept up with each one.",
        points: [
            .init(label: "Sunscreen", detail: "Whether you applied sunscreen before heading outside. Reapply every couple of hours for it to keep working."),
            .init(label: "Protective Clothing", detail: "Whether you covered up with a hat, sunglasses, or long sleeves while in the sun."),
            .init(label: "Tap to update", detail: "These come from Kiran's evening check-in, but you can tap any row to correct it."),
        ]
    )

    // MARK: - Weekly

    static let sunExposureWeekly = WidgetInfo(
        title: "Sun Exposure",
        systemImage: "sun.max.fill",
        summary: "One bar for each of the last seven days, so you can spot which days you spent the most time out in the sun.",
        points: [
            .init(label: "Each bar", detail: "Represents a single day. Taller bars mean more of your waking hours were spent outdoors."),
            .init(label: "Outdoor Time", detail: "The upper segment of each bar — estimated minutes you spent outside that day."),
            .init(label: "Indoor Time", detail: "The lower segment — the remainder of your waking hours spent indoors."),
            .init(label: "Reading the week", detail: "Compare bar heights to see your pattern. Lots of tall bars in a row is a cue to be extra careful with protection."),
        ]
    )

    static let protectionLogWeekly = WidgetInfo(
        title: "Protection Log",
        systemImage: "checkmark.shield.fill",
        summary: "A seven-day adherence grid for each protection habit, so you can see how consistent you've been across the week.",
        points: [
            .init(label: "Each column", detail: "Stands for one day of the week, labelled below with its weekday initial."),
            .init(label: "Filled check", detail: "You kept up with that habit on that day."),
            .init(label: "Empty circle", detail: "The habit was missed that day. A row of gaps is a gentle nudge to do better."),
        ]
    )
}
