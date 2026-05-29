import SwiftUI

/// The Summary dashboard: a date header, a Daily/Weekly toggle, and the
/// matching daily or weekly content over a cream background.
struct SummaryView: View {
    @StateObject private var viewModel: SummaryViewModel
    @Namespace private var periodNamespace

    init(viewModel: SummaryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Palette.canvas.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    SummaryHeader(dateText: headerText)

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

    private var headerText: String {
        switch viewModel.selectedPeriod {
        case .daily:  viewModel.dateText
        case .weekly: viewModel.weekLabel
        }
    }

    @ViewBuilder
    private var dailyContent: some View {
        HeroCharacterCard(headline: viewModel.headline, mood: viewModel.mood)
        SunExposureCard(intervals: viewModel.intervals)
        ProtectionLogCard(items: viewModel.protectionItems) { item in
            viewModel.toggleProtection(item)
        }
    }

    @ViewBuilder
    private var weeklyContent: some View {
        HeroCharacterCard(headline: viewModel.weeklyHeadline, mood: viewModel.weeklyMood)
        WeeklyExposureChart(days: viewModel.weekDays)
        ProtectionWeekGrid(rows: viewModel.protectionWeek)
    }
}

#Preview {
    SummaryView(viewModel: SummaryViewModel())
}
