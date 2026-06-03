import SwiftUI

/// The blue hero card: a bold headline with Kiran standing in the card, her
/// sun-head breaking above the top edge for a "stepping out of the screen" feel
/// while her legs crop to the rounded bottom. The headline sits centered in the
/// left column so it fills the card's height and balances the figure.
struct HeroCharacterCard: View {
    let headline: String
    var mood: KiranMood = .happy

    private let cardHeight: CGFloat = 360
    private let topOverflow: CGFloat = 48
    private let cornerRadius: CGFloat = 26
    private let figureAspect: CGFloat = 1253.0 / 3264.0

    var body: some View {
        Color.clear
            .frame(height: cardHeight)
            .overlay(alignment: .bottom) {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Palette.heroSky)
                        .frame(height: cardHeight)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)

                    Text(headline)
                        .font(AppFont.medium(38))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(6)
                        .minimumScaleFactor(0.6)
                        .lineSpacing(2)
                        .frame(width: 200, alignment: .leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: cardHeight, alignment: .top)
                        .padding(.top, 28)
                        .padding(.leading, 24)

                    GeometryReader { geo in
                        let w = geo.size.width
                        Image(mood.assetName)
                            .resizable()
                            .aspectRatio(figureAspect, contentMode: .fit)
                            .frame(width: w * 0.66)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .offset(x: w * 0.19, y: 6)
                            .id(mood)
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    }
                    .frame(height: cardHeight + topOverflow)
                    .clipShape(
                        UnevenRoundedRectangle(bottomLeadingRadius: cornerRadius, bottomTrailingRadius: cornerRadius, style: .continuous)
                    )
                }
                .frame(height: cardHeight + topOverflow)
            }
    }
}

#Preview {
    HeroCharacterCard(headline: "What a happy day — especially with you", mood: .happy)
        .padding()
        .background(Palette.canvas)
}
