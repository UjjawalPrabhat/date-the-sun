import SwiftUI

enum AppTab: Hashable, CaseIterable {
    case today
    case summary

    var systemImage: String {
        switch self {
        case .today:   "sun.max.fill"
        case .summary: "newspaper.fill"
        }
    }
}

/// The custom dark pill tab bar floating at the bottom of the screen.
struct FloatingTabBar: View {
    @Binding var selection: AppTab
    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                item(tab)
            }
        }
        .padding(6)
        .background(
            Capsule(style: .continuous)
                .fill(Palette.barBG)
                .shadow(color: .black.opacity(0.25), radius: 14, y: 6)
        )
    }

    private func item(_ tab: AppTab) -> some View {
        let isSelected = selection == tab
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selection = tab
            }
        } label: {
            Image(systemName: tab.systemImage)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(isSelected ? Palette.ink : Palette.barIcon)
                .frame(width: isSelected ? 78 : 56, height: 44)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Palette.shirt)
                            .matchedGeometryEffect(id: "tabHighlight", in: namespace)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    struct Demo: View {
        @State private var sel: AppTab = .today
        @Namespace private var ns
        var body: some View {
            ZStack {
                Palette.fieldBottom.ignoresSafeArea()
                FloatingTabBar(selection: $sel, namespace: ns)
            }
        }
    }
    return Demo()
}
