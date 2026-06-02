import SwiftUI

/// Semantic color palette for the app's design.
enum Palette {
    static let ink         = Color(hex: 0x1A2238)   // headline navy
    static let subInk      = Color(hex: 0x3C4257)   // speech-bubble text

    // Today screen
    static let pill        = Color(hex: 0xFFC83D)   // UV pill
    static let pillStroke  = Color(hex: 0xE9A92B)
    static let uvIcon      = Color(hex: 0xF26A1B)
    static let shirt       = Color(hex: 0xFBFAF4)   // speech bubble / tab highlight
    static let fieldBottom = Color(hex: 0xA1C57E)

    // Tab bar
    static let barBG       = Color(hex: 0x14151A)
    static let barIcon     = Color(hex: 0xCFCFD4)

    // Summary dashboard
    static let canvas      = Color(hex: 0xF6F2E3)   // cream screen background
    static let heroSky     = Color(hex: 0x73B2F7)   // blue hero card
    static let pants       = Color(hex: 0xE0739B)   // pink protection card
    static let cardHeader  = Color(hex: 0x14151A)   // black card header
    static let rowSubtitle = Color(hex: 0x8A8F9C)   // muted row subtitle
}
