//
//  HMMTestDataGenerator.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

// HMMTestDataGenerator.swift
// Kiran — #if DEBUG only

#if DEBUG
import Foundation

// MARK: - DTO (mirrors your existing decoder contract)

struct HMMObservationDTO: Codable {
    let classifierLabel: String
    let classifierConfidence: Double
    let provider: String
    let aLabel: String?
    let aConfidence: Double?
    let gLabel: String?
    let gConfidence: Double?
    let speed: Double
    let horizontalAccuracy: Double
    let isMeasured: Bool
    let timestamp: Date
    let uvIndex: Int?
    let trueState: String
    
    enum CodingKeys: String, CodingKey {
        case classifierLabel, classifierConfidence, provider
        case aLabel, aConfidence, gLabel, gConfidence
        case speed, horizontalAccuracy, isMeasured, timestamp, uvIndex
        case trueState = "_trueState"
    }
}

// MARK: - Activity Phase

/// One contiguous block of a person's day.
private struct ActivityPhase {
    let name: String
    let trueState: String          // "indoor" | "outdoor"
    let startMinute: Int           // minutes from midnight
    let durationMinutes: Int
    let speedRange: ClosedRange<Double>
    let accuracyRange: ClosedRange<Double>
    let isMeasuredProbability: Double
    // How often the classifier is *wrong* about the true state
    let classifierErrorRate: Double
    // Which providers appear in this phase
    let providers: [String]
    // UV index range (nil for night/indoor phases)
    let uvRange: ClosedRange<Int>?
}

// MARK: - Day Program

/// A named program that describes one kind of day.
private struct DayProgram {
    let name: String
    let phases: [ActivityPhase]
    let observationsPerDay: ClosedRange<Int>
}

// MARK: - Programs

private let workdayProgram = DayProgram(
    name: "workday",
    phases: [
        ActivityPhase(
            name: "deep_sleep",
            trueState: "indoor",
            startMinute: 0,
            durationMinutes: 360,            // 00:00 – 06:00
            speedRange: -1.0 ... -1.0,
            accuracyRange: 80 ... 200,
            isMeasuredProbability: 0.05,
            classifierErrorRate: 0.4,
            providers: ["synthetic"],
            uvRange: nil
        ),
        ActivityPhase(
            name: "morning_routine",
            trueState: "indoor",
            startMinute: 360,
            durationMinutes: 90,             // 06:00 – 07:30
            speedRange: 0.0 ... 0.8,
            accuracyRange: 10 ... 40,
            isMeasuredProbability: 0.7,
            classifierErrorRate: 0.15,
            providers: ["A", "G", "AG"],
            uvRange: nil
        ),
        ActivityPhase(
            name: "commute_out",
            trueState: "outdoor",
            startMinute: 450,
            durationMinutes: 40,             // 07:30 – 08:10
            speedRange: 1.2 ... 4.5,
            accuracyRange: 5 ... 25,
            isMeasuredProbability: 0.95,
            classifierErrorRate: 0.1,
            providers: ["G", "AG"],
            uvRange: 1 ... 3
        ),
        ActivityPhase(
            name: "office_morning",
            trueState: "indoor",
            startMinute: 490,
            durationMinutes: 210,            // 08:10 – 11:40
            speedRange: 0.0 ... 0.5,
            accuracyRange: 15 ... 60,
            isMeasuredProbability: 0.6,
            classifierErrorRate: 0.2,
            providers: ["A", "G", "AG"],
            uvRange: nil
        ),
        ActivityPhase(
            name: "lunch_outdoor",
            trueState: "outdoor",
            startMinute: 700,
            durationMinutes: 60,             // 11:40 – 12:40
            speedRange: 0.5 ... 2.0,
            accuracyRange: 5 ... 20,
            isMeasuredProbability: 0.9,
            classifierErrorRate: 0.08,
            providers: ["G", "AG"],
            uvRange: 4 ... 8
        ),
        ActivityPhase(
            name: "office_afternoon",
            trueState: "indoor",
            startMinute: 760,
            durationMinutes: 240,            // 12:40 – 16:40
            speedRange: 0.0 ... 0.5,
            accuracyRange: 15 ... 60,
            isMeasuredProbability: 0.6,
            classifierErrorRate: 0.2,
            providers: ["A", "G", "AG"],
            uvRange: nil
        ),
        ActivityPhase(
            name: "commute_back",
            trueState: "outdoor",
            startMinute: 1000,
            durationMinutes: 45,             // 16:40 – 17:25
            speedRange: 1.0 ... 5.0,
            accuracyRange: 5 ... 25,
            isMeasuredProbability: 0.95,
            classifierErrorRate: 0.1,
            providers: ["G", "AG"],
            uvRange: 2 ... 5
        ),
        ActivityPhase(
            name: "evening_home",
            trueState: "indoor",
            startMinute: 1045,
            durationMinutes: 235,            // 17:25 – 21:00
            speedRange: 0.0 ... 0.6,
            accuracyRange: 20 ... 80,
            isMeasuredProbability: 0.5,
            classifierErrorRate: 0.2,
            providers: ["A", "G", "AG", "synthetic"],
            uvRange: nil
        ),
        ActivityPhase(
            name: "sleep",
            trueState: "indoor",
            startMinute: 1260,
            durationMinutes: 180,            // 21:00 – 00:00
            speedRange: -1.0 ... -1.0,
            accuracyRange: 60 ... 180,
            isMeasuredProbability: 0.05,
            classifierErrorRate: 0.4,
            providers: ["synthetic"],
            uvRange: nil
        )
    ],
    observationsPerDay: 120 ... 180
)

private let weekendProgram = DayProgram(
    name: "weekend",
    phases: [
        ActivityPhase(
            name: "sleep_in",
            trueState: "indoor",
            startMinute: 0,
            durationMinutes: 480,            // 00:00 – 08:00
            speedRange: -1.0 ... -1.0,
            accuracyRange: 80 ... 200,
            isMeasuredProbability: 0.05,
            classifierErrorRate: 0.4,
            providers: ["synthetic"],
            uvRange: nil
        ),
        ActivityPhase(
            name: "slow_morning",
            trueState: "indoor",
            startMinute: 480,
            durationMinutes: 120,            // 08:00 – 10:00
            speedRange: 0.0 ... 0.5,
            accuracyRange: 15 ... 50,
            isMeasuredProbability: 0.5,
            classifierErrorRate: 0.2,
            providers: ["A", "G"],
            uvRange: nil
        ),
        ActivityPhase(
            name: "outdoor_walk",
            trueState: "outdoor",
            startMinute: 600,
            durationMinutes: 90,             // 10:00 – 11:30
            speedRange: 0.8 ... 2.5,
            accuracyRange: 4 ... 18,
            isMeasuredProbability: 0.98,
            classifierErrorRate: 0.05,
            providers: ["G", "AG"],
            uvRange: 3 ... 7
        ),
        ActivityPhase(
            name: "indoor_lunch",
            trueState: "indoor",
            startMinute: 690,
            durationMinutes: 90,             // 11:30 – 13:00
            speedRange: 0.0 ... 0.4,
            accuracyRange: 10 ... 40,
            isMeasuredProbability: 0.7,
            classifierErrorRate: 0.18,
            providers: ["A", "G", "AG"],
            uvRange: nil
        ),
        ActivityPhase(
            name: "afternoon_outdoor",
            trueState: "outdoor",
            startMinute: 780,
            durationMinutes: 180,            // 13:00 – 16:00
            speedRange: 0.5 ... 3.0,
            accuracyRange: 4 ... 20,
            isMeasuredProbability: 0.95,
            classifierErrorRate: 0.07,
            providers: ["G", "AG"],
            uvRange: 5 ... 10
        ),
        ActivityPhase(
            name: "evening_home",
            trueState: "indoor",
            startMinute: 960,
            durationMinutes: 300,            // 16:00 – 21:00
            speedRange: 0.0 ... 0.5,
            accuracyRange: 20 ... 80,
            isMeasuredProbability: 0.45,
            classifierErrorRate: 0.22,
            providers: ["A", "synthetic"],
            uvRange: nil
        ),
        ActivityPhase(
            name: "sleep",
            trueState: "indoor",
            startMinute: 1260,
            durationMinutes: 180,
            speedRange: -1.0 ... -1.0,
            accuracyRange: 60 ... 180,
            isMeasuredProbability: 0.05,
            classifierErrorRate: 0.4,
            providers: ["synthetic"],
            uvRange: nil
        )
    ],
    observationsPerDay: 100 ... 150
)

// MARK: - Generator

struct GeneratedTestData {
    let observations: [HMMObservationDTO]
    let summaries: [DailySunSummaryDTO]
}

struct DailySunSummaryDTO {
    let date: Date
    let score: Double
    let wearSunscreen: Bool
    let wearProtectiveClothing: Bool
    let rawUVDose: Double
    let effectiveUVDose: Double
    let totalOutdoorMinutes: Double
    let peakUVIndex: Int
    let averageUVIndex: Double
    let observationCount: Int
}

enum HMMTestDataGenerator {
    
    /// Generate observations + daily summaries for the past `daysBack` days.
    /// Each day is independently seeded for reproducibility.
    static func generate(observationDaysBack: Int = 7) -> GeneratedTestData {
        var allObs: [HMMObservationDTO] = []
        var allSummaries: [DailySunSummaryDTO] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for offset in (1 ... observationDaysBack).reversed() {
            guard let dayStart = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            
            let weekday = calendar.component(.weekday, from: dayStart)
            let isWeekend = weekday == 1 || weekday == 7
            let program = isWeekend ? weekendProgram : workdayProgram
            
            var rng = SeededRNG(seed: UInt64(dayStart.timeIntervalSinceReferenceDate))
            
            let count = Int.random(in: program.observationsPerDay, using: &rng)
            let obs = generateDay(dayStart: dayStart, program: program, count: count, rng: &rng)
            
            allObs.append(contentsOf: obs)
            
            // Only generate a summary if this day is within summaryDaysBack
            if offset >= 2 {
                let summary = summarise(dayStart: dayStart, observations: obs, rng: &rng)
                allSummaries.append(summary)
            }
        }
        
        return GeneratedTestData(
            observations: allObs.sorted { $0.timestamp < $1.timestamp },
            summaries: allSummaries.sorted { $0.date < $1.date }
        )
    }
    
    // MARK: Summary derivation
    
    private static func summarise(
        dayStart: Date,
        observations: [HMMObservationDTO],
        rng: inout SeededRNG
    ) -> DailySunSummaryDTO {
        
        let outdoorObs = observations.filter { $0.trueState == "outdoor" }
        let uvObs = observations.compactMap { $0.uvIndex }
        
        // Each observation represents a ~few-minute window; treat as 8-min slots on average
        let minutesPerObs = 1440.0 / Double(max(observations.count, 1))
        let totalOutdoorMinutes = Double(outdoorObs.count) * minutesPerObs
        
        let peakUV = uvObs.max() ?? 0
        let averageUV = uvObs.isEmpty ? 0.0 : Double(uvObs.reduce(0, +)) / Double(uvObs.count)
        
        // rawUVDose: sum of (uvIndex * minutes) for outdoor observations
        // using Standard Erythema Dose approximation: 1 SED ≈ UV index 3 for 1 hour
        let rawUVDose = outdoorObs.reduce(0.0) { acc, obs in
            let uv = Double(obs.uvIndex ?? 0)
            return acc + (uv * minutesPerObs / 60.0)
        }
        
        // Randomly vary protection choices — higher UV days more likely to prompt protection
        let sunscreenThreshold = peakUV >= 6 ? 0.75 : (peakUV >= 3 ? 0.45 : 0.2)
        let clothingThreshold  = peakUV >= 8 ? 0.6  : (peakUV >= 5 ? 0.3  : 0.1)
        let wearSunscreen = Double.random(in: 0...1, using: &rng) < sunscreenThreshold
        let wearClothing  = Double.random(in: 0...1, using: &rng) < clothingThreshold
        
        // effectiveUVDose: reduced by protection factors
        let sunscreenSPF = 30.0
        let clothingUPF  = 50.0
        var protectionFactor = 1.0
        if wearSunscreen  { protectionFactor /= sunscreenSPF }
        if wearClothing   { protectionFactor /= clothingUPF  }
        let effectiveUVDose = rawUVDose * protectionFactor
        
        // Score: 0–100, higher = better sun relationship
        // Rewards outdoor time, penalises very high UV dose without protection
        let outdoorBonus  = min(50.0, totalOutdoorMinutes / 3.0)   // max at ~2.5h outdoor
        let uvPenalty     = min(30.0, effectiveUVDose * 10.0)
        let protectionBonus = (wearSunscreen ? 15.0 : 0.0) + (wearClothing ? 10.0 : 0.0)
        let rawScore = outdoorBonus - uvPenalty + protectionBonus + Double.random(in: -5...5, using: &rng)
        let score = min(100.0, max(0.0, rawScore))
        
        return DailySunSummaryDTO(
            date: dayStart,
            score: (score * 10).rounded() / 10,
            wearSunscreen: wearSunscreen,
            wearProtectiveClothing: wearClothing,
            rawUVDose: (rawUVDose * 100).rounded() / 100,
            effectiveUVDose: (effectiveUVDose * 1000).rounded() / 1000,
            totalOutdoorMinutes: (totalOutdoorMinutes * 10).rounded() / 10,
            peakUVIndex: peakUV,
            averageUVIndex: (averageUV * 10).rounded() / 10,
            observationCount: observations.count
        )
    }
    
    // MARK: Private
    
    private static func generateDay(
        dayStart: Date,
        program: DayProgram,
        count: Int,
        rng: inout SeededRNG
    ) -> [HMMObservationDTO] {
        
        // Build a weighted sampling pool: each minute of the day belongs to a phase.
        // We then draw `count` random minutes and generate one observation per minute.
        let totalMinutes = 1440
        var minuteToPhase = [ActivityPhase?](repeating: nil, count: totalMinutes)
        
        for phase in program.phases {
            let end = min(phase.startMinute + phase.durationMinutes, totalMinutes)
            for m in phase.startMinute ..< end {
                minuteToPhase[m] = phase
            }
        }
        
        // Sample `count` distinct minutes, biased toward covered phases
        let coveredMinutes = (0 ..< totalMinutes).filter { minuteToPhase[$0] != nil }
        guard !coveredMinutes.isEmpty else { return [] }
        
        var sampledMinutes = Set<Int>()
        var attempts = 0
        while sampledMinutes.count < count && attempts < count * 10 {
            let m = coveredMinutes[Int.random(in: 0 ..< coveredMinutes.count, using: &rng)]
            sampledMinutes.insert(m)
            attempts += 1
        }
        
        return sampledMinutes.sorted().compactMap { minute -> HMMObservationDTO? in
            guard let phase = minuteToPhase[minute] else { return nil }
            
            // Add sub-minute jitter (0–59 seconds)
            let secondOffset = Double(Int.random(in: 0 ..< 60, using: &rng))
            let timestamp = dayStart.addingTimeInterval(Double(minute) * 60 + secondOffset)
            
            // Speed: -1 means unmeasured (sleep/stationary)
            let speed: Double
            if phase.speedRange == -1.0 ... -1.0 {
                speed = -1.0
            } else {
                speed = Double.random(in: phase.speedRange, using: &rng)
            }
            
            let accuracy = Double.random(in: phase.accuracyRange, using: &rng)
            let isMeasured = Double.random(in: 0 ... 1, using: &rng) < phase.isMeasuredProbability
            
            // Provider selection
            let provider = phase.providers[Int.random(in: 0 ..< phase.providers.count, using: &rng)]
            
            // Per-provider labels
            let (aLabel, aConf) = providerLabel(
                provider: provider,
                source: "A",
                trueState: phase.trueState,
                errorRate: phase.classifierErrorRate,
                rng: &rng
            )
            let (gLabel, gConf) = providerLabel(
                provider: provider,
                source: "G",
                trueState: phase.trueState,
                errorRate: phase.classifierErrorRate,
                rng: &rng
            )
            
            // Fused classifier label
            let classifierLabel: String
            let classifierConfidence: Double
            
            switch provider {
            case "AG":
                // Average the two
                let aIsCorrect = aLabel == phase.trueState
                let gIsCorrect = gLabel == phase.trueState
                if aIsCorrect && gIsCorrect {
                    classifierLabel = phase.trueState
                    classifierConfidence = min(1.0, ((aConf ?? 0.5) + (gConf ?? 0.5)) / 2.0 + 0.05)
                } else if aIsCorrect || gIsCorrect {
                    classifierLabel = phase.trueState
                    classifierConfidence = 0.55 + Double.random(in: 0 ... 0.15, using: &rng)
                } else {
                    classifierLabel = opposite(phase.trueState)
                    classifierConfidence = 0.45 + Double.random(in: 0 ... 0.15, using: &rng)
                }
            case "synthetic":
                // Low-confidence synthetic observations
                let isError = Double.random(in: 0 ... 1, using: &rng) < phase.classifierErrorRate
                classifierLabel = isError ? opposite(phase.trueState) : phase.trueState
                classifierConfidence = 0.15 + Double.random(in: 0 ... 0.2, using: &rng)
            default:
                // Single provider
                let singleLabel = aLabel ?? gLabel ?? phase.trueState
                let singleConf = aConf ?? gConf ?? 0.5
                classifierLabel = singleLabel
                classifierConfidence = singleConf
            }
            
            // UV index: only present outdoors during daytime
            let uvIndex: Int?
            if phase.trueState == "outdoor", let uvRange = phase.uvRange {
                // Slight bell curve: peak around solar noon (minute 720)
                let solarFactor = 1.0 - abs(Double(minute) - 720.0) / 720.0
                let rawUV = Double(uvRange.lowerBound) + Double(uvRange.upperBound - uvRange.lowerBound) * solarFactor
                let jitter = Double.random(in: -1 ... 1, using: &rng)
                uvIndex = max(0, min(uvRange.upperBound, Int(rawUV + jitter)))
            } else {
                uvIndex = nil
            }
            
            return HMMObservationDTO(
                classifierLabel: classifierLabel,
                classifierConfidence: round(classifierConfidence * 1000) / 1000,
                provider: provider,
                aLabel: aLabel,
                aConfidence: aConf.map { round($0 * 1000) / 1000 },
                gLabel: gLabel,
                gConfidence: gConf.map { round($0 * 1000) / 1000 },
                speed: round(speed * 100) / 100,
                horizontalAccuracy: round(accuracy * 100) / 100,
                isMeasured: isMeasured,
                timestamp: timestamp,
                uvIndex: uvIndex,
                trueState: phase.trueState
            )
        }
    }
    
    /// Returns (label, confidence) for a given provider source (A or G).
    /// Returns nil label/confidence if the provider doesn't include that source.
    private static func providerLabel(
        provider: String,
        source: String,     // "A" or "G"
        trueState: String,
        errorRate: Double,
        rng: inout SeededRNG
    ) -> (String?, Double?) {
        let hasSource = provider == source || provider == "AG"
        guard hasSource else { return (nil, nil) }
        
        let isError = Double.random(in: 0 ... 1, using: &rng) < errorRate
        let label = isError ? opposite(trueState) : trueState
        
        // Confidence: correct predictions cluster high, errors cluster low
        let baseConfidence: Double
        if isError {
            baseConfidence = 0.3 + Double.random(in: 0 ... 0.25, using: &rng)
        } else {
            baseConfidence = 0.65 + Double.random(in: 0 ... 0.3, using: &rng)
        }
        return (label, min(1.0, baseConfidence))
    }
    
    private static func opposite(_ state: String) -> String {
        state == "indoor" ? "outdoor" : "indoor"
    }
}

// MARK: - Seeded RNG

/// A simple xoshiro256** PRNG that conforms to RandomNumberGenerator.
/// Using a seeded RNG means the same day always generates the same observations,
/// so SwiftData's `guard existing.isEmpty` deduplication keeps working correctly.
private struct SeededRNG: RandomNumberGenerator {
    private var state: (UInt64, UInt64, UInt64, UInt64)
    
    init(seed: UInt64) {
        // SplitMix64 to initialize state from a single seed
        func splitMix(_ z: inout UInt64) -> UInt64 {
            z &+= 0x9E3779B97F4A7C15
            var r = z
            r = (r ^ (r >> 30)) &* 0xBF58476D1CE4E5B9
            r = (r ^ (r >> 27)) &* 0x94D049BB133111EB
            return r ^ (r >> 31)
        }
        var z = seed
        state = (splitMix(&z), splitMix(&z), splitMix(&z), splitMix(&z))
    }
    
    mutating func next() -> UInt64 {
        let result = rotl(state.1 &* 5, 7) &* 9
        let t = state.1 << 17
        state.2 ^= state.0
        state.3 ^= state.1
        state.1 ^= state.2
        state.0 ^= state.3
        state.2 ^= t
        state.3 = rotl(state.3, 45)
        return result
    }
    
    private func rotl(_ x: UInt64, _ k: Int) -> UInt64 {
        (x << k) | (x >> (64 - k))
    }
}
#endif
