import Foundation

/// `catalog.json`: the ordered list of story ids.
public struct Catalog: Codable, Hashable, Sendable {
    public var schemaVersion: Int
    public var catalogVersion: Int
    public var stories: [StoryID]
}

/// The library's level filter ("Stories by level").
public enum LibraryFilter: Hashable, Sendable, CaseIterable {
    case all
    case low
    case medium
    case advanced

    public var tier: Tier? {
        switch self {
        case .all: return nil
        case .low: return .low
        case .medium: return .medium
        case .advanced: return .advanced
        }
    }

    public var displayName: String {
        tier?.displayName ?? "All"
    }

    public func includes(_ tier: Tier) -> Bool {
        self.tier == nil || self.tier == tier
    }
}

/// The header fields the library needs for one story card.
public struct LibraryEntry: Hashable, Sendable, Identifiable {
    public var id: StoryID
    public var title: String
    public var tier: Tier
    public var regionID: RegionID
    /// The origin text under the cover, e.g. "Ancient India".
    public var originLabel: String
    public var pin: GeoPoint?
    public var pinColor: String
    public var cover: ArtRef
    public var spreadCount: Int

    public init(story: Story) {
        id = story.id
        title = story.title
        tier = story.tier
        regionID = story.region.id
        originLabel = story.region.label
        pin = story.region.pin
        pinColor = story.region.pinColor
        cover = story.cover
        spreadCount = story.spreads.count
    }
}

/// One row of the library: the stories of one level, in catalog order (round 5: the catalog
/// grew from three stories to the plan's thirty-two, so the library groups them by level).
public struct LibraryShelf: Hashable, Sendable, Identifiable {
    public var tier: Tier
    public var stories: [Story]

    public init(tier: Tier, stories: [Story]) {
        self.tier = tier
        self.stories = stories
    }

    public var id: Tier { tier }

    /// "1 story", "11 stories".
    public var countText: String {
        stories.count == 1 ? "1 story" : "\(stories.count) stories"
    }
}

/// Everything the app shows: the stories in catalog order and the shared landmarks.
public struct Library: Hashable, Sendable {
    public var catalogVersion: Int
    public var stories: [Story]
    public var landmarks: LandmarkCatalog

    public init(catalogVersion: Int, stories: [Story], landmarks: LandmarkCatalog) {
        self.catalogVersion = catalogVersion
        self.stories = stories
        self.landmarks = landmarks
    }

    public var entries: [LibraryEntry] {
        stories.map { LibraryEntry(story: $0) }
    }

    public func entries(matching filter: LibraryFilter) -> [LibraryEntry] {
        entries.filter { filter.includes($0.tier) }
    }

    public func story(id: StoryID) -> Story? {
        stories.first { $0.id == id }
    }

    /// The stories grouped by level, lowest level first, each shelf in catalog order (the
    /// catalog lists a level's stories region by region). A level with no story has no shelf.
    public func shelves(matching filter: LibraryFilter = .all) -> [LibraryShelf] {
        Tier.allCases.compactMap { tier in
            guard filter.includes(tier) else { return nil }
            let found = stories.filter { $0.tier == tier }
            return found.isEmpty ? nil : LibraryShelf(tier: tier, stories: found)
        }
    }

    /// The stories flagged "needs cultural review before release", in catalog order.
    public var storiesNeedingCulturalReview: [Story] {
        stories.filter { $0.culturalReview.needsReviewBeforeRelease }
    }

    /// The landmark a tap target points to, if it is a landmark target that resolves.
    public func landmark(for target: TapTarget) -> Landmark? {
        guard let ref = target.landmark else { return nil }
        return landmarks.landmark(id: ref.id)
    }
}
