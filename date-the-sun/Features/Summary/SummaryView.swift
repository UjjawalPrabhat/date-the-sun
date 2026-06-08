import SwiftUI

/// The Summary dashboard: a date header, a Daily/Weekly toggle, and the matching
/// content over a cream background.
struct SummaryView: View {
    @Bindable var viewModel: SunViewModel
    @Namespace private var periodNamespace
    @State private var showCalendar = false
    private let router = NotificationRouter.shared

    /// Scroll anchor for the protection log card (used by the "Yes" reminder flow).
    private static let protectionLogID = "protectionLog"

    var body: some View {
        ZStack {
            Palette.canvas.ignoresSafeArea()

            ScrollViewReader { proxy in
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
                                protectionLogCard
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
                .onAppear {
                    // Cold navigation from a "Yes" tap: the flag may already be set.
                    if router.scrollToProtectionLog { scrollToProtectionLog(proxy) }
                }
                .onChange(of: router.scrollToProtectionLog) { _, shouldScroll in
                    if shouldScroll { scrollToProtectionLog(proxy) }
                }
            }
        }
        .sheet(isPresented: $showCalendar) {
            CalendarPickerSheet(selectedDate: $viewModel.selectedDate, summaries: viewModel.allSummaries)
        }
    }

    @ViewBuilder
    private var dailyContent: some View {
        HeroCharacterCard(headline: viewModel.selectedDateHeadline, mood: viewModel.selectedDateMood)
        SunExposureCard(indoorOutdoorObservations: viewModel.selectedObservations, uvPeakWindow: viewModel.uvPeakWindow)
        protectionLogCard
    }

    private var protectionLogCard: some View {
        ProtectionLogCard(items: viewModel.protectionItems) { viewModel.toggleProtection($0) }
            .id(Self.protectionLogID)
    }

    /// Scrolls the protection log into view, allowing a brief delay for the tab
    /// switch and layout to settle, then clears the router flag.
    private func scrollToProtectionLog(_ proxy: ScrollViewProxy) {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            withAnimation { proxy.scrollTo(Self.protectionLogID, anchor: .top) }
            router.scrollToProtectionLog = false
        }
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
