//
//  HMMObservation.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

// Hidden Markov Model
// Used for probabilistic calculation that a sequence of observations O1, O2, O3, ... On
// has a most probable sequence of hidden states S1, S2, S3, ... Sn

import SwiftData
import Foundation

@Model
class HMMObservation {
    var classifierLabel: String         // final fused label
    var classifierConfidence: Double    // fused confidence
    var provider: String                // A, G, AG, synthetic
    
    var aLabel: String?                 // "indoor" | "outdoor" | nil
    var aConfidence: Double?
    var gLabel: String?
    var gConfidence: Double?
    
    var speed: Double
    var horizontalAccuracy: Double
    var isMeasured: Bool
    var timestamp: Date
    
    var uvIndex: Int?
    
    // HMM Output - later after Viterbi runs
    var inferredState: String?
    var stateProbability: Double?
    var outdoorPosterior: Double?   // forward-backward γ_t(outdoor) ∈ [0,1]
    
    init(classifierLabel: String, classifierConfidence: Double, provider: String, aLabel: String? = nil, aConfidence: Double? = nil, gLabel: String? = nil, gConfidence: Double? = nil, speed: Double, horizontalAccuracy: Double, isMeasured: Bool, timestamp: Date, uvIndex: Int? = nil, inferredState: String? = nil, stateProbability: Double? = nil, outdoorPosterior: Double? = nil) {
        self.classifierLabel = classifierLabel
        self.classifierConfidence = classifierConfidence
        self.provider = provider
        self.aLabel = aLabel
        self.aConfidence = aConfidence
        self.gLabel = gLabel
        self.gConfidence = gConfidence
        self.speed = speed
        self.horizontalAccuracy = horizontalAccuracy
        self.isMeasured = isMeasured
        self.timestamp = timestamp
        self.uvIndex = uvIndex
        self.inferredState = inferredState
        self.stateProbability = stateProbability
        self.outdoorPosterior = outdoorPosterior
    }
    
    /// Good way to think about this is "I'm uncertain here, lean on your transition priors instead."
    static func fuseProviders(
        apple: (label: String, confidence: Double)?,
        google: (label: String, confidence: Double)?
    ) -> (label: String, confidence: Double, provider: String) {
        
        switch (apple, google) {
            
            // Both agree → compound the confidence
        case let (a?, g?) where a.label == g.label:
            // Bayesian-style combination: rewards agreement
            let fused = 1 - (1 - a.confidence) * (1 - g.confidence)
            return (a.label, min(fused, 0.97), "AG")
            
            // Both disagree → reduce confidence, lean toward indoor
            // (false outdoor is more dangerous than false indoor for most use cases)
        case let (a?, g?) where a.label != g.label:
            // Weight Google higher for indoor (polygon data is precise)
            // Weight Apple higher for outdoor (satellite is reliable open-sky)
            let indoorScore: Double
            if g.label == "indoor" {
                indoorScore = g.confidence * 0.65 + (1 - a.confidence) * 0.35
            } else {
                indoorScore = a.confidence * 0.35 + (1 - g.confidence) * 0.65
            }
            let label = indoorScore > 0.5 ? "indoor" : "outdoor"
            let confidence = max(indoorScore, 1 - indoorScore) * 0.6 // penalize disagreement
            return (label, confidence, "AG")
            
            // Only Apple fired
        case let (a?, nil):
            return (a.label, a.confidence * 0.80, "A") // slight penalty for single source
            
            // Only Google fired
        case let (nil, g?):
            return (g.label, g.confidence * 0.85, "G") // Google polygon slightly more trusted alone
            
            // Neither fired
        default:
            return ("outdoor", 0.25, "synthetic")
        }
    }
}
