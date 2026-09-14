import Foundation

/// How the open book is laid out in the space it has. Follows Apple's Duo
/// guidance: one compact width foundation for the outer display, one regular
/// width foundation for the inner display, no pose specific breakpoints.
public enum PaneArrangement: Equatable, Sendable {
    /// One page at a time (outer display, narrow Split View, any compact phone).
    case single
    /// Two pages with a spine gap that keeps content clear of the fold.
    case dual(spineWidth: Double)

    public var isDual: Bool {
        if case .dual = self { return true }
        return false
    }
}

/// Pure layout rule. The SwiftUI layer feeds it the size class and measured
/// width; when the Xcode 27.1 SDK is available the same decision can be handed
/// to `ArrangementView(.split)` without changing callers.
///
/// P0 locks this encodes (see DESIGN.md, "Foldable reader P0 locks"):
/// - Regular width is the inner display. It always gets two panes, in any
///   orientation, so nobody has to rotate to landscape to see a spread.
/// - A compact canvas that is nonetheless wide (a phone in landscape) also
///   gets two panes rather than one column stretched across it.
/// - Anything narrower is a real single pane reader, not a shrunken spread.
public struct SpreadLayoutPolicy: Equatable, Sendable {
    /// Sanity floor for regular width. Real regular width canvases are far
    /// wider than this; it only guards against degenerate frames.
    public var minimumDualWidth: Double
    /// Compact width canvases at least this wide (landscape phones) still fit
    /// two pages and must not show one stretched column.
    public var wideCompactWidth: Double
    /// Reserved gap around the spine. Sized so text never sits on the fold.
    public var spineWidth: Double

    public init(minimumDualWidth: Double = 400, wideCompactWidth: Double = 700, spineWidth: Double = 28) {
        self.minimumDualWidth = minimumDualWidth
        self.wideCompactWidth = wideCompactWidth
        self.spineWidth = spineWidth
    }

    public static let standard = SpreadLayoutPolicy()

    public func arrangement(availableWidth: Double, isRegularWidth: Bool) -> PaneArrangement {
        if isRegularWidth {
            return availableWidth >= minimumDualWidth ? .dual(spineWidth: spineWidth) : .single
        }
        return availableWidth >= wideCompactWidth ? .dual(spineWidth: spineWidth) : .single
    }

    /// Width of one page given the total width and arrangement.
    public func pageWidth(availableWidth: Double, arrangement: PaneArrangement) -> Double {
        switch arrangement {
        case .single:
            return max(0, availableWidth)
        case .dual(let spine):
            return max(0, (availableWidth - spine) / 2)
        }
    }
}

/// What the two panes show relative to each other.
public enum SpreadMode: Hashable, Sendable {
    /// Left pane page n, right pane page n + 1, like a printed book.
    case facingPages
    /// Both panes show the same page number in two editions (Te left, En or Hi right).
    case synced(secondary: Language)
    /// Text on the left, the page's illustration or map art on the right.
    case illustrated

    /// Modes a title can offer, driven by which editions are bundled.
    public static func available(for book: Book) -> [SpreadMode] {
        var modes: [SpreadMode] = [.facingPages]
        modes.append(contentsOf: book.pairableLanguages.map { SpreadMode.synced(secondary: $0) })
        modes.append(.illustrated)
        return modes
    }

    public var title: String {
        switch self {
        case .facingPages: return "Pages"
        case .synced(let secondary): return "\(Language.primary.nativeName) | \(secondary.nativeName)"
        case .illustrated: return "Art"
        }
    }

    /// Stable string form for persisting the chosen mode per title.
    public var storageKey: String {
        switch self {
        case .facingPages: return "facing"
        case .synced(let secondary): return "synced:\(secondary.rawValue)"
        case .illustrated: return "illustrated"
        }
    }

    public init?(storageKey: String) {
        switch storageKey {
        case "facing":
            self = .facingPages
        case "illustrated":
            self = .illustrated
        default:
            guard storageKey.hasPrefix("synced:"),
                  let language = Language(rawValue: String(storageKey.dropFirst("synced:".count))) else { return nil }
            self = .synced(secondary: language)
        }
    }
}

/// Where the reader is in a title and how the panes are set. Kept as a plain
/// value so it can be saved, restored, and carried unchanged across a
/// compact to regular size change; `SpreadPager` re-derives the spread.
public struct ReadingPosition: Equatable, Sendable {
    public var pageIndex: Int
    public var mode: SpreadMode

    public init(pageIndex: Int = 0, mode: SpreadMode = .facingPages) {
        self.pageIndex = pageIndex
        self.mode = mode
    }

    /// Clamps to the title's real page count and drops modes the title
    /// cannot offer (for example a synced edition that is still planned).
    public func validated(for book: Book) -> ReadingPosition {
        var position = self
        position.pageIndex = min(max(0, pageIndex), max(0, book.pageCount - 1))
        if !SpreadMode.available(for: book).contains(mode) {
            position.mode = .facingPages
        }
        return position
    }
}

/// Which page indices the left and right panes hold for a given position.
public struct Spread: Equatable, Sendable {
    public var leftIndex: Int
    /// `nil` when the book ends on the left page or the layout is single pane.
    public var rightIndex: Int?

    public init(leftIndex: Int, rightIndex: Int?) {
        self.leftIndex = leftIndex
        self.rightIndex = rightIndex
    }

    public var indices: [Int] {
        if let rightIndex { return [leftIndex, rightIndex] }
        return [leftIndex]
    }
}

/// Turns a page index into the spread that shows it. Facing pages always start
/// on even indices so the same page stays on the same side while turning.
public enum SpreadPager {
    public static func spread(containing pageIndex: Int, pageCount: Int, arrangement: PaneArrangement, mode: SpreadMode) -> Spread? {
        guard pageCount > 0, pageIndex >= 0, pageIndex < pageCount else { return nil }
        switch (arrangement, mode) {
        case (.single, _), (.dual, .synced), (.dual, .illustrated):
            return Spread(leftIndex: pageIndex, rightIndex: nil)
        case (.dual, .facingPages):
            let left = pageIndex - (pageIndex % 2)
            let right = left + 1
            return Spread(leftIndex: left, rightIndex: right < pageCount ? right : nil)
        }
    }

    /// Index to jump to when turning forward. Returns `nil` at the last page.
    public static func nextPageIndex(from spread: Spread, pageCount: Int) -> Int? {
        let next = (spread.rightIndex ?? spread.leftIndex) + 1
        return next < pageCount ? next : nil
    }

    /// Index to jump to when turning back. Returns `nil` at the first page.
    public static func previousPageIndex(from spread: Spread) -> Int? {
        let previous = spread.leftIndex - 1
        return previous >= 0 ? previous : nil
    }
}
