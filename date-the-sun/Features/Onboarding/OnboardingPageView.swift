import SwiftUI

struct OnboardingPageView: View {
    let title: String
    let description: String
    let gradientColor: Color

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            Circle()
                .fill(gradientColor)
                .frame(width: 350, height: 350)
                .blur(radius: 60)
                .offset(y: -40)

            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                Text(title)
                    .font(AppFont.semibold(32))
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
        gradientColor: Color.blue.opacity(0.3)
    )
}
