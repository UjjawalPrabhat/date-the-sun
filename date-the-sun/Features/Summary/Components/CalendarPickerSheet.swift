import SwiftUI

/// A bottom-sheet calendar for selecting a past date (or today) on the Summary screen.
struct CalendarPickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss

    @State private var displayedMonth: Date

    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: .now)

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
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
                        .foregroundStyle(Palette.ink)
                        .frame(width: 44, height: 44)
                }

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
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday    = calendar.isDateInToday(date)
        let isFuture   = date > today

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedDate = date
            }
            dismiss()
        } label: {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Palette.cardHeader)
                } else if isToday {
                    Circle()
                        .stroke(Palette.cardHeader.opacity(0.45), lineWidth: 1.5)
                }

                Text("\(calendar.component(.day, from: date))")
                    .font(AppFont.medium(15))
                    .foregroundStyle(
                        isSelected ? .white :
                        isFuture   ? Palette.ink.opacity(0.2) :
                        Palette.ink
                    )
            }
            .frame(height: 44)
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }

    // MARK: - Helpers

    private var canGoForward: Bool {
        let currentComps  = calendar.dateComponents([.year, .month], from: today)
        let displayComps  = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let cy = currentComps.year, let cm = currentComps.month,
              let dy = displayComps.year,  let dm = displayComps.month else { return false }
        return dy < cy || (dy == cy && dm < cm)
    }

    private func shiftMonth(by value: Int) {
        guard let next = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = next
        }
    }

    /// Returns one slot per grid cell; nil = leading blank.
    private var daysInDisplayedMonth: [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: comps) else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) // 1=Sun
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
            Color.gray
                .sheet(isPresented: $show) {
                    CalendarPickerSheet(selectedDate: $date)
                }
        }
    }
    return Demo()
}
