import SwiftUI

/// The weekly Sun Exposure card: one stacked bar per weekday (outdoor over
/// indoor minutes) plus the shared legend.
struct WeeklyExposureChart: View {
    let days: [DayExposureStat]

    private var maxMinutes: Double {
        max(days.map(\.totalMinutes).max() ?? 1, 1)
    }

    var body: some View {
        SectionCard(title: "Sun Exposure", systemImage: "sun.max.fill", background: .shrek) {
            VStack(spacing: 16) {
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(days) { day in
                        bar(for: day)
                    }
                }
                .frame(height: 160)
                .padding(.top, 20)

                HStack(spacing: 16) {
                    legendItem(color: .outdoor, label: "Outdoor Time")
                    legendItem(color: .indoor, label: "Indoor Time")
                }
                .font(AppFont.medium(12))
                .foregroundStyle(Palette.ink)
            }
            .padding(16)
        }
    }

    private func bar(for day: DayExposureStat) -> some View {
        GeometryReader { geo in
            let h = geo.size.height
            let outdoorH = h * (day.outdoorMinutes / maxMinutes)
            let indoorH = h * (day.indoorMinutes / maxMinutes)

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.outdoor)
                        .frame(height: max(outdoorH, 2))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.indoor)
                        .frame(height: max(indoorH, 2))
                }
                Text(day.weekdayLabel)
                    .font(AppFont.semibold(11))
                    .foregroundStyle(Palette.ink)
                    .padding(.top, 6)
            }
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .foregroundStyle(color)
                .frame(width: 10, height: 10)
            Text(label)
        }
    }
}

#Preview {
    WeeklyExposureChart(days: [
        .init(weekdayLabel: "M", outdoorMinutes: 90,  indoorMinutes: 330),
        .init(weekdayLabel: "T", outdoorMinutes: 150, indoorMinutes: 270),
        .init(weekdayLabel: "W", outdoorMinutes: 60,  indoorMinutes: 360),
        .init(weekdayLabel: "T", outdoorMinutes: 200, indoorMinutes: 220),
        .init(weekdayLabel: "F", outdoorMinutes: 120, indoorMinutes: 300),
        .init(weekdayLabel: "S", outdoorMinutes: 240, indoorMinutes: 180),
        .init(weekdayLabel: "S", outdoorMinutes: 80,  indoorMinutes: 340),
    ])
    .padding()
    .background(Palette.canvas)
}
