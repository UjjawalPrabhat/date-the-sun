import Foundation

/// A single sun-protection habit the user logs for the day.
nonisolated struct ProtectionItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
    var isCompleted: Bool
}
