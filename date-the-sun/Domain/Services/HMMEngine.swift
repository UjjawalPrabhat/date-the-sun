//
//  HMMEngine.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

import Foundation

/// Props to sonnet
struct HMMEngine {
    
    // MARK: - Model Parameters
    
    struct Parameters {
        // States: 0 = outdoor, 1 = indoor
        let states = ["outdoor", "indoor"]
        
        // π — initial state probabilities
        // Slight outdoor bias since app likely starts when user leaves home
        let initialProbabilities: [Double] = [0.6, 0.4]
        
        // A — transition matrix [from][to]
        // People stay in the same state most of the time
        let transitions: [[Double]] = [
            [0.95, 0.05],  // outdoor → [outdoor, indoor]
            [0.10, 0.90]   // indoor  → [outdoor, indoor]
        ]
    }
    
    // MARK: - Emission Probability
    
    // B — how likely is this observation given a known state
    static func emissionProbability(
        observation: HMMObservation,
        state: Int  // 0 = outdoor, 1 = indoor
    ) -> Double {
        let labelMatch = observation.classifierLabel == (state == 0 ? "outdoor" : "indoor")
        let confidence = observation.classifierConfidence
        
        // Base probability from classifier
        let baseProbability = labelMatch ? confidence : (1 - confidence)
        
        // Speed modifier — fast movement strongly suggests outdoor
        let speedModifier: Double
        switch observation.speed {
        case ..<0:        speedModifier = 1.0  // invalid speed, no adjustment
        case 0..<0.5:     speedModifier = 1.0  // stationary, no adjustment
        case 0.5..<1.5:   speedModifier = state == 0 ? 1.1 : 0.9   // slow walk
        case 1.5..<3.0:   speedModifier = state == 0 ? 1.2 : 0.8   // fast walk
        default:          speedModifier = state == 0 ? 1.4 : 0.6   // running/vehicle = outdoor
        }
        
        // GPS accuracy modifier
        // Poor accuracy (high number) = likely indoor (GPS struggles indoors)
        let accuracyModifier: Double
        switch observation.horizontalAccuracy {
        case ..<0:        accuracyModifier = 1.0  // invalid
        case 0..<15:      accuracyModifier = state == 0 ? 1.2 : 0.8   // excellent GPS = outdoor
        case 15..<50:     accuracyModifier = 1.0                       // neutral
        case 50..<150:    accuracyModifier = state == 1 ? 1.2 : 0.8   // poor GPS = indoor
        default:          accuracyModifier = state == 1 ? 1.4 : 0.6   // very poor = strongly indoor
        }
        
        return min(baseProbability * speedModifier * accuracyModifier, 0.9999)
    }
    
    // MARK: - Viterbi
    
    static func viterbi(
        observations: [HMMObservation],
        parameters: Parameters = Parameters()
    ) -> [(state: String, probability: Double)] {
        
        guard !observations.isEmpty else { return [] }
        
        let stateCount = parameters.states.count
        let T = observations.count
        
        // dp[t][s] = log probability of most likely path ending in state s at time t
        var dp = Array(repeating: Array(repeating: Double.zero, count: stateCount), count: T)
        var backpointer = Array(repeating: Array(repeating: 0, count: stateCount), count: T)
        
        // Use log probabilities to avoid underflow across long sequences
        
        // Initialize t=0
        for s in 0..<stateCount {
            let emission = emissionProbability(observation: observations[0], state: s)
            dp[0][s] = log(parameters.initialProbabilities[s]) + log(emission)
        }
        
        // Forward pass
        for t in 1..<T {
            for s in 0..<stateCount {
                var best = -Double.infinity
                var bestPrev = 0
                
                for prev in 0..<stateCount {
                    let score = dp[t-1][prev]
                    + log(parameters.transitions[prev][s])
                    + log(emissionProbability(observation: observations[t], state: s))
                    
                    if score > best {
                        best = score
                        bestPrev = prev
                    }
                }
                dp[t][s] = best
                backpointer[t][s] = bestPrev
            }
        }
        
        
        
        // Backtrack — find best final state then trace back
        var path = Array(repeating: 0, count: T)
        path[T-1] = dp[T-1].indices.max(by: { dp[T-1][$0] < dp[T-1][$1] })!
        
        for t in stride(from: T-2, through: 0, by: -1) {
            path[t] = backpointer[t+1][path[t+1]]
        }
        
        // Convert to labeled output
        return path.enumerated().map { (t, stateIdx) in
            let logProb = dp[t][stateIdx]
            let probability = exp(logProb) // convert back from log space
            return (state: parameters.states[stateIdx], probability: min(max(probability, 0), 1))
        }
    }
    
    // MARK: - Forward-Backward
    
    static func forwardBackward(
        observations: [HMMObservation],
        parameters: Parameters = Parameters()
    ) -> [Double] {  // returns γ_t(outdoor) for each t
        
        let S = parameters.states.count
        let T = observations.count
        guard T > 0 else { return [] }
        
        // --- Forward pass (log scale) ---
        // alpha[t][s] = log P(O_1..O_t, q_t = s)
        var alpha = Array(repeating: Array(repeating: -Double.infinity, count: S), count: T)
        
        for s in 0..<S {
            alpha[0][s] = log(parameters.initialProbabilities[s])
            + log(emissionProbability(observation: observations[0], state: s))
        }
        
        for t in 1..<T {
            for s in 0..<S {
                // log-sum-exp over previous states
                let incoming = (0..<S).map { prev in
                    alpha[t-1][prev] + log(parameters.transitions[prev][s])
                }
                let emission = log(emissionProbability(observation: observations[t], state: s))
                alpha[t][s] = logSumExp(incoming) + emission
            }
        }
        
        // --- Backward pass (log scale) ---
        // beta[t][s] = log P(O_{t+1}..O_T | q_t = s)
        var beta = Array(repeating: Array(repeating: 0.0, count: S), count: T)
        // beta[T-1][s] = log(1) = 0 for all s  ← already set
        
        for t in stride(from: T-2, through: 0, by: -1) {
            for s in 0..<S {
                let outgoing = (0..<S).map { next in
                    log(parameters.transitions[s][next])
                    + log(emissionProbability(observation: observations[t+1], state: next))
                    + beta[t+1][next]
                }
                beta[t][s] = logSumExp(outgoing)
            }
        }
        
        // --- Posterior γ_t(outdoor) ---
        // γ_t(s) = exp(alpha[t][s] + beta[t][s]) / sum_s exp(alpha[t][s] + beta[t][s])
        return (0..<T).map { t in
            let logNumerator = alpha[t][0] + beta[t][0]           // state 0 = outdoor
            let logDenominator = logSumExp((0..<S).map { alpha[t][$0] + beta[t][$0] })
            return exp(logNumerator - logDenominator)             // safe: numerator - denominator in log space
        }
    }
    
    // MARK: - Numerically stable log-sum-exp
    
    private static func logSumExp(_ values: [Double]) -> Double {
        guard let maxVal = values.max(), maxVal > -Double.infinity else { return -Double.infinity }
        let sumExp = values.reduce(0.0) { $0 + exp($1 - maxVal) }
        return maxVal + log(sumExp)
    }
}
