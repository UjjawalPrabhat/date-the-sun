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
