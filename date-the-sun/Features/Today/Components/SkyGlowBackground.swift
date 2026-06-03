import SwiftUI

/// The Today screen background: a soft blue glow up top fading into the app's
/// cream canvas, with a brighter halo behind the character.
struct SkyGlowBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Palette.skyTop, Palette.canvas],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [
                    Palette.glowCore.opacity(0.85),
                    Palette.glowEdge.opacity(0.35),
                    .clear,
                ],
                center: UnitPoint(x: 0.5, y: 0.42),
                startRadius: 8,
                endRadius: 330
            )
        }
    }
}
