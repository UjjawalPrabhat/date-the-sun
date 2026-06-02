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
            .padding(.bottom, 28) // room for the tail
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                SpeechBubbleShape(tailAnchor: 0.7)
                    .fill(Palette.shirt)
                    .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
            )
    }
}

/// A rounded speech bubble with a tail pointing down toward the character.
struct SpeechBubbleShape: Shape {
    var cornerRadius: CGFloat = 18
    var tailHeight: CGFloat = 14
    /// Horizontal position of the tail, 0...1 across the bubble width.
    var tailAnchor: CGFloat = 0.72

    func path(in rect: CGRect) -> Path {
        let body = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height - tailHeight)
        var path = Path(roundedRect: body, cornerRadius: cornerRadius)

        let tailX = rect.minX + rect.width * tailAnchor
        var tail = Path()
        tail.move(to: CGPoint(x: tailX - 11, y: body.maxY - 1))
        tail.addLine(to: CGPoint(x: tailX + 9, y: rect.maxY))
        tail.addLine(to: CGPoint(x: tailX + 14, y: body.maxY - 1))
        tail.closeSubpath()
        path.addPath(tail)
        return path
    }
}

#Preview {
    SpeechBubble(text: "Sun's out, it's gentle today. Perfect weather for a light stroll.")
        .frame(width: 178)
}
