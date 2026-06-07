import SwiftUI
#if canImport(Lottie)
import Lottie
#endif

/// Kiran with life and interaction: a continuous idle float + sway, a tap that
/// makes her bounce (and fires `onTap`), and a drag that lets you nudge her so
/// she leans toward your finger and springs back on release.
struct InteractiveKiranView: View {
    var mood: KiranMood
    var onTap: () -> Void = {}

    @State private var idleFloat: CGFloat = 0
    @State private var idleSway: Double = -2
    @State private var pressScale: CGFloat = 1
    @State private var dragOffset: CGSize = .zero
    @State private var dragTilt: Double = 0

    var body: some View {
        character
            .id(mood)
            .transition(.opacity.combined(with: .scale(scale: 0.96)))
            .scaleEffect(pressScale, anchor: .bottom)
            .rotationEffect(.degrees(idleSway + dragTilt), anchor: .bottom)
            .offset(x: dragOffset.width, y: idleFloat + dragOffset.height)
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .onTapGesture { tap() }
            .onAppear(perform: startIdleAnimation)
    }

    /// Kiran's body: a looping Lottie scene when one exists for this mood (she
    /// blinks and sways on her own), otherwise the static illustration. Guarded
    /// by `#if canImport(Lottie)` so the app still builds — static-only — before
    /// the Lottie Swift package is added.
    @ViewBuilder
    private var character: some View {
        #if canImport(Lottie)
        if let name = mood.lottieName {
            LottieView(animation: .named(name))
                .looping()
                .resizable()
                .aspectRatio(1080.0 / 1920.0, contentMode: .fit) // match canvas + static image
        } else {
            staticCharacter
        }
        #else
        staticCharacter
        #endif
    }

    private var staticCharacter: some View {
        Image(mood.assetName)
            .resizable()
            .scaledToFit()
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = CGSize(width: value.translation.width * 0.35,
                                    height: value.translation.height * 0.22)
                dragTilt = Double(value.translation.width) * 0.05
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.45)) {
                    dragOffset = .zero
                    dragTilt = 0
                }
            }
    }

    private func tap() {
        // Squash-and-stretch bounce, then notify.
        withAnimation(.spring(response: 0.16, dampingFraction: 0.45)) { pressScale = 1.10 }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.55).delay(0.12)) { pressScale = 1.0 }
        onTap()
    }

    private func startIdleAnimation() {
        withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
            idleFloat = -14
            idleSway = 2
        }
    }
}

#Preview {
    struct Demo: View {
        @State private var mood: KiranMood = .happy
        var body: some View {
            ZStack {
                SkyGlowBackground().ignoresSafeArea()
                InteractiveKiranView(mood: mood) {
                    let all = KiranMood.allCases
                    mood = all[((all.firstIndex(of: mood) ?? 0) + 1) % all.count]
                }
                .padding(40)
            }
        }
    }
    return Demo()
}
