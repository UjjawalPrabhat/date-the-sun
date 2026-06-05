//
//  UVDose.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

import Foundation

struct ProtectionProfile {
    var isProtected: Bool   // any protection
    
    // If protected, reduce by ~60%
    // Based on sunscreen (~65%) reduction and clothing alone (~25%)
    var exposureMultiplier: Double {
        isProtected ? 0.4 : 1.0
    }
}


/// Props to Sonnet
/// Cheat to pass static class in Swift
enum UVDose {
    static func computeUVDose(
        observations: [HMMObservation],
        protection: ProtectionProfile
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
        return totalDose * protection.exposureMultiplier
    }

    static func computeSunScore(effectiveDose: Double) -> Double {
        let target = 60.0
        let tolerance = 30.0
        let exponent = -pow(effectiveDose - target, 2) / (2 * pow(tolerance, 2))
        let bellScore = exp(exponent)
        let ghostPenalty = effectiveDose < 5.0 ? 0.6 : 1.0
        return bellScore * ghostPenalty * 100
    }

    static func dailyKiranScore(
        observations: [HMMObservation],
        protection: ProtectionProfile
    ) -> Double {
        let dose = computeUVDose(observations: observations, protection: protection)
        return computeSunScore(effectiveDose: dose)
    }
}
