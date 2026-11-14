import Foundation
import Observation
import OmramoCore

/// A short message shown on the facing pane after the child does something (§5.8).
enum ReaderToast: Equatable {
    case backAtLine
    case bookmarkSaved
    case bookmarkRemoved

    var text: String {
        switch self {
        case .backAtLine: return "You are back at your line"
        case .bookmarkSaved: return "Bookmark saved on this page"
        case .bookmarkRemoved: return "Bookmark removed"
        }
    }
}

/// How a marked word is drawn (docs/DESIGN.md §4.3, §5.8).
enum MarkState: Equatable {
    case idle
    /// Its card is open now.
    case open
    /// Its card has been opened and closed before. Still tappable.
    case seen
}

/// State of the reader: which story, which page and which screen of it, the text size, the open
/// card, the bookmark. It lives outside the views and is keyed by content ids, so a change of
/// posture or window size lays out the same page again, shows the paragraph that was first on
/// screen, and keeps an open card open (docs/ARCHITECTURE.md §8.4).
@MainActor
@Observable
final class ReaderModel {
    let story: Story
    let landmarks: LandmarkCatalog
    let pager: Pager

    /// The page.
    private(set) var spreadID: SpreadID?
    /// Which screen of the page, by content: the paragraph that is first on it.
    private(set) var anchor: ScreenAnchor = .start

    /// The card that is open, if any. While it is open the page cannot be turned.
    private(set) var openCard: OpenCard?
    /// The card that was just closed: its paragraph keeps the place marker and a faint wash
    /// until the child moves on (§5.8 "Returned").
    private(set) var returnedCard: OpenCard?
    private(set) var toast: ReaderToast?
    /// The interim "Aa" panel (design gap G1).
    var isTextPanelOpen = false

    /// Measured paragraph heights, by the layout they were measured for. The screens of a page
    /// are derived from these in the view (`ReaderPageLayout`); nothing here is a pixel position.
    private(set) var measurements: [TextMeasureKey: [BlockID: CGFloat]] = [:]

    private let progress: ReadingProgressStore
    private let memory: ReaderMemoryStore
    private var toastTask: Task<Void, Never>?

    init(
        story: Story,
        progress: ReadingProgressStore,
        memory: ReaderMemoryStore? = nil,
        landmarks: LandmarkCatalog = LandmarkCatalog()
    ) {
        self.story = story
        self.landmarks = landmarks
        self.progress = progress
        // No store given (tests, previews): remember in memory only.
        self.memory = memory ?? ReaderMemoryStore(fileURL: nil)
        let pager = Pager(story: story)
        self.pager = pager
        let saved = progress.position(for: story.id)
        let resumed = pager.resume(from: saved)
        self.spreadID = resumed
        if let saved, saved.spreadID == resumed {
            self.anchor = saved.anchor
        }
    }

    // MARK: Page

    var spread: Spread? {
        guard let spreadID else { return nil }
        return story.spreads.first { $0.id == spreadID }
    }

    /// 1-based, for "1 / 14". Continuation screens keep their page's number.
    var pageNumber: Int {
        spreadID.flatMap { pager.pageNumber(of: $0) } ?? 1
    }

    var pageCount: Int {
        pager.pageCount
    }

    var isLastPage: Bool {
        guard let spreadID else { return true }
        return pager.isLast(spreadID)
    }

    /// The line under the title in the crumb: the part when the story has several, else the
    /// story's own subtitle ("An Anansi story").
    var crumbSubtitle: String {
        let part = spread.flatMap { story.part(id: $0.part) }?.title ?? ""
        if story.parts.count > 1 {
            return part
        }
        return story.subtitle ?? part
    }

    /// The reader came on screen: remember this story as the one being read.
    func didOpen() {
        savePosition()
        #if DEBUG
        if let raw = DebugLaunch.cardID() {
            openLaunchCard(raw)
        }
        #endif
    }

    #if DEBUG
    /// Debug launch helper: open a named tap-to-see or character card, jumping to its page if needed.
    func openLaunchCard(_ raw: String) {
        let tap = StoryCardRef.tapTarget(TapTargetID(raw))
        let character = StoryCardRef.character(CharacterID(raw))
        let ref: StoryCardRef
        if canOpen(tap) {
            ref = tap
        } else if canOpen(character) {
            ref = character
        } else {
            print("[Omramo] -OmramoOpenCard: '\(raw)' is not a card in this story")
            return
        }
        guard let found = firstMark(of: ref) else {
            print("[Omramo] -OmramoOpenCard: '\(raw)' has no marked word in the story")
            return
        }
        spreadID = found.spreadID
        anchor = .block(found.blockID)
        open(ref, from: found.blockID)
    }

    private func firstMark(of ref: StoryCardRef) -> (spreadID: SpreadID, blockID: BlockID)? {
        for spread in story.spreads {
            for block in spread.blocks {
                if block.runs.contains(where: { run in
                    switch ref {
                    case .tapTarget(let id): return run.tapTarget == id
                    case .character(let id): return run.characterName == id
                    }
                }) {
                    return (spread.id, block.id)
                }
            }
        }
        return nil
    }
    #endif

    /// True when the round button has nowhere further to go: the last screen of the last page.
    func isAtEnd(screen: Int, screenCount: Int) -> Bool {
        guard let spreadID else { return true }
        return pager.isAtEnd(spreadID, screen: screen, screenCount: screenCount)
    }

    /// True on the first screen of the first page: there is nothing to go back to.
    func isAtStart(screen: Int) -> Bool {
        guard let spreadID else { return true }
        return pager.isAtStart(spreadID, screen: screen)
    }

    /// The child pressed the round button. A page never turns any other way, and never while a
    /// card is open. `plan` is the current page's screens as laid out now (nil = one screen).
    func turnPage(in plan: ScreenPlan? = nil) {
        // TODO(M5): ask SampleGate before showing a spread beyond `story.sample.freeSpreads`.
        // TODO(M4): record a page-read event (date, story, spread — never a time) in ReadingLog.
        guard openCard == nil, let spreadID else { return }
        let count = plan?.screenCount ?? 1
        let screen = plan?.index(for: anchor) ?? 0
        guard let move = pager.forward(from: spreadID, screen: screen, screenCount: count) else { return }
        apply(move, in: plan)
    }

    /// The child pressed the back-one-page control.
    func goBack(in plan: ScreenPlan? = nil) {
        guard openCard == nil, let spreadID else { return }
        let count = plan?.screenCount ?? 1
        let screen = plan?.index(for: anchor) ?? 0
        guard let move = pager.backward(from: spreadID, screen: screen, screenCount: count) else { return }
        apply(move, in: plan)
    }

    private func apply(_ move: Pager.Move, in plan: ScreenPlan?) {
        switch move {
        case .screen(let index):
            anchor = plan?.anchor(forScreen: index) ?? .start
        case .spread(let id, let newAnchor):
            spreadID = id
            anchor = newAnchor
            // Heights of the page just left are not needed again until it is laid out again.
            measurements.removeAll()
        }
        returnedCard = nil
        isTextPanelOpen = false
        dismissToast()
        savePosition()
    }

    /// The view has laid out the current screen. Settles a "last screen" anchor onto its first
    /// paragraph (so it survives a relaunch or a change of layout) and records friends met.
    func didShow(screen index: Int, of plan: ScreenPlan) {
        guard index >= 0, index < plan.screenCount else { return }
        let settled = plan.anchor(forScreen: index)
        // An open card pins the screen to the one holding its word; follow it, so closing
        // the card after a change of layout leaves the reader on that same screen.
        if anchor == .end || (openCard != nil && plan.index(for: anchor) != index) {
            anchor = settled
            savePosition()
        }
        let shown = plan.screens[index].blocks.compactMap { story.block(id: $0) }
        memory.recordMet(shown.flatMap(\.namedCharacters), in: story.id)
    }

    /// The child pressed the button on the last screen of the last page.
    /// TODO(M6): the story-finished moment (design gap G3). TODO(M4): mark the story finished.
    func finish() {
        progress.clear(storyID: story.id)
    }

    private var currentPosition: ReadingPosition? {
        guard let spreadID else { return nil }
        let block: BlockID?
        switch anchor {
        case .block(let id): block = id.fragmentParent
        case .start: block = spread?.blocks.first?.id
        // Not laid out yet: `didShow` replaces this with the paragraph first on screen.
        case .end: block = spread?.blocks.last?.id
        }
        return ReadingPosition(storyID: story.id, spreadID: spreadID, blockID: block)
    }

    private func savePosition() {
        guard let position = currentPosition else { return }
        progress.record(position)
    }

    // MARK: Text size ("Aa")

    /// The step in use. The first time, the system text size decides (`adoptSystemTextSize`).
    var textSize: TextSizeStep {
        memory.textSize ?? .standard
    }

    func setTextSize(_ step: TextSizeStep) {
        guard openCard == nil else { return }
        memory.setTextSize(step)
    }

    /// Called once when the reader appears: if no size has ever been chosen, start from the
    /// system's text size (docs/ARCHITECTURE.md §12.1).
    func adoptSystemTextSize(index: Int) {
        guard memory.textSize == nil else { return }
        memory.setTextSize(TextSizeStep.initial(systemSizeIndex: index))
    }

    func toggleTextPanel() {
        guard openCard == nil else { return }
        isTextPanelOpen.toggle()
    }

    // MARK: Bookmark

    var bookmark: ReadingPosition? {
        memory.bookmark(for: story.id)
    }

    /// 1-based page of the bookmark, if there is one and its page still exists.
    var bookmarkPage: Int? {
        bookmark.flatMap { pager.pageNumber(of: $0.spreadID) }
    }

    /// True when the bookmark is on the page being read.
    var isCurrentPageBookmarked: Bool {
        bookmark?.spreadID == spreadID && spreadID != nil
    }

    /// The bookmark control: saves the place on this page, or removes the bookmark when it is
    /// already here. One bookmark per story; a new one replaces the old.
    func toggleBookmark() {
        guard openCard == nil, let position = currentPosition else { return }
        if isCurrentPageBookmarked {
            memory.removeBookmark(for: story.id)
            show(.bookmarkRemoved)
        } else {
            memory.setBookmark(position)
            show(.bookmarkSaved)
        }
    }

    /// Returns to the bookmarked place.
    func goToBookmark() {
        guard openCard == nil, let bookmark, pager.index(of: bookmark.spreadID) != nil else { return }
        if spreadID != bookmark.spreadID {
            // Only a new page is measured afresh. The measurer is not rebuilt for the page
            // already on screen, so its heights would never be reported again.
            measurements.removeAll()
        }
        spreadID = bookmark.spreadID
        anchor = bookmark.anchor
        returnedCard = nil
        isTextPanelOpen = false
        dismissToast()
        savePosition()
    }

    // MARK: Cards (tap-to-see, landmark, character)

    /// The card a marked word opens, or nil when it opens none (a name without a card).
    func cardContent(for ref: StoryCardRef) -> StoryCardContent? {
        story.cardContent(for: ref, landmarks: landmarks)
    }

    func canOpen(_ ref: StoryCardRef) -> Bool {
        cardContent(for: ref) != nil
    }

    var openCardContent: StoryCardContent? {
        openCard.flatMap { cardContent(for: $0.ref) }
    }

    /// The child tapped a marked word in `blockID`. Nothing on a card can call this: a card
    /// never opens another card.
    func open(_ ref: StoryCardRef, from blockID: BlockID) {
        guard openCard == nil, canOpen(ref) else { return }
        isTextPanelOpen = false
        dismissToast()
        returnedCard = nil
        openCard = OpenCard(ref: ref, blockID: blockID)
    }

    /// "Back to my line" or ✕.
    func closeCard() {
        guard let card = openCard else { return }
        openCard = nil
        returnedCard = card
        memory.markSeen(card.ref, in: story.id)
        show(.backAtLine)
    }

    func markState(for ref: StoryCardRef) -> MarkState {
        if openCard?.ref == ref {
            return .open
        }
        return memory.hasSeen(ref, in: story.id) ? .seen : .idle
    }

    // MARK: Toast

    private func show(_ toast: ReaderToast) {
        toastTask?.cancel()
        self.toast = toast
        toastTask = Task { [weak self] in
            // §3.7 motion.toast: stays about 1.6 s after appearing.
            try? await Task.sleep(for: .milliseconds(1900))
            guard !Task.isCancelled else { return }
            self?.toast = nil
        }
    }

    private func dismissToast() {
        toastTask?.cancel()
        toastTask = nil
        toast = nil
    }

    // MARK: Measurement

    /// A paragraph reported its height for a layout.
    func report(height: CGFloat, of block: BlockID, for key: TextMeasureKey) {
        guard key.spreadID == spreadID else { return }
        let rounded = (height * 2).rounded() / 2
        if measurements[key]?[block] == rounded {
            return
        }
        // Keep only the layout in use: an old window size or text size is never needed again.
        if measurements[key] == nil, !measurements.isEmpty {
            measurements.removeAll()
        }
        measurements[key, default: [:]][block] = rounded
    }
}

/// Identifies one way of setting a page's text: the page, the column width and the type size.
/// Paragraph heights are only comparable under the same key.
struct TextMeasureKey: Hashable {
    var spreadID: SpreadID
    /// Column width in half points.
    var columnWidth: Int
    var textSize: TextSizeStep
    /// Pane scale in thousandths.
    var paneScale: Int
    var posture: DisplayPosture

    init(spreadID: SpreadID, columnWidth: CGFloat, textSize: TextSizeStep, paneScale: CGFloat, posture: DisplayPosture) {
        self.spreadID = spreadID
        self.columnWidth = Int((columnWidth * 2).rounded())
        self.textSize = textSize
        self.paneScale = Int((paneScale * 1000).rounded())
        self.posture = posture
    }
}
