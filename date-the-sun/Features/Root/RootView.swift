import SwiftUI
import SwiftData

/// Tab container hosting the Today and Summary screens over a floating tab bar,
/// both driven by one shared `SunModel`.
struct RootView: View {
    let modelContainer: ModelContainer
    @State private var viewModel: SunViewModel
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self._viewModel = State(initialValue: SunViewModel(modelContainer: modelContainer))
    }
    
    @State private var selection: AppTab = .today
    @Namespace private var tabNamespace
    
    // Persistent AppStorage
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
#if DEBUG
    @State private var showHMMDebug = false
    @State private var showSummaryDebug = false
#endif
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                ZStack(alignment: .bottom) {
                    Group {
                        switch selection {
                        case .today:
                            TodayView(model: viewModel)
                        case .summary:
                            SummaryView(viewModel: viewModel)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    FloatingTabBar(selection: $selection, namespace: tabNamespace)
                        .padding(.bottom, 6)
                    
#if DEBUG
                    HStack(spacing: 8) {
                        Button("HMM") { showHMMDebug = true }
                            .sheet(isPresented: $showHMMDebug) {
                                NavigationStack { HMMObservationDebugView() }
                            }
                        
                        Button("Summary") { showSummaryDebug = true }
                            .sheet(isPresented: $showSummaryDebug) {
                                NavigationStack { DailySunSummaryDebugView() }
                            }
                    }
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 8)
                    .padding(.trailing, 16)
                    
#endif
                    
#if DEBUG
Button("Run Daily Summary") {
    Task {
        await DailySummaryBackgroundRunner.run(
            modelContainer: modelContainer,
            protection: .init(wearingSunscreen: false, wearingProtectiveClothing: false)
        )
    }
}
#endif
                    
                    // Splash overlay
                    if viewModel.isMainScreenDataLoading {
                        KiranSplashScreen()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.gray)
                            .transition(.opacity)
                            .zIndex(1)
                    }
                }
                .animation(.easeOut(duration: 0.35), value: viewModel.isMainScreenDataLoading)
                .task {
                    await viewModel.refresh()
                }
                .ignoresSafeArea(.keyboard)
            } else {
                OnboardingView()
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: hasCompletedOnboarding)
    }
}

#Preview("Onboarding") {
    let _ = UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    let container = try! ModelContainer(for: HMMObservation.self, configurations: .init(isStoredInMemoryOnly: true))
    RootView(modelContainer: container)
}

#Preview("Normal") {
    let _ = UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    let container = try! ModelContainer(for: HMMObservation.self, configurations: .init(isStoredInMemoryOnly: true))
    RootView(modelContainer: container)
}

#if DEBUG

// MARK: - HMM Debug

struct HMMObservationDebugView: View {
    @Query(sort: \HMMObservation.timestamp, order: .forward)
    private var observations: [HMMObservation]
    
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM HH:mm"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()
    
    var body: some View {
        List(observations, id: \.timestamp) { obs in
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(timeFormatter.string(from: obs.timestamp))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    
                    if let state = obs.inferredState {
                        Text(state)
                            .font(.caption2.bold())
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(state == "indoor" ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                            .foregroundStyle(state == "indoor" ? .blue : .green)
                            .clipShape(Capsule())
                        Text("\(obs.outdoorPosterior ?? 0.0)")
                    } else {
                        Text("pending")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    
                    Spacer()
                    
                    Text(obs.provider)
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: obs.isMeasured ? "checkmark.circle.fill" : "clock.circle")
                        .foregroundStyle(obs.isMeasured ? .green : .orange)
                        .font(.caption)
                }
                
                HStack(spacing: 12) {
                    Label(
                        "\(obs.classifierLabel) \(String(format: "%.2f", obs.classifierConfidence))",
                        systemImage: "waveform.path"
                    )
                    .font(.caption2)
                    .foregroundStyle(.primary)
                    
                    Label(
                        obs.speed < 0 ? "n/a" : String(format: "%.1f m/s", obs.speed),
                        systemImage: "speedometer"
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    
                    Label(
                        String(format: "±%.0fm", obs.horizontalAccuracy),
                        systemImage: "location.circle"
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                
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

// MARK: - Daily Summary Debug

struct DailySunSummaryDebugView: View {
    @Query(sort: \DailySunSummary.date, order: .reverse)
    private var summaries: [DailySunSummary]
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE dd MMM"
        return f
    }()
    
    var body: some View {
        List(summaries, id: \.date) { summary in
            VStack(alignment: .leading, spacing: 6) {
                // Header row: date + score
                HStack {
                    Text(dateFormatter.string(from: summary.date))
                        .font(.subheadline.bold())
                    
                    Spacer()
                    
                    // Score badge
                    Text(String(format: "%.1f", summary.score))
                        .font(.caption.bold())
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(scoreColor(summary.score).opacity(0.2))
                        .foregroundStyle(scoreColor(summary.score))
                        .clipShape(Capsule())
                    
                    Text("/ 100")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                
                // UV row
                HStack(spacing: 12) {
                    Label("Peak \(summary.peakUVIndex)", systemImage: "sun.max.fill")
                        .font(.caption2)
                        .foregroundStyle(uvColor(summary.peakUVIndex))
                    
                    Label(String(format: "Avg %.1f", summary.averageUVIndex), systemImage: "sun.min")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Label(String(format: "%.0f min outdoor", summary.totalOutdoorMinutes), systemImage: "figure.walk")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                // Dose row
                HStack(spacing: 12) {
                    Label(String(format: "Raw %.2f SED", summary.rawUVDose), systemImage: "rays")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Label(String(format: "Eff %.4f SED", summary.effectiveUVDose), systemImage: "shield.lefthalf.filled")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                // Protection + observation count
                HStack(spacing: 8) {
                    protectionBadge("SPF", active: summary.wearSunscreen)
                    protectionBadge("UPF", active: summary.wearProtectiveClothing)
                    
                    Spacer()
                    
                    Text("\(summary.observationCount) obs")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Daily Summaries (\(summaries.count))")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                VStack(alignment: .trailing, spacing: 2) {
                    let avgScore = summaries.isEmpty ? 0.0 : summaries.map(\.score).reduce(0, +) / Double(summaries.count)
                    Text(String(format: "avg score: %.1f", avgScore))
                        .font(.caption2).foregroundStyle(.secondary)
                    Text("\(summaries.count) days")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func protectionBadge(_ label: String, active: Bool) -> some View {
        Text(label)
            .font(.caption2.bold())
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(active ? Color.teal.opacity(0.2) : Color.gray.opacity(0.15))
            .foregroundStyle(active ? .teal : .secondary)
            .clipShape(Capsule())
    }
    
    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 70...: return .green
        case 40...: return .orange
        default:    return .red
        }
    }
    
    private func uvColor(_ uv: Int) -> Color {
        switch uv {
        case 0...2:  return .green
        case 3...5:  return .yellow
        case 6...7:  return .orange
        case 8...10: return .red
        default:     return .purple
        }
    }
}
#endif
