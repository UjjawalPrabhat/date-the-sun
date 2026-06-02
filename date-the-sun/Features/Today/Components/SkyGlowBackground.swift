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
