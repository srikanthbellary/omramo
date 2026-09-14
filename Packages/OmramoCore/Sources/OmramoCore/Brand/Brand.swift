import Foundation

/// Single source of truth for the product's public identity.
///
/// Every user facing string that names the product reads from here, and the
/// fold mark tiles are derived from the name, so changing `displayName` (and
/// `BRAND_DISPLAY_NAME` in `Configuration/Brand.xcconfig`, which feeds the
/// bundle display name) is a complete rebrand. Store identifiers such as the
/// bundle id and product ids are deliberately not here: they are App Store
/// keys, not display copy, and must not change with the name.
public enum Brand {
    /// The public name. Also the fallback for the home screen label.
    public static let displayName = "Omramo"

    /// Public web domain. Kept separate so the name and the site can diverge.
    public static let domain = "omramo.com"

    public static var websiteURL: URL {
        URL(string: "https://\(domain)")!
    }

    /// Stub pages on the brand domain until the real documents are written.
    public static var privacyURL: URL {
        URL(string: "https://\(domain)/privacy")!
    }

    public static var termsURL: URL {
        URL(string: "https://\(domain)/terms")!
    }

    /// Name of the single subscription that unlocks the catalog, as shown in
    /// the simulated store and in copy. The App Store name is set in
    /// App Store Connect and the local StoreKit configuration.
    public static var allAccessName: String {
        "\(displayName) All Access"
    }

    /// The fold mark: left pane | spine | right pane. Derived from the name so
    /// "Omramo" becomes OM | RA | MO. Closed reads the name, open is the book.
    public static let mark = FoldMark.derived(from: displayName)

    /// Telugu tagline under the mark on the splash. Product copy, not a name,
    /// so it stays here with the rest of the identity.
    public static let tagline = "తెలుగు కథలు, తెరిచిన పుస్తకంలా"
}

/// Three tiles that spell the name when closed and become the two covers and
/// spine of a book when open.
public struct FoldMark: Hashable, Sendable {
    public var left: String
    public var spine: String
    public var right: String

    public init(left: String, spine: String, right: String) {
        self.left = left
        self.spine = spine
        self.right = right
    }

    /// All three tiles read together, which is how the closed mark appears.
    public var closed: String { left + spine + right }

    /// Splits a name into three upper case tiles of near equal length. Any
    /// remainder goes to the outer tiles first so the spine stays narrowest.
    /// Names shorter than three characters pad the spine with a middle dot.
    public static func derived(from name: String) -> FoldMark {
        let letters = Array(name.uppercased().filter { !$0.isWhitespace })
        guard letters.count >= 3 else {
            let padded = letters + Array(repeating: Character("·"), count: 3 - letters.count)
            return FoldMark(left: String(padded[0]), spine: String(padded[1]), right: String(padded[2]))
        }
        let base = letters.count / 3
        let remainder = letters.count % 3
        let leftCount = base + (remainder >= 1 ? 1 : 0)
        let rightCount = base + (remainder == 2 ? 1 : 0)
        let spineCount = letters.count - leftCount - rightCount
        let left = String(letters[0..<leftCount])
        let spine = String(letters[leftCount..<(leftCount + spineCount)])
        let right = String(letters[(leftCount + spineCount)...])
        return FoldMark(left: left, spine: spine, right: right)
    }
}
