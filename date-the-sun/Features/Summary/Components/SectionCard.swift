import SwiftUI

/// A rounded card with a black title header (icon + title + info button) over a
/// colored body. Shared by the Sun Exposure and Protection Log cards.
struct SectionCard<Content: View>: View {
    let title: String
    let systemImage: String
    var background: Color
    @ViewBuilder var content: () -> Content

    private let cornerRadius: CGFloat = 22

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
                    .font(AppFont.semibold(17))
                Spacer()
                Image(systemName: "questionmark.circle.fill")
                    .foregroundStyle(.white.opacity(0.85))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Palette.cardHeader)

            content()
                .frame(maxWidth: .infinity)
                .background(background)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Palette.ink, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}

#Preview {
    SectionCard(title: "Sun Exposure", systemImage: "sun.max.fill", background: .shrek) {
        Text("Body")
            .padding(40)
    }
    .padding()
    .background(Palette.canvas)
}
