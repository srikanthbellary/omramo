import Foundation
import Observation
import OmramoCore

/// Owns the catalog for the whole app. Loaded once at launch; views switch on
/// `state` and never touch the repository directly.
@Observable
@MainActor
final class CatalogStore {
    private(set) var state: LoadState<[Book]> = .idle
    private let repository: any ContentRepository

    init(repository: any ContentRepository) {
        self.repository = repository
    }

    var books: [Book] { state.value ?? [] }

    func book(id: BookID) -> Book? {
        books.first { $0.id == id }
    }

    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            let catalog = try await repository.loadCatalog()
            state = catalog.books.isEmpty ? .empty : .loaded(catalog.books)
        } catch {
            state = .failed(LoadFailure(error))
        }
    }

    /// Loads the primary edition plus every edition that can pair with it.
    func loadReaderContent(for book: Book) async throws -> ReaderContent {
        let primary = try await repository.loadEdition(bookID: book.id, language: .primary)
        var secondary: [Language: Edition] = [:]
        for language in book.pairableLanguages {
            secondary[language] = try await repository.loadEdition(bookID: book.id, language: language)
        }
        return ReaderContent(book: book, primary: primary, secondary: secondary)
    }

    /// Same pairing as the reader, clipped to the free sample so the sample
    /// screen cannot page into the rest of the book.
    func loadSampleContent(for book: Book) async throws -> ReaderContent {
        try await loadReaderContent(for: book).limitedToSample()
    }
}

/// Everything a spread needs for one title, already paired page for page.
struct ReaderContent: Equatable, Sendable {
    var book: Book
    var primary: Edition
    var secondary: [Language: Edition]

    func edition(for language: Language) -> Edition? {
        language == .primary ? primary : secondary[language]
    }

    var pageCount: Int { primary.pageCount }

    func limitedToSample() -> ReaderContent {
        let count = book.sample.pageCount
        ReaderContent(
            book: book,
            primary: primary.limited(toPageCount: count),
            secondary: secondary.mapValues { $0.limited(toPageCount: count) }
        )
    }
}
