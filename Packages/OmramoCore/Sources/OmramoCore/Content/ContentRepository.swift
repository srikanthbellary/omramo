import Foundation

/// Source of catalog and page content. The prototype has one implementation
/// that reads bundled JSON; a downloaded library later slots in behind the same
/// protocol without touching views.
public protocol ContentRepository: Sendable {
    func loadCatalog() async throws -> Catalog
    func loadEdition(bookID: BookID, language: Language) async throws -> Edition
}

/// Reads the dummy catalog shipped inside `OmramoCore`'s resource bundle.
///
/// Layout on disk:
///
///     Content/catalog.json
///     Content/books/<book-id>/<book-id>.<lang>.json
public struct BundledContentRepository: ContentRepository {
    public static let contentDirectoryName = "Content"
    public static let catalogFileName = "catalog.json"
    public static let booksDirectoryName = "books"

    private let contentRoot: URL

    /// Uses the package resource bundle.
    public init() {
        self.init(contentRoot: Bundle.module.bundleURL.appendingPathComponent(Self.contentDirectoryName, isDirectory: true))
    }

    /// Points at any folder with the same layout. Tests use this to feed
    /// broken fixtures.
    public init(contentRoot: URL) {
        self.contentRoot = contentRoot
    }

    public func loadCatalog() async throws -> Catalog {
        let url = contentRoot.appendingPathComponent(Self.catalogFileName)
        let catalog: Catalog = try decode(Catalog.self, at: url)
        guard catalog.schemaVersion == Catalog.supportedSchemaVersion else {
            throw ContentError.unsupportedSchema(found: catalog.schemaVersion, supported: Catalog.supportedSchemaVersion)
        }
        return catalog
    }

    public func loadEdition(bookID: BookID, language: Language) async throws -> Edition {
        let catalog = try await loadCatalog()
        guard let book = catalog.book(id: bookID) else {
            throw ContentError.unknownBook(bookID)
        }
        guard let manifest = book.edition(for: language), manifest.isReady, let file = manifest.file else {
            throw ContentError.editionNotAvailable(bookID, language)
        }
        let url = contentRoot
            .appendingPathComponent(Self.booksDirectoryName, isDirectory: true)
            .appendingPathComponent(bookID.rawValue, isDirectory: true)
            .appendingPathComponent(file)
        let edition: Edition = try decode(Edition.self, at: url)
        try edition.validateNumbering()
        guard edition.pageCount == book.pageCount else {
            throw ContentError.pageCountMismatch(bookID: bookID, language: language, expected: book.pageCount, found: edition.pageCount)
        }
        return edition
    }

    private func decode<T: Decodable>(_ type: T.Type, at url: URL) throws -> T {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw ContentError.missingResource(url.lastPathComponent)
        }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw ContentError.unreadable(url.lastPathComponent, underlying: String(describing: error))
        }
    }
}
