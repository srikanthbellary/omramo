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

    /// The landmark a tap target points to, if it is a landmark target that resolves.
    public func landmark(for target: TapTarget) -> Landmark? {
        guard let ref = target.landmark else { return nil }
        return landmarks.landmark(id: ref.id)
    }
}
