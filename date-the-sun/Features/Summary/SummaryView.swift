import SwiftUI

/// The Summary dashboard: a date header, a Daily/Weekly toggle, and the matching
/// content over a cream background.
struct SummaryView: View {
    @Bindable var viewModel: SunViewModel
    @Namespace private var periodNamespace
    @State private var showCalendar = false

    var body: some View {
        ZStack {
            Palette.canvas.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    SummaryHeader(
                        dateText: viewModel.selectedPeriod == .daily
                            ? viewModel.selectedDateLabel
                            : viewModel.weekLabel,
                        onCalendarTap: { showCalendar = true }
                    )
                    PeriodToggle(selection: $viewModel.selectedPeriod, namespace: periodNamespace)

                    switch viewModel.selectedPeriod {
                    case .daily:
                        if viewModel.isSelectedDateToday {
                            TodayNotReadyCard()
                        } else {
                            dailyContent
                        }
                    case .weekly: weeklyContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100) // clear the floating tab bar
            }
        }
        .sheet(isPresented: $showCalendar) {
            CalendarPickerSheet(selectedDate: $viewModel.selectedDate)
        }
    }

    @ViewBuilder
    private var dailyContent: some View {
        HeroCharacterCard(headline: viewModel.headline, mood: viewModel.mood)
        SunExposureCard(indoorOutdoorObservations: viewModel.selectedObservations)
        ProtectionLogCard(items: viewModel.protectionItems) { viewModel.toggleProtection($0) }
    }

    @ViewBuilder
    private var weeklyContent: some View {
        HeroCharacterCard(headline: viewModel.weeklyHeadline, mood: viewModel.weeklyMood)
        WeeklyExposureChart(days: viewModel.dailySummaries)
        ProtectionWeekGrid(days: viewModel.dailySummaries)
    }
}

/// Shown in the daily view when the user selects today — data isn't ready until the next morning.
private struct TodayNotReadyCard: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Palette.heroSky.opacity(0.25))
                    .frame(width: 80, height: 80)
                Image(systemName: "sun.haze.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(Palette.pill)
            }

            VStack(spacing: 8) {
                Text("Very excited to see how I feel, huh?")
                    .font(AppFont.semibold(18))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)

                Text("I will tell you how I feel when I'm ready (probably tomorrow).")
                    .font(AppFont.regular(14))
                    .foregroundStyle(Palette.rowSubtitle)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white)
        )
    }
}

//#Preview {
//    SummaryView(model: SunModel(
//        uvProvider: StaticUVIndexProvider(),
//        locationProvider: StaticLocationProvider(),
//        daylightProvider: MockDaylightProvider()
//    ))
//}
