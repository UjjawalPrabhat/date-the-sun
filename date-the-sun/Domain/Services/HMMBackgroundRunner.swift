//
//  HMMBackgroundRunner.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

import BackgroundTasks
import SwiftData
import OSLog

/// Props to Sonnet
struct HMMBackgroundRunner {
    
    static func run(modelContainer: ModelContainer) async {
        let context = ModelContext(modelContainer)
        
        // Fetch all unprocessed observations, ordered by timestamp
        let descriptor = FetchDescriptor<HMMObservation>(
            predicate: #Predicate { $0.inferredState == nil },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        
        guard let observations = try? context.fetch(descriptor),
              !observations.isEmpty else { return }
        
        // Run Viterbi
        Logger.app.info("Running Viterbi...")
        let results = HMMEngine.viterbi(observations: observations)
        let posteriors = HMMEngine.forwardBackward(observations: observations)
        
        // Write inferred states back
        for (i, (observation, result)) in zip(observations, results).enumerated() {
            observation.inferredState = result.state
            observation.stateProbability = result.probability
            observation.outdoorPosterior = posteriors[i]
        }
        
        do {
            try context.save()
        } catch {
            Logger.app.error("HMM background save error: \(error)")
        }
    }
}
