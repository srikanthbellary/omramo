import Foundation

/// Where a story's text came from.
public struct Provenance: Codable, Hashable, Sendable {
    public enum Kind: String, Codable, Hashable, Sendable {
        /// Our retelling of a traditional tale, with a cited public-domain edition.
        case publicDomainRetelling
        /// A story written by us.
        case original
    }

    public enum TextBasis: String, Codable, Hashable, Sendable {
        /// The app text is the cited edition's wording, unaltered.
        case sourceVerbatim
        /// The app text is our own fresh retelling; the cited edition is the documented source.
        case omramoRetelling
    }

    public var kind: Kind

    // publicDomainRetelling
    public var tradition: String?
    public var sources: [SourceCitation]?
    public var textBasis: TextBasis?

    // original
    public var credit: String?
    public var premise: String?
    public var authors: [String]?

    /// Free text; per-territory notes. Required for both kinds.
    public var rights: String
}

/// One cited edition.
public struct SourceCitation: Codable, Hashable, Sendable {
    public var author: String
    public var title: String
    public var publisher: String?
    public var year: Int
    public var gutenbergId: Int?
    public var url: String?
    /// True when the ebook and the story's presence in it were confirmed.
    public var verified: Bool
}

/// Sign-off state of text and art.
public enum ReviewStatus: String, Codable, Hashable, Sendable {
    case pending
    case approved
}

public struct ReviewRecord: Codable, Hashable, Sendable {
    public var status: ReviewStatus
    public var by: String?
    public var date: String?
}

public struct Review: Codable, Hashable, Sendable {
    public var text: ReviewRecord
    public var art: ReviewRecord
}

/// Cultural review. A `required` review blocks release of the story until `approved`.
public struct CulturalReview: Codable, Hashable, Sendable {
    public enum Level: String, Codable, Hashable, Sendable {
        case required
        case standard
    }

    public enum Status: String, Codable, Hashable, Sendable {
        case pending
        case inReview
        case changesRequested
        case approved
    }

    public var level: Level
    public var status: Status
    /// Why this level. Required when `level` is `required`.
    public var reason: String?
    /// Who should review, e.g. "Buddhist reader".
    public var community: String?
    public var by: String?
    public var date: String?
    public var notes: String?
}

/// What a story teaches. All three pillars are required.
public struct Education: Codable, Hashable, Sendable {
    public var geography: EducationPillar
    public var culture: EducationPillar
    public var moral: EducationPillar
}

public struct EducationPillar: Codable, Hashable, Sendable {
    /// One or two sentences, for editors and the parent view.
    public var lesson: String
    /// Ids of this story's tap targets that teach the lesson.
    public var factCards: [TapTargetID]?
    /// Only used on `moral`. Data only until PRD Q27 is decided.
    public var reflectionQuestion: String?
}
