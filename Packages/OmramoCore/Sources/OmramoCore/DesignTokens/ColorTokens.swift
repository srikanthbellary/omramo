import Foundation

/// Design tokens as plain numbers, copied from docs/DESIGN.md §3 (which copies the locked
/// design source, `designs-v2/src/lib/base.js`). The app wraps these in SwiftUI types.
public enum Tokens {}

// MARK: - Colours (DESIGN.md §3.1)

extension Tokens {
    public enum Palette {
        // Brand
        public static let night = RGBA(hex: 0x130F36)
        public static let night2 = RGBA(hex: 0x1F1856)
        public static let cloud = RGBA(hex: 0xF3F1FF)
        public static let ink = RGBA(hex: 0x16123D)
        public static let coral = RGBA(hex: 0xFF6A4D)
        public static let sun = RGBA(hex: 0xFFC43D)
        public static let mint = RGBA(hex: 0x19C7A2)
        public static let sky = RGBA(hex: 0x3FB4FF)
        public static let violet = RGBA(hex: 0x7257FF)
        public static let rose = RGBA(hex: 0xFF5C8A)

        // Additional UI colours
        public static let surfaceLight = RGBA(hex: 0xF4F2FF)
        public static let surfaceDark = RGBA(hex: 0x110C33)
        public static let sheet = RGBA(hex: 0xF4F2FB)
        public static let keypadTray = RGBA(hex: 0xD8D5E6)
        public static let wordmarkAccent = RGBA(hex: 0xFF5B3D)
        public static let placeMarker = RGBA(hex: 0xFF7A3D)
        public static let mapPinGhana = RGBA(hex: 0xFFB020)
        public static let mapPinJapan = RGBA(hex: 0xFF6A8A)
        public static let violetStrong = RGBA(hex: 0x5A3FE0)
        public static let violetLight = RGBA(hex: 0x8E7BFF)
        public static let chartBar = RGBA(hex: 0xB9ADFF)
        public static let finishedCheck = RGBA(hex: 0x0B8A6C)
        public static let pageTurnAmberArrow = RGBA(hex: 0x3A1B08)

        // Text opacities on light UI
        public static let textPrimary = ink
        public static let textSecondary = ink.opacity(0.62)
        public static let textLabel = ink.opacity(0.5)
        public static let hairline = ink.opacity(0.12)

        /// Default reading text colour; each story sets its own in `theme.textColor`.
        public static let readingTextDefault = RGBA(hex: 0x12203A)
    }
}

// MARK: - Tier colours (DESIGN.md §3.2)

extension Tokens {
    public struct TierColors: Equatable, Sendable {
        /// `--low`, `--med`, `--adv`.
        public let base: RGBA
        /// Solid pill on covers and in the level filter.
        public let pillText: RGBA
        public let pillBackground: RGBA
        /// Tier chip text on glass in the reader footer.
        public let chipTextOnGlass: RGBA

        public static func colors(for tier: Tier) -> TierColors {
            switch tier {
            case .low:
                return TierColors(
                    base: RGBA(hex: 0x12B58F),
                    pillText: RGBA(hex: 0x0B8A6C),
                    pillBackground: RGBA(hex: 0xD6F7EC),
                    chipTextOnGlass: RGBA(hex: 0x0B7A62)
                )
            case .medium:
                return TierColors(
                    base: RGBA(hex: 0xFF9F1A),
                    pillText: RGBA(hex: 0xB36200),
                    pillBackground: RGBA(hex: 0xFFEFC9),
                    chipTextOnGlass: RGBA(hex: 0xFFC43D)
                )
            case .advanced:
                return TierColors(
                    base: RGBA(hex: 0x6E56FF),
                    pillText: RGBA(hex: 0x5A3FE0),
                    pillBackground: RGBA(hex: 0xE6E0FF),
                    chipTextOnGlass: RGBA(hex: 0x5A3FE0)
                )
            }
        }
    }
}

// MARK: - Gradients (DESIGN.md §3.3)

extension Tokens {
    public struct GradientStop: Equatable, Sendable {
        public let color: RGBA
        /// 0...1 along the gradient.
        public let location: Double

        public init(_ color: RGBA, _ location: Double) {
            self.color = color
            self.location = location
        }
    }

    public enum Gradients {
        /// Page-turn button: radial, centred at 32% 26% of the button.
        public static let pageTurnCenter = (x: 0.32, y: 0.26)

        public static func pageTurn(_ accent: StoryTheme.Accent) -> [GradientStop] {
            switch accent {
            case .coral:
                return [.init(RGBA(hex: 0xFF9A66), 0), .init(RGBA(hex: 0xFF5B3D), 0.62), .init(RGBA(hex: 0xE8432B), 1)]
            case .amber:
                return [.init(RGBA(hex: 0xFFD76B), 0), .init(RGBA(hex: 0xFFB020), 0.62), .init(RGBA(hex: 0xF08A12), 1)]
            case .red:
                return [.init(RGBA(hex: 0xFF8A70), 0), .init(RGBA(hex: 0xF4503F), 0.62), .init(RGBA(hex: 0xD8342B), 1)]
            }
        }

        /// Arrow colour on the page-turn button.
        public static func pageTurnArrow(_ accent: StoryTheme.Accent) -> RGBA {
            accent == .amber ? Palette.pageTurnAmberArrow : RGBA(hex: 0xFFFFFF)
        }

        /// Drop-shadow colour under the page-turn button.
        public static func pageTurnShadow(_ accent: StoryTheme.Accent) -> RGBA {
            accent == .amber ? RGBA(hex: 0xFFA014, alpha: 0.4) : RGBA(hex: 0xE8432B, alpha: 0.42)
        }

        // Linear, top to bottom unless noted.
        public static let buttonPrimary: [GradientStop] = [.init(RGBA(hex: 0xFF8A66), 0), .init(RGBA(hex: 0xFF5B3D), 1)]
        public static let buttonSun: [GradientStop] = [.init(RGBA(hex: 0xFFD25A), 0), .init(RGBA(hex: 0xFFB020), 1)]
        public static let buttonViolet: [GradientStop] = [.init(RGBA(hex: 0x8E7BFF), 0), .init(RGBA(hex: 0x5A3FE0), 1)]
        public static let wordmarkRA: [GradientStop] = [
            .init(RGBA(hex: 0xFFD25A), 0.1), .init(RGBA(hex: 0xFF7A4D), 0.6), .init(RGBA(hex: 0xFF4D7A), 1),
        ]
        public static let streakDay: [GradientStop] = [.init(RGBA(hex: 0xFFB84D), 0), .init(RGBA(hex: 0xFF7A3D), 1)]
        /// Linear at 160°.
        public static let mapCard: [GradientStop] = [.init(RGBA(hex: 0x2A1F7A), 0), .init(RGBA(hex: 0x17114A), 0.7)]
        /// Linear at 160°.
        public static let planHeader: [GradientStop] = [.init(RGBA(hex: 0x3A2BB0), 0), .init(RGBA(hex: 0x1B1466), 0.7)]
        public static let characterCardMonkey: [GradientStop] = [
            .init(RGBA(hex: 0xFFD35A), 0), .init(RGBA(hex: 0xFFAE45), 0.46), .init(RGBA(hex: 0xFF8A4D), 0.7),
        ]
    }

    /// One blurred circle of the aurora backdrop, on the 892 × 720 reference canvas.
    public struct AuroraBlob: Equatable, Sendable {
        public let x: Double
        public let y: Double
        public let radius: Double
        public let color: RGBA
        public let opacity: Double
    }

    public struct Aurora: Equatable, Sendable {
        public let base: RGBA
        public let blobs: [AuroraBlob]
        /// Gaussian blur radius, in reference points.
        public let blur: Double
        public let grainOpacity: Double

        public static let light = Aurora(
            base: RGBA(hex: 0xF4F2FF),
            blobs: [
                AuroraBlob(x: 80, y: 60, radius: 300, color: RGBA(hex: 0xC9BEFF), opacity: 0.70),
                AuroraBlob(x: 820, y: 120, radius: 300, color: RGBA(hex: 0xBFEFE6), opacity: 0.75),
                AuroraBlob(x: 760, y: 700, radius: 320, color: RGBA(hex: 0xFFD9C2), opacity: 0.70),
                AuroraBlob(x: 120, y: 700, radius: 280, color: RGBA(hex: 0xFFE9A8), opacity: 0.55),
                AuroraBlob(x: 446, y: 380, radius: 260, color: RGBA(hex: 0xE3DCFF), opacity: 0.60),
            ],
            blur: 70,
            grainOpacity: 0.35
        )

        public static let dark = Aurora(
            base: RGBA(hex: 0x110C33),
            blobs: [
                AuroraBlob(x: 140, y: 120, radius: 300, color: RGBA(hex: 0x5B3BFF), opacity: 0.50),
                AuroraBlob(x: 760, y: 600, radius: 320, color: RGBA(hex: 0xFF5C7A), opacity: 0.32),
                AuroraBlob(x: 820, y: 80, radius: 240, color: RGBA(hex: 0x19C7A2), opacity: 0.28),
                AuroraBlob(x: 80, y: 680, radius: 260, color: RGBA(hex: 0xFF9F1A), opacity: 0.22),
                AuroraBlob(x: 446, y: 360, radius: 240, color: RGBA(hex: 0x7257FF), opacity: 0.30),
            ],
            blur: 70,
            grainOpacity: 0.55
        )
    }
}

// MARK: - Glass and shadows (DESIGN.md §3.6)

extension Tokens {
    public struct Glass: Equatable, Sendable {
        public let fill: RGBA
        public let edge: RGBA
        public let highlight: RGBA
        public let shadow: RGBA
        /// Colour of icons and text on the glass.
        public let content: RGBA
        public static let blurRadius: Double = 18

        public static let light = Glass(
            fill: RGBA(hex: 0xFFFFFF, alpha: 0.62),
            edge: RGBA(hex: 0xFFFFFF, alpha: 0.9),
            highlight: RGBA(hex: 0xFFFFFF, alpha: 0.85),
            shadow: RGBA(red: 20.0 / 255, green: 40.0 / 255, blue: 80.0 / 255, alpha: 0.14),
            content: Palette.ink
        )

        public static let dark = Glass(
            fill: RGBA(red: 40.0 / 255, green: 28.0 / 255, blue: 84.0 / 255, alpha: 0.46),
            edge: RGBA(hex: 0xFFFFFF, alpha: 0.16),
            highlight: RGBA(hex: 0xFFFFFF, alpha: 0.2),
            shadow: RGBA(hex: 0x000000, alpha: 0.35),
            content: RGBA(hex: 0xFFFFFF)
        )

        public static func style(_ chrome: ChromeStyle) -> Glass {
            chrome == .dark ? dark : light
        }

        /// Tab bar glass fill.
        public static let tabBarFill = RGBA(hex: 0xFFFFFF, alpha: 0.72)
    }

    public enum Surfaces {
        /// Card fill: white 78% (86% in the parent view).
        public static let card = RGBA(hex: 0xFFFFFF, alpha: 0.78)
        public static let cardParentView = RGBA(hex: 0xFFFFFF, alpha: 0.86)
        /// Card shadow tint `rgba(60,40,140,…)`.
        public static let cardShadow = RGBA(red: 60.0 / 255, green: 40.0 / 255, blue: 140.0 / 255, alpha: 0.10)
        /// Cover shadow tint `rgba(40,24,110,…)`.
        public static let coverShadow = RGBA(red: 40.0 / 255, green: 24.0 / 255, blue: 110.0 / 255, alpha: 0.22)
        /// Segmented filter track: ink 7%.
        public static let segmentTrack = Palette.ink.opacity(0.07)
        /// Selected tab fill.
        public static let tabSelected = RGBA(red: 110.0 / 255, green: 86.0 / 255, blue: 255.0 / 255, alpha: 0.13)
    }
}

// MARK: - Radii (DESIGN.md §3.4)

extension Tokens {
    public enum Radius {
        public static let roundGlassButton: Double = 20
        public static let capsuleControl: Double = 20
        public static let chip: Double = 14
        public static let pageTurn: Double = 30
        public static let primaryButton: Double = 26
        public static let card: Double = 26
        public static let keepReadingCover: Double = 28
        public static let storyCover: Double = 20
        public static let shelfCover: Double = 12
        public static let subscriptionCover: Double = 16
        public static let settingsCard: Double = 20
        public static let tabBar: Double = 31
        public static let tabItem: Double = 26
        public static let segmentedFilter: Double = 19
        public static let segment: Double = 16
        public static let endOfSampleCard: Double = 30
        public static let gateSheet: Double = 36
        public static let characterSheet: Double = 34
        public static let cultureNote: Double = 22
        /// In em of the word's font size.
        public static let tapHighlightEm: Double = 0.34
        public static let gateDigitBox: Double = 16
        public static let keypadKey: Double = 12
    }
}

// MARK: - Spacing and sizes (DESIGN.md §3.5, §5; positions on the 432 × 720 reference pane)

extension Tokens {
    public enum Spacing {
        public static let insetText: Double = 30
        public static let insetControl: Double = 20
        public static let insetControlFolded: Double = 18
        public static let insetFoot: Double = 28
        public static let topControl: Double = 50
        public static let topControlFolded: Double = 56
        public static let crumbLeft: Double = 70
        public static let crumbTop: Double = 53
        public static let crumbRight: Double = 22
        public static let footBottom: Double = 26
        public static let footHeight: Double = 34
        public static let pageTurnInset: Double = 24
        public static let pageTurnInsetFolded: Double = 22
        public static let cardWidth: Double = 372
        public static let chipGap: Double = 10
        public static let cardGap: Double = 14
        /// Nothing interactive and no text within this distance of the hinge.
        public static let hingeClearance: Double = 20
        /// General scale for new layouts (estimate).
        public static let scale: [Double] = [4, 8, 12, 16, 20, 24, 30]
    }

    public enum Size {
        public static let roundGlassButton: Double = 40
        public static let capsuleControlHeight: Double = 40
        public static let chipHeight: Double = 28
        public static let pillHeightSmall: Double = 22
        public static let pillHeightKeepReading: Double = 24
        public static let pageTurn: Double = 60
        public static let pageTurnFolded: Double = 54
        public static let primaryButtonHeight: Double = 52
        public static let minimumHitTarget: Double = 44
        public static let storyCoverWidth: Double = 116
        public static let storyCoverHeight: Double = 134
        public static let keepReadingHeight: Double = 186
        public static let segmentedFilterHeight: Double = 38
        public static let tabBarHeight: Double = 62
        public static let tabItemWidth: Double = 92
        public static let mapCardHeight: Double = 214
    }
}
