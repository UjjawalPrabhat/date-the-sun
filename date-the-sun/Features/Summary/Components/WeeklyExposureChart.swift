import SwiftUI

/// The weekly Sun Exposure card: one stacked bar per weekday (outdoor over
/// indoor minutes) plus the shared legend.
struct WeeklyExposureChart: View {
    let days: [DailySunSummary]
    
    private static let wakingMinutes: Double = 960 // Waking-hours cap used to infer indoor time
    
    private var maxMinutes: Double {
        let maxOutdoor = days.map(\.totalOutdoorMinutes).max() ?? 1
        let maxTotal   = days.map { min($0.totalOutdoorMinutes + indoorMinutes(for: $0),
                                        Self.wakingMinutes) }.max() ?? 1
        return max(maxTotal, maxOutdoor, 1)
    }
    
    private func indoorMinutes(for day: DailySunSummary) -> Double {
        max(Self.wakingMinutes - day.totalOutdoorMinutes, 0)
    }
    
    private func weekdayLabel(for day: DailySunSummary) -> String {
        day.date.formatted(.dateTime.weekday(.narrow))
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
                .padding(.bottom, 20)
                
                HStack(spacing: 16) {
                    legendItem(color: .outdoor, label: "Outdoor Time")
                    legendItem(color: .indoor,  label: "Indoor Time")
                }
                .font(AppFont.medium(12))
                .foregroundStyle(Palette.ink)
            }
            .padding(16)
        }
    }
    
    private func bar(for day: DailySunSummary) -> some View {
        GeometryReader { geo in
            let h          = geo.size.height
            let outdoorH   = h * (day.totalOutdoorMinutes / maxMinutes)
            let indoorH    = h * (indoorMinutes(for: day)  / maxMinutes)
            
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
                Text(weekdayLabel(for: day))
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
    let calendar = Calendar.current
    let today = Date()
    
    let summaries: [DailySunSummary] = (0..<7).map { offset in
        let date = calendar.date(byAdding: .day, value: -(6 - offset), to: today)!
        return DailySunSummary(
            date: date,
            score: Double.random(in: 60...100),
            wearSunscreen: Bool.random(),
            wearProtectiveClothing: Bool.random(),
            totalOutdoorMinutes: Double.random(in: 30...300),
            peakUVIndex: Int.random(in: 1...11),
            averageUVIndex: Double.random(in: 1...8),
            observationCount: Int.random(in: 10...100)
        )
    }
    
    WeeklyExposureChart(days: summaries)
        .padding()
        .background(Palette.canvas)
}
