import Foundation
import HealthKit

/// Builds the day's outdoor intervals from HealthKit's "Time in Daylight"
/// samples (iOS 17+) — the device already estimates outdoor-daylight minutes
/// via the ambient light sensor, an ideal proxy for sun exposure.
///
/// Requires the **HealthKit** entitlement and read authorization for
/// `timeInDaylight`. Returns `nil` when unavailable so callers keep their
/// existing data.
nonisolated struct HealthKitDaylightProvider: DaylightExposureProviding {
    private let store = HKHealthStore()

    func intervals(on date: Date) async -> [SunExposureInterval]? {
        guard HKHealthStore.isHealthDataAvailable(),
              let type = HKQuantityType.quantityType(forIdentifier: .timeInDaylight) else {
            return nil
        }

        do {
            try await store.requestAuthorization(toShare: [], read: [type])
        } catch {
            return nil
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)

        let samples: [HKQuantitySample] = await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, results, _ in
                continuation.resume(returning: (results as? [HKQuantitySample]) ?? [])
            }
            store.execute(query)
        }

        guard !samples.isEmpty else { return nil }
        return Self.intervals(fromDaylight: samples, startOfDay: startOfDay)
    }

    /// Converts daylight samples into a full day of intervals: an outdoor span
    /// for each (merged) daylight sample, indoor for the gaps in between.
    private static func intervals(fromDaylight samples: [HKQuantitySample], startOfDay: Date) -> [SunExposureInterval] {
        let ranges = samples
            .map { sample -> (Double, Double) in
                let start = max(0, sample.startDate.timeIntervalSince(startOfDay) / 60)
                let end = min(1440, sample.endDate.timeIntervalSince(startOfDay) / 60)
                return (start, end)
            }
            .filter { $0.1 > $0.0 }
            .sorted { $0.0 < $1.0 }

        // Merge overlapping / touching outdoor ranges.
        var merged: [(Double, Double)] = []
        for range in ranges {
            if let last = merged.last, range.0 <= last.1 {
                merged[merged.count - 1].1 = max(last.1, range.1)
            } else {
                merged.append(range)
            }
        }

        // Stitch indoor gaps and outdoor spans across the full 24 hours.
        var intervals: [SunExposureInterval] = []
        var cursor: Double = 0
        for span in merged {
            if span.0 > cursor {
                intervals.append(.init(isOutdoor: false, startMinute: cursor, endMinute: span.0))
            }
            intervals.append(.init(isOutdoor: true, startMinute: span.0, endMinute: span.1))
            cursor = span.1
        }
        if cursor < 1440 {
            intervals.append(.init(isOutdoor: false, startMinute: cursor, endMinute: 1440))
        }
        return intervals
    }
}
