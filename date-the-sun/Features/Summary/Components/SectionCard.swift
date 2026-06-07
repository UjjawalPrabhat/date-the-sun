import SwiftUI

/// A rounded card with a black title header (icon + title + info button) over a
/// colored body. Shared by the Sun Exposure and Protection Log cards.
struct SectionCard<Content: View>: View {
    let title: String
    let systemImage: String
    var background: Color
    /// Optional explanatory copy. When provided, the header's "?" button becomes
    /// tappable and presents an info sheet.
    var info: WidgetInfo? = nil
    @ViewBuilder var content: () -> Content

    private let cornerRadius: CGFloat = 22
    @State private var showInfo = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
                    .font(AppFont.semibold(17))
                Spacer()
                if info != nil {
                    Button {
                        showInfo = true
                    } label: {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("About \(title)")
                }
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
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .sheet(isPresented: $showInfo) {
            if let info {
                WidgetInfoSheet(info: info)
            }
        }
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
