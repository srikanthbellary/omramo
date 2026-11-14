import Foundation

/// A colour as plain numbers (0...1). Content files and design tokens store colours as
/// `#RRGGBB` or `#RRGGBBAA` strings; the app turns `RGBA` into a SwiftUI `Color`.
public struct RGBA: Hashable, Sendable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// `RGBA(hex: 0x130F36)`; `alpha` is separate so tokens read like the design source.
    public init(hex: UInt32, alpha: Double = 1) {
        self.red = Double((hex >> 16) & 0xFF) / 255
        self.green = Double((hex >> 8) & 0xFF) / 255
        self.blue = Double(hex & 0xFF) / 255
        self.alpha = alpha
    }

    /// Parses `#RRGGBB` or `#RRGGBBAA`. Returns nil for anything else.
    public init?(string: String) {
        guard string.hasPrefix("#") else { return nil }
        let digits = String(string.dropFirst())
        guard digits.count == 6 || digits.count == 8 else { return nil }
        guard digits.allSatisfy({ $0.isHexDigit && $0.isASCII }) else { return nil }
        guard let value = UInt64(digits, radix: 16) else { return nil }
        if digits.count == 6 {
            self.init(hex: UInt32(value))
        } else {
            self.init(hex: UInt32(value >> 8), alpha: Double(value & 0xFF) / 255)
        }
    }

    public func opacity(_ newAlpha: Double) -> RGBA {
        RGBA(red: red, green: green, blue: blue, alpha: newAlpha)
    }

    /// `#RRGGBB`, upper case. Alpha is not included.
    public var hexString: String {
        let r = Int((red * 255).rounded())
        let g = Int((green * 255).rounded())
        let b = Int((blue * 255).rounded())
        return "#" + RGBA.twoHexDigits(r) + RGBA.twoHexDigits(g) + RGBA.twoHexDigits(b)
    }

    private static func twoHexDigits(_ value: Int) -> String {
        let clamped = min(255, max(0, value))
        let text = String(clamped, radix: 16, uppercase: true)
        return text.count == 1 ? "0" + text : text
    }
}
