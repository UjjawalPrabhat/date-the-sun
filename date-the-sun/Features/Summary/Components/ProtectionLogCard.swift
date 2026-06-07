import SwiftUI

/// The pink Protection Log card listing the day's protection habits with a
/// tappable completion radio per row.
struct ProtectionLogCard: View {
    let items: [ProtectionItem]
    var onToggle: (ProtectionItem) -> Void = { _ in }

    var body: some View {
        SectionCard(title: "Protection Log", systemImage: "checkmark.shield.fill", background: Palette.pants, info: .protectionLogDaily) {
            VStack(spacing: 12) {
                ForEach(items) { item in
                    ProtectionRow(item: item) { onToggle(item) }
                }
            }
            .padding(16)
        }
    }
}

private struct ProtectionRow: View {
    let item: ProtectionItem
    var onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.systemImage)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Palette.ink)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(AppFont.semibold(16))
                    .foregroundStyle(Palette.ink)
                Text(item.subtitle)
                    .font(AppFont.medium(13))
                    .foregroundStyle(Palette.rowSubtitle)
            }

            Spacer()

            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(item.isCompleted ? Palette.ink : Palette.ink.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
        )
    }
}

#Preview {
    ProtectionLogCard(items: [
        .init(title: "Sunscreen", subtitle: "Apply when going outside", systemImage: "drop.fill", isCompleted: true),
        .init(title: "Protective Clothing", subtitle: "Use hat and long-sleeved shirt", systemImage: "tshirt.fill", isCompleted: false),
    ])
    .padding()
    .background(Palette.canvas)
}
