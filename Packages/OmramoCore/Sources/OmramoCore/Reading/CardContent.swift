import Foundation

/// What a tap-to-see card shows (docs/DESIGN.md §5.9): one picture, a title, one line to read,
/// one note, and nothing that leads anywhere else. An ordinary target fills it from the story;
/// a landmark target fills it from the shared landmark catalog in the story's tier wording
/// (docs/ARCHITECTURE.md §6.5) — the same card, no new layout.
public struct TapCardContent: Equatable, Sendable {
    /// Where the picture's file lives.
    public enum PictureSource: Equatable, Sendable {
        case story(StoryID)
        case landmark
    }

    public var targetID: TapTargetID
    public var title: String
    public var subtitle: String?
    /// The one line to read.
    public var line: String
    public var noteLabel: String?
    public var noteText: String?
    public var picture: ArtRef
    public var pictureSource: PictureSource
    /// The card's own background colour (`#RRGGBB`).
    public var background: String
    public var isLandmark: Bool
    /// True when the landmark is outside the story's time or place and the note is the framing
    /// device that says so.
    public var isFramed: Bool

    /// Nil when the target cannot make a card: a landmark target whose landmark is missing, or
    /// an ordinary target without its title, line or picture (the validator refuses both).
    public init?(target: TapTarget, story: Story, landmarks: LandmarkCatalog) {
        targetID = target.id
        if target.kind == .landmark {
            guard let ref = target.landmark,
                  let landmark = landmarks.landmark(id: ref.id),
                  let card = LandmarkCardContent(target: target, landmark: landmark, tier: story.tier) else {
                return nil
            }
            title = card.title
            subtitle = card.subtitle
            line = card.line
            noteLabel = card.noteLabel
            noteText = card.noteText
            picture = card.picture
            pictureSource = .landmark
            background = card.background
            isLandmark = true
            isFramed = ref.appearance == .framed && ref.framingDevice != nil
        } else {
            guard let title = target.title, let line = target.line, let picture = target.picture else {
                return nil
            }
            self.title = title
            subtitle = target.subtitle
            self.line = line
            noteLabel = target.cultureNote?.label
            noteText = target.cultureNote?.text
            self.picture = picture
            pictureSource = .story(story.id)
            background = target.background
            isLandmark = false
            isFramed = false
        }
    }

    /// Custom-action name for VoiceOver ("Show picture: Rin Gin").
    public var actionName: String {
        "Show picture: \(title)"
    }
}

/// What a character card shows (docs/DESIGN.md §5.10).
public struct CharacterCardContent: Equatable, Sendable {
    public var characterID: CharacterID
    public var label: String
    public var title: String
    /// At most three are shown.
    public var traits: [StoryCharacter.Trait]
    public var body: String
    public var portrait: ArtRef
    /// Top-to-bottom gradient behind the portrait.
    public var background: [String]

    public static let maximumTraits = 3

    /// Nil when the character has no card (a name with no card is not tappable).
    public init?(character: StoryCharacter) {
        guard let card = character.card else { return nil }
        characterID = character.id
        label = card.label
        title = card.title
        traits = Array(card.traits.prefix(CharacterCardContent.maximumTraits))
        body = card.body
        portrait = card.portrait
        background = card.background
    }

    /// Custom-action name for VoiceOver ("About: The Monkey").
    public var actionName: String {
        "About: \(title)"
    }
}

/// The content of any card a marked word can open.
public enum StoryCardContent: Equatable, Sendable {
    case tap(TapCardContent)
    case character(CharacterCardContent)

    public var title: String {
        switch self {
        case .tap(let content): return content.title
        case .character(let content): return content.title
        }
    }

    public var actionName: String {
        switch self {
        case .tap(let content): return content.actionName
        case .character(let content): return content.actionName
        }
    }
}

extension Story {
    /// The card a marked word opens, or nil when it opens none.
    public func cardContent(for ref: StoryCardRef, landmarks: LandmarkCatalog) -> StoryCardContent? {
        switch ref {
        case .tapTarget(let id):
            guard let target = tapTarget(id: id),
                  let content = TapCardContent(target: target, story: self, landmarks: landmarks) else { return nil }
            return .tap(content)
        case .character(let id):
            guard let character = character(id: id),
                  let content = CharacterCardContent(character: character) else { return nil }
            return .character(content)
        }
    }

    /// Finds an authored paragraph by id (a sentence-group id finds its paragraph).
    public func block(id: BlockID) -> TextBlock? {
        let parent = id.fragmentParent
        for spread in spreads {
            if let block = spread.blocks.first(where: { $0.id == parent }) {
                return block
            }
        }
        return nil
    }
}
