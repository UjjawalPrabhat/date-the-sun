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
    let startMinute: Double // 0–719
    let endMinute: Double   // 0–719
    let isAM: Bool
    
    var absoluteStartMinute: Double {
        isAM ? startMinute : startMinute + 720
    }
    var absoluteEndMinute: Double {
        isAM ? endMinute : endMinute + 720
    }
}

struct IndoorOutdoorClock: View {
    var clockDataPoints: [ClockDataPoint] = []
    
    let radius: CGFloat = 90.0
    
    var body: some View {
        let startMinute: Double = 3 * 60
        let endMinute: Double = 10 * 60
        let wedge = WedgeShape(startMinute: startMinute, endMinute: endMinute, radius: radius + 20)
        
        ZStack {
            /// UV Index mark
            wedge
                .fill(
                    AngularGradient(
                        stops: [
                            .init(color: .vermillion.opacity(0), location: 0.0),
                            .init(color: .vermillion,            location: 0.5),
                            .init(color: .vermillion.opacity(0), location: 1.0),
                        ],
                        center: .center,
                        startAngle: .degrees(wedge.startDegrees),
                        endAngle:   .degrees(wedge.endDegrees)
                    )
                )
            
            Circle()
                .fill(.white)
                .frame(width: radius * 2, height: radius * 2)
            
            /// Night wege
            WedgeShape(startMinute: 11 * 60, endMinute: 1 * 60, radius: radius)
                .foregroundStyle(.night)
            
            ForEach(clockDataPoints) { data in
                WedgeShape(
                    startMinute: data.absoluteStartMinute,
                    endMinute: data.absoluteEndMinute,
                    radius: radius
                )
                .foregroundStyle(data.isOutdoor ? .outdoor : .indoor)
            }
            
            // Single unified 24-hour mark loop
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

struct WedgeShape: Shape {
    var startMinute: Double  // absolute 0–1440
    var endMinute: Double
    var radius: CGFloat
    
    var startDegrees: Double { startMinute / 1440.0 * 360.0 - 90.0 }
    var endDegrees:   Double { endMinute   / 1440.0 * 360.0 - 90.0 }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startDegrees),
            endAngle:   .degrees(endDegrees),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

#Preview {
    let data: [ClockDataPoint] = [
        .init(isOutdoor: false, startMinute: 1 * 60, endMinute: 4 * 60, isAM: true),
        .init(isOutdoor: true, startMinute: (4 * 60) , endMinute: (4 * 60) + 30, isAM: true),
        .init(isOutdoor: false, startMinute: (4 * 60) + 30, endMinute: (6 * 60) + 30, isAM: true),
        .init(isOutdoor: true, startMinute: (6 * 60) + 30, endMinute: (9 * 60) + 30, isAM: true),
        .init(isOutdoor: false, startMinute: (9 * 60) + 30, endMinute: 11 * 60, isAM: true),
    ]
    IndoorOutdoorClock(clockDataPoints: data)
}
