//
//  DesignSystem.swift
//  date-the-sun
//
//  Shared colors and reusable shapes for the main screen design.
//

import SwiftUI

// MARK: - Color helpers

extension Color {
    /// Create a color from a 0xRRGGBB hex literal.
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

/// Palette tuned to the "Main Screen Option 2 (Neutral)" mock.
enum Palette {
    static let ink        = Color(hex: 0x1A2238)   // headline navy
    static let subInk     = Color(hex: 0x3C4257)   // speech-bubble text

    // Sky → field gradient
    static let skyTop     = Color(hex: 0xCFE4F1)
    static let skyBottom  = Color(hex: 0xDDEBDF)
    static let fieldTop   = Color(hex: 0xC3D9A7)
    static let fieldBottom = Color(hex: 0xA1C57E)

    // UV pill
    static let pill       = Color(hex: 0xFFC83D)
    static let pillStroke = Color(hex: 0xE9A92B)

    // Sun character
    static let rayOuter   = Color(hex: 0xF15A24)   // deep orange tips
    static let rayInner   = Color(hex: 0xFFA12E)   // warm orange
    static let face       = Color(hex: 0xFBC74A)   // golden face
    static let faceShade  = Color(hex: 0xF1A93B)
    static let feature    = Color(hex: 0x4A2C12)   // eyes / smile

    // Outfit
    static let sash       = Color(hex: 0x9AA63E)   // olive wrap
    static let sashShade  = Color(hex: 0x7E8A30)
    static let shirt      = Color(hex: 0xFBFAF4)   // off-white tee
    static let pants      = Color(hex: 0xE0739B)   // pink trousers
    static let skin       = Color(hex: 0xF6C249)

    // Tab bar
    static let barBG      = Color(hex: 0x14151A)
    static let barIcon    = Color(hex: 0xCFCFD4)
}

// MARK: - Shapes

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
