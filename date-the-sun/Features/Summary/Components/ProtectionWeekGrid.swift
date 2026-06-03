import SwiftUI

/// The weekly Protection Log card: each habit shown as a 7-day adherence row.
struct ProtectionWeekGrid: View {
    let rows: [ProtectionWeekRow]

    private let weekdayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        SectionCard(title: "Protection Log", systemImage: "checkmark.shield.fill", background: Palette.pants) {
            VStack(spacing: 12) {
                ForEach(rows) { row in
                    habitRow(row)
                }
            }
            .padding(16)
        }
    }

    private func habitRow(_ row: ProtectionWeekRow) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: row.systemImage)
                    .font(.system(size: 18, weight: .semibold))
                Text(row.title)
                    .font(AppFont.semibold(16))
            }
            .foregroundStyle(Palette.ink)

            HStack(spacing: 0) {
                ForEach(Array(row.completedDays.enumerated()), id: \.offset) { index, done in
                    VStack(spacing: 4) {
                        Image(systemName: done ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundStyle(done ? Palette.ink : Palette.ink.opacity(0.3))
                        Text(weekdayLabels[index % weekdayLabels.count])
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
    ProtectionWeekGrid(rows: [
        .init(title: "Sunscreen", systemImage: "drop.fill",
              completedDays: [true, true, false, true, true, true, false]),
        .init(title: "Protective Clothing", systemImage: "tshirt.fill",
              completedDays: [false, true, true, false, true, false, false]),
    ])
    .padding()
    .background(Palette.canvas)
}
