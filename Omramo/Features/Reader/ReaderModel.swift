import Foundation
import Observation
import OmramoCore

/// Reading position and spread mode for one title. Page turning is delegated
/// to `SpreadPager` so the same rules apply on one pane or two.
///
/// The position is a plain `ReadingPosition` value: it does not depend on the
/// arrangement, so folding the device or moving between displays never moves
/// the reader. It is also saved per title, so reopening a book or opening it
/// in a second window lands on the same page in the same mode.
@Observable
@MainActor
final class ReaderModel {
    let book: Book
    private(set) var content: LoadState<ReaderContent> = .idle
    private(set) var position: ReadingPosition

    private let catalog: CatalogStore
    private let progress: ReadingProgressStore

    init(book: Book, catalog: CatalogStore, progress: ReadingProgressStore = .standard) {
        self.book = book
        self.catalog = catalog
        self.progress = progress
        self.position = progress.position(for: book.id).validated(for: book)
    }

    var pageIndex: Int { position.pageIndex }
    var mode: SpreadMode { position.mode }

    var pageCount: Int { content.value?.pageCount ?? book.pageCount }

    var availableModes: [SpreadMode] { SpreadMode.available(for: book) }

    func load() async {
        content = .loading
        do {
            let loaded = try await catalog.loadReaderContent(for: book)
            content = loaded.pageCount == 0 ? .empty : .loaded(loaded)
            position.pageIndex = min(position.pageIndex, max(0, loaded.pageCount - 1))
        } catch {
            content = .failed(LoadFailure(error))
        }
    }

    func setMode(_ mode: SpreadMode) {
        guard availableModes.contains(mode) else { return }
        position.mode = mode
        progress.save(position, for: book.id)
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
        go(to: next)
    }

    func turnBack(in arrangement: PaneArrangement) {
        guard let spread = spread(for: arrangement),
              let previous = SpreadPager.previousPageIndex(from: spread) else { return }
        go(to: previous)
    }

    func go(to index: Int) {
        guard index >= 0, index < pageCount else { return }
        position.pageIndex = index
        progress.save(position, for: book.id)
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

/// Per title reading progress in `UserDefaults`. Small on purpose: two keys
/// per book, no sync. A cloud backed store can replace it behind the same
/// two methods.
struct ReadingProgressStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    static let standard = ReadingProgressStore(defaults: .standard)

    func position(for bookID: BookID) -> ReadingPosition {
        let pageIndex = defaults.integer(forKey: pageKey(bookID))
        let mode = defaults.string(forKey: modeKey(bookID)).flatMap(SpreadMode.init(storageKey:)) ?? .facingPages
        return ReadingPosition(pageIndex: pageIndex, mode: mode)
    }

    func save(_ position: ReadingPosition, for bookID: BookID) {
        defaults.set(position.pageIndex, forKey: pageKey(bookID))
        defaults.set(position.mode.storageKey, forKey: modeKey(bookID))
    }

    private func pageKey(_ bookID: BookID) -> String { "reading.\(bookID.rawValue).page" }
    private func modeKey(_ bookID: BookID) -> String { "reading.\(bookID.rawValue).mode" }
}
