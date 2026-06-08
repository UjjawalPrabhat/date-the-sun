//
//  DebugSheetView.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 06/06/26.
//

#if DEBUG
import SwiftUI
import SwiftData
import UserNotifications

// MARK: - Root Debug Sheet

struct DebugSheetView: View {
    let modelContainer: ModelContainer
    @State private var selectedTab: DebugTab = .observations
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    enum DebugTab: String, CaseIterable {
        case observations = "Observations"
        case summaries    = "Summaries"
        case locations    = "Locations"
        case seed         = "Seed"
        case notif        = "Notif"

        var icon: String {
            switch self {
            case .observations: return "eye"
            case .summaries:    return "sun.max"
            case .locations:    return "location"
            case .seed:         return "square.and.arrow.down"
            case .notif:        return "bell.badge"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab bar
                HStack(spacing: 0) {
                    ForEach(DebugTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            DebugTabLabel(
                                icon: tab.icon,
                                title: tab.rawValue,
                                isSelected: selectedTab == tab
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(.bar)

                Divider()

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Filter…", text: $searchText)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemBackground))

                Divider()

                // Content
                switch selectedTab {
                case .observations:
                    HMMObservationListView(modelContainer: modelContainer, search: searchText)
                case .summaries:
                    DailySummaryListView(modelContainer: modelContainer, search: searchText)
                case .locations:
                    LocationEntryListView(modelContainer: modelContainer, search: searchText)
                case .seed:
                    GPXSeedView(modelContainer: modelContainer)
                case .notif:
                    NotificationDebugView()
                }
            }
            .navigationTitle("🛠 SwiftData Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Tab Label (extracted to help type-checker)

private struct DebugTabLabel: View {
    let icon: String
    let title: String
    let isSelected: Bool

    var body: some View {
        let fg: Color = isSelected ? .accentColor : .secondary
        let bg: Color = isSelected ? Color.accentColor.opacity(0.12) : .clear
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
            Text(title)
                .font(.caption2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .foregroundStyle(fg)
        .background(bg)
    }
}

// MARK: - HMMObservation List

private struct HMMObservationListView: View {
    let modelContainer: ModelContainer
    let search: String
    @State private var items: [HMMObservation] = []

    var filtered: [HMMObservation] {
        guard !search.isEmpty else { return items }
        return items.filter {
            $0.classifierLabel.localizedCaseInsensitiveContains(search) ||
            $0.provider.localizedCaseInsensitiveContains(search) ||
            ($0.inferredState?.localizedCaseInsensitiveContains(search) ?? false)
        }
    }

    var body: some View {
        List {
            Section {
                Text("\(filtered.count) record(s)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(filtered, id: \.persistentModelID) { obs in
                NavigationLink {
                    HMMObservationDetailView(obs: obs)
                } label: {
                    HMMObservationRow(obs: obs)
                }
            }
        }
        .listStyle(.plain)
        .task { await load() }
    }

    private func load() async {
        let context = ModelContext(modelContainer)
        var desc = FetchDescriptor<HMMObservation>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        desc.fetchLimit = 500
        items = (try? context.fetch(desc)) ?? []
    }
}

private struct HMMObservationRow: View {
    let obs: HMMObservation
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                // Show inferred state if available, else classifier label
                let displayLabel = obs.inferredState ?? obs.classifierLabel
                Label(
                    displayLabel.uppercased(),
                    systemImage: displayLabel == "outdoor" ? "sun.max.fill" : "house.fill"
                )
                .font(.caption.bold())
                .foregroundStyle(displayLabel == "outdoor" ? .orange : .blue)

                if obs.inferredState != nil {
                    Text("HMM")
                        .font(.system(size: 8, weight: .bold))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.indigo.opacity(0.15))
                        .foregroundStyle(.indigo)
                        .clipShape(Capsule())
                }
                Spacer()
                Text(obs.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 6) {
                if let uv = obs.uvIndex {
                    debugBadge("UV \(uv)", color: uvColor(uv))
                } else {
                    debugBadge("UV —", color: .gray)
                }
                debugBadge(String(format: "%.0f%%", obs.classifierConfidence * 100), color: .gray)
                debugBadge(obs.provider, color: .purple)
                if let posterior = obs.outdoorPosterior {
                    debugBadge(String(format: "γ %.2f", posterior), color: .teal)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

private struct HMMObservationDetailView: View {
    let obs: HMMObservation
    var body: some View {
        List {
            Section("Classifier") {
                debugRow("Label", obs.classifierLabel)
                debugRow("Confidence", String(format: "%.4f", obs.classifierConfidence))
                debugRow("Provider", obs.provider)
            }
            Section("Activity Signals") {
                debugRow("A Label",      obs.aLabel      ?? "nil")
                debugRow("A Confidence", obs.aConfidence.map { String(format: "%.4f", $0) } ?? "nil")
                debugRow("G Label",      obs.gLabel      ?? "nil")
                debugRow("G Confidence", obs.gConfidence.map { String(format: "%.4f", $0) } ?? "nil")
            }
            Section("HMM Output") {
                debugRow("Inferred State",    obs.inferredState    ?? "not yet run")
                debugRow("State Probability", obs.stateProbability.map { String(format: "%.4f", $0) } ?? "nil")
                debugRow("Outdoor Posterior γ", obs.outdoorPosterior.map { String(format: "%.4f", $0) } ?? "nil")
            }
            Section("Location & Motion") {
                debugRow("Speed",       String(format: "%.2f m/s", obs.speed))
                debugRow("H. Accuracy", String(format: "%.1f m", obs.horizontalAccuracy))
                debugRow("Is Measured", obs.isMeasured ? "Yes" : "No")
            }
            Section("Environment") {
                debugRow("UV Index",  obs.uvIndex.map { "\($0)" } ?? "nil")
                debugRow("Timestamp", obs.timestamp.formatted(date: .abbreviated, time: .standard))
            }
        }
        .navigationTitle("Observation Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - DailySunSummary List

private struct DailySummaryListView: View {
    let modelContainer: ModelContainer
    let search: String
    @State private var items: [DailySunSummary] = []

    var filtered: [DailySunSummary] {
        guard !search.isEmpty else { return items }
        return items.filter {
            $0.date.formatted().localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        List {
            Section {
                Text("\(filtered.count) record(s)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(filtered, id: \.persistentModelID) { summary in
                NavigationLink {
                    DailySummaryDetailView(summary: summary)
                } label: {
                    DailySummaryRow(summary: summary)
                }
            }
        }
        .listStyle(.plain)
        .task { await load() }
    }

    private func load() async {
        let context = ModelContext(modelContainer)
        let desc = FetchDescriptor<DailySunSummary>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        items = (try? context.fetch(desc)) ?? []
    }
}

private struct DailySummaryRow: View {
    let summary: DailySunSummary
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(summary.date, style: .date)
                    .font(.subheadline.bold())
                Spacer()
                // Score pill
                Text(String(format: "Score %.0f", summary.score))
                    .font(.caption2.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(scoreColor(summary.score).opacity(0.15))
                    .foregroundStyle(scoreColor(summary.score))
                    .clipShape(Capsule())
            }
            HStack(spacing: 6) {
                debugBadge("UV \(summary.peakUVIndex)", color: uvColor(summary.peakUVIndex))
                debugBadge(String(format: "%.0f min", summary.totalOutdoorMinutes), color: .green)
                debugBadge("\(summary.observationCount) obs", color: .gray)
                if summary.wearSunscreen { debugBadge("🧴 SPF", color: .yellow) }
                if summary.wearProtectiveClothing { debugBadge("👕 UPF", color: .teal) }
            }
        }
        .padding(.vertical, 2)
    }
}

private struct DailySummaryDetailView: View {
    let summary: DailySunSummary
    var body: some View {
        List {
            Section("Date") {
                debugRow("Date", summary.date.formatted(date: .complete, time: .omitted))
            }
            Section("Score") {
                debugRow("Score", String(format: "%.4f", summary.score))
            }
            Section("UV Exposure") {
                debugRow("Peak UV Index", "\(summary.peakUVIndex)")
                debugRow("Avg UV Index",  String(format: "%.2f", summary.averageUVIndex))
            }
            Section("Outdoor Time") {
                debugRow("Total Outdoor Minutes", String(format: "%.1f", summary.totalOutdoorMinutes))
                debugRow("Observation Count",     "\(summary.observationCount)")
            }
            Section("Protection") {
                debugRow("Sunscreen",            summary.wearSunscreen           ? "✅ Yes" : "❌ No")
                debugRow("Protective Clothing",  summary.wearProtectiveClothing  ? "✅ Yes" : "❌ No")
            }
        }
        .navigationTitle("Summary Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - LocationEntry List

private struct LocationEntryListView: View {
    let modelContainer: ModelContainer
    let search: String
    @State private var items: [LocationEntry] = []

    var filtered: [LocationEntry] {
        guard !search.isEmpty else { return items }
        return items.filter {
            $0.timestamp.formatted().localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        List {
            Section {
                Text("\(filtered.count) record(s)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(filtered, id: \.persistentModelID) { entry in
                NavigationLink {
                    LocationEntryDetailView(entry: entry)
                } label: {
                    LocationEntryRow(entry: entry)
                }
            }
        }
        .listStyle(.plain)
        .task { await load() }
    }

    private func load() async {
        let context = ModelContext(modelContainer)
        var desc = FetchDescriptor<LocationEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        desc.fetchLimit = 500
        items = (try? context.fetch(desc)) ?? []
    }
}

private struct LocationEntryRow: View {
    let entry: LocationEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(String(format: "%.5f, %.5f", entry.latitude, entry.longitude))
                    .font(.caption.monospaced())
                Spacer()
                Text(entry.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                debugBadge(String(format: "±%.0fm", entry.horizontalAccuracy), color: .blue)
                debugBadge(String(format: "%.1f m/s", entry.speed), color: .green)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct LocationEntryDetailView: View {
    let entry: LocationEntry
    var body: some View {
        List {
            Section("Coordinates") {
                debugRow("Latitude",  String(format: "%.7f", entry.latitude))
                debugRow("Longitude", String(format: "%.7f", entry.longitude))
            }
            Section("Accuracy & Motion") {
                debugRow("Horizontal Accuracy", String(format: "%.1f m", entry.horizontalAccuracy))
                debugRow("Speed",               String(format: "%.2f m/s", entry.speed))
            }
            Section("Time") {
                debugRow("Timestamp", entry.timestamp.formatted(date: .abbreviated, time: .standard))
            }
        }
        .navigationTitle("Location Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Notification Debug

private struct NotificationDebugView: View {
    @State private var status = ""

    var body: some View {
        List {
            Section {
                Button {
                    NotificationManager.scheduleTestEveningNotification(seconds: 8)
                    status = "Scheduled — background the app now, then long-press the banner in ~8s to see Yes / No."
                } label: {
                    Label("Fire evening reminder (8s)", systemImage: "bell.badge.fill")
                }
            } footer: {
                Text("Sends the evening check-in with the Yes/No actions and custom UI. Send the app to the background within 8 seconds so the banner appears; pull down / long-press it to reveal the buttons.")
            }

            if !status.isEmpty {
                Section {
                    Text(status)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button(role: .destructive) {
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                    status = "Cleared all pending & delivered notifications."
                } label: {
                    Label("Clear all notifications", systemImage: "trash")
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Shared Helpers

private func debugRow(_ label: String, _ value: String) -> some View {
    HStack {
        Text(label)
            .foregroundStyle(.secondary)
        Spacer()
        Text(value)
            .font(.caption.monospaced())
            .multilineTextAlignment(.trailing)
    }
}

private func debugBadge(_ text: String, color: Color) -> some View {
    Text(text)
        .font(.caption2.bold())
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.15))
        .foregroundStyle(color)
        .clipShape(Capsule())
}

private func uvColor(_ index: Int) -> Color {
    switch index {
    case 0...2:  return .green
    case 3...5:  return .yellow
    case 6...7:  return .orange
    case 8...10: return .red
    default:     return .purple
    }
}

/// Score color: higher score = more UV exposure / worse = redder
private func scoreColor(_ score: Double) -> Color {
    switch score {
    case ..<25:  return .green
    case ..<50:  return .yellow
    case ..<75:  return .orange
    default:     return .red
    }
}
#endif
