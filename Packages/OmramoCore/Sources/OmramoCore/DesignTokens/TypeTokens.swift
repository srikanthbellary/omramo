import Foundation

// Typography as data (docs/DESIGN.md §4). Sizes are points on the 432 × 720 reference pane.
// Weights are variable-font `wght` values; `opsz` and `wdth` are Bricolage Grotesque axes.

extension Tokens {
    /// The three bundled families (all SIL OFL 1.1).
    public enum FontFamily: String, Equatable, Hashable, Sendable, CaseIterable {
        /// Bricolage Grotesque: titles, lead sentences, sound words, labels, chips, buttons.
        case display
        /// Atkinson Hyperlegible Next: all story text, card body text, captions.
        case reading
        /// Inter in the designs, standing in for the system font (PRD Q15).
        case system

        /// The font file in `App/Resources/Fonts`.
        public var fileName: String {
            switch self {
            case .display: return "BricolageGrotesque.ttf"
            case .reading: return "AtkinsonHyperlegibleNext.ttf"
            case .system: return "Inter.ttf"
            }
        }

        /// The italic file, where the family has one.
        public var italicFileName: String? {
            self == .reading ? "AtkinsonHyperlegibleNext-Italic.ttf" : nil
        }

        /// PostScript name of the default instance, read from the font file's name table.
        public var postScriptName: String {
            switch self {
            case .display: return "BricolageGrotesque-96ptExtraBold"
            case .reading: return "AtkinsonHyperlegibleNext-Regular"
            case .system: return "Inter-Regular"
            }
        }

        public var italicPostScriptName: String? {
            self == .reading ? "AtkinsonHyperlegibleNext-Italic" : nil
        }

        /// Every font file the app must bundle and list in `UIAppFonts`.
        public static let allFileNames: [String] = [
            "BricolageGrotesque.ttf",
            "AtkinsonHyperlegibleNext.ttf",
            "AtkinsonHyperlegibleNext-Italic.ttf",
            "Inter.ttf",
        ]

        /// The `wght` range of the variable font, read from its `fvar` table.
        public var weightRange: ClosedRange<Double> {
            switch self {
            case .display, .reading: return 200...800
            case .system: return 100...900
            }
        }
    }

    /// Bricolage Grotesque axis ranges, read from the font's `fvar` table.
    public enum DisplayAxes {
        public static let opticalSize: ClosedRange<Double> = 12...96
        public static let width: ClosedRange<Double> = 75...100
    }

    /// One text style: family, size and variable-font axis values.
    public struct TypeRole: Equatable, Hashable, Sendable {
        public var family: FontFamily
        public var size: Double
        /// Nil = the font's natural line height.
        public var lineHeight: Double?
        public var weight: Double
        public var tracking: Double
        /// Bricolage optical size. Nil = follow the point size (what the browser did in the designs).
        public var opticalSize: Double?
        /// Bricolage width axis. Nil = 100.
        public var width: Double?
        public var uppercase: Bool
        public var italic: Bool

        public init(
            _ family: FontFamily,
            size: Double,
            lineHeight: Double? = nil,
            weight: Double,
            tracking: Double = 0,
            opticalSize: Double? = nil,
            width: Double? = nil,
            uppercase: Bool = false,
            italic: Bool = false
        ) {
            self.family = family
            self.size = size
            self.lineHeight = lineHeight
            self.weight = weight
            self.tracking = tracking
            self.opticalSize = opticalSize
            self.width = width
            self.uppercase = uppercase
            self.italic = italic
        }

        /// The same role at another size (tracking and line height scale with it).
        public func scaled(by factor: Double) -> TypeRole {
            var copy = self
            copy.size = size * factor
            copy.lineHeight = lineHeight.map { $0 * factor }
            copy.tracking = tracking * factor
            return copy
        }
    }

    /// UI type scale (DESIGN.md §4.4).
    public enum UIType {
        public static let splashWordmark = TypeRole(.display, size: 158, lineHeight: 158, weight: 800, tracking: -3, opticalSize: 96, width: 100)
        public static let splashTagline = TypeRole(.reading, size: 19, weight: 480, tracking: 0.2)
        public static let screenTitle = TypeRole(.display, size: 30, lineHeight: 31.5, weight: 760, tracking: -0.9, opticalSize: 48, width: 90)
        public static let heroTitle = TypeRole(.display, size: 36, lineHeight: 37, weight: 780, tracking: -1.2, opticalSize: 60, width: 90)
        public static let cardHeroTitle = TypeRole(.display, size: 40, lineHeight: 40, weight: 780, tracking: -1.2, opticalSize: 60, width: 90)
        public static let characterNameTitle = TypeRole(.display, size: 38, lineHeight: 38, weight: 800, tracking: -1.2, opticalSize: 60, width: 90)
        public static let bigNumber = TypeRole(.display, size: 56, lineHeight: 56, weight: 800, tracking: -2.5, opticalSize: 96, width: 90)
        public static let price = TypeRole(.display, size: 46, lineHeight: 46, weight: 800, tracking: -1.5, opticalSize: 96, width: 90)
        public static let statNumber = TypeRole(.display, size: 26, weight: 800, tracking: -0.8)
        public static let keepReadingTitle = TypeRole(.display, size: 25, lineHeight: 26, weight: 760, tracking: -0.7, opticalSize: 36, width: 88)
        public static let gateTitle = TypeRole(.display, size: 25, weight: 780, tracking: -0.7, opticalSize: 36, width: 90)
        public static let cardHeading = TypeRole(.display, size: 17, weight: 700, tracking: -0.3, opticalSize: 20, width: 92)
        public static let navWordmark = TypeRole(.display, size: 22, weight: 800, tracking: -0.3, opticalSize: 30, width: 96)
        public static let buttonLabel = TypeRole(.display, size: 17, weight: 700, tracking: -0.2)
        public static let sectionLabel = TypeRole(.display, size: 11, weight: 650, tracking: 0.9, uppercase: true)
        public static let chip = TypeRole(.display, size: 12, weight: 650, tracking: 0.1)
        public static let crumbTitle = TypeRole(.display, size: 14, lineHeight: 16, weight: 650, tracking: -0.1, opticalSize: 14, width: 95)
        public static let crumbSubtitle = TypeRole(.display, size: 11.5, weight: 500, tracking: 0.1)
        public static let footer = TypeRole(.display, size: 12, weight: 600)
        public static let storyCardTitle = TypeRole(.display, size: 13, lineHeight: 15.5, weight: 680, tracking: -0.15)
        public static let storyCardPlace = TypeRole(.display, size: 11, weight: 600)
        public static let tabLabel = TypeRole(.display, size: 10.5, weight: 650)
        public static let segmentLabel = TypeRole(.display, size: 13, weight: 650)
        public static let bodySmall = TypeRole(.reading, size: 13, lineHeight: 18, weight: 450)
        public static let cardLine = TypeRole(.reading, size: 19, lineHeight: 29, weight: 480)
        public static let cultureNoteBody = TypeRole(.reading, size: 13.5, lineHeight: 19.5, weight: 440)
        public static let cultureNoteLabel = TypeRole(.display, size: 12, weight: 700, tracking: 0.7, uppercase: true)
        public static let cardSubtitle = TypeRole(.display, size: 13, weight: 600, tracking: 0.2, opticalSize: 14)
        public static let traitPill = TypeRole(.display, size: 12.5, weight: 680)
        public static let toast = TypeRole(.display, size: 13.5, weight: 650)
        public static let aaControl = TypeRole(.reading, size: 16, weight: 700, tracking: -0.3)
        public static let aaControlSmall = TypeRole(.reading, size: 12, weight: 700, tracking: -0.3)
        public static let settingsRow = TypeRole(.system, size: 15.5, weight: 400, tracking: -0.2)
        public static let settingsValue = TypeRole(.system, size: 14.5, weight: 400, tracking: -0.2)
        public static let gateWords = TypeRole(.reading, size: 21, weight: 700, tracking: 0.2)
        public static let gateDigit = TypeRole(.display, size: 30, weight: 760)
        public static let keypadKey = TypeRole(.system, size: 23, weight: 400)
        public static let chartAxis = TypeRole(.system, size: 10, weight: 400)
        /// Label on a map pin (design source: Bricolage 10.5, wght 700).
        public static let mapPinLabel = TypeRole(.display, size: 10.5, weight: 700)
        /// Map legend (design source: Bricolage 11, wght 600).
        public static let mapLegend = TypeRole(.display, size: 11, weight: 600)
    }
}

/// The reading typography of one tier in one posture (DESIGN.md §4.2). The tier metrics are
/// data: views read them from here and never hardcode a size.
public struct ReadingTypeScale: Equatable, Hashable, Sendable {
    public var tier: Tier
    public var posture: DisplayPosture
    /// Body text (Atkinson Hyperlegible Next).
    public var body: Tokens.TypeRole
    /// Lead sentence (Bricolage Grotesque).
    public var lead: Tokens.TypeRole
    public var wordSpacing: Double
    public var paragraphGap: Double
    /// Width of the text column.
    public var column: Double
    /// Top of the first line of story text on the pane.
    public var textTop: Double
    /// About how many words a page holds at the designed size.
    public var targetWordsPerSpread: Int
    /// True when the designs draw this tier in this posture; false when the values are a
    /// stand-in (folded Medium and Advanced are design gap G8).
    public var isDesigned: Bool

    // Word-level styles shared by every tier (DESIGN.md §4.3).
    /// `wght` of voices, tap words and names.
    public static let emphasisWeight: Double = 640
    /// Sound word: Bricolage wght 760, opsz 30, wdth 86, tracking −0.2.
    public static let popWeight: Double = 760
    public static let popOpticalSize: Double = 30
    public static let popWidth: Double = 86
    public static let popTracking: Double = -0.2
    public static let popDefaultScale: Double = 1.25
    /// Stretched word: italic, wght 560, letter spacing 0.14 em.
    public static let stretchWeight: Double = 560
    public static let stretchTrackingEm: Double = 0.14
    /// Face chip: circle 1.12 em, baseline offset −0.22 em, margins 0.04 em / 0.22 em, ring 1.5 pt.
    public static let faceChipSizeEm: Double = 1.12
    public static let faceChipBaselineEm: Double = -0.22
    public static let faceChipLeadingEm: Double = 0.04
    public static let faceChipTrailingEm: Double = 0.22
    public static let faceChipRing: Double = 1.5
    /// Tap word: padding 0.18 em, highlight from 8% to 92% of the line box, 2 pt underline,
    /// spark 0.5 em raised 0.5 em, 0.16 em after the word.
    public static let tapPaddingEm: Double = 0.18
    public static let tapBandTop: Double = 0.08
    public static let tapBandBottom: Double = 0.92
    public static let tapUnderline: Double = 2
    public static let tapSparkEm: Double = 0.5
    public static let tapSparkRaiseEm: Double = 0.5
    public static let tapSparkGapEm: Double = 0.16
    /// Name: dotted underline 2 pt, offset 0.2 em.
    public static let nameUnderline: Double = 2
    public static let nameUnderlineOffsetEm: Double = 0.2

    public static func scale(for tier: Tier, posture: DisplayPosture = .unfolded) -> ReadingTypeScale {
        switch tier {
        case .low:
            let lead = Tokens.TypeRole(.display, size: 32, lineHeight: 38, weight: 720, tracking: -0.6, opticalSize: 48, width: 92)
            if posture == .folded {
                // Screen 10: 22.5 / 35 with 12 pt paragraph gaps, text at left 30, top 366, width 376.
                // The folded lead sentence is not drawn in the designs; it is scaled by the same ratio.
                return ReadingTypeScale(
                    tier: .low,
                    posture: .folded,
                    body: Tokens.TypeRole(.reading, size: 22.5, lineHeight: 35, weight: 460, tracking: 0.1),
                    lead: lead.scaled(by: 22.5 / 23.5),
                    wordSpacing: 0.4,
                    paragraphGap: 12,
                    column: 376,
                    textTop: 366,
                    targetWordsPerSpread: 55,
                    isDesigned: true
                )
            }
            return ReadingTypeScale(
                tier: .low,
                posture: .unfolded,
                body: Tokens.TypeRole(.reading, size: 23.5, lineHeight: 37, weight: 460, tracking: 0.1),
                lead: lead,
                wordSpacing: 0.4,
                paragraphGap: 17,
                column: 374,
                textTop: 106,
                targetWordsPerSpread: 55,
                isDesigned: true
            )
        case .medium:
            return ReadingTypeScale(
                tier: .medium,
                posture: posture,
                body: Tokens.TypeRole(.reading, size: 19.5, lineHeight: 32, weight: 430, tracking: 0.1),
                lead: Tokens.TypeRole(.display, size: 27, lineHeight: 33, weight: 700, tracking: -0.5, opticalSize: 36, width: 90),
                wordSpacing: 0.6,
                paragraphGap: 16,
                column: 372,
                textTop: 108,
                targetWordsPerSpread: 90,
                isDesigned: posture == .unfolded
            )
        case .advanced:
            return ReadingTypeScale(
                tier: .advanced,
                posture: posture,
                body: Tokens.TypeRole(.reading, size: 16.5, lineHeight: 27, weight: 420, tracking: 0.05),
                lead: Tokens.TypeRole(.display, size: 21, lineHeight: 27, weight: 680, tracking: -0.3, opticalSize: 24, width: 88),
                wordSpacing: 0.3,
                paragraphGap: 12,
                column: 374,
                textTop: 108,
                targetWordsPerSpread: 190,
                isDesigned: posture == .unfolded
            )
        }
    }
}
