import SwiftUI

/// Card summarizing the day's sun exposure: a 24-hour clock plus a legend.
struct SunExposureCard: View {
    var intervals: [SunExposureInterval]

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "sun.max.fill")
                Text("Sun Exposure")
                Spacer()
                Image(systemName: "info.circle.fill")
            }
            .padding()
            .foregroundStyle(.white)
            .background(.black)

            IndoorOutdoorClock(intervals: intervals)

            HStack {
                legendItem(color: .indoor, label: "Indoor Time")
                legendItem(color: .outdoor, label: "Outdoor Time")
                legendItem(color: .vermillion, label: "Peak UV Index")
            }
        }
        .background(.shrek)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack {
            Circle()
                .foregroundStyle(color)
                .frame(width: 10, height: 10)
            Text(label)
        }
    }
}

#Preview {
    SunExposureCard(intervals: SunExposureInterval.sampleDay)
}
