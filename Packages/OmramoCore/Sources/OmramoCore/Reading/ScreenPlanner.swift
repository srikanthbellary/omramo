import Foundation

// Continuation screens (docs/ARCHITECTURE.md §8.3).
//
// A page's text is authored to fit its pane at the tier's designed size. When it does not fit —
// larger text chosen with "Aa", a smaller window, the folded screen — the page continues on
// further screens: same page number, same scene, the next slice of paragraphs. The view
// measures how tall each paragraph is; this file decides, from those numbers alone, which
// paragraphs go on which screen. Nothing is ever clipped or truncated.

/// One paragraph (or one sentence group of a split paragraph) to place, with its measured height.
public struct FlowItem: Equatable, Hashable, Sendable {
    public var id: BlockID
    /// Height in points at the width it will be shown.
    public var height: Double
    /// The pane the block was authored for.
    public var pane: TextBlock.Pane
    /// Do not leave this item at the bottom of a column on its own (a lead sentence).
    public var keepWithNext: Bool
    /// The item continues the paragraph of the item before it (the next sentences of a split
    /// paragraph): no paragraph gap between them.
    public var joinsPrevious: Bool

    public init(
        id: BlockID,
        height: Double,
        pane: TextBlock.Pane = .leading,
        keepWithNext: Bool = false,
        joinsPrevious: Bool = false
    ) {
        self.id = id
        self.height = height
        self.pane = pane
        self.keepWithNext = keepWithNext
        self.joinsPrevious = joinsPrevious
    }
}

/// How much text height each column of a screen can hold.
public struct FlowColumns: Equatable, Hashable, Sendable {
    /// The leading pane's text area (the only one when folded, or when the page keeps the
    /// trailing pane for its picture).
    public var leading: Double
    /// The trailing pane's text area; nil when text flows in one column.
    public var trailing: Double?

    public init(leading: Double, trailing: Double? = nil) {
        self.leading = leading
        self.trailing = trailing
    }
}

/// The screens of one page.
public struct ScreenPlan: Equatable, Hashable, Sendable {
    public struct Screen: Equatable, Hashable, Sendable {
        /// Blocks in the leading column (all of them when there is one column).
        public var leading: [BlockID]
        /// Blocks in the trailing column.
        public var trailing: [BlockID]

        public init(leading: [BlockID] = [], trailing: [BlockID] = []) {
            self.leading = leading
            self.trailing = trailing
        }

        /// Reading order: leading column, then trailing.
        public var blocks: [BlockID] { leading + trailing }

        public var isEmpty: Bool { leading.isEmpty && trailing.isEmpty }
    }

    /// Never empty: a page always has at least one screen.
    public var screens: [Screen]
    /// Items taller than the column they were given even on their own. The view splits such a
    /// paragraph into sentences and plans again; a single sentence that is still too tall is
    /// shown in a scrolling column rather than clipped.
    public var oversize: Set<BlockID>

    public init(screens: [Screen], oversize: Set<BlockID> = []) {
        self.screens = screens.isEmpty ? [Screen()] : screens
        self.oversize = oversize
    }

    /// Everything on one screen, in the columns it was authored for: the plan used before the
    /// text has been measured, and for a page that simply fits.
    public init(unmeasured blocks: [TextBlock], twoColumns: Bool) {
        if twoColumns {
            self.init(screens: [Screen(
                leading: blocks.filter { $0.pane == .leading }.map(\.id),
                trailing: blocks.filter { $0.pane == .trailing }.map(\.id)
            )])
        } else {
            self.init(screens: [Screen(leading: blocks.map(\.id))])
        }
    }

    public var screenCount: Int { screens.count }

    /// The screen to show for an anchor. A paragraph that was split into sentences is found
    /// through its parent id, in either direction, so a place survives a change of layout.
    public func index(for anchor: ScreenAnchor) -> Int {
        switch anchor {
        case .start:
            return 0
        case .end:
            return screens.count - 1
        case .block(let id):
            if let exact = screens.firstIndex(where: { $0.blocks.contains(id) }) {
                return exact
            }
            let parent = id.fragmentParent
            if let related = screens.firstIndex(where: { screen in
                screen.blocks.contains { $0 == parent || $0.fragmentParent == parent }
            }) {
                return related
            }
            return 0
        }
    }

    /// The anchor that brings the reader back to this screen after the layout changes: the
    /// paragraph that is first on it.
    public func anchor(forScreen index: Int) -> ScreenAnchor {
        guard index > 0, index < screens.count, let first = screens[index].blocks.first else {
            return .start
        }
        return .block(first)
    }

    /// Which column of which screen shows a block (or a sentence group of it).
    public func pane(of id: BlockID, onScreen index: Int) -> TextBlock.Pane? {
        guard index >= 0, index < screens.count else { return nil }
        let parent = id.fragmentParent
        let matches: (BlockID) -> Bool = { $0 == id || $0.fragmentParent == parent }
        if screens[index].leading.contains(where: matches) { return .leading }
        if screens[index].trailing.contains(where: matches) { return .trailing }
        return nil
    }
}

public enum ScreenPlanner {
    /// Rounding slack, so a paragraph that measures a hair over its column still fits.
    public static let tolerance: Double = 0.5

    /// Flows the items, in reading order, into columns.
    ///
    /// - One column (`columns.trailing == nil`): leading column of screen 1, of screen 2, …
    /// - Two columns: leading then trailing column of screen 1, then of screen 2, … The first
    ///   item authored for the trailing pane always starts a trailing column, so a page that
    ///   fits looks exactly as authored; after it, text simply continues.
    ///
    /// Every item is placed, in order, exactly once. An item taller than an empty column is
    /// placed there alone and reported in `oversize`.
    public static func plan(items: [FlowItem], gap: Double, columns: FlowColumns) -> ScreenPlan {
        var screens: [ScreenPlan.Screen] = []
        var oversize = Set<BlockID>()
        var current = ScreenPlan.Screen()
        var pane = TextBlock.Pane.leading
        var used = 0.0
        var trailingStarted = false
        let twoColumns = columns.trailing != nil

        func capacity(_ pane: TextBlock.Pane) -> Double {
            max(0, pane == .leading ? columns.leading : (columns.trailing ?? columns.leading))
        }

        for (index, item) in items.enumerated() {
            if twoColumns, item.pane == .trailing, !trailingStarted {
                trailingStarted = true
                if pane == .leading {
                    pane = .trailing
                    used = 0
                }
            }

            while true {
                let columnIsEmpty = pane == .leading ? current.leading.isEmpty : current.trailing.isEmpty
                let need = item.height + (columnIsEmpty || item.joinsPrevious ? 0 : gap)
                var wanted = need
                if item.keepWithNext, index + 1 < items.count {
                    let next = items[index + 1]
                    // The next item will jump to the trailing column anyway: nothing to keep.
                    let nextJumps = twoColumns && next.pane == .trailing && !trailingStarted && pane == .leading
                    if !nextJumps {
                        wanted += next.height + (next.joinsPrevious ? 0 : gap)
                    }
                }
                let room = capacity(pane) + tolerance - used
                if wanted <= room || columnIsEmpty {
                    if pane == .leading {
                        current.leading.append(item.id)
                    } else {
                        current.trailing.append(item.id)
                    }
                    used += need
                    if item.height > capacity(pane) + tolerance {
                        oversize.insert(item.id)
                    }
                    break
                }
                // Next column: the trailing pane of this screen, or a new screen.
                if twoColumns, pane == .leading {
                    pane = .trailing
                } else {
                    screens.append(current)
                    current = ScreenPlan.Screen()
                    pane = .leading
                }
                used = 0
            }
        }
        if !current.isEmpty || screens.isEmpty {
            screens.append(current)
        }
        return ScreenPlan(screens: screens, oversize: oversize)
    }
}

// MARK: - Splitting a paragraph into sentences

extension BlockID {
    /// Separator between a block id and the number of one of its sentence groups.
    public static let fragmentSeparator: Character = "#"

    /// The id of the `number`-th (1-based) sentence group of this block.
    public func fragment(_ number: Int) -> BlockID {
        BlockID(rawValue + String(BlockID.fragmentSeparator) + String(number))
    }

    /// The authored block this id belongs to: itself, or the block a sentence group was cut from.
    public var fragmentParent: BlockID {
        guard let cut = rawValue.lastIndex(of: BlockID.fragmentSeparator) else { return self }
        let suffix = rawValue[rawValue.index(after: cut)...]
        guard !suffix.isEmpty, suffix.allSatisfy({ $0.isASCII && $0.isNumber }) else { return self }
        return BlockID(String(rawValue[..<cut]))
    }

    public var isFragment: Bool { fragmentParent != self }
}

extension TextBlock {
    /// The paragraph cut into its sentences, for a pane too small to hold it whole. Joining the
    /// pieces' texts gives the paragraph exactly: no character is added, dropped or changed.
    /// Styles stay on their words; a face chip stays with the sentence that starts the speech.
    /// Returns the block itself, unsplit, when it has one sentence or is text on a path.
    public func sentenceFragments() -> [TextBlock] {
        guard kind == .paragraph else { return [self] }

        // The paragraph as characters, each remembering its run.
        var characters: [(run: Int, character: Character)] = []
        for (index, run) in runs.enumerated() {
            for character in run.text {
                characters.append((index, character))
            }
        }
        guard !characters.isEmpty else { return [self] }

        // A sentence ends at . ! ? or … (with any closing quotes), followed by a space and then
        // something that is not a lower-case letter: “Stop!” he cried.  stays one sentence.
        let terminators: Set<Character> = [".", "!", "?", "…"]
        let closers: Set<Character> = ["”", "’", "\"", "'", ")", "]", "»"]
        var cuts: [Int] = []
        var position = 0
        while position < characters.count {
            guard terminators.contains(characters[position].character) else {
                position += 1
                continue
            }
            var end = position + 1
            while end < characters.count,
                  terminators.contains(characters[end].character) || closers.contains(characters[end].character) {
                end += 1
            }
            var afterSpace = end
            while afterSpace < characters.count, characters[afterSpace].character.isWhitespace {
                afterSpace += 1
            }
            if afterSpace > end, afterSpace < characters.count, !characters[afterSpace].character.isLowercase {
                cuts.append(afterSpace)
            }
            position = max(end, position + 1)
        }
        guard !cuts.isEmpty else { return [self] }

        var fragments: [TextBlock] = []
        var start = 0
        for (number, end) in (cuts + [characters.count]).enumerated() {
            var pieces: [TextRun] = []
            var cursor = start
            while cursor < end {
                let runIndex = characters[cursor].run
                var text = ""
                let pieceStart = cursor
                while cursor < end, characters[cursor].run == runIndex {
                    text.append(characters[cursor].character)
                    cursor += 1
                }
                var piece = runs[runIndex]
                piece.text = text
                // The chip is drawn once, where the run begins.
                let runBeginsHere = pieceStart == 0 || characters[pieceStart - 1].run != runIndex
                if !runBeginsHere {
                    piece.showsFaceChip = false
                }
                pieces.append(piece)
            }
            fragments.append(TextBlock(id: id.fragment(number + 1), pane: pane, kind: kind, runs: pieces, path: nil))
            start = end
        }
        return fragments
    }

    /// Sentence groups that ended up side by side on a screen, shown as one paragraph again.
    /// Pieces of different paragraphs are left apart.
    public static func rejoiningFragments(_ blocks: [TextBlock]) -> [TextBlock] {
        var result: [TextBlock] = []
        for block in blocks {
            if block.id.isFragment, let last = result.last, last.id.isFragment,
               last.id.fragmentParent == block.id.fragmentParent {
                var joined = last
                joined.runs.append(contentsOf: block.runs)
                result[result.count - 1] = joined
            } else {
                result.append(block)
            }
        }
        return result
    }
}
