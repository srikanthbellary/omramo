import Foundation

/// The three reading tiers. Each story belongs to exactly one.
public enum Tier: String, Codable, CaseIterable, Hashable, Sendable, Comparable {
    case low
    case medium
    case advanced

    /// 1, 2 or 3: how many bars of the tier glyph are lit.
    public var level: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .advanced: return 3
        }
    }

    /// The name on chips and pills. Whether these names are final is PRD Q3.
    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .advanced: return "Advanced"
        }
    }

    public static func < (lhs: Tier, rhs: Tier) -> Bool {
        lhs.level < rhs.level
    }

    /// The tier's reading typography for a posture (docs/DESIGN.md §4.2).
    public func readingScale(posture: DisplayPosture = .unfolded) -> ReadingTypeScale {
        ReadingTypeScale.scale(for: self, posture: posture)
    }
}
