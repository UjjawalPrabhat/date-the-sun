//
//  OnboardingOne.swift
//  date-the-sun
//
//  Created by I Gusti Ngurah Bagus Ferry Mahayudha on 05/06/26.
//

import SwiftUI

struct OnboardingPageView: View {
    
    let title: String
    let description: String
    let gradientColor: Color
    let pageIndex: Int
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            // The Soft Circular Gradient Background
            Circle()
                .fill(gradientColor)
                .frame(width: 350, height: 350)
                .blur(radius: 60)
                .offset(y: -40)
            
            // Text Content
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black.opacity(0.7))
                    .lineSpacing(4)
                
                // Padding to push layout above the page control indicators
                Spacer()
                    .frame(height: 120)
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    OnboardingPageView(
        title: "Meet Kiran",
        description: "Kiran is your partner. Their mood will show how much—or less—sun exposure you need.",
        gradientColor: Color.blue.opacity(0.3),
        pageIndex: 1
    )
}
