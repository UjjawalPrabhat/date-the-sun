//
//  ContentView.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 28/05/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selection: AppTab = .today
    @Namespace private var tabNamespace

    var body: some View {
        ZStack(alignment: .bottom) {
            switch selection {
            case .today:
                MainScreenView()
            case .summary:
                SummaryView()
            }

            FloatingTabBar(selection: $selection, namespace: tabNamespace)
                .padding(.bottom, 6)
        }
        .ignoresSafeArea(.keyboard)
    }
}

/// Placeholder for the "Summary" tab, themed to match the main screen.
struct SummaryView: View {
    var body: some View {
        ZStack {
            FieldBackground()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Your Day in the Sun")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(Palette.ink)

                IndoorOutdoorClock(clockDataPoints: [
                    .init(isOutdoor: false, startMinute: 9 * 60, endMinute: 12 * 60),
                    .init(isOutdoor: true,  startMinute: 0,       endMinute: 15),
                    .init(isOutdoor: false, startMinute: 15,      endMinute: 60 + 10),
                    .init(isOutdoor: true,  startMinute: 60 + 10, endMinute: 5 * 60),
                    .init(isOutdoor: false, startMinute: 5 * 60,  endMinute: 6 * 60),
                ])
            }
            .padding(.bottom, 80)
        }
    }
}

#Preview {
    ContentView()
}
