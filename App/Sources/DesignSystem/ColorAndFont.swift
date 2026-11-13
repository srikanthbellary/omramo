import SwiftUI
import UIKit
import CoreText
import OmramoCore

// SwiftUI wrappers over the core's design tokens (docs/DESIGN.md §3–4).

// MARK: - Colour

extension Color {
    init(rgba: RGBA) {
        self.init(.sRGB, red: rgba.red, green: rgba.green, blue: rgba.blue, opacity: rgba.alpha)
    }

    /// A content colour string (`#RRGGBB` or `#RRGGBBAA`). Falls back if the string is not a
    /// colour; the validator rejects such content, so the fallback is only a safety net.
    init(hex string: String, fallback: RGBA = Tokens.Palette.ink) {
        self.init(rgba: RGBA(string: string) ?? fallback)
    }
}

extension UIColor {
    convenience init(rgba: RGBA) {
        self.init(
            red: CGFloat(rgba.red),
            green: CGFloat(rgba.green),
            blue: CGFloat(rgba.blue),
            alpha: CGFloat(rgba.alpha)
        )
    }
}

extension Gradient {
    init(tokens: [Tokens.GradientStop]) {
        self.init(stops: tokens.map { stop in
            Gradient.Stop(color: Color(rgba: stop.color), location: CGFloat(stop.location))
        })
    }
}

extension LinearGradient {
    /// Top-to-bottom gradient from token stops.
    init(vertical tokens: [Tokens.GradientStop]) {
        self.init(gradient: Gradient(tokens: tokens), startPoint: .top, endPoint: .bottom)
    }
}

// MARK: - Fonts

/// Finds the bundled font files and makes sure they are registered.
///
/// The fonts are listed under `UIAppFonts` in Info.plist, which registers them at launch.
/// This type also registers them by URL (harmless if already registered) and reads each
/// file's real PostScript name, so a font is found even if a name assumed in the tokens
/// turns out to be different on device.
enum FontRegistrar {
    private struct Registration: Sendable {
        var postScriptNames: [String: String] = [:]
        var problems: [String] = []
    }

    private static let registration: Registration = {
        var result = Registration()
        for fileName in Tokens.FontFamily.allFileNames {
            let name = (fileName as NSString).deletingPathExtension
            let ext = (fileName as NSString).pathExtension
            guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
                result.problems.append("\(fileName) is not in the app bundle")
                continue
            }
            // Returns false when UIAppFonts has already registered the file; that is fine.
            _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            let descriptors = (CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor]) ?? []
            if let first = descriptors.first,
               let postScriptName = CTFontDescriptorCopyAttribute(first, kCTFontNameAttribute) as? String {
                result.postScriptNames[fileName] = postScriptName
            } else {
                result.problems.append("\(fileName) has no readable font descriptor")
            }
        }
        return result
    }()

    /// Registers the bundled fonts. Returns a list of problems; empty when all four files load.
    @discardableResult
    static func registerBundledFonts() -> [String] {
        registration.problems
    }

    /// The PostScript name to ask UIKit for: the one read from the file, else the token.
    static func postScriptName(for family: Tokens.FontFamily, italic: Bool) -> String {
        if italic, let file = family.italicFileName {
            return registration.postScriptNames[file] ?? family.italicPostScriptName ?? family.postScriptName
        }
        return registration.postScriptNames[family.fileName] ?? family.postScriptName
    }

    /// PostScript names actually found in the bundle, for the debug font check.
    static var registeredPostScriptNames: [String] {
        registration.postScriptNames.values.sorted()
    }
}

/// Builds fonts at exact variable-font axis values (`wght`, `opsz`, `wdth`). SwiftUI cannot
/// set fractional weights or other axes directly, so the font is made through a UIKit font
/// descriptor carrying Core Text variation values.
enum OmramoFont {
    /// - Parameter scale: the pane's scale from the reference pane (`PaneContext.scale`).
    static func uiFont(_ role: Tokens.TypeRole, scale: CGFloat = 1) -> UIFont {
        let name = FontRegistrar.postScriptName(for: role.family, italic: role.italic)
        var variations: [NSNumber: NSNumber] = [
            axis("wght"): NSNumber(value: clamp(role.weight, to: role.family.weightRange)),
        ]
        switch role.family {
        case .display:
            // Where the design gives no optical size, the browser used the point size.
            // The design value is kept when the pane is scaled, so letter shapes match the
            // screenshots at any size.
            let opticalSize = role.opticalSize ?? role.size
            variations[axis("opsz")] = NSNumber(value: clamp(opticalSize, to: Tokens.DisplayAxes.opticalSize))
            variations[axis("wdth")] = NSNumber(value: clamp(role.width ?? 100, to: Tokens.DisplayAxes.width))
        case .system:
            // Inter's optical-size axis runs 14–32 (read from the font file).
            variations[axis("opsz")] = NSNumber(value: clamp(role.size, to: 14...32))
        case .reading:
            break
        }
        let descriptor = UIFontDescriptor(fontAttributes: [
            .name: name,
            UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): variations,
        ])
        return UIFont(descriptor: descriptor, size: CGFloat(role.size) * scale)
    }

    static func font(_ role: Tokens.TypeRole, scale: CGFloat = 1) -> Font {
        Font(uiFont(role, scale: scale) as CTFont)
    }

    /// Extra space between lines so the line box equals the role's line height exactly.
    static func lineSpacing(for role: Tokens.TypeRole, scale: CGFloat = 1) -> CGFloat {
        guard let lineHeight = role.lineHeight else { return 0 }
        return max(0, CGFloat(lineHeight) * scale - uiFont(role, scale: scale).lineHeight)
    }

    /// A variation axis identifier: the four-character tag as a big-endian number.
    private static func axis(_ tag: String) -> NSNumber {
        var value: UInt32 = 0
        for byte in tag.utf8 {
            value = (value << 8) | UInt32(byte)
        }
        return NSNumber(value: value)
    }

    private static func clamp(_ value: Double, to range: ClosedRange<Double>) -> Double {
        min(range.upperBound, max(range.lowerBound, value))
    }
}

// MARK: - Text roles in views

private struct TypeRoleModifier: ViewModifier {
    @Environment(\.pane) private var pane
    let role: Tokens.TypeRole

    func body(content: Content) -> some View {
        content
            .font(OmramoFont.font(role, scale: pane.scale))
            .tracking(CGFloat(role.tracking) * pane.scale)
            .lineSpacing(OmramoFont.lineSpacing(for: role, scale: pane.scale))
            .textCase(role.uppercase ? .uppercase : nil)
    }
}

extension View {
    /// Applies a DESIGN.md text role, scaled to the pane.
    func typeRole(_ role: Tokens.TypeRole) -> some View {
        modifier(TypeRoleModifier(role: role))
    }
}
