import SwiftUI
import SwiftData

/// The Today screen: greeting, UV index, and the full-body Sun mascot speaking
/// through a bottom dialogue box, over a soft blue-glow background.
struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LocationEntry.timestamp, order: .reverse)
    private var entries: [LocationEntry]
    var latestEntry: LocationEntry? { entries.first }
    
    let model: SunModel
    
    var body: some View {
        ZStack(alignment: .top) {
            SkyGlowBackground()
                .ignoresSafeArea()
            
            GeometryReader { geo in
                InteractiveKiranView(mood: model.mood)
                    .frame(width: geo.size.width * 0.82)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .offset(y: geo.size.height * 0.15)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 14) {
                Text("\(model.greeting), \(model.userName)")
                    .font(AppFont.semibold(32))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
                
                UVIndexBadge(value: model.uvIndex)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            
            if let entry = latestEntry {
                DialogueBox(speaker: "Kiran", text: "\(entry.latitude), \(entry.longitude)")
                    .padding(.horizontal, 18)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 78) // clear the floating tab bar
                    .id(model.message)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: model.message)
                
            }
        }
    }
}

#Preview {
    TodayView(model: SunModel(
        uvProvider: StaticUVIndexProvider(),
        locationProvider: StaticLocationProvider(),
        daylightProvider: MockDaylightProvider()
    ))
}
