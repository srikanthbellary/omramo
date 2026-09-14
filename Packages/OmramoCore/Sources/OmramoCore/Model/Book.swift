import Foundation

/// Stable identifier for a title. Matches the folder name under `Content/books`.
public struct BookID: RawRepresentable, Hashable, Codable, Sendable, Identifiable, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public var id: String { rawValue }
    public var description: String { rawValue }
}

/// Availability of one language edition of a title.
public enum EditionStatus: String, Codable, Hashable, Sendable {
    /// Pages are bundled and can be opened.
    case ready
    /// The edition is announced but its pages are not bundled yet.
    case planned
}

/// One entry in a book's edition list. `file` is relative to the book folder.
public struct EditionManifest: Codable, Hashable, Sendable {
    public var language: Language
    public var status: EditionStatus
    public var file: String?

    public init(language: Language, status: EditionStatus, file: String? = nil) {
        self.language = language
        self.status = status
        self.file = file
    }

    public var isReady: Bool { status == .ready && file != nil }
}

/// How much of a title is free to sample. The sample is always the opening
/// pages so the open-book moment reads like picking the book off a shelf.
public struct SampleSpec: Codable, Hashable, Sendable {
    /// Number of pages shown before the hard paywall. Two fills a Duo spread.
    public var pageCount: Int

    public init(pageCount: Int) {
        self.pageCount = pageCount
    }
}

/// Catalog level metadata for a title. Page content lives in edition files so
/// the catalog stays light and browsing never loads page text.
public struct Book: Codable, Hashable, Identifiable, Sendable {
    public var id: BookID
    public var title: LocalizedText
    public var author: LocalizedText
    public var description: LocalizedText
    public var poster: Artwork
    public var pageCount: Int
    public var editions: [EditionManifest]
    public var sample: SampleSpec

    public init(
        id: BookID,
        title: LocalizedText,
        author: LocalizedText,
        description: LocalizedText,
        poster: Artwork,
        pageCount: Int,
        editions: [EditionManifest],
        sample: SampleSpec
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.description = description
        self.poster = poster
        self.pageCount = pageCount
        self.editions = editions
        self.sample = sample
    }

    public func edition(for language: Language) -> EditionManifest? {
        editions.first { $0.language == language }
    }

    /// Languages whose pages are bundled, primary edition first.
    public var readyLanguages: [Language] {
        Language.allCases.filter { edition(for: $0)?.isReady == true }
    }

    /// Editions that can sit beside the primary edition in a synced spread.
    public var pairableLanguages: [Language] {
        readyLanguages.filter { $0 != .primary }
    }
}

/// The bundled catalog. `schemaVersion` guards against reading content written
/// for a newer app.
public struct Catalog: Codable, Hashable, Sendable {
    public static let supportedSchemaVersion = 1

    public var schemaVersion: Int
    public var books: [Book]

    public init(schemaVersion: Int = Catalog.supportedSchemaVersion, books: [Book]) {
        self.schemaVersion = schemaVersion
        self.books = books
    }

    public func book(id: BookID) -> Book? {
        books.first { $0.id == id }
    }
}
