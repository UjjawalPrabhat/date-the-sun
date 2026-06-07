import SwiftUI

/// Describes the explanatory copy shown when a card's "?" button is tapped.
struct WidgetInfo {
    let title: String
    let systemImage: String
    /// A short paragraph describing what the widget shows.
    let summary: String
    /// Labelled bullet points explaining each element of the widget.
    let points: [Point]

    struct Point: Identifiable {
        let id = UUID()
        let label: String
        let detail: String
    }
}

/// A small sheet that explains what a dashboard card shows. Presented from the
/// "?" button in `SectionCard`'s header.
struct WidgetInfoSheet: View {
    let info: WidgetInfo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Palette.heroSky.opacity(0.18))
                                .frame(width: 52, height: 52)
                            Image(systemName: info.systemImage)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(Palette.heroSky)
                        }
                        Text(info.title)
                            .font(AppFont.semibold(22))
                            .foregroundStyle(Palette.ink)
                    }

                    Text(info.summary)
                        .font(AppFont.regular(15))
                        .foregroundStyle(Palette.subInk)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(info.points) { point in
                            VStack(alignment: .leading, spacing: 3) {
                                Text(point.label)
                                    .font(AppFont.semibold(15))
                                    .foregroundStyle(Palette.ink)
                                Text(point.detail)
                                    .font(AppFont.regular(14))
                                    .foregroundStyle(Palette.rowSubtitle)
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.white)
                    )
                }
                .padding(24)
            }
            .background(Palette.canvas.ignoresSafeArea())
            .navigationTitle("About this widget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    Color.clear.sheet(isPresented: .constant(true)) {
        WidgetInfoSheet(info: .sunExposureDaily)
    }
}
