//
//  KiranSplashScreen.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

import SwiftUI

struct KiranSplashScreen: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "sun.max")
                .font(.system(size: 64, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.vermillion)
                .symbolEffect(.pulse, options: .repeating)
                .symbolEffect(.rotate, options: .repeating)
            Text("Seeing what Kiran is up to…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
