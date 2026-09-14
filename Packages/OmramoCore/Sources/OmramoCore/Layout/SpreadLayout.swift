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
public struct SpreadLayoutPolicy: Equatable, Sendable {
    /// Below this width two readable Telugu pages do not fit even in regular width.
    public var minimumDualWidth: Double
    /// Reserved gap around the spine. Sized so text never sits on the fold.
    public var spineWidth: Double

    public init(minimumDualWidth: Double = 560, spineWidth: Double = 28) {
        self.minimumDualWidth = minimumDualWidth
        self.spineWidth = spineWidth
    }

    public static let standard = SpreadLayoutPolicy()

    public func arrangement(availableWidth: Double, isRegularWidth: Bool) -> PaneArrangement {
        guard isRegularWidth, availableWidth >= minimumDualWidth else { return .single }
        return .dual(spineWidth: spineWidth)
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
