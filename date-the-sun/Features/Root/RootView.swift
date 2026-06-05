import SwiftUI

/// Tab container hosting the Today and Summary screens over a floating tab bar,
/// both driven by one shared `SunModel`.
struct RootView: View {
    @State private var model = SunModel()
    @State private var selection: AppTab = .today
    @Namespace private var tabNamespace
    
    // Persistent AppStorage
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                ZStack(alignment: .bottom) {
                    // Wrapped in a Group to keep modifiers uniform
                    Group {
                        switch selection {
                        case .today:
                            TodayView(model: model)
                        case .summary:
                            SummaryView(model: model)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    FloatingTabBar(selection: $selection, namespace: tabNamespace)
                        .padding(.bottom, 6)
                }
                // Run the async task safely when the main container shows up
                .task {
                    await model.refresh()
                }
                .ignoresSafeArea(.keyboard)
            } else {
                OnboardingView()
            }
        }
        // Native spring animation offers a smoother swipe-away feel than .default
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: hasCompletedOnboarding)
    }
}

#Preview {
    // Clear the flag every time the preview reloads so you can test onboarding reliably
    let _ = UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    
    return RootView()
}
