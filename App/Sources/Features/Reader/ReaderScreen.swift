import Foundation
import SwiftUI
import OmramoCore

/// Reading (docs/DESIGN.md §6, screens 03–07 and 10).
///
/// One continuous scene under both panes and the hinge; story text in the calm part of it;
/// glass chrome; the round page-turn button as the only way forward, and a small back control.
/// The same code lays out the Duo, an iPhone (one pane), an iPad and any Split View or Stage
/// Manager window: everything comes from `PaneLayout` (docs/ARCHITECTURE.md §5).
///
/// - M2: text size ("Aa"), bookmark, back one page, continuation screens for text that does
///   not fit, folded reading, all three tiers with their own light.
/// - M3: marked words open a tap-to-see, landmark or character card on the facing pane (a
///   bottom card when folded); the text pane holds the place and never re-wraps.
/// - Still stubbed: the sample gate and paywall (M5), the reading log (M4), page-turn motion
///   beyond a cross-fade and the story-finished moment (M6).
struct ReaderScreen: View {
    private let story: Story
    private let landmarks: LandmarkCatalog
    private let progress: ReadingProgressStore
    private let memory: ReaderMemoryStore
    private let router: AppRouter
    /// Created once, when the screen appears (not in `init`, which runs on every parent update).
    @State private var model: ReaderModel?

    init(story: Story, landmarks: LandmarkCatalog, progress: ReadingProgressStore, memory: ReaderMemoryStore, router: AppRouter) {
        self.story = story
        self.landmarks = landmarks
        self.progress = progress
        self.memory = memory
        self.router = router
    }

    var body: some View {
        Group {
            if let model {
                ReaderContent(model: model, router: router)
            } else {
                Color.black
            }
        }
        .onAppear {
            if model == nil {
                let created = ReaderModel(story: story, progress: progress, memory: memory, landmarks: landmarks)
                created.didOpen()
                model = created
            }
        }
    }
}

// MARK: - One render of the reader

/// What changed on screen, for "the reader is now looking at this".
private struct ShownScreen: Equatable {
    /// The page and the way it is set (window size, text size): a new layout can bring other
    /// paragraphs onto the same screen number.
    var key: TextMeasureKey
    var screen: Int
    var isReady: Bool
    var cardOpen: Bool
}

/// Everything the panes need for the page as it is laid out right now. Derived afresh on every
/// render from the model (what is being read) and the window (how it fits); it holds no state.
@MainActor
private struct ReaderPage {
    let model: ReaderModel
    let router: AppRouter
    let spread: Spread
    let metrics: ReaderMetrics
    let layout: ReaderPageLayout
    let reduceMotion: Bool

    var story: Story { model.story }
    var plan: ScreenPlan? { layout.plan }
    /// False for the instant between a change of page or layout and its text being measured.
    var isReady: Bool { layout.plan != nil }
    var chrome: ChromeTheme { spread.chrome ?? model.story.theme.chrome }

    /// The screen of the page to show. While a card is open it is the screen holding the
    /// tapped word, wherever a change of layout has moved that paragraph.
    var screenIndex: Int {
        guard let plan = layout.plan else { return 0 }
        let current = plan.index(for: model.anchor)
        if let card = model.openCard {
            // Stay on the screen being read when it shows the paragraph (or the sentence group
            // of it) that holds the word: a paragraph continued over two screens must not jump
            // back to its first screen when a card opens (criterion 3.2).
            if plan.pane(of: card.blockID, onScreen: current) != nil {
                return current
            }
            return plan.index(for: .block(card.blockID))
        }
        return current
    }

    var screenCount: Int { layout.plan?.screenCount ?? 1 }
    var hasMoreOfThisPage: Bool { screenIndex + 1 < screenCount }
    var isAtEnd: Bool { model.isAtEnd(screen: screenIndex, screenCount: screenCount) }
    var isAtStart: Bool { model.isAtStart(screen: screenIndex) }
    var isCardOpen: Bool { model.openCard != nil }

    func blocks(in pane: TextBlock.Pane) -> [TextBlock] {
        layout.blocks(in: pane, onScreen: screenIndex)
    }

    /// The pane a paragraph is shown on now.
    func pane(showing blockID: BlockID) -> TextBlock.Pane {
        layout.plan?.pane(of: blockID, onScreen: screenIndex) ?? .leading
    }

    /// Where the open card goes: the pane facing the tapped word, or the bottom when folded.
    var placement: CardPlacement? {
        model.openCard.map { card in
            CardPlacement.resolve(posture: metrics.posture, wordPane: pane(showing: card.blockID))
        }
    }

    var cardContent: StoryCardContent? { model.openCardContent }

    /// The pane the toast appears on: the one the card was on (§5.8), else the trailing pane.
    var toastPane: TextBlock.Pane {
        if let returned = model.returnedCard, model.toast == .backAtLine {
            return pane(showing: returned.blockID).opposite
        }
        return .trailing
    }

    var shown: ShownScreen {
        ShownScreen(key: layout.key, screen: screenIndex, isReady: isReady, cardOpen: isCardOpen)
    }

    func reportShown() {
        if let plan = layout.plan {
            model.didShow(screen: screenIndex, of: plan)
        }
    }

    // Actions

    func close() {
        router.showLibrary()
    }

    func next() {
        // Not while a card is open, and not in the instant before the page is laid out.
        guard !isCardOpen, isReady else { return }
        if isAtEnd {
            model.finish()
            router.showLibrary()
        } else {
            model.turnPage(in: layout.plan)
        }
    }

    func back() {
        guard !isCardOpen, isReady else { return }
        model.goBack(in: layout.plan)
    }

    func closeCard() {
        model.closeCard()
    }

    // Text hooks

    func interaction(for pane: TextBlock.Pane, focus: AccessibilityFocusState<ReaderFocus?>.Binding) -> StoryTextInteraction {
        let model = self.model
        return StoryTextInteraction(
            markState: { ref in model.markState(for: ref) },
            canOpen: { ref in model.canOpen(ref) },
            actionName: { ref in model.cardContent(for: ref)?.actionName },
            open: { ref, blockID in model.open(ref, from: blockID) },
            hold: { blockID in
                if let card = model.openCard {
                    return card.blockID == blockID ? .held : .dimmed
                }
                if let returned = model.returnedCard, returned.blockID == blockID {
                    return .returned
                }
                return .none
            },
            // The beam points at the card: toward the hinge side of the pane.
            beamTowardTrailingEdge: pane == .leading,
            columnX: metrics.columnX,
            paneWidth: metrics.paneSize.width,
            focus: focus,
            measure: nil
        )
    }
}

/// The reader once its model exists.
private struct ReaderContent: View {
    @Environment(\.paneLayout) private var layout
    @Environment(\.windowSafeArea) private var safeArea
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var focus: ReaderFocus?
    let model: ReaderModel
    let router: AppRouter

    var body: some View {
        if let spread = model.spread {
            let metrics = ReaderMetrics(
                layout: layout,
                safeArea: safeArea,
                story: model.story,
                spread: spread,
                textSize: model.textSize
            )
            let page = ReaderPage(
                model: model,
                router: router,
                spread: spread,
                metrics: metrics,
                layout: ReaderPageLayout(spread: spread, metrics: metrics, measurements: model.measurements),
                reduceMotion: reduceMotion
            )
            let sceneName = spread.scene.unfolded.assetName
            TwoPane {
                backdrop(for: spread)
            } leading: {
                ReaderLeadingPane(page: page, focus: $focus)
            } trailing: {
                ReaderTrailingPane(page: page, focus: $focus)
            } folded: {
                ReaderFoldedPane(page: page, focus: $focus)
            }
            .background {
                ReaderKeyCommands(page: page)
            }
            // §3.7: scenes cross-fade; cards and the hold state ease in. Opacity only, so
            // Reduce Motion needs no separate path here.
            .animation(.easeInOut(duration: reduceMotion ? 0.2 : 0.35), value: sceneName)
            .animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.35, dampingFraction: 0.85), value: model.openCard)
            .animation(.easeOut(duration: 0.2), value: model.toast)
            .animation(.easeOut(duration: 0.18), value: model.isTextPanelOpen)
            .onChange(of: page.shown, initial: true) { _, _ in
                page.reportShown()
            }
            .onChange(of: model.openCard) { old, new in
                // VoiceOver: into the card when it opens, back to the paragraph when it closes.
                // The request waits a moment, until the card (or the paragraph, no longer behind
                // a modal card) is in the accessibility tree.
                let target: ReaderFocus
                if new != nil {
                    target = ReaderFocus.cardTitle
                } else if let old {
                    target = ReaderFocus.block(old.blockID)
                } else {
                    return
                }
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(300))
                    if (model.openCard != nil) == (new != nil) {
                        focus = target
                    }
                }
            }
            .onChange(of: model.toast) { _, toast in
                if let toast {
                    AccessibilityNotification.Announcement(toast.text).post()
                }
            }
            .onAppear {
                // The first time only, start from the system's text size (ARCHITECTURE §12.1).
                let index = DynamicTypeSize.allCases.firstIndex(of: dynamicTypeSize) ?? 3
                model.adoptSystemTextSize(index: index)
            }
        } else {
            // A story with no pages cannot be shown; the validator refuses such content.
            Color.black.onAppear { router.showLibrary() }
        }
    }

    @ViewBuilder
    private func backdrop(for spread: Spread) -> some View {
        if layout.posture == .unfolded {
            // One scene across both panes and under the hinge.
            SceneArtView(
                storyID: model.story.id,
                art: spread.scene.unfolded,
                role: .sceneUnfolded,
                fallbackColors: spread.scene.fallbackColors
            )
            .id(spread.scene.unfolded.assetName)
            .transition(.opacity)
        } else {
            // Folded: a calm ground for the text in the story's own light; the picture band
            // is placed by the pane.
            FoldedGround(spread: spread, chrome: (spread.chrome ?? model.story.theme.chrome).folded)
        }
    }
}

/// Hardware keyboard (Mi): space turns the page, like the round button. The arrow keys belong
/// to the page-turn and back buttons themselves, and Escape / Return to an open card's buttons.
private struct ReaderKeyCommands: View {
    let page: ReaderPage

    var body: some View {
        Button {
            page.next()
        } label: {
            Text(verbatim: "Next page")
        }
        .keyboardShortcut(.space, modifiers: [])
        .opacity(0)
        .frame(width: 0, height: 0)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Text column and its measurer

/// One column of story text on a pane, at the place the design gives it.
private struct ReaderColumn: View {
    @Environment(\.pane) private var pane
    let page: ReaderPage
    let column: TextBlock.Pane
    let focus: AccessibilityFocusState<ReaderFocus?>.Binding

    var body: some View {
        let metrics = page.metrics
        let blocks = page.blocks(in: column)
        // Screen 05: a text-on-a-path block starts 22 pt above the ordinary top of text.
        let startsWithPath = blocks.first?.kind == .pathText
        let top = metrics.textTop - (startsWithPath ? pane.pt(22) : 0)
        let ready = page.isReady
        let text = StoryTextView(
            story: page.story,
            blocks: blocks,
            typeScale: metrics.typeScale,
            textScale: metrics.textSize.scale,
            interaction: page.interaction(for: column, focus: focus)
        )
        .frame(width: metrics.columnWidth, alignment: .leading)

        Group {
            if page.layout.needsScrolling(in: column, onScreen: page.screenIndex) {
                // A single sentence taller than the whole column (the largest text in the
                // smallest window): let this one column scroll rather than clip a word.
                ScrollView(.vertical) {
                    text.padding(.bottom, pane.pt(12))
                }
                .frame(width: metrics.columnWidth, height: metrics.capacity(of: column), alignment: .top)
            } else {
                text
            }
        }
        .padding(.leading, metrics.columnX)
        .padding(.top, top)
        .opacity(ready ? 1 : 0)
        // New text fades in once it is laid out; it never fades out over the next page.
        .animation(ready ? .easeOut(duration: 0.22) : nil, value: ready)
    }
}

/// Measures the page's paragraphs, hidden, at the column width in use, and tells the model.
/// The screens of the page are planned from these heights (`ReaderPageLayout`).
private struct ReaderMeasurer: View {
    let page: ReaderPage

    var body: some View {
        let key = page.layout.key
        let model = page.model
        StoryTextView(
            story: page.story,
            blocks: page.layout.blocksToMeasure,
            typeScale: page.metrics.typeScale,
            textScale: page.metrics.textSize.scale,
            interaction: StoryTextInteraction(measure: { blockID, height in
                model.report(height: height, of: blockID, for: key)
            })
        )
        .frame(width: page.metrics.columnWidth, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .hidden()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        // A new layout measures afresh, even when a paragraph's height happens not to change.
        .id(key)
    }
}

// MARK: - Shared chrome rows

/// The back-one-page control and the page chip, in the 34 pt footer row.
private struct ReaderPageRow: View {
    @Environment(\.pane) private var pane
    let page: ReaderPage
    let chrome: ChromeStyle
    var maximumDashes = PageDashes.maximumDashes

    var body: some View {
        HStack(spacing: pane.pt(8)) {
            if !page.isAtStart {
                PreviousPageButton(
                    chrome: chrome,
                    fill: RGBA(string: page.story.theme.chipGlass),
                    isEnabled: !page.isCardOpen,
                    action: { page.back() }
                )
            }
            PageChip(
                story: page.story,
                page: page.model.pageNumber,
                pageCount: page.model.pageCount,
                screen: page.screenIndex,
                screenCount: page.screenCount,
                maximumDashes: maximumDashes
            )
        }
        .frame(height: pane.pt(Tokens.Spacing.footHeight))
    }
}

/// "Aa" + bookmark, with the interim text-size panel hanging beneath it.
private struct ReaderTextControls: View {
    @Environment(\.pane) private var pane
    let page: ReaderPage
    let chrome: ChromeStyle

    var body: some View {
        VStack(alignment: .trailing, spacing: pane.pt(10)) {
            TextControlsCapsule(model: page.model, chrome: chrome)
            if page.model.isTextPanelOpen {
                TextSizePanel(model: page.model, chrome: chrome)
                    .transition(.opacity)
            }
        }
    }
}

/// While the text-size panel is open, a tap anywhere else on the pane closes it.
private struct PanelDismissLayer: View {
    let model: ReaderModel

    var body: some View {
        if model.isTextPanelOpen {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { model.isTextPanelOpen = false }
                .accessibilityHidden(true)
        }
    }
}

private struct ReaderNextButton: View {
    let page: ReaderPage
    var diameter: Double = Tokens.Size.pageTurn

    var body: some View {
        NextPageButton(
            story: page.story,
            page: page.model.pageNumber,
            pageCount: page.model.pageCount,
            isAtEnd: page.isAtEnd,
            hasMoreOfThisPage: page.hasMoreOfThisPage,
            diameter: diameter,
            isEnabled: !page.isCardOpen,
            action: { page.next() }
        )
    }
}

// MARK: - Unfolded: leading pane

private struct ReaderLeadingPane: View {
    @Environment(\.pane) private var pane
    let page: ReaderPage
    let focus: AccessibilityFocusState<ReaderFocus?>.Binding

    var body: some View {
        let story = page.story
        let chrome = page.chrome.leading
        let covered = page.placement?.covers(.leading) ?? false
        let trailingCovered = page.placement?.covers(.trailing) ?? false
        let model = page.model

        ZStack(alignment: .topLeading) {
            Color.clear
            ReaderColumn(page: page, column: .leading, focus: focus)

            HStack(alignment: .top, spacing: pane.pt(10)) {
                RoundGlassButton(icon: .back, chrome: chrome, label: "Back to the library", action: { page.close() })
                StoryCrumb(title: story.title, subtitle: model.crumbSubtitle, chrome: chrome)
                    .padding(.top, pane.pt(Tokens.Spacing.crumbTop - Tokens.Spacing.topControl))
                Spacer(minLength: 0)
            }
            .padding(.leading, pane.pt(Tokens.Spacing.insetControl))
            .padding(.trailing, pane.pt(Tokens.Spacing.crumbRight))
            .padding(.top, page.metrics.controlTop)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(alignment: .topLeading) {
            ReaderMeasurer(page: page)
        }
        .overlay(alignment: .bottomLeading) {
            // While a card covers the trailing pane, the page number moves here (screen 07).
            StoryChips(
                story: story,
                pageText: trailingCovered ? "\(model.pageNumber) / \(model.pageCount)" : nil,
                pageLabel: "Page \(model.pageNumber) of \(model.pageCount)"
            )
            .padding(.leading, pane.pt(Tokens.Spacing.insetFoot))
            // Chips are 28 pt high, centred in the 34 pt footer row that sits 26 pt up.
            .padding(.bottom, pane.bottomInset(Tokens.Spacing.footBottom + 3))
        }
        .overlay(alignment: .top) {
            if let toast = model.toast, page.toastPane == .leading, !covered {
                ReaderToastView(toast: toast)
                    .padding(.top, pane.controlTop() + pane.pt(54))
                    .transition(.opacity)
            }
        }
        .overlay {
            if covered, let content = page.cardContent {
                OpenCardView(content: content, storyID: story.id, focus: focus, onClose: { page.closeCard() })
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - Unfolded: trailing pane

private struct ReaderTrailingPane: View {
    @Environment(\.pane) private var pane
    let page: ReaderPage
    let focus: AccessibilityFocusState<ReaderFocus?>.Binding

    var body: some View {
        let story = page.story
        let chrome = page.chrome.trailing
        let covered = page.placement?.covers(.trailing) ?? false
        let model = page.model

        ZStack(alignment: .topLeading) {
            Color.clear
            if page.layout.twoColumns {
                // Advanced-tier pages put text on both panes.
                ReaderColumn(page: page, column: .trailing, focus: focus)
            }
            PanelDismissLayer(model: model)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .overlay(alignment: .topTrailing) {
            ReaderTextControls(page: page, chrome: chrome)
                .padding(.trailing, pane.pt(Tokens.Spacing.insetControl))
                .padding(.top, page.metrics.controlTop)
        }
        .overlay(alignment: .bottomLeading) {
            ReaderPageRow(page: page, chrome: chrome)
                .padding(.leading, pane.pt(Tokens.Spacing.insetFoot))
                .padding(.bottom, pane.bottomInset(Tokens.Spacing.footBottom))
        }
        .overlay(alignment: .bottomTrailing) {
            ReaderNextButton(page: page)
                .padding(.trailing, pane.pt(Tokens.Spacing.pageTurnInset))
                .padding(.bottom, pane.bottomInset(Tokens.Spacing.pageTurnInset))
        }
        .overlay(alignment: .top) {
            if let toast = model.toast, page.toastPane == .trailing, !covered {
                // Top 104 on the reference pane, centred (§5.8).
                ReaderToastView(toast: toast)
                    .padding(.top, pane.controlTop() + pane.pt(54))
                    .transition(.opacity)
            }
        }
        .overlay {
            // The card covers the "Aa" capsule, the page chip and the round button: the page
            // cannot be turned while a card is open.
            if covered, let content = page.cardContent {
                OpenCardView(content: content, storyID: story.id, focus: focus, onClose: { page.closeCard() })
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - Folded: one pane (screen 10)

/// The calm ground under the folded text, in the story's own light: pale for a light-chrome
/// story, deep for a dark one.
private struct FoldedGround: View {
    let spread: Spread
    let chrome: ChromeStyle

    var body: some View {
        let first = spread.scene.fallbackColors.first.flatMap { RGBA(string: $0) }
        let base = first ?? (chrome == .dark ? Tokens.Palette.night : Tokens.Palette.cloud)
        let top: RGBA
        let bottom: RGBA
        if chrome == .dark {
            top = base
            bottom = FoldedGround.mix(base, RGBA(hex: 0x000000), 0.18)
        } else {
            // Mostly white, tinted by the scene (screen 10's pale mint under the river).
            top = FoldedGround.mix(base, RGBA(hex: 0xFFFFFF), 0.62)
            bottom = FoldedGround.mix(base, RGBA(hex: 0xFFFFFF), 0.8)
        }
        return LinearGradient(colors: [Color(rgba: top), Color(rgba: bottom)], startPoint: .top, endPoint: .bottom)
            .accessibilityHidden(true)
    }

    static func mix(_ a: RGBA, _ b: RGBA, _ amount: Double) -> RGBA {
        RGBA(
            red: a.red + (b.red - a.red) * amount,
            green: a.green + (b.green - a.green) * amount,
            blue: a.blue + (b.blue - a.blue) * amount,
            alpha: 1
        )
    }
}

/// The crest line of the folded picture's wave edge.
private struct WaveCrest: Shape {
    var amplitude: CGFloat
    var waves: CGFloat = 2.5
    var phase: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let base = rect.maxY - amplitude
        let steps = 48
        for step in 0...steps {
            let t = CGFloat(step) / CGFloat(steps)
            let x = rect.maxX - rect.width * t
            let angle = (t * waves + phase) * 2 * CGFloat.pi
            let point = CGPoint(x: x, y: base + amplitude * 0.5 * (1 + sin(angle)))
            if step == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }
}

/// The picture at the top of the folded pane, ending in a wave edge over the text ground.
private struct FoldedPictureBand: View {
    @Environment(\.pane) private var pane
    let storyID: StoryID
    let spread: Spread
    let height: CGFloat
    let chrome: ChromeStyle

    var body: some View {
        let amplitude = pane.pt(10)
        SceneArtView(
            storyID: storyID,
            art: spread.scene.folded,
            role: .sceneFolded,
            fallbackColors: spread.scene.fallbackColors
        )
        .frame(width: pane.size.width, height: height)
        .clipShape(WaveEdge(amplitude: amplitude, waves: 2.5, phase: 0.1))
        .overlay {
            // A soft foam line along the edge.
            WaveCrest(amplitude: amplitude, waves: 2.5, phase: 0.1)
                .stroke(Color.white.opacity(chrome == .dark ? 0.22 : 0.6), style: StrokeStyle(lineWidth: pane.pt(3), lineCap: .round))
                .accessibilityHidden(true)
        }
        .id(spread.scene.folded.assetName)
        .transition(.opacity)
    }
}

private struct ReaderFoldedPane: View {
    @Environment(\.pane) private var pane
    let page: ReaderPage
    let focus: AccessibilityFocusState<ReaderFocus?>.Binding

    var body: some View {
        let story = page.story
        let metrics = page.metrics
        let chrome = page.chrome.folded
        let model = page.model
        let controlLeading = pane.pt(Tokens.Spacing.insetControlFolded)
        // The sheet leaves the top controls and a strip of the scene in view.
        let sheetTop = metrics.controlTop + pane.pt(Tokens.Size.roundGlassButton) + pane.pt(14)

        ZStack(alignment: .topLeading) {
            Color.clear
            FoldedPictureBand(storyID: story.id, spread: page.spread, height: metrics.pictureHeight, chrome: chrome)
            // The origin chip and the crumb are omitted when folded, as designed.
            ReaderColumn(page: page, column: .leading, focus: focus)
            PanelDismissLayer(model: model)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(alignment: .topLeading) {
            ReaderMeasurer(page: page)
        }
        .overlay(alignment: .topLeading) {
            RoundGlassButton(icon: .back, chrome: chrome, label: "Back to the library", action: { page.close() })
                .padding(.leading, controlLeading)
                .padding(.top, metrics.controlTop)
        }
        .overlay(alignment: .topTrailing) {
            ReaderTextControls(page: page, chrome: chrome)
                .padding(.trailing, controlLeading)
                .padding(.top, metrics.controlTop)
        }
        .overlay(alignment: .bottomLeading) {
            StoryChips(story: story, showsOrigin: false)
                .padding(.leading, pane.pt(Tokens.Spacing.insetFoot))
                .padding(.bottom, pane.bottomInset(Tokens.Spacing.footBottom + 3))
        }
        .overlay(alignment: .bottomTrailing) {
            // The page chip ends 92 pt from the right edge, clear of the page-turn button.
            // Seven dashes, as drawn on screen 10, leave room for the back control.
            ReaderPageRow(page: page, chrome: chrome, maximumDashes: 7)
                .padding(.trailing, pane.pt(92))
                .padding(.bottom, pane.bottomInset(Tokens.Spacing.footBottom))
        }
        .overlay(alignment: .bottomTrailing) {
            ReaderNextButton(page: page, diameter: Tokens.Size.pageTurnFolded)
                .padding(.trailing, pane.pt(Tokens.Spacing.pageTurnInsetFolded))
                .padding(.bottom, pane.bottomInset(Tokens.Spacing.pageTurnInsetFolded))
        }
        .overlay(alignment: .top) {
            if let toast = model.toast, !page.isCardOpen {
                ReaderToastView(toast: toast)
                    .padding(.top, sheetTop)
                    .transition(.opacity)
            }
        }
        .overlay {
            if page.placement == .bottomSheet, let content = page.cardContent {
                CardSheet(content: content, storyID: story.id, topGap: sheetTop, focus: focus, onClose: { page.closeCard() })
                    .transition(page.reduceMotion ? AnyTransition.opacity : AnyTransition.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}
