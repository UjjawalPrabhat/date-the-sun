import Foundation
import CoreLocation

/// One-shot device location via CoreLocation's async live updates (iOS 17+),
/// which transparently requests When-In-Use authorization on first use.
/// Returns `nil` if access is denied or no fix is obtained.
nonisolated struct DeviceLocationProvider: LocationProviding {
    func currentLocation() async -> Coordinate? {
        do {
            for try await update in CLLocationUpdate.liveUpdates() {
                if update.authorizationDenied || update.authorizationDeniedGlobally {
                    return nil
                }
                if let location = update.location {
                    return Coordinate(latitude: location.coordinate.latitude,
                                      longitude: location.coordinate.longitude)
                }
            }
        } catch {
            return nil
        }
        return nil
    }
    
}

private var associatedDelegateKey: UInt8 = 0

final class LocationProvider {
    static func fetchCurrentLocation() async -> CLLocation? {
        await withCheckedContinuation { continuation in
            let delegate = SingleLocationDelegate { location in
                continuation.resume(returning: location)
            }
            let manager = CLLocationManager()
            manager.delegate = delegate
            manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            manager.requestWhenInUseAuthorization()
            manager.requestLocation()
            objc_setAssociatedObject(manager, &associatedDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

private final class SingleLocationDelegate: NSObject, CLLocationManagerDelegate {
    private let onLocation: (CLLocation?) -> Void
    private var resumed = false

    init(onLocation: @escaping (CLLocation?) -> Void) {
        self.onLocation = onLocation
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !resumed else { return }
        resumed = true
        onLocation(locations.last)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard !resumed else { return }
        resumed = true
        onLocation(nil)
    }
}
