//
//  LocationTracker.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 04/06/26.
//

import CoreLocation
import SwiftData

@Observable
class LocationTracker: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let processor: LocationProcessor
    
    init(modelContainer: ModelContainer) {
        self.processor = LocationProcessor(modelContainer: modelContainer)
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
    }
    
    func start() {
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.startUpdatingLocation()
    }
    
    func stop() {
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task {
            await processor.handleLocationUpdate(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

@ModelActor
actor LocationProcessor {
    private var debounceTask: Task<Void, Never>?
//    private let debounceInterval: Duration = .seconds(5 * 60)
    private let debounceInterval: Duration = .seconds(5)
    
    
    func handleLocationUpdate(_ location: CLLocation) {
        let entry = LocationEntry(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            horizontalAccuracy: location.horizontalAccuracy,
            speed: location.speed,
            course: location.course,
            altitude: location.altitude,
            timestamp: location.timestamp
        )
        modelContext.insert(entry)
        try? modelContext.save()
        
        debounceTask?.cancel()
        debounceTask = Task {
            do {
                try await Task.sleep(for: debounceInterval)
                /// When debounce interval reached, do image classification for location
                try await locationClassification(for: entry)
            } catch is CancellationError {
                /// cancelled, new update
            } catch {
                print("Classification error: \(error)")
            }
        }
    }
    
    private func locationClassification(for entry: LocationEntry) async throws {
        // Run classfication
        if let res = try await MapTileClassification.classify(lat: entry.latitude, lng: entry.longitude, isAppleMaps: true) {
            let record = IndoorOutdoorEntry(identifier: res.identifier, confidence: Double(res.confidence), provider: "A", timestamp: Date.now)
            modelContext.insert(record)
        }
        if let res = try await MapTileClassification.classify(lat: entry.latitude, lng: entry.longitude, isAppleMaps: false) {
            let record = IndoorOutdoorEntry(identifier: res.identifier, confidence: Double(res.confidence), provider: "G", timestamp: Date.now)
            modelContext.insert(record)
        }
        try? modelContext.save()
    }
}
