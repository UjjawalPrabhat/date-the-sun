//
//  IndoorOutdoorClock.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 28/05/26.
//

import SwiftUI

struct ClockDataPoint: Identifiable {
    let id = UUID()
    let isOutdoor: Bool
    let startMinute: Double
    let endMinute: Double
}

struct IndoorOutdoorClock: View {
    var clockDataPoints: [ClockDataPoint] = []
    
    let radius: CGFloat = 100.0
    var body: some View {
        let startMinute: Double = 9 * 60
        let endMinute: Double = 5 * 60
        let wedge = WedgeShape(startMinute: startMinute, endMinute: endMinute, radius: radius + 10)
        ZStack {
            Circle()
                .fill(.gray.secondary)
                .frame(width: radius * 2, height: radius * 2)
            
            wedge
                .fill(
                    AngularGradient(
                        stops: [
                            .init(color: .purple.opacity(0), location: 0.0),
                            .init(color: .purple,            location: 0.5),
                            .init(color: .purple.opacity(0), location: 1.0),
                        ],
                        center: .center,
                        startAngle: .degrees(wedge.startDegrees),
                        endAngle:   .degrees(wedge.endDegrees + 360)
                    )
                )
            
            ForEach(clockDataPoints) { data in
                let shape = WedgeShape(startMinute: data.startMinute, endMinute: data.endMinute, radius: radius)
                
                shape
                    .foregroundStyle(data.isOutdoor ? .vermillion : .sea)
                
                shape
                    .stroke(.white.opacity(0.6), lineWidth: 1.5)
            }
            
            ForEach(1...12, id: \.self) { i in
                HourMark(i: i, radius: radius - 16)
            }
        }
    }
}

struct HourMark: View {
    var i: Int = 1
    var radius: CGFloat
    
    private var angle: Angle {
        .degrees(Double(i) / 12.0 * 360.0)
    }
    
    var body: some View {
        Text("\(i)")
            .rotationEffect(.degrees(-angle.degrees))
            .offset(y: -radius)
            .rotationEffect(angle)
            .font(.title2)
            .bold()
            .foregroundStyle(.white)
        
        //        Rectangle()
        //            .frame(width: 2, height: 10)
        //            .offset(y: -radius)
        //            .rotationEffect(angle)
    }
}

struct WedgeShape: Shape {
    var startMinute: Double
    var endMinute: Double
    var radius: CGFloat
    
    var startDegrees: Double { startMinute / 720 * 360 - 90 }
    var endDegrees: Double   { endMinute   / 720 * 360 - 90 }
    
    private func angle(for minute: Double) -> Angle {
        .degrees(minute / 720.0 * 360.0 - 90)
    }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: angle(for: startMinute),
            endAngle: angle(for: endMinute),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

#Preview {
    let data: [ClockDataPoint] = [
        .init(isOutdoor: false, startMinute: 9 * 60, endMinute: 12 * 60),
        .init(isOutdoor: true, startMinute: 0, endMinute: 15),
        .init(isOutdoor: false, startMinute: 15, endMinute: 60 + 10),
        .init(isOutdoor: true, startMinute: 60 + 10, endMinute: 5 * 60),
        .init(isOutdoor: false, startMinute: 5 * 60, endMinute: 6 * 60)
    ]
    
    IndoorOutdoorClock(clockDataPoints: data)
}
