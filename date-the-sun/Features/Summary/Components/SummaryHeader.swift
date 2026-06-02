import SwiftUI

/// The Summary screen's top bar: the current date and a circular calendar button.
struct SummaryHeader: View {
    let dateText: String
    var onCalendarTap: () -> Void = {}

    var body: some View {
        HStack {
            Text(dateText)
                .font(AppFont.medium(30))
                .foregroundStyle(Palette.ink)

            Spacer()

            Button(action: onCalendarTap) {
                Image(systemName: "calendar")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Palette.cardHeader))
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    SummaryHeader(dateText: "16 May 2026")
        .padding()
        .background(Palette.canvas)
}
