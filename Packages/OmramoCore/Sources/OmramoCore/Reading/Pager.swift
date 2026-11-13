import Foundation

/// Where the reader is, by content id, so a corrected story or a posture change keeps the place.
public struct ReadingPosition: Codable, Hashable, Sendable {
    public var storyID: StoryID
    public var spreadID: SpreadID
    /// The paragraph that was first on screen. Used from M2 (continuation screens).
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

/// Page arithmetic over a story's spreads. A page is an authored spread.
/// M1: next and previous spread only. Continuation screens for overflow arrive in M2.
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
    public init(page: Int, pageCount: Int) {
        let count = max(1, min(pageCount, PageDashes.maximumDashes))
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
