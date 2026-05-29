import SwiftUI

/// White canvas with a soft blue glow behind the character (the Today screen).
struct SkyGlowBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0xE8F3FB), .white],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [
                    Color(hex: 0xBBDDF2).opacity(0.85),
                    Color(hex: 0xD6EAF7).opacity(0.35),
                    .clear,
                ],
                center: UnitPoint(x: 0.5, y: 0.42),
                startRadius: 8,
                endRadius: 330
            )
        }
    }
}

/// Sky-to-field gradient with a soft flower-field bokeh (the Summary screen).
struct FieldBackground: View {
    private let dots: [(x: CGFloat, y: CGFloat, r: CGFloat, color: Color)] = [
        (0.12, 0.72, 10, .white),
        (0.22, 0.86, 7,  Palette.pill),
        (0.35, 0.78, 9,  .white),
        (0.5,  0.9,  8,  Palette.pants),
        (0.66, 0.74, 11, .white),
        (0.8,  0.85, 7,  Palette.sash),
        (0.9,  0.7,  9,  .white),
        (0.08, 0.9,  8,  Palette.pill),
        (0.45, 0.68, 7,  .white),
        (0.74, 0.92, 9,  .white),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Palette.skyTop, location: 0.0),
                    .init(color: Palette.skyBottom, location: 0.32),
                    .init(color: Palette.fieldTop, location: 0.58),
                    .init(color: Palette.fieldBottom, location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Canvas { context, size in
                for dot in dots {
                    let rect = CGRect(
                        x: size.width * dot.x - dot.r,
                        y: size.height * dot.y - dot.r,
                        width: dot.r * 2,
                        height: dot.r * 2
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(dot.color.opacity(0.45)))
                }
            }
            .blur(radius: 2)
        }
    }
}
