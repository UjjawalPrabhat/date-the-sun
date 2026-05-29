//
//  FloatingTabBar.swift
//  date-the-sun
//
//  The custom dark pill tab bar shown floating at the bottom of the screen.
//

import SwiftUI

enum AppTab: Hashable {
    case today
    case summary
}

struct FloatingTabBar: View {
    @Binding var selection: AppTab
    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 4) {
            item(.today, system: "sun.max.fill")
            item(.summary, system: "newspaper.fill")
        }
        .padding(6)
        .background(
            Capsule(style: .continuous)
                .fill(Palette.barBG)
                .shadow(color: .black.opacity(0.25), radius: 14, y: 6)
        )
    }

    private func item(_ tab: AppTab, system: String) -> some View {
        let isSelected = selection == tab
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selection = tab
            }
        } label: {
            Image(systemName: system)
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
