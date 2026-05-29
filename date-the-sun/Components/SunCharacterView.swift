import SwiftUI

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
                LowerBodyShape()
                    .fill(
                        LinearGradient(colors: [Palette.pants.opacity(0.95), Palette.pants],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(LowerBodyShape().stroke(Ink.line.opacity(0.35), style: Ink.stroke(2)))
                    .frame(width: w * 0.58, height: h * 0.62)
                    .position(x: w * 0.5, y: h * 0.74)

                Capsule()
                    .fill(Palette.skin)
                    .frame(width: w * 0.13, height: h * 0.1)
                    .position(x: w * 0.5, y: h * 0.36)

                TorsoView()
                    .frame(width: w * 0.6, height: h * 0.34)
                    .position(x: w * 0.5, y: h * 0.5)

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
    private let blushOffsets: [CGFloat] = [0.26, 0.74]

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

                ForEach(blushOffsets, id: \.self) { fx in
                    blush.position(x: w * fx, y: h * 0.6)
                }

                eye.frame(width: w * 0.11, height: h * 0.17)
                    .position(x: w * 0.36, y: h * 0.45)
                eye.frame(width: w * 0.11, height: h * 0.17)
                    .position(x: w * 0.64, y: h * 0.45)

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
