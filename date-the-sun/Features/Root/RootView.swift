import SwiftUI

/// Root tab container hosting the Today and Summary screens behind a floating
/// tab bar. Builds each screen's ViewModel from the injected dependencies.
struct RootView: View {
    let dependencies: AppDependencies

    @State private var selection: AppTab = .today
    @Namespace private var tabNamespace

    init(dependencies: AppDependencies = AppDependencies()) {
        self.dependencies = dependencies
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            switch selection {
            case .today:
                TodayView(viewModel: dependencies.makeTodayViewModel())
            case .summary:
                SummaryView(viewModel: dependencies.makeSummaryViewModel())
            }

            FloatingTabBar(selection: $selection, namespace: tabNamespace)
                .padding(.bottom, 6)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    RootView()
}
