import SwiftUI

/// The Summary dashboard: a date header, a Daily/Weekly toggle, and the matching
/// content over a cream background.
struct SummaryView: View {
    @Bindable var viewModel: SunViewModel
    @Namespace private var periodNamespace

    var body: some View {
        ZStack {
            Palette.canvas.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    SummaryHeader(dateText: viewModel.selectedPeriod == .daily ? viewModel.dateText : viewModel.weekLabel)
                    PeriodToggle(selection: $viewModel.selectedPeriod, namespace: periodNamespace)

                    switch viewModel.selectedPeriod {
                    case .daily:  dailyContent
                    case .weekly: weeklyContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100) // clear the floating tab bar
            }
        }
    }

    @ViewBuilder
    private var dailyContent: some View {
        HeroCharacterCard(headline: viewModel.headline, mood: viewModel.mood)
        SunExposureCard()
//        ProtectionLogCard(items: model.protection) { model.toggleProtection($0) }
    }

    @ViewBuilder
    private var weeklyContent: some View {
//        HeroCharacterCard(headline: model.weekly.headline, mood: model.weekly.mood)
//        WeeklyExposureChart(days: model.weekly.days)
//        ProtectionWeekGrid(rows: model.weekly.protection)
    }
}

//#Preview {
//    SummaryView(model: SunModel(
//        uvProvider: StaticUVIndexProvider(),
//        locationProvider: StaticLocationProvider(),
//        daylightProvider: MockDaylightProvider()
//    ))
//}
