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
                    .frame(width: geo.size.width * 0.80)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .offset(y: geo.size.height * 0.15)
            }
            .ignoresSafeArea()

            GeometryReader { geo in
                SpeechBubble(text: viewModel.message)
                    .frame(width: min(178, geo.size.width * 0.46))
                    .position(x: geo.size.width * 0.29, y: geo.size.height * 0.55)
            }

            VStack(spacing: 12) {
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
        }
    }
}

#Preview {
    TodayView(viewModel: TodayViewModel())
}
