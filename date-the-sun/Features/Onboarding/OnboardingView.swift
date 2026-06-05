//
//  OnboardingView.swift
//  date-the-sun
//
//  Created by I Gusti Ngurah Bagus Ferry Mahayudha on 05/06/26.
//
import SwiftUI

struct OnboardingView: View {
    // 1. Track the current page
    @State private var currentPage = 0
    @State private var isShowingMainView = false
        
    // Connect to the same AppStorage key here
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            // 2. Swipeable TabView configured as pages
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    title: "Meet Kiran",
                    description: "Kiran is your partner. Their mood will show how much—or less—sun exposure you need.",
                    gradientColor: Color.blue.opacity(0.3),
                    pageIndex: 0
                )
                .tag(0)
                
                OnboardingPageView(
                    title: "Keep it balanced",
                    description: "If Kiran's happy, that means you're balanced in your sun exposure. Less or more exposure will affect their emotions to you.",
                    gradientColor: Color.orange.opacity(0.4),
                    pageIndex: 1
                )
                .tag(1)
                
                OnboardingPageView(
                    title: "Track your progress",
                    description: "Details on your sun exposure and protection log can be accessed daily or weekly, along with Kiran's moods.",
                    gradientColor: Color.pink.opacity(0.3),
                    pageIndex: 2
                )
                .tag(2)
            }
            // This modifier transforms the TabView into a swipeable carousel
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // 3. Persistent Bottom Controls Layer
            VStack {
                Spacer()
                HStack {
                    // Custom Page Indicator Dots
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(currentPage == index ? Color.black : Color.gray.opacity(0.4))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Spacer()
                    
                    // Dynamic Button based on the specific page requirements
                    if currentPage == 0 {
                        // 1. Skip button ONLY for page 0
                        Button(action: { hasCompletedOnboarding = true }) {
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
                        // 2. Get Started button ONLY for page 2
                        Button(action: { hasCompletedOnboarding = true }) {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(Color.black)
                                .cornerRadius(25)
                        }
                    } else {
                        // Page 1: Empty view so the layout alignment stays consistent
                        Color.clear
                            .frame(width: 1, height: 1)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .animation(.easeInOut, value: currentPage) // Smooth transitions
    }
}

#Preview {
    OnboardingView()
}
