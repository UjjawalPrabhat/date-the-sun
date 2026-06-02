import SwiftUI
import CoreText

/// The app's Jost typeface, bundled as static instances and registered at launch.
enum AppFont {
    static func regular(_ size: CGFloat) -> Font { .custom("JostRoman-Regular", size: size) }
    static func medium(_ size: CGFloat) -> Font { .custom("JostRoman-Medium", size: size) }
    static func semibold(_ size: CGFloat) -> Font { .custom("JostRoman-SemiBold", size: size) }

    /// Registers the bundled Jost faces with Core Text. Safe to call once at launch.
    static func registerBundledFonts() {
        for name in ["Jost-Regular", "Jost-Medium", "Jost-SemiBold"] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
