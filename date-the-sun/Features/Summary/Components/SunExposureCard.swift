import SwiftUI

/// The green Sun Exposure card: a 24-hour indoor/outdoor clock plus a legend.
struct SunExposureCard: View {
    var intervals: [SunExposureInterval]

    var body: some View {
        SectionCard(title: "Sun Exposure", systemImage: "sun.max.fill", background: .shrek) {
            VStack(spacing: 16) {
                IndoorOutdoorClock(intervals: intervals)
                    .padding(.top, 20)

                HStack(spacing: 16) {
                    legendItem(color: .outdoor, label: "Outdoor Time")
                    legendItem(color: .indoor, label: "Indoor Time")
                    legendItem(color: .vermillion, label: "UV Index Peak")
                }
                .font(AppFont.medium(12))
                .foregroundStyle(Palette.ink)
            }
            .padding(16)
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
    SunExposureCard(intervals: SunExposureInterval.sampleDay)
        .padding()
        .background(Palette.canvas)
}
