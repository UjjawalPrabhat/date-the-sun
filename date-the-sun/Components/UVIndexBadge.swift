import SwiftUI

/// A pill badge showing the current UV index.
struct UVIndexBadge: View {
    var value: Int

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Palette.uvIcon)
            Text("UV Index")
            Text("\(value)")
        }
        .font(.system(size: 20, weight: .regular))
        .foregroundStyle(Palette.ink)
        .padding(.horizontal, 22)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(Palette.pill)
                .overlay(Capsule().stroke(Palette.pillStroke, lineWidth: 1))
                .shadow(color: Palette.pillStroke.opacity(0.4), radius: 6, y: 3)
        )
    }
}

#Preview {
    UVIndexBadge(value: 4)
}
