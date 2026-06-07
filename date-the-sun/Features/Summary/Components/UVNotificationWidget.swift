//
//  UVNotificationWidget.swift
//  date-the-sun
//
//  Created by I Gusti Ngurah Bagus Ferry Mahayudha on 03/06/26.
//

import SwiftUI

struct UVNotificationWidget: View {
    
    var onLazyTap: () -> Void
    var onDoneTap: () -> Void
    var value: Int
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - Top Row: Status Content & Kiran's Mood
            WidgetInnerContent(value: value)
            
            // MARK: - Bottom Row: Custom Action Buttons
            HStack(spacing: 12) {
                // Left Side: "lazy laa" Button
                Button(action: {
                    onLazyTap()
                }) {
                    Text("lazy laa")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(red: 0.75, green: 0.22, blue: 0.15)) // Deep Rust Red
                        .cornerRadius(22)
                }
                .buttonStyle(.plain)

                // Right Side: "done!" Button
                Button(action: {
                    onDoneTap()
                }) {
                    Text("done!")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(red: 0.53, green: 0.71, blue: 0.96)) // Sky Blue Accent
                        .cornerRadius(22)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.all, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(red: 0.97, green: 0.96, blue: 0.94) // Cream/Off-white background overlay color
        )
        .cornerRadius(28)
    }

    private var moodImage: Image {
        switch value {
        case ..<3:
            return Image("happy_kiran_face")
        case 3...7:
            return Image("neutral_kiran_face")
        default:
            return Image("mad_kiran_face")
        }
    }
}

#Preview {
    UVNotificationWidget(
        onLazyTap: {},
        onDoneTap: {},
        value: 8)
}
