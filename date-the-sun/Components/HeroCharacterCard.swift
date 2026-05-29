import SwiftUI

/// The blue hero card: a bold headline on the left with Kiran overlapping on
/// the right, clipped to the card's rounded rect.
struct HeroCharacterCard: View {
    let headline: String
    var mood: KiranMood

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear

            SunCharacterView(mood: mood)
                .scaledToFit()
                .frame(maxWidth: .infinity, alignment: .trailing)
                .scaleEffect(1.25, anchor: .top)
                .offset(x: 30, y: 30)

            Text(headline)
                .font(.system(size: 30, weight: .heavy))
                .foregroundStyle(Palette.ink)
                .lineLimit(5)
                .minimumScaleFactor(0.6)
                .frame(width: 180, alignment: .leading)
                .padding(24)
        }
        .frame(height: 360)
        .frame(maxWidth: .infinity)
        .background(Palette.heroSky)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

#Preview {
    HeroCharacterCard(headline: "What a happy day — especially with you", mood: .happy)
        .padding()
        .background(Palette.canvas)
}
