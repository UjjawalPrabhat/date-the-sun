//
//  EveningReminderView.swift
//  UVNotificationExtension
//
//  Display-only SwiftUI card shown inside the expanded notification. Mirrors the
//  in-app UVNotificationWidget look, but is fully self-contained (no shared
//  assets or types) so it builds in the extension target.
//

import SwiftUI

struct EveningReminderView: View {
    let uvValue: Int
    let message: String

    private var statusText: String {
        switch uvValue {
        case ..<3:  return "Let's Date!"
        case 3...7: return "Don't forget your sunscreen."
        default:    return "USE PROTECTION!"
        }
    }

    private var sunIconColor: Color {
        switch uvValue {
        case ..<3:  return .yellow
        case 3...7: return .orange
        default:    return Color(red: 0.75, green: 0.22, blue: 0.15)
        }
    }

    private var moodSymbol: String {
        switch uvValue {
        case ..<3:  return "face.smiling.inverse"
        case 3...7: return "sun.max.fill"
        default:    return "exclamationmark.triangle.fill"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(sunIconColor)
                        .font(.system(size: 22))
                    Text("UV \(uvValue)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                    Text(statusText)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                Image(systemName: moodSymbol)
                    .font(.system(size: 56))
                    .foregroundColor(sunIconColor)
                    .frame(width: 88, height: 88)
            }

            if !message.isEmpty {
                Text(message)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("Tap “lazy laa” or “done!” below to let Kiran know.")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.black.opacity(0.45))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.97, green: 0.96, blue: 0.94))
    }
}

#Preview {
    EveningReminderView(uvValue: 8, message: "You better tell me you wore protection today. I'm waiting. 👀")
}
