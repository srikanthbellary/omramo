import Foundation

/// One story, exactly as stored in `story.json` (docs/ARCHITECTURE.md §6.3, schema version 1).
public struct Story: Codable, Hashable, Sendable, Identifiable {
    public var schemaVersion: Int
    public var id: StoryID
    public var contentVersion: Int
    public var title: String
    public var subtitle: String?
    public var tier: Tier
    public var language: String
    public var region: Region
    public var setting: Setting
    public var provenance: Provenance
    public var review: Review
    public var culturalReview: CulturalReview
    public var education: Education
    public var sample: Sample
    public var theme: StoryTheme
    public var cover: ArtRef
    public var parts: [Part]
    public var characters: [StoryCharacter]
    public var tapTargets: [TapTarget]
    public var spreads: [Spread]

    public func part(id: PartID) -> Part? {
        parts.first { $0.id == id }
    }

    public func character(id: CharacterID) -> StoryCharacter? {
        characters.first { $0.id == id }
    }

    public func tapTarget(id: TapTargetID) -> TapTarget? {
        tapTargets.first { $0.id == id }
    }

    /// Every landmark id this story points to, in tap-target order.
    public var landmarkIDs: [LandmarkID] {
        tapTargets.compactMap { $0.landmark?.id }
    }
}

public struct Sample: Codable, Hashable, Sendable {
    /// How many spreads can be read without a subscription.
    public var freeSpreads: Int
}

public struct Part: Codable, Hashable, Sendable, Identifiable {
    public var id: PartID
    /// e.g. "Part I".
    public var title: String
}

/// A picture by reference. `file` is relative to the story folder (or the landmarks folder).
public struct ArtRef: Codable, Hashable, Sendable {
    public var file: String
    /// Alt text. Required, never empty.
    public var alt: String
    /// Pixel size of the master image.
    public var width: Int
    public var height: Int

    /// The file name without folder or extension(s): "art/scene-river.unfolded.heic" → "scene-river".
    /// Placeholder art is keyed by this name.
    public var assetName: String {
        let lastComponent = file.split(separator: "/").last.map { String($0) } ?? file
        return lastComponent.split(separator: ".").first.map { String($0) } ?? lastComponent
    }
}

/// Light or dark glass controls.
public enum ChromeStyle: String, Codable, Hashable, Sendable {
    case light
    case dark
}

public struct ChromeTheme: Codable, Hashable, Sendable {
    public var leading: ChromeStyle
    public var trailing: ChromeStyle
    public var folded: ChromeStyle
}

/// A story's own light: text colour, chrome variant, page-turn colour, tap-word colours.
public struct StoryTheme: Codable, Hashable, Sendable {
    public enum Accent: String, Codable, Hashable, Sendable {
        case coral
        case amber
        case red
    }

    public struct TapColors: Codable, Hashable, Sendable {
        public var fill: String
        public var fill2: String
        public var line: String
        public var spark: String
    }

    public var textColor: String
    public var chrome: ChromeTheme
    public var accent: Accent
    public var tap: TapColors
    public var chipGlass: String
}

/// A story character. (Named StoryCharacter so it never shadows Swift.Character.)
public struct StoryCharacter: Codable, Hashable, Sendable, Identifiable {
    public struct Trait: Codable, Hashable, Sendable {
        public var text: String
        public var fill: String
        public var ink: String
    }

    public struct Card: Codable, Hashable, Sendable {
        public var label: String
        public var title: String
        public var traits: [Trait]
        public var body: String
        public var portrait: ArtRef
        public var background: [String]
    }

    public var id: CharacterID
    public var name: String
    /// Voice and underline colour.
    public var color: String
    public var face: ArtRef
    public var chipBackground: String?
    public var card: Card?
}

public struct TapTarget: Codable, Hashable, Sendable, Identifiable {
    public enum Kind: String, Codable, Hashable, Sendable {
        case place
        case object
        case creature
        case idea
        case landmark
    }

    public struct CultureNote: Codable, Hashable, Sendable {
        public var label: String
        public var text: String
    }

    public var id: TapTargetID
    public var kind: Kind
    /// Omitted for `kind: landmark` (the landmark catalog supplies it).
    public var title: String?
    public var subtitle: String?
    /// The one line to read. Omitted for `kind: landmark`.
    public var line: String?
    /// Omitted for `kind: landmark`.
    public var cultureNote: CultureNote?
    /// Omitted for `kind: landmark`.
    public var picture: ArtRef?
    public var background: String
    /// Required for `kind: landmark`.
    public var landmark: LandmarkRef?
}

/// A story's pointer to a landmark in the shared catalog.
public struct LandmarkRef: Codable, Hashable, Sendable {
    public enum Appearance: String, Codable, Hashable, Sendable {
        /// The landmark belongs to the story's own place and time.
        case natural
        /// The landmark is outside the story's time or place and needs a framing device.
        case framed
    }

    public var id: LandmarkID
    public var appearance: Appearance
    /// Required when `appearance` is `framed`.
    public var framingDevice: FramingDevice?
}

/// How a story honestly shows a landmark that is not part of its world (docs/CONTENT_PLAN.md §5).
public struct FramingDevice: Codable, Hashable, Sendable {
    public enum Kind: String, Codable, Hashable, Sendable {
        case thenAndNow
        case mapMoment
        case worldLink
        case presentDayNarrator
    }

    public var kind: Kind
    /// The note label on the card, e.g. "LONG AFTER THIS STORY".
    public var label: String
    /// One bridging sentence shown before the landmark's fact, written for this story.
    public var line: String
}

/// One page: an authored spread that owns one scene. The same folded and unfolded.
public struct Spread: Codable, Hashable, Sendable, Identifiable {
    public struct Scene: Codable, Hashable, Sendable {
        /// Where the calm part of the scene ends on each pane: the y position, on the 720-point
        /// reference pane, below which the picture needs the space and story text must not go.
        /// Omitted values mean "down to the footer chrome".
        public struct TextArea: Codable, Hashable, Sendable {
            public static let range: ClosedRange<Double> = 200...720

            public var leadingBottom: Double?
            public var trailingBottom: Double?

            public init(leadingBottom: Double? = nil, trailingBottom: Double? = nil) {
                self.leadingBottom = leadingBottom
                self.trailingBottom = trailingBottom
            }
        }

        public var unfolded: ArtRef
        public var folded: ArtRef
        public var fallbackColors: [String]
        public var textArea: TextArea?
    }

    public var id: SpreadID
    public var part: PartID
    public var scene: Scene
    /// Overrides the theme's chrome for this spread.
    public var chrome: ChromeTheme?
    public var blocks: [TextBlock]

    /// Number of words on the spread (whitespace-separated).
    public var wordCount: Int {
        blocks.reduce(0) { $0 + $1.wordCount }
    }
}

public struct TextBlock: Codable, Hashable, Sendable, Identifiable {
    public enum Pane: String, Codable, Hashable, Sendable {
        case leading
        case trailing
    }

    public enum Kind: String, Codable, Hashable, Sendable {
        case paragraph
        case pathText
    }

    public var id: BlockID
    /// Ignored when folded, where blocks flow in order.
    public var pane: Pane
    public var kind: Kind
    public var runs: [TextRun]
    /// For `pathText`: an SVG-style curve in a 400 × 96 box.
    public var path: String?

    public init(id: BlockID, pane: Pane, kind: Kind = .paragraph, runs: [TextRun], path: String? = nil) {
        self.id = id
        self.pane = pane
        self.kind = kind
        self.runs = runs
        self.path = path
    }

    /// The paragraph exactly as written: the run texts joined.
    public var plainText: String {
        runs.map(\.text).joined()
    }

    public var wordCount: Int {
        plainText.split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "\t" }).count
    }
}

/// A piece of a paragraph with one style. In JSON the keys are short: `t`, `lead`, `say`,
/// `chip`, `name`, `tap`, `fx`, `scale`.
public struct TextRun: Codable, Hashable, Sendable {
    public enum Effect: String, Codable, Hashable, Sendable {
        /// A sound or motion word in the display face.
        case pop
        /// A stretched, letter-spaced italic word.
        case stretch
    }

    public var text: String
    /// Display-face lead sentence.
    public var isLead: Bool
    /// The character speaking: voice colour and weight.
    public var speaker: CharacterID?
    /// Draw the speaker's face chip before this run.
    public var showsFaceChip: Bool
    /// A character's name: dotted underline; opens the character card (M3).
    public var characterName: CharacterID?
    /// A tap-to-see word; opens its card (M3).
    public var tapTarget: TapTargetID?
    public var effect: Effect?
    /// Size multiplier for `pop`.
    public var scale: Double?

    public init(
        text: String,
        isLead: Bool = false,
        speaker: CharacterID? = nil,
        showsFaceChip: Bool = false,
        characterName: CharacterID? = nil,
        tapTarget: TapTargetID? = nil,
        effect: Effect? = nil,
        scale: Double? = nil
    ) {
        self.text = text
        self.isLead = isLead
        self.speaker = speaker
        self.showsFaceChip = showsFaceChip
        self.characterName = characterName
        self.tapTarget = tapTarget
        self.effect = effect
        self.scale = scale
    }

    private enum CodingKeys: String, CodingKey {
        case text = "t"
        case isLead = "lead"
        case speaker = "say"
        case showsFaceChip = "chip"
        case characterName = "name"
        case tapTarget = "tap"
        case effect = "fx"
        case scale
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        isLead = try container.decodeIfPresent(Bool.self, forKey: .isLead) ?? false
        speaker = try container.decodeIfPresent(CharacterID.self, forKey: .speaker)
        showsFaceChip = try container.decodeIfPresent(Bool.self, forKey: .showsFaceChip) ?? false
        characterName = try container.decodeIfPresent(CharacterID.self, forKey: .characterName)
        tapTarget = try container.decodeIfPresent(TapTargetID.self, forKey: .tapTarget)
        effect = try container.decodeIfPresent(Effect.self, forKey: .effect)
        scale = try container.decodeIfPresent(Double.self, forKey: .scale)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        if isLead { try container.encode(true, forKey: .isLead) }
        try container.encodeIfPresent(speaker, forKey: .speaker)
        if showsFaceChip { try container.encode(true, forKey: .showsFaceChip) }
        try container.encodeIfPresent(characterName, forKey: .characterName)
        try container.encodeIfPresent(tapTarget, forKey: .tapTarget)
        try container.encodeIfPresent(effect, forKey: .effect)
        try container.encodeIfPresent(scale, forKey: .scale)
    }
}
