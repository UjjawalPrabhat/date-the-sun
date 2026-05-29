import SwiftUI

/// The Today screen: greeting, UV index, the full-body Sun mascot and a
/// contextual speech bubble over a soft blue-glow background.
struct TodayView: View {
    @StateObject private var viewModel: TodayViewModel

    init(viewModel: TodayViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .top) {
            SkyGlowBackground()
                .ignoresSafeArea()

            GeometryReader { geo in
                SunCharacterView(mood: viewModel.mood)
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.82)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .offset(y: geo.size.height * 0.15)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .black, location: 0.0),
                                .init(color: .black, location: 0.80),
                                .init(color: .clear, location: 0.97),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .ignoresSafeArea()

            GeometryReader { geo in
                SpeechBubble(text: viewModel.message)
                    .frame(width: min(196, geo.size.width * 0.5))
                    .position(x: geo.size.width * 0.30, y: geo.size.height * 0.47)
            }

            VStack(spacing: 14) {
                Text("\(viewModel.greeting), \(viewModel.userName)")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)

                UVIndexBadge(value: viewModel.uvIndex)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
    }
}

#Preview {
    TodayView(viewModel: TodayViewModel())
}
