#if DEBUG
import SwiftUI
import SwiftData
import Foundation

// MARK: - GPX Data Types

private struct GPXWaypoint {
    let latitude: Double
    let longitude: Double
    let time: Date
}

// MARK: - GPX Parser

private final class GPXParser: NSObject, XMLParserDelegate {
    private(set) var waypoints: [GPXWaypoint] = []
    private var currentLat: Double?
    private var currentLon: Double?
    private var currentText = ""
    private var currentTime: Date?
    private var inWpt = false

    static func parse(named name: String) -> [GPXWaypoint] {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gpx"),
              let data = try? Data(contentsOf: url) else { return [] }
        let parser = GPXParser()
        let xml = XMLParser(data: data)
        xml.delegate = parser
        xml.parse()
        return parser.waypoints
    }

    func parser(_ parser: XMLParser, didStartElement el: String, namespaceURI: String?,
                qualifiedName: String?, attributes attrs: [String: String] = [:]) {
        currentText = ""
        if el == "wpt" {
            inWpt = true
            currentLat = attrs["lat"].flatMap(Double.init)
            currentLon = attrs["lon"].flatMap(Double.init)
            currentTime = nil
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(_ parser: XMLParser, didEndElement el: String, namespaceURI: String?, qualifiedName: String?) {
        let text = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        if el == "time", inWpt {
            currentTime = ISO8601DateFormatter().date(from: text)
        } else if el == "wpt", let lat = currentLat, let lon = currentLon, let t = currentTime {
            waypoints.append(GPXWaypoint(latitude: lat, longitude: lon, time: t))
            inWpt = false
        }
    }
}

// MARK: - Seeder

private enum GPXSeeder {
    static func seed(waypoints: [GPXWaypoint], startAt seedStart: Date, into container: ModelContainer) async {
        let context = ModelContext(container)
        let cal = Calendar.current
        let firstTime = waypoints[0].time

        for (i, wpt) in waypoints.enumerated() {
            let elapsed = wpt.time.timeIntervalSince(firstTime)
            let timestamp = seedStart.addingTimeInterval(elapsed)
            let speed: Double = i > 0
                ? haversine(waypoints[i - 1], wpt) / max(wpt.time.timeIntervalSince(waypoints[i - 1].time), 1)
                : 0
            let hour = cal.component(.hour, from: timestamp)

            context.insert(LocationEntry(
                latitude: wpt.latitude,
                longitude: wpt.longitude,
                horizontalAccuracy: 15,
                speed: speed,
                timestamp: timestamp
            ))
            context.insert(HMMObservation(
                classifierLabel: "outdoor",
                classifierConfidence: 0.75,
                provider: "synthetic",
                speed: speed,
                horizontalAccuracy: 15,
                isMeasured: false,
                timestamp: timestamp,
                uvIndex: tropicalUV(hour: hour)
            ))
        }
        try? context.save()
    }

    // Rough tropical UV estimate by hour
    private static func tropicalUV(hour: Int) -> Int {
        switch hour {
        case 7:       return 3
        case 8:       return 5
        case 9:       return 7
        case 10:      return 9
        case 11...13: return 11
        case 14:      return 9
        case 15:      return 7
        case 16:      return 5
        case 17:      return 3
        default:      return 0
        }
    }

    private static func haversine(_ a: GPXWaypoint, _ b: GPXWaypoint) -> Double {
        let R = 6_371_000.0
        let φ1 = a.latitude  * .pi / 180
        let φ2 = b.latitude  * .pi / 180
        let Δφ = (b.latitude  - a.latitude)  * .pi / 180
        let Δλ = (b.longitude - a.longitude) * .pi / 180
        let c = sin(Δφ/2)*sin(Δφ/2) + cos(φ1)*cos(φ2)*sin(Δλ/2)*sin(Δλ/2)
        return R * 2 * atan2(sqrt(c), sqrt(1 - c))
    }
}

// MARK: - View

struct GPXSeedView: View {
    let modelContainer: ModelContainer

    enum GPXFile: String, CaseIterable, Identifiable {
        case springToPark    = "Spring-to-Park23-5kmh"
        case parkToKeranjang = "Park23-to-Keranjang-15kmh"
        case parkToMBG       = "Park23-to-MBG-15mph"

        var id: String { rawValue }
        var label: String {
            switch self {
            case .springToPark:    return "Spring → Park23 (5 km/h)"
            case .parkToKeranjang: return "Park23 → Keranjang (15 km/h)"
            case .parkToMBG:       return "Park23 → MBG (15 mph)"
            }
        }
    }

    @State private var file: GPXFile = .springToPark
    @State private var seedStart: Date = {
        let cal = Calendar.current
        let yesterday = cal.date(byAdding: .day, value: -1, to: .now)!
        return cal.date(bySettingHour: 8, minute: 0, second: 0, of: yesterday)!
    }()
    @State private var runHMM = true
    @State private var runSummary = true
    @State private var status: String?
    @State private var isRunning = false

    var body: some View {
        List {
            Section("Route") {
                Picker("GPX file", selection: $file) {
                    ForEach(GPXFile.allCases) { f in
                        Text(f.label).tag(f)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Timing") {
                DatePicker(
                    "Seed start",
                    selection: $seedStart,
                    in: ...Date.now,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }

            Section("Pipeline") {
                Toggle("Run HMM after seed", isOn: $runHMM)
                Toggle("Compute daily summary", isOn: $runSummary)
                    .disabled(!runHMM)
            }

            Section {
                Button {
                    Task { await run() }
                } label: {
                    HStack(spacing: 8) {
                        if isRunning { ProgressView().scaleEffect(0.8) }
                        Text(isRunning ? "Running…" : "Seed from GPX")
                            .frame(maxWidth: .infinity)
                    }
                }
                .foregroundStyle(.white)
                .opacity(isRunning ? 0.5 : 1)
                .listRowBackground(isRunning ? Color(.systemFill) : Color.accentColor)
                .disabled(isRunning)
            }

            if let status {
                Section("Last run") {
                    Text(status)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func run() async {
        isRunning = true
        defer { isRunning = false }

        status = "Parsing \(file.rawValue).gpx…"
        let waypoints = GPXParser.parse(named: file.rawValue)
        guard !waypoints.isEmpty else {
            status = "Error: 0 waypoints found — is the file in the app bundle?"
            return
        }

        status = "Inserting \(waypoints.count) waypoints from \(seedStart.formatted(date: .abbreviated, time: .shortened))…"
        await GPXSeeder.seed(waypoints: waypoints, startAt: seedStart, into: modelContainer)

        if runHMM {
            status = "Running HMM Viterbi…"
            await HMMBackgroundRunner.run(modelContainer: modelContainer)
        }

        if runHMM && runSummary {
            status = "Computing daily summary…"
            // run() expects the day *after* the target day (it computes for date - 1)
            let summaryRef = Calendar.current.date(byAdding: .day, value: 1, to: seedStart)!
            await DailySummaryBackgroundRunner.run(
                modelContainer: modelContainer,
                protection: .init(wearingSunscreen: false, wearingProtectiveClothing: false),
                for: summaryRef
            )
        }

        let dateStr = seedStart.formatted(date: .abbreviated, time: .omitted)
        status = "✓ \(waypoints.count) points seeded for \(dateStr)"
    }
}
#endif
