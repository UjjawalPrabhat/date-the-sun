import Foundation

/// The two protection habits tracked on a `DailySunSummary`.
nonisolated enum ProtectionKind {
    case sunscreen
    case protectiveClothing
}

/// A single sun-protection habit the user logs for the day.
nonisolated struct ProtectionItem: Identifiable {
    var id: ProtectionKind { kind }
    let kind: ProtectionKind
    let title: String
    let subtitle: String
    let systemImage: String
    var isCompleted: Bool
}
