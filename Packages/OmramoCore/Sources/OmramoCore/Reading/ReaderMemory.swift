import Foundation

/// The "Aa" text-size steps (docs/ARCHITECTURE.md §12.1). The tier's designed size is step
/// `standard`; every other step multiplies size, line height and paragraph gap by one factor,
/// so the proportions of docs/DESIGN.md §4.2 hold and the tiers keep their order.
/// The step values are an estimate until the panel is designed (design gap G1).
public enum TextSizeStep: Int, Codable, CaseIterable, Hashable, Sendable, Comparable {
    case small = 0
    case standard = 1
    case large = 2
    case larger = 3
    case largest = 4

    public var scale: Double {
        switch self {
        case .small: return 0.9
        case .standard: return 1.0
        case .large: return 1.15
        case .larger: return 1.3
        case .largest: return 1.5
        }
    }

    /// For VoiceOver and the panel.
    public var displayName: String {
        switch self {
        case .small: return "Small"
        case .standard: return "Standard"
        case .large: return "Large"
        case .larger: return "Larger"
        case .largest: return "Largest"
        }
    }

    public var smaller: TextSizeStep? { TextSizeStep(rawValue: rawValue - 1) }
    public var bigger: TextSizeStep? { TextSizeStep(rawValue: rawValue + 1) }

    public static func < (lhs: TextSizeStep, rhs: TextSizeStep) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// The step to start from, the first time, given the system text size.
    /// - Parameter systemSizeIndex: 0 = extra small … 3 = large (the system default) …
    ///   6 = extra extra extra large; 7 and above are the accessibility sizes.
    public static func initial(systemSizeIndex: Int) -> TextSizeStep {
        switch systemSizeIndex {
        case ..<4: return .standard
        case 4: return .large
        case 5, 6: return .larger
        default: return .largest
        }
    }
}

extension ReadingTypeScale {
    /// The same tier typography at a text-size step: sizes, line heights, tracking and the
    /// paragraph gap grow together; the column and its position do not.
    public func scaled(by factor: Double) -> ReadingTypeScale {
        guard factor != 1 else { return self }
        var copy = self
        copy.body = body.scaled(by: factor)
        copy.lead = lead.scaled(by: factor)
        copy.wordSpacing = wordSpacing * factor
        copy.paragraphGap = paragraphGap * factor
        return copy
    }

    public func scaled(to step: TextSizeStep) -> ReadingTypeScale {
        scaled(by: step.scale)
    }
}

/// Which card is open: a tap-to-see word (an ordinary target or a landmark) or a character.
public enum StoryCardRef: Hashable, Sendable {
    case tapTarget(TapTargetID)
    case character(CharacterID)
}

/// An open card and the paragraph it was opened from. Kept in the reader's model, not in a
/// view, so the card stays open — and finds its new place — when the layout changes.
public struct OpenCard: Hashable, Sendable {
    public var ref: StoryCardRef
    /// The authored paragraph holding the tapped word (never a sentence-group id).
    public var blockID: BlockID

    public init(ref: StoryCardRef, blockID: BlockID) {
        self.ref = ref
        self.blockID = blockID.fragmentParent
    }
}

/// What the reader remembers on the device besides the reading position: the text size, one
/// bookmark per story, which tap-to-see cards have been seen and which characters have been
/// met. No times, no durations, nothing that leaves the device.
public struct ReaderMemoryFile: Codable, Hashable, Sendable {
    public static let currentSchemaVersion = 1

    public var schemaVersion: Int
    /// Nil until the child (or the first launch, from the system text size) picks one.
    public var textSize: TextSizeStep?
    /// One bookmark per story, keyed by story id.
    public var bookmarks: [String: ReadingPosition]
    /// Tap-to-see targets whose card has been opened and closed, by story id.
    public var seenTapTargets: [String: [TapTargetID]]
    /// Characters whose card has been opened and closed, by story id.
    public var seenCharacterCards: [String: [CharacterID]]
    /// Characters whose first naming has been shown on screen, by story id ("friends met").
    public var friendsMet: [String: [CharacterID]]

    public init(
        schemaVersion: Int = ReaderMemoryFile.currentSchemaVersion,
        textSize: TextSizeStep? = nil,
        bookmarks: [String: ReadingPosition] = [:],
        seenTapTargets: [String: [TapTargetID]] = [:],
        seenCharacterCards: [String: [CharacterID]] = [:],
        friendsMet: [String: [CharacterID]] = [:]
    ) {
        self.schemaVersion = schemaVersion
        self.textSize = textSize
        self.bookmarks = bookmarks
        self.seenTapTargets = seenTapTargets
        self.seenCharacterCards = seenCharacterCards
        self.friendsMet = friendsMet
    }

    // Bookmark

    public func bookmark(for storyID: StoryID) -> ReadingPosition? {
        bookmarks[storyID.rawValue]
    }

    public mutating func setBookmark(_ position: ReadingPosition) {
        bookmarks[position.storyID.rawValue] = position
    }

    public mutating func removeBookmark(for storyID: StoryID) {
        bookmarks[storyID.rawValue] = nil
    }

    // Seen cards

    public func hasSeen(_ ref: StoryCardRef, in storyID: StoryID) -> Bool {
        switch ref {
        case .tapTarget(let id):
            return seenTapTargets[storyID.rawValue]?.contains(id) ?? false
        case .character(let id):
            return seenCharacterCards[storyID.rawValue]?.contains(id) ?? false
        }
    }

    /// Returns true when this is the first time the card is marked seen.
    @discardableResult
    public mutating func markSeen(_ ref: StoryCardRef, in storyID: StoryID) -> Bool {
        guard !hasSeen(ref, in: storyID) else { return false }
        switch ref {
        case .tapTarget(let id):
            seenTapTargets[storyID.rawValue, default: []].append(id)
        case .character(let id):
            seenCharacterCards[storyID.rawValue, default: []].append(id)
        }
        return true
    }

    // Friends met

    public func hasMet(_ character: CharacterID, in storyID: StoryID) -> Bool {
        friendsMet[storyID.rawValue]?.contains(character) ?? false
    }

    /// Characters met in a story, in the order they were met.
    public func friends(in storyID: StoryID) -> [CharacterID] {
        friendsMet[storyID.rawValue] ?? []
    }

    /// Records the characters named on a screen that has just been shown. Returns the ones met
    /// for the first time (empty when nothing changed, so the caller can skip saving).
    @discardableResult
    public mutating func recordMet(_ characters: [CharacterID], in storyID: StoryID) -> [CharacterID] {
        var new: [CharacterID] = []
        for character in characters where !hasMet(character, in: storyID) && !new.contains(character) {
            new.append(character)
        }
        if !new.isEmpty {
            friendsMet[storyID.rawValue, default: []].append(contentsOf: new)
        }
        return new
    }
}

extension TextBlock {
    /// The characters named in this paragraph, in order, each once.
    public var namedCharacters: [CharacterID] {
        var result: [CharacterID] = []
        for run in runs {
            if let name = run.characterName, !result.contains(name) {
                result.append(name)
            }
        }
        return result
    }

    /// The marked words of this paragraph that open a card, in reading order, each card once.
    public var cardRefs: [StoryCardRef] {
        var result: [StoryCardRef] = []
        for run in runs {
            let ref: StoryCardRef?
            if let tap = run.tapTarget {
                ref = .tapTarget(tap)
            } else if let name = run.characterName {
                ref = .character(name)
            } else {
                ref = nil
            }
            if let ref, !result.contains(ref) {
                result.append(ref)
            }
        }
        return result
    }
}
