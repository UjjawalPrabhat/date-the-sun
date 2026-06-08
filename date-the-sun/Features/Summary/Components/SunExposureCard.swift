import SwiftUI

/// The green Sun Exposure card: a 24-hour indoor/outdoor clock plus a legend.
struct SunExposureCard: View {
    var indoorOutdoorObservations: [HMMObservation] = []
    var uvPeakWindow: (startMinute: Double, endMinute: Double)? = nil

    var body: some View {
        SectionCard(title: "Sun Exposure", systemImage: "sun.max.fill", background: .shrek, info: .sunExposureDaily) {
            VStack(spacing: 16) {
                IndoorOutdoorClock(indoorOutdoorObservations: indoorOutdoorObservations, uvPeakWindow: uvPeakWindow)
                    .padding(.top, 20)

                HStack(spacing: 16) {
                    ExposureLegendItem(color: .outdoor, label: "Outdoor Time")
                    ExposureLegendItem(color: .indoor, label: "Indoor Time")
                    ExposureLegendItem(color: .vermillion, label: "UV Index Peak")
                }
                .font(AppFont.medium(12))
                .foregroundStyle(Palette.ink)
            }
            .padding(16)
        }
    }
}

/// A coloured dot + label used in the daily and weekly Sun Exposure legends.
struct ExposureLegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .foregroundStyle(color)
                .frame(width: 10, height: 10)
            Text(label)
        }
    }
}

#Preview {
    SunExposureCard(indoorOutdoorObservations: PreviewData.observations, uvPeakWindow: PreviewData.uvPeakWindow)
        .padding()
        .background(Palette.canvas)
}
 
