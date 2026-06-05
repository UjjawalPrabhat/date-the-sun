import SwiftUI
import SwiftData
import Observation

/// Single source of truth for the day, shared by the Today and Summary screens.
/// Reads processed HMMObservations and DailySunSummary from SwiftData.
@MainActor
@Observable
final class SunViewModel {
    /// For Main Screen
    private(set) var isMainScreenDataLoading: Bool = true
    private(set) var mood: KiranMood = .neutral
    private(set) var uvIndex: Int
    // computed
    var headline: String { mood.headline }
    var message: String { mood.line }
    
    
    
    
    
    
    var selectedPeriod: SummaryPeriod = .daily
    
    private(set) var greeting: String
    private(set) var userName: String
    private(set) var todaySummary: DailySunSummary?      // nil until HMM has run
    //    private(set) var protection: ProtectionProfile
    
    let dateText: String
    let weekLabel: String
    
    private let uvProvider: UVIndexProviding
    private let locationProvider: LocationProviding
    private let modelContext: ModelContext
    
    // Inject
    init(
        modelContainer: ModelContainer,
        greetingProvider: GreetingProviding = GreetingProvider(),
        uvProvider: UVIndexProviding = RESTUVIndexProvider(),
        locationProvider: LocationProviding = DeviceLocationProvider(),
        now: Date = .now
    ) {
        /// For main screen
        self.modelContext = ModelContext(modelContainer)
        self.userName = "James"
        self.greeting = greetingProvider.greeting(at: now )
        self.locationProvider = locationProvider
        self.uvProvider = uvProvider
        self.uvIndex = 0
        //        self.protection = ProtectionProfile(
        //            wearingSunscreen: false,
        //            wearingProtectiveClothing: false
        //        )
        self.dateText = now.formatted(.dateTime.day().month().year())
        self.weekLabel = Self.weekLabel(for: now)
    }
    
    func refresh() async {
        isMainScreenDataLoading = true
        defer { isMainScreenDataLoading = false }
        
        let coordinate = await locationProvider.currentLocation() ?? .fallback
        if let uv = try? await uvProvider.currentUVIndex(latitude: coordinate.latitude, longitude: coordinate.longitude) {
            uvIndex = uv
        }
        //
        //        let yesterday = Calendar.current.startOfDay(
        //            for: Calendar.current.date(byAdding: .day, value: -1, to: day)!
        //        )
        //        let today = Calendar.current.startOfDay(for: day)
        //
        //        let summaryDescriptor = FetchDescriptor<DailySunSummary>(
        //            predicate: #Predicate { $0.date >= yesterday && $0.date < today }
        //        )
        //        todaySummary = try? modelContext.fetch(summaryDescriptor).first
        
        withAnimation(.easeInOut(duration: 0.35)) { updateMood() }
    }
    
    //    func toggleSunscreen() {
    //        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
    //            protection.wearingSunscreen.toggle()
    //            updateMood()
    //        }
    //    }
    //
    //    func toggleProtectiveClothing() {
    //        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
    //            protection.wearingProtectiveClothing.toggle()
    //            updateMood()
    //        }
    //    }
    
    private func updateMood() {
        mood = KiranMood.from(uvIndex: uvIndex)
    }
    
    private static func weekLabel(for date: Date) -> String {
        guard let week = Calendar.current.dateInterval(of: .weekOfYear, for: date) else { return "This Week" }
        let start = week.start.formatted(.dateTime.day().month())
        let end = week.end.addingTimeInterval(-1).formatted(.dateTime.day().month())
        return "\(start) – \(end)"
    }
}
