import SwiftUI

/// The soft blue halo over a white base. Reusable so the Today background and the
/// Summary hero card share the exact same glow, tying the two screens together.
struct SkyGlow: View {
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

/// Full-screen sky glow used as the Today screen's background.
struct SkyGlowBackground: View {
    var body: some View {
        SkyGlow()
    }
}
