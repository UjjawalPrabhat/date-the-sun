import SwiftUI

/// The Summary screen: the day's indoor/outdoor sun-exposure clock.
struct SummaryView: View {
    @StateObject private var viewModel: SummaryViewModel

    init(viewModel: SummaryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            FieldBackground()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Your Day in the Sun")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(Palette.ink)

                IndoorOutdoorClock(intervals: viewModel.intervals)
            }
            .padding(.bottom, 80)
        }
    }
}

#Preview {
    SummaryView(viewModel: SummaryViewModel())
}
