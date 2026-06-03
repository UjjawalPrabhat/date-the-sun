import SwiftUI

/// A JRPG / Harvest Moon style dialogue panel that sits along the bottom of the
/// screen: a speaker name tag tucked over the top-left edge, the line typing out
/// as if Kiran is speaking it, and a gently blinking continue chevron.
struct DialogueBox: View {
    let speaker: String
    let text: String

    @State private var shown: String = ""
    @State private var typeTask: Task<Void, Never>?
    @State private var bob = false

    private let cornerRadius: CGFloat = 20

    var body: some View {
        // Reserve the full size with an invisible copy so the panel holds its
        // shape while the words reveal into it.
        Text(text)
            .opacity(0)
            .accessibilityHidden(true)
            .overlay(alignment: .topLeading) {
                Text(shown)
                    .accessibilityLabel(text)
            }
            .font(AppFont.medium(17))
            .foregroundStyle(Palette.subInk)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, minHeight: 50, alignment: .topLeading)
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 18)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Palette.shirt)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Palette.ink.opacity(0.10), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
            )
            .overlay(alignment: .topLeading) { nameTag }
            .overlay(alignment: .bottomTrailing) { continueChevron }
            .onAppear {
                startTyping()
                bob = true
            }
            .onDisappear { typeTask?.cancel() }
            .onChange(of: text) { startTyping() }
    }

    private var nameTag: some View {
        Text(speaker)
            .font(AppFont.semibold(14))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 5)
            .background(Capsule(style: .continuous).fill(Palette.cardHeader))
            .offset(x: 16, y: -13)
    }

    private var continueChevron: some View {
        Image(systemName: "arrowtriangle.down.fill")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(Palette.ink.opacity(0.35))
            .padding(.trailing, 16)
            .padding(.bottom, 12)
            .offset(y: bob ? 2 : -1)
            .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: bob)
    }

    /// Reveals the message one character at a time, lingering on punctuation so
    /// the cadence feels spoken rather than printed.
    private func startTyping() {
        typeTask?.cancel()
        shown = ""
        let full = text
        typeTask = Task { @MainActor in
            for index in full.indices {
                shown = String(full[...index])
                let pause = ",.!?—".contains(full[index]) ? 230 : 30
                try? await Task.sleep(for: .milliseconds(pause))
                if Task.isCancelled { return }
            }
        }
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        SkyGlow().ignoresSafeArea()
        DialogueBox(speaker: "Kiran", text: "You're so understanding and attentive of me, I can't love you enough.")
            .padding(.horizontal, 18)
            .padding(.bottom, 80)
    }
}
