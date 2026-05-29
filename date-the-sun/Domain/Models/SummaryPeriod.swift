import Foundation

/// The time span shown on the Summary screen.
nonisolated enum SummaryPeriod: CaseIterable {
    case daily
    case weekly

    var title: String {
        switch self {
        case .daily:  "Daily"
        case .weekly: "Weekly"
        }
    }
}
