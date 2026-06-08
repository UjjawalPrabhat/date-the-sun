//
//  DebugSheetModifier.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 06/06/26.
//

#if DEBUG
import SwiftUI
import SwiftData

/// Hidden debug trigger: tap the top-left corner twice within 2 seconds.
/// The tap zone is 60×60pt — invisible, sits above all content via ZStack overlay.
extension View {
    func debugSheet(modelContainer: ModelContainer) -> some View {
        modifier(DebugSheetModifier(modelContainer: modelContainer))
    }
}

private struct DebugSheetModifier: ViewModifier {
    let modelContainer: ModelContainer
    @State private var isPresented = false
    @State private var tapCount = 0
    @State private var resetTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                Color.clear
                    .frame(width: 60, height: 60)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        tapCount += 1
                        resetTask?.cancel()

                        if tapCount >= 2 {
                            tapCount = 0
                            isPresented = true
                        } else {
                            resetTask = Task {
                                try? await Task.sleep(for: .seconds(2))
                                if !Task.isCancelled { tapCount = 0 }
                            }
                        }
                    }
                    // Optional: faint pulse when tapping so you know it registered
                    .overlay(alignment: .topLeading) {
                        if tapCount > 0 {
                            Circle()
                                .fill(Color.accentColor.opacity(0.25))
                                .frame(width: 12, height: 12)
                                .padding(8)
                                .transition(.scale.combined(with: .opacity))
                                .id(tapCount)
                        }
                    }
                    .animation(.easeOut(duration: 0.15), value: tapCount)
            }
            .sheet(isPresented: $isPresented) {
                DebugSheetView(modelContainer: modelContainer)
            }
    }
}
#endif
