import Foundation
import Observation
import OmramoCore

/// Reading position and spread mode for one title. Page turning is delegated
/// to `SpreadPager` so the same rules apply on one pane or two.
@Observable
@MainActor
final class ReaderModel {
    let book: Book
    private(set) var content: LoadState<ReaderContent> = .idle
    private(set) var pageIndex = 0
    var mode: SpreadMode = .facingPages

    private let catalog: CatalogStore

    init(book: Book, catalog: CatalogStore) {
        self.book = book
        self.catalog = catalog
    }

    var pageCount: Int { content.value?.pageCount ?? book.pageCount }

    var availableModes: [SpreadMode] { SpreadMode.available(for: book) }

    func load() async {
        content = .loading
        do {
            let loaded = try await catalog.loadReaderContent(for: book)
            content = loaded.pageCount == 0 ? .empty : .loaded(loaded)
            pageIndex = min(pageIndex, max(0, loaded.pageCount - 1))
        } catch {
            content = .failed(LoadFailure(error))
        }
    }

    func spread(for arrangement: PaneArrangement) -> Spread? {
        SpreadPager.spread(containing: pageIndex, pageCount: pageCount, arrangement: arrangement, mode: mode)
    }

    func canTurnForward(in arrangement: PaneArrangement) -> Bool {
        guard let spread = spread(for: arrangement) else { return false }
        return SpreadPager.nextPageIndex(from: spread, pageCount: pageCount) != nil
    }

    func canTurnBack(in arrangement: PaneArrangement) -> Bool {
        guard let spread = spread(for: arrangement) else { return false }
        return SpreadPager.previousPageIndex(from: spread) != nil
    }

    func turnForward(in arrangement: PaneArrangement) {
        guard let spread = spread(for: arrangement),
              let next = SpreadPager.nextPageIndex(from: spread, pageCount: pageCount) else { return }
        pageIndex = next
    }

    func turnBack(in arrangement: PaneArrangement) {
        guard let spread = spread(for: arrangement),
              let previous = SpreadPager.previousPageIndex(from: spread) else { return }
        pageIndex = previous
    }

    func go(to index: Int) {
        guard index >= 0, index < pageCount else { return }
        pageIndex = index
    }

    /// Human readable position, e.g. "Pages 3 and 4 of 10".
    func positionLabel(for arrangement: PaneArrangement) -> String {
        guard let spread = spread(for: arrangement) else { return "" }
        if let right = spread.rightIndex {
            return "Pages \(spread.leftIndex + 1) and \(right + 1) of \(pageCount)"
        }
        return "Page \(spread.leftIndex + 1) of \(pageCount)"
    }
}
