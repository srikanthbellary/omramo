import SwiftUI
import OmramoCore

// The reader's glass chrome (docs/DESIGN.md §5.1–5.7): crumb, "Aa" + bookmark capsule and its
// interim panel, footer chips, page chip, the back-one-page control, the round page-turn
// button and the toast. All sizes are DESIGN.md values scaled by the pane.

// MARK: - Crumb (§5.7)

/// Story title and part beside the back button.
struct StoryCrumb: View {
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

// MARK: - "Aa" + bookmark capsule (§5.2)

/// The bookmark glyph of the design (`I.bookmark`, 14 × 19), as a shape so it can be drawn
/// outlined or filled.
struct BookmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        // M2 3.2 C2 2.5 2.5 2 3.2 2 h7.6 c.7 0 1.2.5 1.2 1.2 V17 l-5-3.8 L2 17 Z in a 14 × 19 box.
        let sx = rect.width / 14
        let sy = rect.height / 19
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        var path = Path()
        path.move(to: point(2, 3.2))
        path.addCurve(to: point(3.2, 2), control1: point(2, 2.5), control2: point(2.5, 2))
        path.addLine(to: point(10.8, 2))
        path.addCurve(to: point(12, 3.2), control1: point(11.5, 2), control2: point(12, 2.5))
        path.addLine(to: point(12, 17))
        path.addLine(to: point(7, 13.2))
        path.addLine(to: point(2, 17))
        path.closeSubpath()
        return path
    }
}

/// Two controls in one glass capsule: "Aa" opens the text-size panel; the bookmark saves this
/// page (filled when the bookmark is here). Each has its own hit target of at least 44 pt.
struct TextControlsCapsule: View {
    @Environment(\.pane) private var pane
    let model: ReaderModel
    let chrome: ChromeStyle

    var body: some View {
        let content = Color(rgba: Tokens.Glass.style(chrome).content)
        let height = pane.pt(Tokens.Size.capsuleControlHeight)
        let minimum = CGFloat(Tokens.Size.minimumHitTarget)
        let bookmarked = model.isCurrentPageBookmarked
        // A card is open: the text must not re-wrap, so the size control waits.
        let locked = model.openCard != nil

        HStack(spacing: 0) {
            Button {
                model.toggleTextPanel()
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(verbatim: "A").typeRole(Tokens.UIType.aaControl)
                    Text(verbatim: "A").typeRole(Tokens.UIType.aaControlSmall)
                }
                .padding(.leading, pane.pt(15))
                .padding(.trailing, pane.pt(7))
                .frame(minWidth: minimum, minHeight: minimum)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressScaleButtonStyle())
            .frame(height: height)
            .accessibilityLabel(Text(verbatim: "Text size"))
            .accessibilityValue(Text(verbatim: model.textSize.displayName))
            .accessibilityHint(Text(verbatim: model.isTextPanelOpen ? "Closes the text size panel" : "Opens the text size panel"))

            Button {
                model.toggleBookmark()
            } label: {
                ZStack {
                    BookmarkShape()
                        .fill(content.opacity(bookmarked ? 1 : 0))
                    BookmarkShape()
                        .stroke(content, style: StrokeStyle(lineWidth: pane.pt(2), lineJoin: .round))
                }
                .frame(width: pane.pt(14), height: pane.pt(19))
                .padding(.leading, pane.pt(7))
                .padding(.trailing, pane.pt(15))
                .frame(minWidth: minimum, minHeight: minimum)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressScaleButtonStyle())
            .frame(height: height)
            .accessibilityLabel(Text(verbatim: bookmarked ? "Remove bookmark" : "Bookmark this page"))
            .accessibilityAddTraits(bookmarked ? .isSelected : [])
        }
        .foregroundStyle(content)
        .glass(chrome, in: Capsule(style: .continuous))
        .opacity(locked ? 0.5 : 1)
        .disabled(locked)
    }
}

/// The interim text-size panel (design gap G1): five steps, and the way back to a bookmark.
/// It is deliberately small and plain; a designed panel replaces it when G1 is answered.
struct TextSizePanel: View {
    @Environment(\.pane) private var pane
    let model: ReaderModel
    let chrome: ChromeStyle

    /// Sizes of the five sample letters, in reference points.
    private static let letterSizes: [Double] = [13, 16, 19, 22.5, 26]

    var body: some View {
        let content = Color(rgba: Tokens.Glass.style(chrome).content)
        let accent = Color(rgba: Tokens.Palette.violetStrong)
        let minimum = CGFloat(Tokens.Size.minimumHitTarget)
        let shape = RoundedRectangle(cornerRadius: pane.pt(22), style: .continuous)
        let darkFill = RGBA(red: 30.0 / 255, green: 20.0 / 255, blue: 70.0 / 255, alpha: 0.86)
        let panelFill: RGBA = chrome == .dark ? darkFill : RGBA(hex: 0xFFFFFF, alpha: 0.9)

        VStack(alignment: .leading, spacing: pane.pt(8)) {
            Text(verbatim: "Text size")
                .typeRole(Tokens.UIType.sectionLabel)
                .opacity(0.6)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: pane.pt(2)) {
                ForEach(TextSizeStep.allCases, id: \.self) { step in
                    let selected = step == model.textSize
                    Button {
                        model.setTextSize(step)
                    } label: {
                        Text(verbatim: "A")
                            .typeRole(Tokens.TypeRole(.reading, size: TextSizePanel.letterSizes[step.rawValue], weight: 700))
                            .foregroundStyle(selected ? Color.white : content)
                            .frame(width: max(minimum, pane.pt(44)), height: max(minimum, pane.pt(44)))
                            .background {
                                if selected {
                                    Circle().fill(accent).padding(pane.pt(3))
                                }
                            }
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PressScaleButtonStyle())
                    .accessibilityLabel(Text(verbatim: "Text size: \(step.displayName)"))
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }

            if let page = model.bookmarkPage, !model.isCurrentPageBookmarked {
                Rectangle()
                    .fill(content.opacity(0.14))
                    .frame(height: 0.5)
                Button {
                    model.goToBookmark()
                } label: {
                    HStack(spacing: pane.pt(9)) {
                        BookmarkShape()
                            .fill(content)
                            .frame(width: pane.pt(11), height: pane.pt(15))
                        Text(verbatim: "Go to my bookmark · page \(page)")
                            .typeRole(Tokens.UIType.chip.scaled(by: 13.0 / 12.0))
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: minimum)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressScaleButtonStyle())
                .accessibilityLabel(Text(verbatim: "Go to my bookmark on page \(page)"))
            }
        }
        .foregroundStyle(content)
        .padding(.horizontal, pane.pt(14))
        .padding(.top, pane.pt(14))
        .padding(.bottom, pane.pt(10))
        .glass(chrome, fill: panelFill, in: shape)
        .fixedSize()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(verbatim: "Text size panel"))
    }
}

// MARK: - Footer chips (§5.3)

/// Tier chip and origin chip in the footer of the text pane.
struct StoryChips: View {
    @Environment(\.pane) private var pane
    let story: Story
    var showsOrigin = true
    /// "7 / 14" beside the chips while a card covers the pane that holds the page chip (§6, 07).
    var pageText: String?
    var pageLabel: String?

    var body: some View {
        let ink = story.theme.chrome.leading == .dark ? Color.white : Color(rgba: Tokens.Palette.ink.opacity(0.86))
        let fill = RGBA(string: story.theme.chipGlass)
        let chrome = story.theme.chrome.leading
        let tierColor = Color(rgba: Tokens.TierColors.colors(for: story.tier).chipTextOnGlass)
        HStack(spacing: pane.pt(Tokens.Spacing.chipGap)) {
            GlassChip(chrome: chrome, fill: fill, foreground: tierColor) {
                TierGlyph(tier: story.tier, color: tierColor)
                Text(verbatim: story.tier.displayName)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: "Level: \(story.tier.displayName)"))

            if showsOrigin {
                GlassChip(chrome: chrome, fill: fill, foreground: ink) {
                    // The design source draws the reader's pin in coral on every story.
                    PinIcon(color: Color(rgba: Tokens.Palette.coral), width: 10)
                    Text(verbatim: story.region.label)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: "From \(story.region.label)"))
            }

            if let pageText {
                GlassChip(chrome: chrome, fill: fill, foreground: ink, leadingPadding: 12, trailingPadding: 12) {
                    Text(verbatim: pageText)
                        .typeRole(Tokens.UIType.footer)
                        .monospacedDigit()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: pageLabel ?? pageText))
            }
        }
    }
}

/// Page dashes and "1 / 14" (§5.3, §5.5). When a page continues over several screens, the
/// current dash fills up screen by screen; the page number does not change.
struct PageChip: View {
    @Environment(\.pane) private var pane
    let story: Story
    let page: Int
    let pageCount: Int
    /// 0-based screen of the page, and how many screens it has in this layout.
    var screen = 0
    var screenCount = 1
    /// Fewer dashes where the footer is narrow (folded).
    var maximumDashes = PageDashes.maximumDashes

    var body: some View {
        let chrome = story.theme.chrome.trailing
        let ink = chrome == .dark ? Color.white : Color(rgba: Tokens.Palette.ink.opacity(0.86))
        let accent = Color(rgba: Tokens.Palette.coral)
        let dashes = PageDashes(page: page, pageCount: pageCount, maximumDashes: maximumDashes)
        let progress = screenCount > 1 ? CGFloat(min(screen + 1, screenCount)) / CGFloat(screenCount) : 1
        GlassChip(
            chrome: chrome,
            fill: RGBA(string: story.theme.chipGlass),
            foreground: ink,
            leadingPadding: 12,
            trailingPadding: 12,
            spacing: 9
        ) {
            HStack(spacing: pane.pt(3)) {
                ForEach(Array(dashes.states.enumerated()), id: \.offset) { item in
                    dash(item.element, ink: ink, accent: accent, progress: progress)
                }
            }
            .accessibilityHidden(true)
            Text(verbatim: "\(page) / \(pageCount)")
                .typeRole(Tokens.UIType.footer)
                .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: PageChip.label(page: page, pageCount: pageCount, screen: screen, screenCount: screenCount)))
    }

    static func label(page: Int, pageCount: Int, screen: Int, screenCount: Int) -> String {
        if screenCount > 1 {
            return "Page \(page) of \(pageCount), part \(min(screen + 1, screenCount)) of \(screenCount)"
        }
        return "Page \(page) of \(pageCount)"
    }

    @ViewBuilder
    private func dash(_ state: PageDashes.State, ink: Color, accent: Color, progress: CGFloat) -> some View {
        let height = pane.pt(4)
        switch state {
        case .done:
            Capsule(style: .continuous).fill(ink.opacity(0.6)).frame(width: pane.pt(10), height: height)
        case .upcoming:
            Capsule(style: .continuous).fill(ink.opacity(0.22)).frame(width: pane.pt(10), height: height)
        case .current:
            let width = pane.pt(20)
            ZStack(alignment: .leading) {
                Capsule(style: .continuous).fill(accent.opacity(0.35))
                Capsule(style: .continuous).fill(accent).frame(width: max(height, width * progress))
            }
            .frame(width: width, height: height)
        }
    }
}

// MARK: - Page turning (§5.6)

/// The round button: the only way forward. A page turns only when the child presses it.
struct NextPageButton: View {
    let story: Story
    let page: Int
    let pageCount: Int
    /// True on the last screen of the last page.
    let isAtEnd: Bool
    /// True when the page has more screens to show before the next page.
    let hasMoreOfThisPage: Bool
    var diameter: Double = Tokens.Size.pageTurn
    /// False while a card is open: the page cannot be turned (criterion 3.5).
    var isEnabled = true
    let action: @MainActor () -> Void

    var body: some View {
        PageTurnButton(
            accent: story.theme.accent,
            diameter: diameter,
            // TODO(M6): the story-finished moment (design gap G3). For now the last page's
            // button shows a tick and returns to the library.
            icon: isAtEnd ? .check : .forward,
            label: isAtEnd ? "Finish the story" : (hasMoreOfThisPage ? "More of this page" : "Next page"),
            value: "Page \(page) of \(pageCount)",
            action: action
        )
        // Hardware keyboard: → turns the page (Mi).
        .keyboardShortcut(.rightArrow, modifiers: [])
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.4)
    }
}

/// Back one page: the interim control for design gap G3 — a small glass button with the
/// design's unused `prev` arrow, beside the page chip. Hidden on the very first screen.
struct PreviousPageButton: View {
    let chrome: ChromeStyle
    var fill: RGBA?
    var isEnabled = true
    let action: @MainActor () -> Void

    var body: some View {
        RoundGlassButton(
            icon: .previous,
            chrome: chrome,
            label: "Previous page",
            diameter: 34,
            fill: fill,
            action: action
        )
        // Hardware keyboard: ← goes back (Mi).
        .keyboardShortcut(.leftArrow, modifiers: [])
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.4)
    }
}

// MARK: - Toast (§5.8)

/// "You are back at your line": glass capsule, 38 pt high, with the orange return disc.
struct ReaderToastView: View {
    @Environment(\.pane) private var pane
    let toast: ReaderToast

    var body: some View {
        HStack(spacing: pane.pt(9)) {
            ZStack {
                Circle().fill(Color(rgba: Tokens.Palette.placeMarker))
                if toast == .backAtLine {
                    OmramoIcon(name: .returnArrow, multiplier: 12.0 / 18.0)
                        .foregroundStyle(Color.white)
                } else {
                    BookmarkShape()
                        .fill(Color.white)
                        .frame(width: pane.pt(8.5), height: pane.pt(11.5))
                }
            }
            .frame(width: pane.pt(22), height: pane.pt(22))
            Text(verbatim: toast.text)
                .typeRole(Tokens.UIType.toast)
                .foregroundStyle(Color(rgba: RGBA(hex: 0x13264A)))
                .lineLimit(1)
        }
        .padding(.leading, pane.pt(12))
        .padding(.trailing, pane.pt(16))
        .frame(height: pane.pt(38))
        .glass(.light, fill: RGBA(hex: 0xFFFFFF, alpha: 0.86), in: Capsule(style: .continuous))
        .fixedSize()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: toast.text))
    }
}
