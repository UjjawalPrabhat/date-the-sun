import SwiftUI

/// A Daily / Weekly segmented control bound to a `SummaryPeriod`.
struct PeriodToggle: View {
    @Binding var selection: SummaryPeriod
    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 4) {
            ForEach(SummaryPeriod.allCases, id: \.self) { period in
                segment(period)
            }
        }
        .padding(4)
        .background(
            Capsule(style: .continuous)
                .fill(.white)
                .overlay(Capsule().stroke(Palette.ink.opacity(0.12), lineWidth: 1))
        )
    }

    private func segment(_ period: SummaryPeriod) -> some View {
        let isSelected = selection == period
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                selection = period
            }
        } label: {
            Text(period.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isSelected ? .white : Palette.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background {
                    if isSelected {
                        Capsule(style: .continuous)
                            .fill(Palette.cardHeader)
                            .matchedGeometryEffect(id: "periodHighlight", in: namespace)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    struct Demo: View {
        @State private var sel: SummaryPeriod = .daily
        @Namespace private var ns
        var body: some View {
            PeriodToggle(selection: $sel, namespace: ns)
                .padding()
                .background(Palette.canvas)
        }
    }
    return Demo()
}
