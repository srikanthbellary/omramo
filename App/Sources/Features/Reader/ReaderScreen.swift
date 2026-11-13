import SwiftUI
import OmramoCore

/// Reading (docs/DESIGN.md §6, screens 03 and 10). M1 implements the Low tier: one continuous
/// scene under both panes and the hinge, text on the leading pane, glass chrome, and the round
/// page-turn button as the only way forward.
///
/// Not in M1 (stubs are marked TODO): tap-to-see and character cards (M3), the "Aa" text-size
/// control and bookmark (M2), continuation screens for overflow (M2), going back a page (M2),
/// the sample gate and paywall (M5), page-turn motion (M6).
struct ReaderScreen: View {
    private let story: Story
    private let progress: ReadingProgressStore
    private let router: AppRouter
    /// Created once, when the screen appears (not in `init`, which runs on every parent update).
    @State private var model: ReaderModel?

    init(story: Story, progress: ReadingProgressStore, router: AppRouter) {
        self.story = story
        self.progress = progress
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
                let created = ReaderModel(story: story, progress: progress)
                created.didOpen()
                model = created
            }
        }
    }
}

/// The reader once its model exists.
private struct ReaderContent: View {
    @Environment(\.paneLayout) private var layout
    let model: ReaderModel
    let router: AppRouter

    var body: some View {
        if let spread = model.spread {
            let chrome = spread.chrome ?? model.story.theme.chrome
            TwoPane {
                backdrop(for: spread)
            } leading: {
                ReaderLeadingPane(model: model, spread: spread, chrome: chrome.leading, onBack: close)
            } trailing: {
                ReaderTrailingPane(model: model, spread: spread, chrome: chrome.trailing, onNext: next)
            } folded: {
                ReaderFoldedPane(model: model, spread: spread, chrome: chrome.folded, onBack: close, onNext: next)
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
                fallbackColors: spread.scene.fallbackColors
            )
        } else {
            // Folded: a calm pale ground for the text; the picture is placed by the pane.
            let colors = spread.scene.fallbackColors.map { Color(hex: $0, fallback: Tokens.Palette.cloud) }
            LinearGradient(
                colors: [colors.first ?? Color(rgba: Tokens.Palette.cloud), Color.white, colors.dropFirst().first ?? Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.9)
            .background(Color.white)
        }
    }

    private func close() {
        router.showLibrary()
    }

    private func next() {
        if model.isLastPage {
            model.finish()
            router.showLibrary()
        } else {
            model.turnPage()
        }
    }
}

// MARK: - Chrome pieces

/// Story title and part beside the back button (§5.7).
private struct StoryCrumb: View {
    @Environment(\.pane) private var pane
    let title: String
    let subtitle: String
    let chrome: ChromeStyle

    var body: some View {
        let color = chrome == .dark ? Color.white : Color(rgba: Tokens.Palette.ink.opacity(0.9))
        VStack(alignment: .leading, spacing: pane.pt(3)) {
            Text(verbatim: title)
                .typeRole(Tokens.UIType.crumbTitle)
                .lineLimit(1)
                .truncationMode(.tail)
            if !subtitle.isEmpty {
                Text(verbatim: subtitle)
                    .typeRole(Tokens.UIType.crumbSubtitle)
                    .opacity(0.66)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(color)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

/// "Aa" + bookmark capsule (§5.2). Drawn to match the design, but not interactive yet.
/// TODO(M2): text-size steps (design gap G1) and the bookmark; two ≥ 44 pt hit targets.
private struct TextControlsCapsule: View {
    @Environment(\.pane) private var pane
    let chrome: ChromeStyle

    var body: some View {
        HStack(spacing: pane.pt(14)) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(verbatim: "A").typeRole(Tokens.UIType.aaControl)
                Text(verbatim: "A").typeRole(Tokens.UIType.aaControlSmall)
            }
            OmramoIcon(name: .bookmark)
        }
        .foregroundStyle(Color(rgba: Tokens.Glass.style(chrome).content))
        .padding(.horizontal, pane.pt(15))
        .frame(height: pane.pt(Tokens.Size.capsuleControlHeight))
        .glass(chrome, in: Capsule(style: .continuous))
        .accessibilityHidden(true)
    }
}

/// Page dashes and "1 / 14" (§5.3).
private struct PageChip: View {
    let model: ReaderModel

    var body: some View {
        let story = model.story
        let ink = Color(hex: story.theme.textColor, fallback: Tokens.Palette.ink)
        GlassChip(
            chrome: .light,
            fill: RGBA(string: story.theme.chipGlass),
            foreground: ink,
            leadingPadding: 12,
            trailingPadding: 12,
            spacing: 9
        ) {
            PageDashesView(
                dashes: PageDashes(page: model.pageNumber, pageCount: model.pageCount),
                color: ink,
                accent: Color(rgba: Tokens.Palette.coral)
            )
            Text(verbatim: "\(model.pageNumber) / \(model.pageCount)")
                .typeRole(Tokens.UIType.footer)
                .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Page \(model.pageNumber) of \(model.pageCount)"))
    }
}

/// Tier chip and origin chip in the footer of the text pane (§5.3).
private struct StoryChips: View {
    @Environment(\.pane) private var pane
    let story: Story
    var showsOrigin = true

    var body: some View {
        let ink = Color(hex: story.theme.textColor, fallback: Tokens.Palette.ink)
        let fill = RGBA(string: story.theme.chipGlass)
        let tierColor = Color(rgba: Tokens.TierColors.colors(for: story.tier).chipTextOnGlass)
        HStack(spacing: pane.pt(Tokens.Spacing.chipGap)) {
            GlassChip(chrome: .light, fill: fill, foreground: tierColor) {
                TierGlyph(tier: story.tier, color: tierColor)
                Text(verbatim: story.tier.displayName)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: "Level: \(story.tier.displayName)"))

            if showsOrigin {
                GlassChip(chrome: .light, fill: fill, foreground: ink) {
                    // The design source draws the reader's pin in coral on every story.
                    PinIcon(color: Color(rgba: Tokens.Palette.coral), width: 10)
                    Text(verbatim: story.region.label)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: "From \(story.region.label)"))
            }
        }
    }
}

private struct NextPageButton: View {
    let model: ReaderModel
    var diameter: Double = Tokens.Size.pageTurn
    let action: @MainActor () -> Void

    var body: some View {
        PageTurnButton(
            accent: model.story.theme.accent,
            diameter: diameter,
            // TODO(M6): the story-finished moment (design gap G3). For now the last page's
            // button shows a tick and returns to the library.
            icon: model.isLastPage ? .check : .forward,
            label: model.isLastPage ? "Finish the story" : "Next page",
            value: "Page \(model.pageNumber) of \(model.pageCount)",
            action: action
        )
    }
}

// MARK: - Unfolded: leading pane (text)

private struct ReaderLeadingPane: View {
    @Environment(\.pane) private var pane
    let model: ReaderModel
    let spread: Spread
    let chrome: ChromeStyle
    let onBack: @MainActor () -> Void

    var body: some View {
        let story = model.story
        let typeScale = story.tier.readingScale(posture: .unfolded)
        // Gap between the back button and the first line: 106 − 50 − 40 on the reference pane.
        let textGap = typeScale.textTop - Tokens.Spacing.topControl - Tokens.Size.roundGlassButton
        // Keep the column clear of the hinge edge.
        let column = min(
            pane.pt(typeScale.column),
            pane.size.width - pane.pt(Tokens.Spacing.insetText) - pane.pt(Tokens.Spacing.hingeClearance)
        )
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: pane.pt(10)) {
                RoundGlassButton(icon: .back, chrome: chrome, label: "Back to the library", action: onBack)
                StoryCrumb(title: story.title, subtitle: model.partTitle, chrome: chrome)
                    .padding(.top, pane.pt(Tokens.Spacing.crumbTop - Tokens.Spacing.topControl))
                Spacer(minLength: 0)
            }
            .padding(.leading, pane.pt(Tokens.Spacing.insetControl))
            .padding(.trailing, pane.pt(Tokens.Spacing.crumbRight))

            StoryTextView(story: story, blocks: spread.blocks.filter { $0.pane == .leading }, typeScale: typeScale)
                .frame(width: max(0, column), alignment: .leading)
                .padding(.leading, pane.pt(Tokens.Spacing.insetText))
                .padding(.top, pane.pt(textGap))

            Spacer(minLength: 0)
        }
        .padding(.top, pane.controlTop())
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .overlay(alignment: .bottomLeading) {
            StoryChips(story: story)
                .padding(.leading, pane.pt(Tokens.Spacing.insetFoot))
                // Chips are 28 pt high, centred in the 34 pt footer row that sits 26 pt up.
                .padding(.bottom, pane.bottomInset(Tokens.Spacing.footBottom + 3))
        }
    }
}

// MARK: - Unfolded: trailing pane (picture, page controls)

private struct ReaderTrailingPane: View {
    @Environment(\.pane) private var pane
    let model: ReaderModel
    let spread: Spread
    let chrome: ChromeStyle
    let onNext: @MainActor () -> Void

    var body: some View {
        let story = model.story
        let typeScale = story.tier.readingScale(posture: .unfolded)
        let trailingBlocks = spread.blocks.filter { $0.pane == .trailing }
        ZStack(alignment: .topLeading) {
            Color.clear
            if !trailingBlocks.isEmpty {
                // Advanced-tier spreads put text on both panes (M2 polishes this layout).
                StoryTextView(story: story, blocks: trailingBlocks, typeScale: typeScale)
                    .frame(width: pane.pt(typeScale.column), alignment: .leading)
                    .padding(.leading, pane.pt(Tokens.Spacing.insetText))
                    .padding(.top, pane.controlTop() + pane.pt(typeScale.textTop - Tokens.Spacing.topControl))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .overlay(alignment: .topTrailing) {
            TextControlsCapsule(chrome: chrome)
                .padding(.trailing, pane.pt(Tokens.Spacing.insetControl))
                .padding(.top, pane.controlTop())
        }
        .overlay(alignment: .bottomLeading) {
            PageChip(model: model)
                .padding(.leading, pane.pt(Tokens.Spacing.insetFoot))
                .padding(.bottom, pane.bottomInset(Tokens.Spacing.footBottom + 3))
        }
        .overlay(alignment: .bottomTrailing) {
            NextPageButton(model: model, action: onNext)
                .padding(.trailing, pane.pt(Tokens.Spacing.pageTurnInset))
                .padding(.bottom, pane.bottomInset(Tokens.Spacing.pageTurnInset))
        }
    }
}

// MARK: - Folded: one pane

/// M1's simple single-pane reading layout: picture on top, text below (screen 10 without its
/// polish, which lands in M2).
///
/// INTERIM: the text area scrolls if a page does not fit. The design turns pages only with
/// the round button and never scrolls; M2 replaces this with continuation screens
/// (docs/ARCHITECTURE.md §8.3). The origin chip and crumb are omitted when folded, as designed.
private struct ReaderFoldedPane: View {
    @Environment(\.pane) private var pane
    let model: ReaderModel
    let spread: Spread
    let chrome: ChromeStyle
    let onBack: @MainActor () -> Void
    let onNext: @MainActor () -> Void

    var body: some View {
        let story = model.story
        let typeScale = story.tier.readingScale(posture: .folded)
        // The picture fills the top of the pane, to about y 340 on the reference pane.
        let pictureHeight = pane.pt(340)
        let column = min(pane.pt(typeScale.column), pane.size.width - pane.pt(Tokens.Spacing.insetText) - pane.pt(26))
        let footerClearance = pane.bottomInset(Tokens.Spacing.pageTurnInsetFolded) + pane.pt(Tokens.Size.pageTurnFolded) + pane.pt(12)

        VStack(spacing: 0) {
            SceneArtView(
                storyID: story.id,
                art: spread.scene.folded,
                fallbackColors: spread.scene.fallbackColors,
                // The part of the wide placeholder scene with the tree, the Monkey and the water.
                viewport: CGRect(x: 380, y: 190, width: 432, height: 340)
            )
            .frame(width: pane.size.width, height: pictureHeight)
            .clipped()
            .overlay(alignment: .bottom) {
                // Soft edge into the text area (the design uses a wave edge; M2).
                LinearGradient(colors: [Color.white.opacity(0), Color.white.opacity(0.92)], startPoint: .top, endPoint: .bottom)
                    .frame(height: pane.pt(44))
                    .accessibilityHidden(true)
            }

            ScrollView(.vertical) {
                StoryTextView(story: story, blocks: spread.blocks, typeScale: typeScale)
                    .frame(width: max(0, column), alignment: .leading)
                    .padding(.leading, pane.pt(Tokens.Spacing.insetText))
                    .padding(.top, pane.pt(typeScale.textTop - 340))
                    .padding(.bottom, footerClearance)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
            // A new page starts at its top.
            .id(spread.id)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .topLeading) {
            RoundGlassButton(icon: .back, chrome: chrome, label: "Back to the library", action: onBack)
                .padding(.leading, pane.pt(Tokens.Spacing.insetControlFolded))
                .padding(.top, pane.controlTop(folded: true))
        }
        .overlay(alignment: .topTrailing) {
            TextControlsCapsule(chrome: chrome)
                .padding(.trailing, pane.pt(Tokens.Spacing.insetControlFolded))
                .padding(.top, pane.controlTop(folded: true))
        }
        .overlay(alignment: .bottomLeading) {
            StoryChips(story: story, showsOrigin: false)
                .padding(.leading, pane.pt(Tokens.Spacing.insetFoot))
                .padding(.bottom, pane.bottomInset(Tokens.Spacing.footBottom + 3))
        }
        .overlay(alignment: .bottomTrailing) {
            // The page chip ends 92 pt from the right edge, clear of the page-turn button.
            PageChip(model: model)
                .padding(.trailing, pane.pt(92))
                .padding(.bottom, pane.bottomInset(Tokens.Spacing.footBottom + 3))
        }
        .overlay(alignment: .bottomTrailing) {
            NextPageButton(model: model, diameter: Tokens.Size.pageTurnFolded, action: onNext)
                .padding(.trailing, pane.pt(Tokens.Spacing.pageTurnInsetFolded))
                .padding(.bottom, pane.bottomInset(Tokens.Spacing.pageTurnInsetFolded))
        }
    }
}
