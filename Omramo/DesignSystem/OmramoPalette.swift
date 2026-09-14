import SwiftUI
import OmramoCore

/// The small set of colours the whole app draws from. Paper and ink carry the
/// reading surface and adapt to the appearance setting: Light is cream paper
/// with dark ink, Dark is warm night paper with light ink, like a reading
/// lamp turned down. Saffron is the single accent used for actions.
enum OmramoPalette {
    static let paper = adaptive(light: 0xF7F1E3, dark: 0x1E1B18)
    static let paperShade = adaptive(light: 0xEDE6D4, dark: 0x282320)
    static let ink = adaptive(light: 0x1C1C21, dark: 0xEDE6D4)
    static let inkSoft = adaptive(light: 0x5C5754, dark: 0xB7AFA3)

    /// Fixed light text for surfaces that are always dark or saturated: the
    /// shelf behind an open book, poster art, mark tiles, saffron buttons.
    static let onShelf = Color(red: 0.97, green: 0.945, blue: 0.89)

    static let saffron = Color(red: 0.88, green: 0.48, blue: 0.12)
    static let indigo = Color(red: 0.17, green: 0.23, blue: 0.40)
    static let spine = Color(red: 0.24, green: 0.15, blue: 0.14)
    static let shelf = Color(red: 0.13, green: 0.10, blue: 0.09)

    private static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(rgb: dark) : UIColor(rgb: light)
        })
    }
}

private extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension Color {
    init(_ hex: HexColor) {
        self.init(
            red: Double(hex.red) / 255,
            green: Double(hex.green) / 255,
            blue: Double(hex.blue) / 255
        )
    }
}

extension Artwork {
    /// Colours as SwiftUI values, with a safe default when content has none.
    var swiftUIColors: [Color] {
        let mapped = colors.map(Color.init)
        return mapped.isEmpty ? [OmramoPalette.indigo, OmramoPalette.saffron] : mapped
    }
}
