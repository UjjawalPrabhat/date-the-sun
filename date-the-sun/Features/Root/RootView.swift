import SwiftUI

/// Tab container hosting the Today and Summary screens over a floating tab bar,
/// both driven by one shared `SunModel`.
struct RootView: View {
    @State private var model = SunModel()
    @State private var selection: AppTab = .today
    @Namespace private var tabNamespace

    var body: some View {
        ZStack(alignment: .bottom) {
            switch selection {
            case .today:   TodayView(model: model)
            case .summary: SummaryView(model: model)
            }

            FloatingTabBar(selection: $selection, namespace: tabNamespace)
                .padding(.bottom, 6)
        }
        .task { await model.refresh() }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    RootView()
}
