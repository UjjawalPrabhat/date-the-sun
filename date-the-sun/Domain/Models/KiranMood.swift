import SwiftUI

/// Kiran's mood, driven by how well the user balances their time in the sun.
/// (See "KIRAN Brief Character Page".)
nonisolated enum KiranMood: String, CaseIterable {
    case happy      // balanced — warm pink corona, beaming
    case calm       // balanced — cool blue corona, gentle smile
    case neutral    // a little too much / too little — orange corona
    case toxic      // way too much or too little — fiery red corona, scowling

    /// Name of the illustrated asset in the asset catalog.
    var assetName: String {
        switch self {
        case .happy:   "KiranHappy"
        case .calm:    "KiranCalm"
        case .neutral: "KiranNeutral"
        case .toxic:   "KiranToxic"
        }
    }

    /// Corona color, useful for tinting accents to match Kiran's mood.
    var accent: Color {
        switch self {
        case .happy:   Color(hex: 0xEC5F86)
        case .calm:    Color(hex: 0x2E48C8)
        case .neutral: Color(hex: 0xF26A1B)
        case .toxic:   Color(hex: 0xB01E1E)
        }
    }

    /// A representative line of dialogue from the character brief.
    var line: String {
        switch self {
        case .happy:   "You're so understanding and attentive of me, I can't love you enough."
        case .calm:    "I like how you know me well and what you've been doing so far. Thank you."
        case .neutral: "I wanna see you. Don't get yourself too busy that you'd forget about me."
        case .toxic:   "Your obsession with me is getting out of hand! I need space, stay away!"
        }
    }
}
