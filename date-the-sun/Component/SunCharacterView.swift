//
//  SunCharacterView.swift
//  date-the-sun
//
//  The "Sun" mascot. If an illustrated asset named `imageName` exists in the
//  asset catalog it is used; otherwise a vector stand-in is drawn so the
//  screen is always complete.
//

import SwiftUI

/// Kiran's mood, driven by how well the user balances their time in the sun.
/// (See "KIRAN Brief Character Page".)
enum KiranMood: String, CaseIterable {
    case happy      // balanced — warm pink corona, beaming
    case calm       // balanced — cool blue corona, gentle smile
    case neutral    // a little too much / too little — orange corona
    case toxic      // way too much or way too little — fiery red corona, scowling

    var assetName: String {
        switch self {
        case .happy:   "KiranHappy"
        case .calm:    "KiranCalm"
        case .neutral: "KiranNeutral"
        case .toxic:   "KiranToxic"
        }
    }

    /// Corona color, useful for tinting accents to match Kiran's mood.
    var accent: Color {
        switch self {
        case .happy:   Color(hex: 0xEC5F86)
        case .calm:    Color(hex: 0x2E48C8)
        case .neutral: Color(hex: 0xF26A1B)
        case .toxic:   Color(hex: 0xB01E1E)
        }
    }

    /// A representative line of dialogue from the character brief.
    var line: String {
        switch self {
        case .happy:   "You're so understanding and attentive of me, I can't love you enough."
        case .calm:    "I like how you know me well and what you've been doing so far. Thank you."
        case .neutral: "I wanna see you. Don't get yourself too busy that you'd forget about me."
        case .toxic:   "Your obsession with me is getting out of hand! I need space, stay away!"
        }
    }
}

/// Displays Kiran in the given mood using the illustrated asset, falling back
/// to a vector rendition if the asset is unavailable (e.g. in some previews).
struct SunCharacterView: View {
    var mood: KiranMood = .neutral

    var body: some View {
        if UIImage(named: mood.assetName) != nil {
            Image(mood.assetName)
                .resizable()
        } else {
            VectorSunCharacter()
        }
    }
}

private enum Ink {
    static let line = Color(hex: 0x3E2A14)
    static func stroke(_ width: CGFloat = 2) -> StrokeStyle {
        StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round)
    }
}

/// Pure-SwiftUI rendition of the mascot: a glowing sun head over a wrapped,
/// single-figure body so nothing reads as floating shapes.
private struct VectorSunCharacter: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let head = w * 0.74

            ZStack {
                // Lower body: hips + legs as one connected shape.
                LowerBodyShape()
                    .fill(
                        LinearGradient(colors: [Palette.pants.opacity(0.95), Palette.pants],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(LowerBodyShape().stroke(Ink.line.opacity(0.35), style: Ink.stroke(2)))
                    .frame(width: w * 0.58, height: h * 0.62)
                    .position(x: w * 0.5, y: h * 0.74)

                // Neck linking head and torso.
                Capsule()
                    .fill(Palette.skin)
                    .frame(width: w * 0.13, height: h * 0.1)
                    .position(x: w * 0.5, y: h * 0.36)

                // Torso: white shirt with the olive sash wrapped over it.
                TorsoView()
                    .frame(width: w * 0.6, height: h * 0.34)
                    .position(x: w * 0.5, y: h * 0.5)

                // Head with corona of rays.
                SunHead()
                    .frame(width: head, height: head)
                    .position(x: w * 0.5, y: h * 0.21)
            }
        }
    }
}

// MARK: - Head

private struct SunHead: View {
    var body: some View {
        ZStack {
            // Back corona, rotated to fill the gaps of the front one.
            SunburstShape(points: 12, innerRatio: 0.46)
                .fill(Palette.rayOuter)
                .rotationEffect(.degrees(15))
                .scaleEffect(1.03)

            // Front corona with a warm vertical gradient + soft outline.
            SunburstShape(points: 12, innerRatio: 0.5)
                .fill(
                    LinearGradient(colors: [Palette.rayInner, Palette.rayOuter],
                                   startPoint: .top, endPoint: .bottom)
                )
                .overlay(
                    SunburstShape(points: 12, innerRatio: 0.5)
                        .stroke(Ink.line.opacity(0.25), lineWidth: 1.5)
                )

            // Face, sized proportionally to the head.
            GeometryReader { geo in
                FaceView()
                    .frame(width: geo.size.width * 0.54,
                           height: geo.size.height * 0.64)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
    }
}

private struct FaceView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                Ellipse()
                    .fill(Palette.face)
                    .overlay(
                        Ellipse()
                            .fill(
                                LinearGradient(colors: [.clear, Palette.faceShade.opacity(0.35)],
                                               startPoint: .center, endPoint: .bottom)
                            )
                    )

                // Blush
                blush.position(x: w * 0.26, y: h * 0.6)
                blush.position(x: w * 0.74, y: h * 0.6)

                // Eyes
                eye.frame(width: w * 0.11, height: h * 0.17)
                    .position(x: w * 0.36, y: h * 0.45)
                eye.frame(width: w * 0.11, height: h * 0.17)
                    .position(x: w * 0.64, y: h * 0.45)

                // Smile
                SmileShape()
                    .stroke(Palette.feature, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: w * 0.3, height: h * 0.12)
                    .position(x: w * 0.5, y: h * 0.66)
            }
        }
    }

    private var eye: some View {
        Capsule().fill(Palette.feature)
    }

    private var blush: some View {
        Ellipse()
            .fill(Palette.rayInner.opacity(0.4))
            .frame(width: 15, height: 9)
            .blur(radius: 3)
    }
}

// MARK: - Torso (shirt + sash)

private struct TorsoView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                TorsoShape().fill(Palette.shirt)

                // Diagonal sash drape from shoulder to opposite hip.
                Rectangle()
                    .fill(
                        LinearGradient(colors: [Palette.sash, Palette.sashShade],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: w * 0.5, height: h * 1.9)
                    .rotationEffect(.degrees(34))
                    .position(x: w * 0.44, y: h * 0.52)

                // Wrap around the waist.
                Rectangle()
                    .fill(Palette.sashShade)
                    .frame(width: w * 1.3, height: h * 0.38)
                    .position(x: w * 0.5, y: h * 0.84)

                // Soft fold highlight on the sash.
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: w * 0.08, height: h * 1.9)
                    .rotationEffect(.degrees(34))
                    .position(x: w * 0.34, y: h * 0.52)
            }
            .clipShape(TorsoShape())
            .overlay(TorsoShape().stroke(Ink.line.opacity(0.3), style: Ink.stroke(2)))
        }
    }
}

/// Shirt outline: rounded shoulders tapering toward the waist.
private struct TorsoShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + w * 0.16, y: rect.maxY))            // waist left
        path.addLine(to: CGPoint(x: rect.minX + w * 0.02, y: rect.minY + h * 0.24)) // shoulder left
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + w * 0.34, y: rect.minY),
            control: CGPoint(x: rect.minX + w * 0.06, y: rect.minY)
        )
        path.addQuadCurve(                                                       // neckline dip
            to: CGPoint(x: rect.minX + w * 0.66, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.minY + h * 0.1)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - w * 0.02, y: rect.minY + h * 0.24),
            control: CGPoint(x: rect.maxX - w * 0.06, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - w * 0.16, y: rect.maxY))         // waist right
        path.closeSubpath()
        return path
    }
}

// MARK: - Lower body (hips + legs)

private struct LowerBodyShape: Shape {
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
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))                    // right leg outer
        path.addLine(to: CGPoint(x: midX + gap / 2, y: rect.maxY))               // right leg inner
        path.addLine(to: CGPoint(x: midX, y: crotchY))                           // crotch
        path.addLine(to: CGPoint(x: midX - gap / 2, y: rect.maxY))               // left leg inner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))                    // left leg outer
        path.closeSubpath()
        return path
    }
}

#Preview("Moods") {
    ScrollView(.horizontal) {
        HStack(spacing: 0) {
            ForEach(KiranMood.allCases, id: \.self) { mood in
                ZStack {
                    LinearGradient(colors: [Palette.skyTop, Palette.fieldBottom],
                                   startPoint: .top, endPoint: .bottom)
                    SunCharacterView(mood: mood)
                        .scaledToFit()
                }
                .frame(width: 280, height: 600)
            }
        }
    }
    .ignoresSafeArea()
}
