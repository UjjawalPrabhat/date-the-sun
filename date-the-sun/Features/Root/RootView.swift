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

    // Routing driven by notification action taps (see NotificationRouter).
    private let router = NotificationRouter.shared

    // Persistent AppStorage
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
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
                    
                    if viewModel.isMainScreenDataLoading {
                        KiranSplashScreen()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.white)
                            .transition(.opacity)
                            .zIndex(1)
                    }
                }
                .animation(.easeOut(duration: 0.35), value: viewModel.isMainScreenDataLoading)
                .task {
                    // Ensure notification permission is requested even for users
                    // who already finished onboarding (idempotent — iOS only
                    // prompts once).
                    NotificationManager.requestAuthorization()
                    await viewModel.refresh()
                    // Catch a "Yes" tap that arrived during a cold launch, before
                    // onChange was observing.
                    presentProtectionLogIfNeeded()
                }
                .onChange(of: router.shouldShowProtectionLog) { _, _ in
                    presentProtectionLogIfNeeded()
                }
                .ignoresSafeArea(.keyboard)
            } else {
                OnboardingView()
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: hasCompletedOnboarding)
    }

    /// Navigates to the Summary tab's daily view for today and asks it to scroll
    /// the protection log into view, when a "Yes" evening-reminder tap requested it.
    private func presentProtectionLogIfNeeded() {
        guard router.shouldShowProtectionLog else { return }
        viewModel.beginTodayProtectionLog()
        viewModel.selectedPeriod = .daily
        selection = .summary
        router.shouldShowProtectionLog = false
        // SummaryView scrolls to the protection log when this flips — handled
        // there via both onAppear (cold navigation) and onChange (already shown).
        router.scrollToProtectionLog = true
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
