//
//  WidgetInnerContent.swift
//  date-the-sun
//
//  Created by I Gusti Ngurah Bagus Ferry Mahayudha on 07/06/26.
//

import SwiftUI

struct WidgetInnerContent: View {
    let value: Int
        
    // 1. Dynamic Text Sub-property
    private var statusText: String {
        switch value {
        case ..<3:   return "Let's Date!"
        case 3...7:  return "Dont Forget to use sunscreen."
        default:     return "USE PROTECTION!"
        }
    }
    
    // 2. Dynamic Icon Color Property
    private var sunIconColor: Color {
        switch value {
        case ..<3:   return Color.yellow // Safe UV levels
        case 3...7:  return Color.orange // Moderate/High UV levels
        default:     return Color(red: 0.75, green: 0.22, blue: 0.15) // Extreme UV (Styled Rust Red)
        }
    }
    
    // 3. Dynamic Mood Image Selection
    private var moodImage: Image {
        switch value {
        case ..<3:   return Image("happy_kiran_face") // Name of your happy asset
        case 3...7:  return Image("neutral_kiran_face") // Name of your neutral asset
        default:     return Image("mad_kiran_face") // Name of your protected/stressed asset
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            
            // Left Side: Status text block
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(sunIconColor) // Dynamically updates color
                    .font(.system(size: 24))
                
                Text("UV \(value)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                
                // Renders the dynamic status message string
                Text(statusText)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 12)
            
            // Right Side: Kiran's dynamic mood graphic asset
            moodImage
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
        }
    }
}

#Preview {
    WidgetInnerContent(value: 2)
}
