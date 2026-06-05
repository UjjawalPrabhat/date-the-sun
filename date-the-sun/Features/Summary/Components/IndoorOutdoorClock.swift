import SwiftUI

/// A 24-hour radial dial: a white face labelled 12am (top) · 6 · 12pm · 18,
/// ringed by thick rounded arcs for outdoor (pink) and indoor (blue) time, with
/// the peak-UV window as a separate thinner orange arc just outside the ring.
struct IndoorOutdoorClock: View {
    var indoorOutdoorObservations: [HMMObservation]
    
    private let dialSize: CGFloat = 240
    private let faceDiameter: CGFloat = 150
    private let ringRadius: CGFloat = 96
    private let uvRadius: CGFloat = 113
    private let ringWidth: CGFloat = 19
    private let uvWidth: CGFloat = 10
    private let labelRadius: CGFloat = 41
    private let tickRadius: CGFloat = 66
    
    // Midday peak-UV window (≈11am–1pm), drawn as a separate arc near the bottom of the dial.
    private let uvWindow = (start: 660.0, end: 780.0)
    
    private struct Interval: Identifiable {
        let id = UUID()
        let startMinute: Double
        let endMinute: Double
        let isOutdoor: Bool
    }
    
    private var intervals: [Interval] {
        let sorted = indoorOutdoorObservations.sorted { $0.timestamp < $1.timestamp }
        guard !sorted.isEmpty else { return [] }
        
        var result: [Interval] = []
        
        for (i, obs) in sorted.enumerated() {
            let start = minuteOfDay(obs.timestamp)
            
            // End of this arc = start of next observation, or midnight (1440) for the last one
            let end: Double
            if i + 1 < sorted.count {
                end = minuteOfDay(sorted[i + 1].timestamp)
            } else {
                end = 1440
            }
            
            guard end > start else { continue }   // skip zero-width or wrap-around arcs
            
            let isOutdoor = obs.classifierLabel.lowercased() == "outdoor"
            result.append(Interval(startMinute: start, endMinute: end, isOutdoor: isOutdoor))
        }
        
        return result
    }
    
    var body: some View {
        ZStack {
            ForEach(intervals) { interval in
                RingArc(startMinute: interval.startMinute, endMinute: interval.endMinute, radius: ringRadius)
                    .stroke(interval.isOutdoor ? Color.outdoor : Color.indoor,
                            style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
            }
            
            RingArc(startMinute: uvWindow.start, endMinute: uvWindow.end, radius: uvRadius)
                .stroke(Color.vermillion, style: StrokeStyle(lineWidth: uvWidth, lineCap: .round))
            
            Circle()
                .fill(.white)
                .frame(width: faceDiameter, height: faceDiameter)
            
            tick(width: 2, height: 6).offset(y: -tickRadius)
            tick(width: 2, height: 6).offset(y: tickRadius)
            tick(width: 6, height: 2).offset(x: tickRadius)
            tick(width: 6, height: 2).offset(x: -tickRadius)
            
            label("12", period: "am").offset(y: -labelRadius)
            label("6",  period: nil).offset(x: labelRadius)
            label("12", period: "pm").offset(y: labelRadius)
            label("18", period: nil).offset(x: -labelRadius)
        }
        .frame(width: dialSize, height: dialSize)
    }
    
    private func label(_ number: String, period: String?) -> some View {
        VStack(spacing: 0) {
            Text(number)
                .font(AppFont.medium(22))
            if let period {
                Text(period)
                    .font(AppFont.regular(9))
                    .opacity(0.55)
            }
        }
        .foregroundStyle(Palette.ink)
    }
    
    private func tick(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 1, style: .continuous)
            .fill(Palette.ink)
            .frame(width: width, height: height)
    }
    
    private func minuteOfDay(_ date: Date) -> Double {
            let cal = Calendar.current
            let comps = cal.dateComponents([.hour, .minute, .second], from: date)
            return Double((comps.hour ?? 0) * 60 + (comps.minute ?? 0)) + Double(comps.second ?? 0) / 60.0
        }
}

/// An arc segment spanning a minute range on a 24-hour dial where midnight sits
/// at the top and time advances clockwise (6 → right, noon → bottom, 18 → left).
private struct RingArc: Shape {
    var startMinute: Double
    var endMinute: Double
    var radius: CGFloat
    
    /// Position angle for a minute, in the addArc convention (0° = right,
    /// 90° = bottom, 180° = left, 270° = top), advancing clockwise.
    private func degrees(_ minute: Double) -> Double { 270 + minute / 4.0 }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: radius,
            startAngle: .degrees(degrees(startMinute)),
            endAngle: .degrees(degrees(endMinute)),
            clockwise: false
        )
        return path
    }
}

#Preview {
IndoorOutdoorClock(indoorOutdoorObservations: PreviewData.observations)
        .padding()
        .background(Color.shrek)
}
