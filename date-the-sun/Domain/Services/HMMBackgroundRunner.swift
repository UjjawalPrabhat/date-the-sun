//
//  HMMBackgroundRunner.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

import BackgroundTasks
import SwiftData

/// Props to Sonnet
struct HMMBackgroundRunner {
    
    static func schedule() {
        print("Scheduling HMM Viterbi task")
        let request = BGAppRefreshTaskRequest(identifier: "dev.heryan.date-the-sun.hmm-viterbi")
        request.earliestBeginDate = Calendar.current.nextDate(
            after: .now,
            matching: DateComponents(hour: 3),  // 3am
            matchingPolicy: .nextTime
        )
        try? BGTaskScheduler.shared.submit(request)
    }
    
    static func run(modelContainer: ModelContainer) async {
        let context = ModelContext(modelContainer)
        
        // Fetch all unprocessed observations, ordered by timestamp
        var descriptor = FetchDescriptor<HMMObservation>(
            predicate: #Predicate { $0.inferredState == nil },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        
        guard let observations = try? context.fetch(descriptor),
              !observations.isEmpty else { return }
        
        // Run Viterbi
        print("Running Viterbi...")
        let results = HMMEngine.viterbi(observations: observations)
        
        // Write inferred states back
        for (observation, result) in zip(observations, results) {
            observation.inferredState = result.state
            observation.stateProbability = result.probability
        }
        
        do {
            try context.save()
        } catch {
            print("HMM background save error: \(error)")
        }
        
        // Reschedule for next night
        schedule()
    }
}
