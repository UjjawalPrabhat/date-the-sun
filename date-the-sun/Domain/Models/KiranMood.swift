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
    /// Every mood is animated; the optional keeps the static `assetName` fallback
    /// available if the Lottie package is ever absent.
    var lottieName: String? {
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

    /// A representative line of dialogue from the character brief.
    var line: String {
        switch self {
        case .happy:   "You're so understanding and attentive of me, I can't love you enough."
        case .neutral: "I wanna see you. Don't get yourself too busy that you'd forget about me."
        case .angry:   "Your obsession with me is getting out of hand! I need space, stay away!"
        }
    }
}
