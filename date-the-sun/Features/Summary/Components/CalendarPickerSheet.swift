import SwiftUI

// MARK: - Day Mood

private enum DayMood {
    case happy    // score 60..<70  → Circle    + fieldBottom (green)
    case neutral  // score 40..<60 or 70..<80 → RoundedRect + pill (yellow)
    case angry    // score < 40 or >= 80       → Diamond     + pants (pink)
    case noData   // no DailySunSummary        → faint Circle

    init(summary: DailySunSummary?) {
        guard let score = summary?.score else { self = .noData; return }
        switch score {
        case 60..<70:
            self = .happy
        case 40..<60, 70..<80:
            self = .neutral
        default:
            self = .angry
        }
    }

    var color: Color {
        switch self {
        case .happy:   return Palette.fieldBottom
        case .neutral: return Palette.pill
        case .angry:   return Palette.pants
        case .noData:  return Palette.ink
        }
    }

    var fillOpacity: Double {
        self == .noData ? 0.10 : 0.65
    }
}

// MARK: - Sheet

/// A bottom-sheet calendar for selecting a past date (or today) on the Summary screen.
/// Each day shows a mood-state shape derived from that day's DailySunSummary score.
struct CalendarPickerSheet: View {
    @Binding var selectedDate: Date
    let summaries: [Date: DailySunSummary]

    @Environment(\.dismiss) private var dismiss
    @State private var displayedMonth: Date

    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: .now)

    init(selectedDate: Binding<Date>, summaries: [Date: DailySunSummary]) {
        self._selectedDate = selectedDate
        self.summaries = summaries
        let cal   = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: selectedDate.wrappedValue)
        let start = cal.date(from: comps) ?? selectedDate.wrappedValue
        self._displayedMonth = State(initialValue: start)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Palette.ink.opacity(0.15))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 24)

            // Month navigation
            HStack {
                Button { shiftMonth(by: -1) } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(canGoBack ? Palette.ink : Palette.ink.opacity(0.25))
                        .frame(width: 44, height: 44)
                }
                .disabled(!canGoBack)

                Spacer()

                Text(displayedMonth, format: .dateTime.month(.wide).year())
                    .font(AppFont.semibold(18))
                    .foregroundStyle(Palette.ink)
                    .contentTransition(.numericText())

                Spacer()

                Button { shiftMonth(by: 1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(canGoForward ? Palette.ink : Palette.ink.opacity(0.25))
                        .frame(width: 44, height: 44)
                }
                .disabled(!canGoForward)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)

            // Weekday headers
            HStack(spacing: 0) {
                ForEach(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { label in
                    Text(label)
                        .font(AppFont.medium(12))
                        .foregroundStyle(Palette.rowSubtitle)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 6)

            // Day grid
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                spacing: 4
            ) {
                ForEach(Array(daysInDisplayedMonth.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(date)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
            .padding(.horizontal, 16)
            .animation(.easeInOut(duration: 0.2), value: displayedMonth)

            // Legend
            legendRow
                .padding(.horizontal, 24)
                .padding(.top, 20)

            Spacer(minLength: 24)
        }
        .background(Palette.canvas)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Palette.canvas)
    }

    // MARK: - Day Cell

    @ViewBuilder
    private func dayCell(_ date: Date) -> some View {
        let isSelected  = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday     = calendar.isDateInToday(date)
        let isFuture    = date > today
        let key         = calendar.startOfDay(for: date)
        let mood        = DayMood(summary: isFuture ? nil : summaries[key])
        // Past days with no data are unselectable; today is always tappable (shows "not ready" card)
        let isDisabled  = isFuture || (mood == .noData && !isToday)

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedDate = date
            }
            dismiss()
        } label: {
            ZStack {
                // Mood shape background (hidden for disabled dates)
                if !isDisabled {
                    moodShape(mood)
                }

                // Selection ring
                if isSelected {
                    Circle()
                        .strokeBorder(Palette.cardHeader, lineWidth: 2)
                        .frame(width: 38, height: 38)
                }

                // Today dot (shown when not selected so the ring alone marks today)
                if isToday && !isSelected {
                    VStack(spacing: 0) {
                        Spacer()
                        Circle()
                            .fill(Palette.cardHeader)
                            .frame(width: 4, height: 4)
                            .padding(.bottom, 3)
                    }
                    .frame(height: 44)
                }

                // Day number
                Text("\(calendar.component(.day, from: date))")
                    .font(isSelected ? AppFont.semibold(15) : AppFont.medium(15))
                    .foregroundStyle(
                        isDisabled && !isToday ? Palette.ink.opacity(0.2) :
                        mood == .noData        ? Palette.rowSubtitle      :
                        Palette.ink
                    )
            }
            .frame(height: 44)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    // MARK: - Mood Shape

    private let shapeSize: CGFloat = 32

    @ViewBuilder
    private func moodShape(_ mood: DayMood) -> some View {
        switch mood {
        case .happy:
            // Smooth circle — balanced, calm sun exposure
            Circle()
                .fill(mood.color.opacity(mood.fillOpacity))
                .frame(width: shapeSize, height: shapeSize)

        case .neutral:
            // Soft rounded square — moderate, in-between
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(mood.color.opacity(mood.fillOpacity))
                .frame(width: shapeSize, height: shapeSize)

        case .angry:
            // Diamond (rotated square) — sharp, out-of-range exposure
            // Inner square sized so its diagonal matches shapeSize (s = shapeSize / √2)
            Rectangle()
                .fill(mood.color.opacity(mood.fillOpacity))
                .frame(width: shapeSize * 0.71, height: shapeSize * 0.71)
                .rotationEffect(.degrees(45))

        case .noData:
            // Faint circle placeholder — no data collected
            Circle()
                .fill(mood.color.opacity(mood.fillOpacity))
                .frame(width: shapeSize * 0.55, height: shapeSize * 0.55)
        }
    }

    // MARK: - Legend

    private var legendRow: some View {
        HStack(spacing: 16) {
            legendItem(shape: .happy,   label: "Great")
            legendItem(shape: .neutral, label: "OK")
            legendItem(shape: .angry,   label: "High risk")
            legendItem(shape: .noData,  label: "No data")
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func legendItem(shape mood: DayMood, label: String) -> some View {
        HStack(spacing: 6) {
            ZStack {
                moodShape(mood)
            }
            .frame(width: 18, height: 18)
            .scaleEffect(18 / shapeSize)

            Text(label)
                .font(AppFont.regular(12))
                .foregroundStyle(Palette.rowSubtitle)
        }
    }

    // MARK: - Helpers

    /// The set of "year-month" strings for which at least one summary exists.
    private var monthsWithData: Set<String> {
        var result = Set<String>()
        for date in summaries.keys {
            let c = calendar.dateComponents([.year, .month], from: date)
            if let y = c.year, let m = c.month {
                result.insert("\(y)-\(m)")
            }
        }
        return result
    }

    private var canGoBack: Bool {
        guard let prev = calendar.date(byAdding: .month, value: -1, to: displayedMonth) else { return false }
        let c = calendar.dateComponents([.year, .month], from: prev)
        guard let y = c.year, let m = c.month else { return false }
        return monthsWithData.contains("\(y)-\(m)")
    }

    private var canGoForward: Bool {
        let cur = calendar.dateComponents([.year, .month], from: today)
        let dis = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let cy = cur.year, let cm = cur.month,
              let dy = dis.year,  let dm = dis.month else { return false }
        return dy < cy || (dy == cy && dm < cm)
    }

    private func shiftMonth(by value: Int) {
        guard let next = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = next
        }
    }

    /// One slot per grid cell; nil = leading blank before the 1st.
    private var daysInDisplayedMonth: [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: comps) else { return [] }

        let firstWeekday  = calendar.component(.weekday, from: firstOfMonth) // 1=Sun
        let leadingBlanks = firstWeekday - 1

        guard let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else { return [] }

        var slots: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                slots.append(date)
            }
        }
        return slots
    }
}

#Preview {
    struct Demo: View {
        @State private var date = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        @State private var show = true
        var body: some View {
            Color.gray.sheet(isPresented: $show) {
                CalendarPickerSheet(selectedDate: $date, summaries: [:])
            }
        }
    }
    return Demo()
}
