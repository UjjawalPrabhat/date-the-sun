import SwiftUI

/// The weekly Protection Log card: each habit shown as a 7-day adherence row.
struct ProtectionWeekGrid: View {
    let days: [DailySunSummary]
    
    var body: some View {
        SectionCard(title: "Protection Log", systemImage: "checkmark.shield.fill", background: Palette.pants) {
            VStack(spacing: 12) {
                habitRow(
                    title: "Sunscreen",
                    systemImage: "drop.fill",
                    completed: days.map(\.wearSunscreen)
                )
                habitRow(
                    title: "Protective Clothing",
                    systemImage: "tshirt.fill",
                    completed: days.map(\.wearProtectiveClothing)
                )
            }
            .padding(16)
        }
    }
    
    private func habitRow(title: String, systemImage: String, completed: [Bool]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(AppFont.semibold(16))
            }
            .foregroundStyle(Palette.ink)
            
            HStack(spacing: 0) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    VStack(spacing: 4) {
                        Image(systemName: completed[index] ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundStyle(completed[index] ? Palette.ink : Palette.ink.opacity(0.3))
                        // Label derived from the actual date — always in sync with the chart
                        Text(day.date.formatted(.dateTime.weekday(.narrow)))
                            .font(AppFont.semibold(11))
                            .foregroundStyle(Palette.rowSubtitle)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
        )
    }
}

#Preview {
    let calendar = Calendar.current
    let today = Date()
    let summaries: [DailySunSummary] = (0..<7).map { offset in
        let date = calendar.date(byAdding: .day, value: -(6 - offset), to: today)!
        return DailySunSummary(
            date: date,
            score: Double.random(in: 40...90),
            wearSunscreen: Bool.random(),
            wearProtectiveClothing: Bool.random(),
            totalOutdoorMinutes: Double.random(in: 30...300),
            peakUVIndex: Int.random(in: 1...11),
            averageUVIndex: Double.random(in: 1...8),
            observationCount: Int.random(in: 10...100)
        )
    }
    ProtectionWeekGrid(days: summaries)
        .padding()
        .background(Palette.canvas)
}
