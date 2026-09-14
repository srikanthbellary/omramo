import SwiftUI
import OmramoCore

/// The small set of colours the whole app draws from. Paper and ink carry the
/// reading surface; saffron is the single accent used for actions.
enum OmramoPalette {
    static let paper = Color(red: 0.97, green: 0.945, blue: 0.89)
    static let paperShade = Color(red: 0.93, green: 0.90, blue: 0.83)
    static let ink = Color(red: 0.11, green: 0.11, blue: 0.13)
    static let inkSoft = Color(red: 0.36, green: 0.34, blue: 0.33)
    static let saffron = Color(red: 0.88, green: 0.48, blue: 0.12)
    static let indigo = Color(red: 0.17, green: 0.23, blue: 0.40)
    static let spine = Color(red: 0.24, green: 0.15, blue: 0.14)
    static let shelf = Color(red: 0.13, green: 0.10, blue: 0.09)
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
