import SwiftUI

/// A 24-hour radial clock visualizing indoor/outdoor time, the peak-UV window,
/// and the night span.
struct IndoorOutdoorClock: View {
    var intervals: [SunExposureInterval] = []

    private let radius: CGFloat = 90
    private let uvWindow = (start: 3.0 * 60, end: 10.0 * 60)    // peak UV-index span
    private let nightWindow = (start: 11.0 * 60, end: 1.0 * 60) // wraps past midnight

    var body: some View {
        let uvWedge = WedgeShape(startMinute: uvWindow.start, endMinute: uvWindow.end, radius: radius + 20)

        ZStack {
            uvWedge
                .fill(
                    AngularGradient(
                        stops: [
                            .init(color: .vermillion.opacity(0), location: 0.0),
                            .init(color: .vermillion,            location: 0.5),
                            .init(color: .vermillion.opacity(0), location: 1.0),
                        ],
                        center: .center,
                        startAngle: .degrees(uvWedge.startDegrees),
                        endAngle:   .degrees(uvWedge.endDegrees)
                    )
                )

            Circle()
                .fill(.white)
                .frame(width: radius * 2, height: radius * 2)

            WedgeShape(startMinute: nightWindow.start, endMinute: nightWindow.end, radius: radius)
                .foregroundStyle(.night)

            ForEach(intervals) { interval in
                WedgeShape(
                    startMinute: interval.startMinute,
                    endMinute: interval.endMinute,
                    radius: radius
                )
                .foregroundStyle(interval.isOutdoor ? .outdoor : .indoor)
            }

            ForEach(0..<24, id: \.self) { hour in
                HourMark(hour: hour, radius: radius - 16)
            }
        }
    }
}

struct HourMark: View {
    var hour: Int        // 0–23 in absolute 24h space
    var radius: CGFloat

    private var angle: Angle {
        .degrees(Double(hour) / 24.0 * 360.0 - 90.0)
    }

    private var isNightHour: Bool {
        hour <= 6 || hour >= 18
    }

    private var label: String? {
        switch hour {
        case 0:  return "12 AM"
        case 6:  return "6 AM"
        case 12: return "12 PM"
        case 18: return "6 PM"
        default: return nil
        }
    }

    var body: some View {
        // Major (quarter-day) ticks are tallest, even hours medium, odd hours short.
        let tickHeight: CGFloat = (hour % 6 == 0) ? 10 : (hour % 2 == 0) ? 8 : 4
        let tickWidth:  CGFloat = (hour % 6 == 0) ? 2  : 1
        let tickColor: Color = isNightHour ? .white : .primary

        Rectangle()
            .frame(width: tickWidth, height: tickHeight)
            .offset(y: -(radius + 10 + tickHeight / 2))
            .rotationEffect(angle)
            .foregroundStyle(tickColor)

        if let label {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(tickColor)
                .rotationEffect(.degrees(-angle.degrees))
                .offset(y: -radius + 8)
                .rotationEffect(angle)
        }

        if hour == 12 {
            Image(systemName: "sun.max")
                .offset(y: -radius + 40)
                .rotationEffect(angle)
                .foregroundStyle(.gray)
        }
        if hour == 0 {
            Image(systemName: "moon.stars.fill")
                .offset(y: -radius + 40)
                .rotationEffect(angle)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    IndoorOutdoorClock(intervals: SunExposureInterval.sampleDay)
}
