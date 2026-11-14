import SwiftUI
import OmramoCore

// The reader's geometry and the screens of a page, derived from the window's `PaneLayout`.
// Nothing here knows what device it is on: an iPhone, the Duo, an iPad pane or a Stage Manager
// window all come through the same numbers (docs/ARCHITECTURE.md §5).

/// Where the text column and the chrome sit on a pane, and how much text a column holds.
/// All values are in points of the real pane.
struct ReaderMetrics: Equatable {
    let posture: DisplayPosture
    /// Scale from the 432 × 720 reference pane (capped on large windows).
    let scale: CGFloat
    let paneSize: CGSize
    /// Top of the back button and the "Aa" capsule.
    let controlTop: CGFloat
    /// Leading edge of the text column, from the pane's leading edge.
    let columnX: CGFloat
    let columnWidth: CGFloat
    /// Top of the first line of text.
    let textTop: CGFloat
    /// Height of text the leading column (or the only column) can hold.
    let leadingCapacity: CGFloat
    /// Height of text the trailing column can hold (two panes only).
    let trailingCapacity: CGFloat
    /// Height of the picture band at the top of a single pane; 0 with two panes.
    let pictureHeight: CGFloat
    /// The tier's typography at the chosen text size.
    let typeScale: ReadingTypeScale
    let textSize: TextSizeStep

    init(layout: PaneLayout, safeArea: EdgeInsets, story: Story, spread: Spread, textSize: TextSizeStep) {
        let s = CGFloat(layout.referenceScale)
        let width = CGFloat(layout.leading.width)
        let height = CGFloat(layout.leading.height)
        let contentWidth = min(width, CGFloat(ReferenceCanvas.paneWidth) * s)
        let contentInset = max(0, (width - contentWidth) / 2)
        let referenceHeight = CGFloat(ReferenceCanvas.paneHeight)

        // The same rule as `PaneContext.bottomInset`: the designed inset, or more when the
        // home indicator needs it.
        func bottomInset(_ reference: CGFloat) -> CGFloat {
            max(reference * s, safeArea.bottom + 6 * s)
        }

        posture = layout.posture
        scale = s
        paneSize = CGSize(width: width, height: height)
        self.textSize = textSize
        let base = story.tier.readingScale(posture: layout.posture)
        typeScale = base.scaled(to: textSize)
        let button = CGFloat(Tokens.Size.roundGlassButton) * s
        let inset = CGFloat(Tokens.Spacing.insetText) * s
        columnX = contentInset + inset

        switch layout.posture {
        case .unfolded:
            let top = max(CGFloat(Tokens.Spacing.topControl) * s, safeArea.top + 4 * s)
            controlTop = top
            // The designed gap between the controls and the first line (106 or 108 − 50 − 40).
            let unfoldedTop = story.tier.readingScale(posture: .unfolded).textTop
            let gap = CGFloat(unfoldedTop - Tokens.Spacing.topControl - Tokens.Size.roundGlassButton) * s
            textTop = top + button + gap
            let hingeMargin = max(contentInset, CGFloat(Tokens.Spacing.hingeClearance) * s)
            columnWidth = max(0, min(CGFloat(base.column) * s, width - contentInset - inset - hingeMargin))
            pictureHeight = 0

            // The scene's art is anchored to the bottom of the pane, so the text area ends a
            // fixed distance above the bottom edge — and above the footer chrome in any case.
            let area = spread.scene.textArea
            let chipsTop = height - bottomInset(CGFloat(Tokens.Spacing.footBottom + 3)) - CGFloat(Tokens.Size.chipHeight) * s
            let leadingReserve = (referenceHeight - CGFloat(area?.leadingBottom ?? ReaderMetrics.defaultLeadingBottom)) * s
            let leadingBottom = min(height - leadingReserve, chipsTop - 12 * s)
            let pageTurnTop = height - bottomInset(CGFloat(Tokens.Spacing.pageTurnInset)) - CGFloat(Tokens.Size.pageTurn) * s
            let trailingReserve = (referenceHeight - CGFloat(area?.trailingBottom ?? ReaderMetrics.defaultTrailingBottom)) * s
            let trailingBottom = min(height - trailingReserve, pageTurnTop - 12 * s)
            leadingCapacity = max(ReaderMetrics.minimumCapacity * s, leadingBottom - textTop)
            trailingCapacity = max(ReaderMetrics.minimumCapacity * s, trailingBottom - textTop)

        case .folded:
            let top = max(CGFloat(Tokens.Spacing.topControlFolded) * s, safeArea.top + 4 * s)
            controlTop = top
            // Screen 10: the picture fills the top 340 pt of the 720 pt pane. A wide single
            // pane (an 11-inch iPad in portrait) gets a taller band, so the picture keeps a
            // generous shape; larger text sizes give some of the picture's room to the words.
            let designed = ReaderMetrics.foldedPictureHeight * s
            let roomy = min(width * 0.62, height * 0.5)
            let band = max(designed, roomy) * ReaderMetrics.pictureFactor(for: textSize)
            pictureHeight = max(band, top + button + 16 * s)
            textTop = pictureHeight + ReaderMetrics.foldedTextGap * s
            columnWidth = max(0, min(CGFloat(base.column) * s, width - contentInset * 2 - inset - 26 * s))
            let pageTurnTop = height - bottomInset(CGFloat(Tokens.Spacing.pageTurnInsetFolded)) - CGFloat(Tokens.Size.pageTurnFolded) * s
            leadingCapacity = max(ReaderMetrics.minimumCapacity * s, pageTurnTop - 4 * s - textTop)
            trailingCapacity = 0
        }
    }

    /// Where text stops on the reference pane when the scene does not say: above the footer
    /// chips (leading) and above the page chip and round button (trailing).
    static let defaultLeadingBottom = 648.0
    static let defaultTrailingBottom = 612.0
    /// Screen 10: picture to y 340, text from y 366.
    static let foldedPictureHeight: CGFloat = 340
    static let foldedTextGap: CGFloat = 26
    /// Never plan for less than this (reference points), however small the window.
    static let minimumCapacity: CGFloat = 80

    /// At the two largest text sizes the folded picture gives up some height to the words.
    static func pictureFactor(for step: TextSizeStep) -> CGFloat {
        switch step {
        case .small, .standard, .large: return 1
        case .larger: return 0.8
        case .largest: return 0.62
        }
    }

    /// Space between paragraphs, in points.
    var paragraphGap: CGFloat {
        CGFloat(typeScale.paragraphGap) * scale
    }

    func capacity(of pane: TextBlock.Pane) -> CGFloat {
        pane == .leading ? leadingCapacity : trailingCapacity
    }
}

/// The screens of one page for one layout: which paragraphs to measure, and — once they are
/// measured — which paragraphs each screen shows (docs/ARCHITECTURE.md §8.3).
struct ReaderPageLayout {
    let spread: Spread
    let metrics: ReaderMetrics
    let key: TextMeasureKey
    /// Text on both panes (Advanced, unfolded): two columns a screen. Otherwise one.
    let twoColumns: Bool
    /// Authored paragraphs, plus the sentence groups of any paragraph too tall for a column.
    let blocksToMeasure: [TextBlock]
    /// Nil until every paragraph it needs has been measured.
    let plan: ScreenPlan?

    private let blocksByID: [BlockID: TextBlock]

    init(spread: Spread, metrics: ReaderMetrics, measurements: [TextMeasureKey: [BlockID: CGFloat]]) {
        self.spread = spread
        self.metrics = metrics
        let key = TextMeasureKey(
            spreadID: spread.id,
            columnWidth: metrics.columnWidth,
            textSize: metrics.textSize,
            paneScale: metrics.scale,
            posture: metrics.posture
        )
        self.key = key
        let twoColumns = metrics.posture == .unfolded && spread.blocks.contains { $0.pane == .trailing }
        self.twoColumns = twoColumns

        let heights = measurements[key] ?? [:]
        // With two columns a paragraph can land in either, so it must fit the shorter one
        // whole; otherwise it is continued sentence by sentence (pieces that end up together
        // are shown as one paragraph again).
        let tallest = twoColumns ? min(metrics.leadingCapacity, metrics.trailingCapacity) : metrics.leadingCapacity
        var toMeasure = spread.blocks
        var byID: [BlockID: TextBlock] = [:]
        var items: [FlowItem] = []
        var complete = true

        for block in spread.blocks {
            byID[block.id] = block
            guard let height = heights[block.id] else {
                complete = false
                continue
            }
            let isLead = !block.runs.isEmpty && block.runs.allSatisfy(\.isLead)
            if height > tallest + CGFloat(ScreenPlanner.tolerance) {
                // Too tall for any column: continue it sentence by sentence.
                let pieces = block.sentenceFragments()
                if pieces.count > 1 {
                    toMeasure.append(contentsOf: pieces)
                    var pieceItems: [FlowItem] = []
                    for (index, piece) in pieces.enumerated() {
                        byID[piece.id] = piece
                        if let pieceHeight = heights[piece.id] {
                            pieceItems.append(FlowItem(
                                id: piece.id,
                                height: Double(pieceHeight),
                                pane: block.pane,
                                joinsPrevious: index > 0
                            ))
                        }
                    }
                    if pieceItems.count == pieces.count {
                        items.append(contentsOf: pieceItems)
                    } else {
                        complete = false
                    }
                    continue
                }
            }
            items.append(FlowItem(id: block.id, height: Double(height), pane: block.pane, keepWithNext: isLead))
        }

        blocksToMeasure = toMeasure
        blocksByID = byID
        if complete {
            plan = ScreenPlanner.plan(
                items: items,
                gap: Double(metrics.paragraphGap),
                columns: FlowColumns(
                    leading: Double(metrics.leadingCapacity),
                    trailing: twoColumns ? Double(metrics.trailingCapacity) : nil
                )
            )
        } else {
            plan = nil
        }
    }

    /// The paragraphs one column of one screen shows; sentence groups that ended up together
    /// are one paragraph again.
    func blocks(in pane: TextBlock.Pane, onScreen index: Int) -> [TextBlock] {
        guard let plan, index >= 0, index < plan.screenCount else { return [] }
        let ids = pane == .leading ? plan.screens[index].leading : plan.screens[index].trailing
        return TextBlock.rejoiningFragments(ids.compactMap { blocksByID[$0] })
    }

    /// True when a column holds a single piece that is taller than the column even after
    /// splitting into sentences. The view lets that one column scroll rather than clip it.
    func needsScrolling(in pane: TextBlock.Pane, onScreen index: Int) -> Bool {
        guard let plan, index >= 0, index < plan.screenCount else { return false }
        let ids = pane == .leading ? plan.screens[index].leading : plan.screens[index].trailing
        return ids.contains { plan.oversize.contains($0) }
    }
}
