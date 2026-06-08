//
//  OnboardingView.swift
//  date-the-sun
//
//  Created by I Gusti Ngurah Bagus Ferry Mahayudha on 05/06/26.
//
import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    private func completeOnboarding() {
        NotificationManager.requestAuthorization()
        hasCompletedOnboarding = true
    }

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    title: "Meet Kiran",
                    description: "Kiran is your partner. Their mood will show how much—or less—sun exposure you need.",
                    gradientColor: Color.blue.opacity(0.3)
                )
                .tag(0)

                OnboardingPageView(
                    title: "Keep it balanced",
                    description: "If Kiran's happy, that means you're balanced in your sun exposure. Less or more exposure will affect their emotions to you.",
                    gradientColor: Color.orange.opacity(0.4)
                )
                .tag(1)

                OnboardingPageView(
                    title: "Track your progress",
                    description: "Details on your sun exposure and protection log can be accessed daily or weekly, along with Kiran's moods.",
                    gradientColor: Color.pink.opacity(0.3)
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            VStack {
                Spacer()
                HStack {
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(currentPage == index ? Color.black : Color.gray.opacity(0.4))
                                .frame(width: 8, height: 8)
                        }
                    }

                    Spacer()

                    if currentPage == 0 {
                        Button(action: completeOnboarding) {
                            Text("Skip")
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                        }
                    } else if currentPage == 2 {
                        Button(action: completeOnboarding) {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(Color.black)
                                .cornerRadius(25)
                        }
                    } else {
                        // Keeps the trailing edge aligned on the middle page.
                        Color.clear.frame(width: 1, height: 1)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .animation(.easeInOut, value: currentPage)
    }
}

#Preview {
    OnboardingView()
}
