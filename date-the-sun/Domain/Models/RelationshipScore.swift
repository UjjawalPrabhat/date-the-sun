import Foundation

/// A 0–100 measure of how well the user is "treating" Kiran (the sun) today,
/// derived from the UV index, time spent outdoors vs. indoors, and which
/// protection habits were logged.
///
/// Both *neglecting* the sun (barely going outside) and *overexposing* to it
/// (too much time under a strong UV index, unprotected) pull the score down;
/// balanced, protected time keeps it high. Kiran's `mood` is read from the
/// resulting score.
nonisolated struct RelationshipScore {
    /// 0 (the relationship is in trouble) … 100 (perfectly balanced).
    let value: Int
    let mood: KiranMood

    static func evaluate(
        uvIndex: Int,
        intervals: [SunExposureInterval],
        protection: [ProtectionItem]
    ) -> RelationshipScore {
        let outdoorMinutes = intervals
            .filter { $0.isOutdoor }
            .reduce(0.0) { $0 + ($1.endMinute - $1.startMinute) }

        let protectionTotal = max(protection.count, 1)
        let protectionRatio = Double(protection.filter { $0.isCompleted }.count) / Double(protectionTotal)

        // "UV-hours": how much sun intensity the user actually soaked up.
        let uvLoad = (outdoorMinutes / 60.0) * Double(uvIndex)

        // 1. Neglect — too little time together ("don't forget about me").
        let idealMinOutdoor = 45.0
        let neglect = outdoorMinutes < idealMinOutdoor
            ? (1 - outdoorMinutes / idealMinOutdoor) * 55
            : 0

        // 2. Overexposure — too much sun, eased by protection ("I need space").
        let safeLoad = 5.0 + protectionRatio * 9.0            // 5 … 14 UV-hours
        let overexposure = uvLoad > safeLoad
            ? min(55, (uvLoad - safeLoad) / safeLoad * 55)
            : 0

        // 3. Skipping protection when the sun actually warranted it.
        let protectionNeeded = uvIndex >= 3 && outdoorMinutes >= 30
        let protectionGap = protectionNeeded ? (1 - protectionRatio) * 20 : 0

        let score = max(0, min(100, 100 - neglect - overexposure - protectionGap))
        return RelationshipScore(value: Int(score.rounded()), mood: mood(for: score))
    }

    private static func mood(for score: Double) -> KiranMood {
        switch score {
        case 78...:   return .happy
        case 58..<78: return .calm
        case 33..<58: return .neutral
        default:      return .toxic
        }
    }
}
