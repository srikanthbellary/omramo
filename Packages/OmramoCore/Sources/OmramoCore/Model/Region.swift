import Foundation

/// The ten shelf regions (docs/CONTENT_PLAN.md §1.1). A region is a shelf label, not a
/// culture: every story also names a specific people and place in `Region`.
public enum RegionID: String, Codable, CaseIterable, Hashable, Sendable {
    case indian
    case egyptian
    case japanese
    case chinese
    case nativeAmericanFirstNations
    case arctic
    case russian
    case european
    case african
    case persianArabian
}

/// A point on the globe. Latitude -90...90, longitude -180...180; negative = south or west.
public struct GeoPoint: Codable, Hashable, Sendable {
    public var lat: Double
    public var lon: Double

    public init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
    }

    public var isInRange: Bool {
        (-90.0...90.0).contains(lat) && (-180.0...180.0).contains(lon)
    }
}

/// Rules for the story map now that it carries a pin for every story (round 5).
public enum StoryMapRules {
    /// Up to this many pins, every pin carries its label; above it only the story being read
    /// does, or the labels would cover the map and each other.
    public static let labelledPinLimit = 6

    public static func showsLabel(isReadingNow: Bool, pinCount: Int) -> Bool {
        isReadingNow || pinCount <= labelledPinLimit
    }

    /// True when no pin lies within `degrees` of `point` in both latitude and longitude: a
    /// "more cultures later" ring is only drawn where no story has arrived yet.
    public static func isClear(_ point: GeoPoint, of pins: [GeoPoint], within degrees: Double = 10) -> Bool {
        !pins.contains { abs($0.lat - point.lat) <= degrees && abs($0.lon - point.lon) <= degrees }
    }
}

/// Where a story is from.
public struct Region: Codable, Hashable, Sendable {
    public var id: RegionID
    /// The specific people or tradition, e.g. "Akan (Asante/Fante)". Never a continent.
    public var culture: String
    /// e.g. "Ghana, West Africa".
    public var place: String
    /// The origin chip text, e.g. "Akan · Ghana".
    public var label: String
    /// Optional pin for the story map.
    public var pin: GeoPoint?
    public var pinColor: String
}

/// When a story's world is set. Used only to check landmark anachronisms.
public struct Setting: Codable, Hashable, Sendable {
    public var period: String
    /// The latest year the story's world could be; negative = BCE. Omitted for present-day stories.
    public var latestYear: Int?
}
