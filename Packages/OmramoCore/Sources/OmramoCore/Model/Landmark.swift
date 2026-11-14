import Foundation

/// One landmark in the shared catalog (docs/ARCHITECTURE.md §6.5). Stories point to it by id
/// from a tap-to-see target; its facts are written once, in a wording for each tier.
public struct Landmark: Codable, Hashable, Sendable, Identifiable {
    /// Era boundaries are an assumption (docs/CONTENT_PLAN.md §5): ancient before 500 CE;
    /// medieval 500–1500; early-modern 1500–1800; modern 1800–1945; contemporary after 1945.
    public enum Era: String, Codable, CaseIterable, Hashable, Sendable {
        case ancient
        case medieval
        case earlyModern
        case modern
        case contemporary
        case natural
    }

    public enum Status: String, Codable, Hashable, Sendable {
        case standing
        case ruins
        case lost
        case unproven
        case natural
    }

    public enum Depiction: String, Codable, Hashable, Sendable {
        case asIs
        /// An artist's idea of a wonder that is gone (or may never have stood).
        case reconstruction
    }

    public enum List: String, Codable, Hashable, Sendable {
        case ancientSeven
        case new7Wonders
        case other
    }

    /// When it was built. Years are integers; negative = BCE.
    public struct Built: Codable, Hashable, Sendable {
        public var from: Int
        public var to: Int?
        public var circa: Bool
        public var note: String?
    }

    /// The fact card in one tier's wording.
    public struct FactCard: Codable, Hashable, Sendable {
        /// The one line to read.
        public var line: String
        public var note: String?
    }

    /// All three wordings are required.
    public struct TierFactCards: Codable, Hashable, Sendable {
        public var low: FactCard
        public var medium: FactCard
        public var advanced: FactCard

        public subscript(tier: Tier) -> FactCard {
            switch tier {
            case .low: return low
            case .medium: return medium
            case .advanced: return advanced
            }
        }
    }

    public struct ReviewState: Codable, Hashable, Sendable {
        public var facts: ReviewStatus
        public var art: ReviewStatus
    }

    public var id: LandmarkID
    public var name: String
    public var localName: String?
    public var era: Era
    /// Omitted for `natural` landmarks.
    public var built: Built?
    public var status: Status
    public var depiction: Depiction
    public var country: String
    public var place: String?
    public var coordinates: GeoPoint
    /// One of the ten region ids; omitted when the landmark is outside them.
    public var region: RegionID?
    /// List membership; at least one.
    public var lists: [List]
    public var factCards: TierFactCards
    /// The tap-to-see picture (1296 × 1212).
    public var art: ArtRef
    public var background: String
    /// Free text: image or name concerns.
    public var rights: String?
    public var review: ReviewState
}

/// `landmarks/landmarks.json`.
public struct LandmarkCatalog: Codable, Hashable, Sendable {
    public var schemaVersion: Int
    public var landmarks: [Landmark]

    public init(schemaVersion: Int = ContentDecoder.supportedSchemaVersion, landmarks: [Landmark] = []) {
        self.schemaVersion = schemaVersion
        self.landmarks = landmarks
    }

    public func landmark(id: LandmarkID) -> Landmark? {
        landmarks.first { $0.id == id }
    }
}

/// What a landmark's tap-to-see card shows for one story (docs/ARCHITECTURE.md §6.5).
/// The card itself is drawn in M3; this is the data it will be filled from.
public struct LandmarkCardContent: Equatable, Sendable {
    public static let defaultNoteLabel = "WHERE IN THE WORLD"
    public static let reconstructionSubtitle = "An artist's idea — this wonder is gone"

    public var title: String
    public var subtitle: String
    /// The one line to read, in the story's tier wording.
    public var line: String
    public var noteLabel: String
    public var noteText: String?
    public var picture: ArtRef
    public var background: String

    /// Returns nil when the target is not a landmark target.
    public init?(target: TapTarget, landmark: Landmark, tier: Tier) {
        guard target.kind == .landmark, let ref = target.landmark, ref.id == landmark.id else {
            return nil
        }
        let fact = landmark.factCards[tier]
        title = landmark.name
        if landmark.depiction == .reconstruction {
            subtitle = LandmarkCardContent.reconstructionSubtitle
        } else if let place = landmark.place, !place.isEmpty {
            subtitle = place
        } else {
            subtitle = landmark.country
        }
        line = fact.line
        if ref.appearance == .framed, let device = ref.framingDevice {
            noteLabel = device.label
            if let note = fact.note, !note.isEmpty {
                noteText = device.line + " " + note
            } else {
                noteText = device.line
            }
        } else {
            noteLabel = LandmarkCardContent.defaultNoteLabel
            noteText = fact.note
        }
        picture = landmark.art
        // The tap target may override the landmark's background.
        background = target.background.isEmpty ? landmark.background : target.background
    }
}
