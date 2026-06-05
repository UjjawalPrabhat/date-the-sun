import SwiftUI
import SwiftData

/// The Today screen: greeting, UV index, and the full-body Sun mascot speaking
/// through a bottom dialogue box, over a soft blue-glow background.
struct TodayView: View {
    //    @Query(sort: \LocationEntry.timestamp, order: .reverse)
    //    private var entries: [LocationEntry]
    //    var latestEntry: LocationEntry? { entries.first }
    
    let model: SunModel
    
    var body: some View {
        ZStack(alignment: .top) {
            SkyGlowBackground()
                .ignoresSafeArea()
            
            GeometryReader { geo in
                InteractiveKiranView(mood: model.mood)
                    .frame(width: geo.size.width)        // full-bleed; bump >1.0 to enlarge her
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .offset(y: 22)                       // sink feet past the edge so the idle float (~18px up) never opens a gap
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
            
            DialogueBox(speaker: "Kiran", text: model.message)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 78) // clear the floating tab bar
                .id(model.message)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: model.message)
        }
    }
}
//
//#Preview {
//    TodayView(model: SunModel(
//        uvProvider: StaticUVIndexProvider(),
//        locationProvider: StaticLocationProvider(),
//        daylightProvider: MockDaylightProvider()
//    ))
//}
