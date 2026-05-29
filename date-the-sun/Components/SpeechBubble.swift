import SwiftUI

/// A speech bubble with a downward tail, used for Kiran's dialogue.
struct SpeechBubble: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(Palette.subInk)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 14 + 14) // leave room for the tail
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                SpeechBubbleShape(tailAnchor: 0.7)
                    .fill(Palette.shirt)
                    .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
            )
    }
}

#Preview {
    SpeechBubble(text: "Sun's out, it's gentle today. Perfect weather for a light stroll.")
        .frame(width: 178)
}
