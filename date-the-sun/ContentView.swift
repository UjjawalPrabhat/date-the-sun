//
//  ContentView.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 28/05/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    var body: some View {
        TabView {
            Tab("Today", systemImage: "sun.max.fill") {
                Text("Hello Today")
            }
            Tab("Summary", systemImage: "lines.measurement.horizontal") {
                Text("Hello Summary")
            }
        }
        .tint(.saffron)
    }
    
}

#Preview {
    ContentView()
}
