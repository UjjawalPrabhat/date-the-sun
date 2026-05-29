import SwiftUI

/// Semantic color palette for the app's design.
enum Palette {
    static let ink        = Color(hex: 0x1A2238)   // headline navy
    static let subInk     = Color(hex: 0x3C4257)   // speech-bubble text

    // Sky → field gradient
    static let skyTop      = Color(hex: 0xCFE4F1)
    static let skyBottom   = Color(hex: 0xDDEBDF)
    static let fieldTop    = Color(hex: 0xC3D9A7)
    static let fieldBottom = Color(hex: 0xA1C57E)

    // UV pill
    static let pill       = Color(hex: 0xFFC83D)
    static let pillStroke = Color(hex: 0xE9A92B)

    // Sun character
    static let rayOuter   = Color(hex: 0xF15A24)   // deep orange tips
    static let rayInner   = Color(hex: 0xFFA12E)   // warm orange
    static let face       = Color(hex: 0xFBC74A)   // golden face
    static let faceShade  = Color(hex: 0xF1A93B)
    static let feature    = Color(hex: 0x4A2C12)   // eyes / smile

    // Outfit
    static let sash       = Color(hex: 0x9AA63E)   // olive wrap
    static let sashShade  = Color(hex: 0x7E8A30)
    static let shirt      = Color(hex: 0xFBFAF4)   // off-white tee
    static let pants      = Color(hex: 0xE0739B)   // pink trousers
    static let skin       = Color(hex: 0xF6C249)

    // Tab bar
    static let barBG      = Color(hex: 0x14151A)
    static let barIcon    = Color(hex: 0xCFCFD4)

    // UV accent
    static let uvIcon     = Color(hex: 0xF26A1B)

    // Summary dashboard
    static let canvas     = Color(hex: 0xF6F2E3)   // cream screen background
    static let heroSky    = Color(hex: 0x6FA8DC)   // blue hero card
    static let cardHeader  = Color(hex: 0x14151A)  // black card header
    static let rowSubtitle = Color(hex: 0x8A8F9C)  // muted row subtitle
}
