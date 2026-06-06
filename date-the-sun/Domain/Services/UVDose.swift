//
//  UVDose.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

import Foundation
import OSLog

struct ProtectionProfile {
    var wearingSunscreen: Bool
    var wearingProtectiveClothing: Bool
    
    // Each reduces effective UV independently
    // Sunscreen (SPF 30+): blocks ~65% of UV
    // Protective clothing (UPF fabric): blocks ~75% of UV
    // Combined: multiplicative, not additive
    var exposureMultiplier: Double {
        var multiplier = 1.0
        if wearingSunscreen         { multiplier *= 0.35 }  // 65% reduction
        if wearingProtectiveClothing { multiplier *= 0.25 } // 75% reduction
        return multiplier
        // Both active: 0.35 * 0.25 = 0.0875 → ~91% total reduction
    }
}

/// Props to Sonnet
enum UVDose {
    static func computeUVDose(
        observations: [HMMObservation]
    ) -> Double {
        var totalDose = 0.0
        
        for i in 0..<(observations.count - 1) {
            let obs = observations[i]
            let next = observations[i + 1]
            
            guard let posterior = obs.outdoorPosterior,
                  let uvIndex = obs.uvIndex else { continue }
            
            let intervalMinutes = next.timestamp.timeIntervalSince(obs.timestamp) / 60.0
            let effectiveMinutes = min(intervalMinutes, 30.0)
            
            totalDose += Double(uvIndex) * effectiveMinutes * posterior
        }
        return totalDose
    }
    static func computeSunScore(
        effectiveDose: Double,
        protection: ProtectionProfile
    ) -> Double {
        var effectiveTarget = 120.0
        if protection.wearingSunscreen          { effectiveTarget += 30.0 }
        if protection.wearingProtectiveClothing { effectiveTarget += 20.0 }
        // both on: target = 170
        
        if effectiveDose <= effectiveTarget {
            // Ramp up: 0 → 70 as dose approaches target
            // Linear feels natural on the "need more sun" side
            let score = (effectiveDose / effectiveTarget) * 70.0
            return score  // dose=0 → 0, dose=target → 70
        } else {
            // Bell drop: 70 → 0 as dose goes to dangerous levels
            // Gaussian tail so it degrades gradually
            let tolerance = 250.0
            let excess = effectiveDose - effectiveTarget
            let drop = exp(-pow(excess, 2) / (2 * pow(tolerance, 2)))
            // drop=1.0 at excess=0, approaches 0 as excess grows
            // remap: 70 × drop gives 70 at peak, falling toward 0
            let score = drop * 70.0
            
            // Danger bonus: pushes toward 100 for extreme overexposure
            let dangerThreshold = effectiveTarget * 3
            if effectiveDose > dangerThreshold {
                let excess2 = (effectiveDose - dangerThreshold) / dangerThreshold
                let danger = min(excess2 * 30.0, 30.0)
                return min(score + danger, 100.0)
            }
            
            return score
        }
    }
    /// Calculate and return Kiran Score given a day's observations and its protection profile
    static func dailyKiranScore(
        observations: [HMMObservation],
        protection: ProtectionProfile
    ) -> Double {
        let dose = computeUVDose(observations: observations)
        Logger.dailySummary.info("Raw UV dose: \(dose)")
        return computeSunScore(effectiveDose: dose, protection: protection)
    }
}
