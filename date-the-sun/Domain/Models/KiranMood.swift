import SwiftUI

/// Kiran's mood, driven by how well the user balances their time in the sun.
/// (See "KIRAN Brief Character Page".)
nonisolated enum KiranMood: String, CaseIterable {
    case happy      // balanced — warm pink corona, beaming
    case neutral    // a little too much / too little — orange corona
    case angry      // way too much or too little — fiery red corona, scowling
    
    /// Name of the illustrated asset in the asset catalog (static fallback).
    var assetName: String {
        switch self {
        case .happy:   "KiranHappy"
        case .neutral: "KiranNeutral"
        case .angry:   "KiranAngry"
        }
    }
    
    /// Name of the bundled Lottie animation (a `<name>.json` in the app bundle).
    var lottieName: String {
        switch self {
        case .happy:   "KiranHappy"
        case .neutral: "KiranNeutral"
        case .angry:   "KiranAngry"
        }
    }
    
    /// Corona color, useful for tinting accents to match Kiran's mood.
    var accent: Color {
        switch self {
        case .happy:   Color(hex: 0xEC5F86)
        case .neutral: Color(hex: 0xF26A1B)
        case .angry:   Color(hex: 0xB01E1E)
        }
    }
    
    /// The bold hero headline shown on the Summary screen for this mood.
    var headline: String {
        switch self {
        case .happy:   "What a happy day — especially with you"
        case .neutral: "Don't get so busy you forget about me"
        case .angry:   "Easy — I think I need a little space today"
        }
    }
    
    /// A random line of dialogue from the character brief for this mood.
    var line: String {
        let phrases: [String]
        switch self {
        case .happy:
            phrases = [
                "I'm feeling pretty chill today. Do you want to hang?",
                "I am fine today, thank you. You're fine as well, to me.",
                "You notice that I'm doing good today. I hope you do too!"
            ]
        case .neutral:
            phrases = [
                "I don't know about today. I'm not feeling great.",
                "If you ask me if I were okay, I can't say so."
            ]
        case .angry:
            phrases = [
                "Your obsession with me is getting out of hand! I need space, stay away",
                "I'm so infuriated today, I might burn you if you're not careful with me.",
                "I'm in a really bad mood, don't try to cross me!",
                "Do you think I look okay to you?! I am far from okay!"
            ]
        }
        return phrases.randomElement() ?? ""
    }
}

extension KiranMood {
    static func from(uvIndex: Int) -> KiranMood {
        switch uvIndex {
        case 0...3: return .happy
        case 4...6: return .neutral
        case 7...12: return .angry
        default:    return .neutral
        }
    }
    
    static func from(score: Double) -> KiranMood {
        switch score {
        case 60...70:           return .happy
        case 40..<60, 70..<80:  return .neutral
        default:                return .angry
        }
    }
}
