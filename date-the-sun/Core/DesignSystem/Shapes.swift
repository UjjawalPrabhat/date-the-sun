import SwiftUI

/// A spiky sun corona — a star polygon with `points` tips.
struct SunburstShape: Shape {
    var points: Int = 12
    /// Ratio of the inner valley radius to the outer tip radius.
    var innerRatio: CGFloat = 0.52

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * innerRatio
        let total = points * 2
        let step = Double.pi / Double(points)

        for i in 0..<total {
            let radius = i.isMultiple(of: 2) ? outer : inner
            let angle = Double(i) * step - .pi / 2
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

/// A gentle upward smile drawn as a single quad curve.
struct SmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.maxY * 1.6)
        )
        return path
    }
}

/// A rounded speech bubble with a tail pointing down toward the character.
struct SpeechBubbleShape: Shape {
    var cornerRadius: CGFloat = 18
    var tailHeight: CGFloat = 14
    /// Horizontal position of the tail, 0...1 across the bubble width.
    var tailAnchor: CGFloat = 0.72

    func path(in rect: CGRect) -> Path {
        let body = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: rect.height - tailHeight
        )
        var path = Path(roundedRect: body, cornerRadius: cornerRadius)

        let tailX = rect.minX + rect.width * tailAnchor
        var tail = Path()
        tail.move(to: CGPoint(x: tailX - 11, y: body.maxY - 1))
        tail.addLine(to: CGPoint(x: tailX + 9, y: rect.maxY))
        tail.addLine(to: CGPoint(x: tailX + 14, y: body.maxY - 1))
        tail.closeSubpath()
        path.addPath(tail)
        return path
    }
}

/// A pie wedge spanning an arc of the 24-hour clock (minutes in 0–1440 space).
struct WedgeShape: Shape {
    var startMinute: Double
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

/// Shirt outline: rounded shoulders tapering toward the waist.
struct TorsoShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + w * 0.16, y: rect.maxY))                // waist left
        path.addLine(to: CGPoint(x: rect.minX + w * 0.02, y: rect.minY + h * 0.24))  // shoulder left
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + w * 0.34, y: rect.minY),
            control: CGPoint(x: rect.minX + w * 0.06, y: rect.minY)
        )
        path.addQuadCurve(                                                           // neckline dip
            to: CGPoint(x: rect.minX + w * 0.66, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.minY + h * 0.1)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - w * 0.02, y: rect.minY + h * 0.24),
            control: CGPoint(x: rect.maxX - w * 0.06, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - w * 0.16, y: rect.maxY))             // waist right
        path.closeSubpath()
        return path
    }
}

/// Hips and legs as one connected shape.
struct LowerBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let r = w * 0.18                 // hip corner rounding
        let gap = w * 0.1                // gap between legs
        let crotchY = rect.minY + h * 0.5
        let midX = rect.midX

        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + r))
        path.addQuadCurve(to: CGPoint(x: rect.minX + r, y: rect.minY),
                          control: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + r),
                          control: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))                        // right leg outer
        path.addLine(to: CGPoint(x: midX + gap / 2, y: rect.maxY))                   // right leg inner
        path.addLine(to: CGPoint(x: midX, y: crotchY))                               // crotch
        path.addLine(to: CGPoint(x: midX - gap / 2, y: rect.maxY))                   // left leg inner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))                        // left leg outer
        path.closeSubpath()
        return path
    }
}
