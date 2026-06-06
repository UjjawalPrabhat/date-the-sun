//
//  LocationTracker.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 04/06/26.
//

import CoreLocation
import SwiftData
import OSLog

@Observable
class LocationTracker: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let processor: LocationProcessor
    private var oneTimeContinuation: CheckedContinuation<CLLocation?, Never>?
    
    init(modelContainer: ModelContainer) {
        self.processor = LocationProcessor(modelContainer: modelContainer)
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters  /// `kCLLocationAccuracyBest` drains battery
        /// 100m is supposedly OK for indoor/outdoor transition happens at building scale
        manager.distanceFilter = 50     /// minimum meters the user must move before didUpdateLocations fires again.
        /// 5m is sub-footstep indoors
        /// 50m is "entered new area"
    }
    
    /// One time
    func requestOneTimeLocation() async -> CLLocation? {
        await withCheckedContinuation { continuation in
            oneTimeContinuation = continuation
            manager.requestWhenInUseAuthorization()
            manager.requestLocation()
        }
    }
    
    func start() {
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        
        //  manager.startUpdatingLocation()
        /// Coarse background tracking — fires every ~500m or cell tower change
        manager.startMonitoringSignificantLocationChanges()
    }
    
    func stop() {
        manager.stopMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        /// For one time location
        if let continuation = oneTimeContinuation {
            oneTimeContinuation = nil
            continuation.resume(returning: location)
            return
        }
        
        /// For live location
        Task {
            await processor.handleLocationUpdate(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.app.error("Location error: \(error.localizedDescription)")
    }
}

@ModelActor
actor LocationProcessor {
    private var debounceTask: Task<Void, Never>?
    private let debounceInterval: Duration = .seconds(60 * 2) // 2 min still = user is static
    
    func handleLocationUpdate(_ location: CLLocation) {
        /// Insert for Location
        let entry = LocationEntry(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            horizontalAccuracy: location.horizontalAccuracy,
            speed: location.speed,
            timestamp: location.timestamp
        )
        self.saveLocationEntry(entry)
        
        /// Insert for HMMObservation
        /// A synthetic outdoor, since user seems to move
        let observation = HMMObservation(
            classifierLabel: "outdoor",
            classifierConfidence: location.horizontalAccuracy < 20 ? 0.45 : 0.20, /// We are confidence only if GPS accuracy below 20
            provider: "synthetic",
            speed: location.speed,
            horizontalAccuracy: location.horizontalAccuracy,
            isMeasured: false,  /// Classifier not run yet
            timestamp: location.timestamp,
            uvIndex: nil    // fetched asyncly
        )
        self.saveHMMObservation(observation)
        
        debounceTask?.cancel()
        debounceTask = Task {
            do {
                try await Task.sleep(for: debounceInterval)
                /// When debounce interval reached, do image classification for location
                try await locationClassification(for: entry)
            } catch is CancellationError {
                /// cancelled, new update
            } catch {
                Logger.app.error("Classification error: \(error)")
            }
        }
    }
    
    private func locationClassification(for entry: LocationEntry) async throws {
        let uvProvider: UVIndexProviding
        // Run classfication
        async let appleResult = MapTileClassification.classify(
            lat: entry.latitude, lng: entry.longitude, isAppleMaps: true
        )
        async let googleResult = MapTileClassification.classify(
            lat: entry.latitude, lng: entry.longitude, isAppleMaps: false
        )
        async let uvResult = UVIndexService.fetch(
            latitude: entry.latitude,
            longitude: entry.longitude
        )
        
        let (apple, google, uv) = try await (appleResult, googleResult, uvResult)
        
        let appleSignal = apple.map { (label: $0.identifier, confidence: Double($0.confidence)) }
        let googleSignal = google.map { (label: $0.identifier, confidence: Double($0.confidence)) }
        let fused = HMMObservation.fuseProviders(apple: appleSignal, google: googleSignal)
        
        /// Time comparison
        let ts = entry.timestamp
        let lower = ts.addingTimeInterval(-1) // to prevent fragile comparison
        let upper = ts.addingTimeInterval(1)
        let descriptor = FetchDescriptor<HMMObservation>(
            predicate: #Predicate {
                $0.timestamp >= lower &&
                $0.timestamp <= upper &&
                $0.provider == "synthetic"
            }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            existing.classifierLabel = fused.label
            existing.classifierConfidence = fused.confidence
            existing.provider = fused.provider
            existing.aLabel = appleSignal?.label
            existing.aConfidence = appleSignal?.confidence
            existing.gLabel = googleSignal?.label
            existing.gConfidence = googleSignal?.confidence
            existing.isMeasured = true
            existing.uvIndex = uv
        }
        
        do { try modelContext.save() } catch { Logger.app.error("SwiftData save error: \(error)") }
    }
    
    private func saveLocationEntry(_ entry: LocationEntry) {
        modelContext.insert(entry)
        try? modelContext.save()
    }
    
    private func saveHMMObservation(_ observation: HMMObservation) {
        modelContext.insert(observation)
        try? modelContext.save()
    }
}
