import SwiftUI
import SwiftData

/// Tab container hosting the Today and Summary screens over a floating tab bar,
/// both driven by one shared `SunModel`.
struct RootView: View {
    @State private var model = SunModel()
    @State private var selection: AppTab = .today
    @Namespace private var tabNamespace
    
#if DEBUG
    @State private var showHMMDebug = false
#endif
    
    var body: some View {
        ZStack(alignment: .bottom) {
            switch selection {
            case .today:   TodayView(model: model)
            case .summary: SummaryView(model: model)
            }
            
            FloatingTabBar(selection: $selection, namespace: tabNamespace)
                .padding(.bottom, 6)
            
#if DEBUG
            Button("HMM Debug") { showHMMDebug = true }
                .font(.caption2)
                .padding(6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.top, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.trailing, 16)
                .sheet(isPresented: $showHMMDebug) {
                    NavigationStack {
                        HMMObservationDebugView()
                    }
                }
#endif
        }
        .task { await model.refresh() }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    RootView()
}

#if DEBUG
struct HMMObservationDebugView: View {
    @Query(sort: \HMMObservation.timestamp, order: .forward)
    private var observations: [HMMObservation]
    
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = TimeZone(identifier: "UTC")  // ← match the test data timezone
        return f
    }()
    
    var body: some View {
        List(observations, id: \.timestamp) { obs in
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(timeFormatter.string(from: obs.timestamp))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    
                    // Inferred state badge
                    if let state = obs.inferredState {
                        Text(state)
                            .font(.caption2.bold())
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(state == "indoor" ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                            .foregroundStyle(state == "indoor" ? .blue : .green)
                            .clipShape(Capsule())
                    } else {
                        Text("pending")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    
                    Spacer()
                    
                    // Provider badge
                    Text(obs.provider)
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                    
                    // Measured indicator
                    Image(systemName: obs.isMeasured ? "checkmark.circle.fill" : "clock.circle")
                        .foregroundStyle(obs.isMeasured ? .green : .orange)
                        .font(.caption)
                }
                
                HStack(spacing: 12) {
                    // Fused label + confidence
                    Label(
                        "\(obs.classifierLabel) \(String(format: "%.2f", obs.classifierConfidence))",
                        systemImage: "waveform.path"
                    )
                    .font(.caption2)
                    .foregroundStyle(.primary)
                    
                    // Speed
                    Label(
                        obs.speed < 0 ? "n/a" : String(format: "%.1f m/s", obs.speed),
                        systemImage: "speedometer"
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    
                    // GPS accuracy
                    Label(
                        String(format: "±%.0fm", obs.horizontalAccuracy),
                        systemImage: "location.circle"
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                
                // Raw A/G signals if measured
                if obs.isMeasured, obs.aLabel != nil || obs.gLabel != nil {
                    HStack(spacing: 8) {
                        if let aLabel = obs.aLabel, let aConf = obs.aConfidence {
                            Text("A: \(aLabel) \(String(format: "%.2f", aConf))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        if let gLabel = obs.gLabel, let gConf = obs.gConfidence {
                            Text("G: \(gLabel) \(String(format: "%.2f", gConf))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .navigationTitle("HMM Observations (\(observations.count))")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                VStack(alignment: .trailing, spacing: 2) {
                    let measured = observations.filter(\.isMeasured).count
                    let inferred = observations.filter { $0.inferredState != nil }.count
                    Text("measured: \(measured)/\(observations.count)")
                        .font(.caption2).foregroundStyle(.secondary)
                    Text("inferred: \(inferred)/\(observations.count)")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
    }
}
#endif
