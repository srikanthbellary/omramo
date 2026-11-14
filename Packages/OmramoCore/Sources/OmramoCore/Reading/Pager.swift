import Foundation

/// Where the reader is, by content id, so a corrected story or a posture change keeps the place.
public struct ReadingPosition: Codable, Hashable, Sendable {
    public var storyID: StoryID
    public var spreadID: SpreadID
    /// The paragraph that was first on screen, so the same screen of the page is shown again
    /// after a relaunch or a change of layout.
    public var blockID: BlockID?

    public init(storyID: StoryID, spreadID: SpreadID, blockID: BlockID? = nil) {
        self.storyID = storyID
        self.spreadID = spreadID
        self.blockID = blockID
    }
}

/// The saved reading positions of every story, as stored on the device.
public struct ReadingProgressFile: Codable, Hashable, Sendable {
    public static let currentSchemaVersion = 1

    public var schemaVersion: Int
    /// Keyed by story id.
    public var positions: [String: ReadingPosition]
    /// The story read most recently; the library's "Keep reading" card shows it.
    public var lastStoryID: StoryID?

    public init(
        schemaVersion: Int = ReadingProgressFile.currentSchemaVersion,
        positions: [String: ReadingPosition] = [:],
        lastStoryID: StoryID? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.positions = positions
        self.lastStoryID = lastStoryID
    }

    public func position(for storyID: StoryID) -> ReadingPosition? {
        positions[storyID.rawValue]
    }

    public mutating func record(_ position: ReadingPosition) {
        positions[position.storyID.rawValue] = position
        lastStoryID = position.storyID
    }

    public mutating func clear(storyID: StoryID) {
        positions[storyID.rawValue] = nil
        if lastStoryID == storyID {
            lastStoryID = nil
        }
    }
}

/// Page arithmetic over a story's spreads. A page is an authored spread: the page indicator and
/// "pages read" count spreads. A page whose text does not fit continues on further screens of
/// the same page (see `ScreenPlanner`); `forward` and `backward` step through those.
public struct Pager: Equatable, Sendable {
    public let spreadIDs: [SpreadID]

    public init(spreadIDs: [SpreadID]) {
        self.spreadIDs = spreadIDs
    }

    public init(story: Story) {
        self.init(spreadIDs: story.spreads.map(\.id))
    }

    public var pageCount: Int { spreadIDs.count }

    public func index(of id: SpreadID) -> Int? {
        spreadIDs.firstIndex(of: id)
    }

    /// 1-based page number for the page indicator.
    public func pageNumber(of id: SpreadID) -> Int? {
        index(of: id).map { $0 + 1 }
    }

    public var first: SpreadID? { spreadIDs.first }

    public func next(after id: SpreadID) -> SpreadID? {
        guard let index = index(of: id), index + 1 < spreadIDs.count else { return nil }
        return spreadIDs[index + 1]
    }

    public func previous(before id: SpreadID) -> SpreadID? {
        guard let index = index(of: id), index > 0 else { return nil }
        return spreadIDs[index - 1]
    }

    public func isLast(_ id: SpreadID) -> Bool {
        spreadIDs.last == id
    }

    /// Where to open a story: the saved spread if it still exists, else the first page.
    public func resume(from position: ReadingPosition?) -> SpreadID? {
        if let saved = position?.spreadID, index(of: saved) != nil {
            return saved
        }
        return first
    }
}

/// The dashes in the page chip (docs/DESIGN.md §5.5). Rule (estimate): show at most nine
/// dashes and map the current page onto them proportionally.
public struct PageDashes: Equatable, Sendable {
    public static let maximumDashes = 9

    public enum State: Equatable, Sendable {
        case done
        case current
        case upcoming
    }

    public let states: [State]

    /// - Parameters:
    ///   - page: 1-based current page.
    ///   - pageCount: number of pages in the story.
    ///   - maximumDashes: fewer where the footer is narrow (the folded pane draws seven).
    public init(page: Int, pageCount: Int, maximumDashes: Int = PageDashes.maximumDashes) {
        let count = max(1, min(pageCount, max(1, maximumDashes)))
        let total = max(1, pageCount)
        let clampedPage = min(max(1, page), total)
        let currentDash: Int
        if total <= count {
            currentDash = clampedPage - 1
        } else if clampedPage == total {
            currentDash = count - 1
        } else {
            currentDash = min(count - 1, (clampedPage - 1) * count / total)
        }
        states = (0..<count).map { index -> State in
            if index < currentDash { return .done }
            if index == currentDash { return .current }
            return .upcoming
        }
    }
}

// MARK: - Continuation screens (docs/ARCHITECTURE.md §8.3)

/// Which screen of a page to show. A page (spread) whose text does not fit its pane continues
/// on further screens with the same page number; how many there are depends on the pane size
/// and the text size, so a place inside a page is remembered by content, never by index.
public enum ScreenAnchor: Hashable, Sendable {
    /// The first screen of the page.
    case start
    /// The screen that shows this paragraph.
    case block(BlockID)
    /// The last screen of the page (used when going back into a page).
    case end
}

extension Pager {
    /// One press of the page-turn button or of the back-one-page control.
    public enum Move: Equatable, Sendable {
        /// Stay on the page; show another of its screens (0-based).
        case screen(Int)
        /// Go to another page, at its first or last screen.
        case spread(SpreadID, ScreenAnchor)
    }

    /// The round button: through the page's continuation screens first, then to the next page.
    /// Nil at the very end of the story.
    public func forward(from id: SpreadID, screen: Int, screenCount: Int) -> Move? {
        if screen + 1 < max(1, screenCount) {
            return .screen(screen + 1)
        }
        return next(after: id).map { Move.spread($0, .start) }
    }

    /// The back control: back through the page's screens, then to the last screen of the page
    /// before. Nil at the very start of the story.
    public func backward(from id: SpreadID, screen: Int, screenCount: Int) -> Move? {
        if screen > 0 {
            return .screen(min(screen, max(1, screenCount)) - 1)
        }
        return previous(before: id).map { Move.spread($0, .end) }
    }

    /// True on the last screen of the last page.
    public func isAtEnd(_ id: SpreadID, screen: Int, screenCount: Int) -> Bool {
        isLast(id) && screen + 1 >= max(1, screenCount)
    }

    /// True on the first screen of the first page.
    public func isAtStart(_ id: SpreadID, screen: Int) -> Bool {
        first == id && screen <= 0
    }
}

extension ReadingPosition {
    /// Where inside the saved page to reopen: at the paragraph that was first on screen.
    public var anchor: ScreenAnchor {
        blockID.map { ScreenAnchor.block($0) } ?? .start
    }
}
