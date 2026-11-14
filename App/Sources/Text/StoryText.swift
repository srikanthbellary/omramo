import SwiftUI
import UIKit
import OmramoCore

// Story text (docs/ARCHITECTURE.md §8.2, docs/DESIGN.md §4.2–4.3, §5.8).
//
// One `Text` per paragraph, built by joining a styled `Text` for each run. Tap-to-see words and
// character names carry a custom `TextAttribute`; `StoryTextRenderer` (a `TextRenderer`, iOS 18)
// draws the highlight band, underline, spark and dotted underline around them, in their idle,
// open and seen states.
//
// Marked words are tappable (M3): the paragraph reads the laid-out text back through
// `Text.LayoutKey` and lays an invisible button, at least 44 × 44 pt, over each marked word
// (`HitTargets` in the core shares the room between neighbouring words). Each button has the
// stable accessibility identifier `word.<cardID>` and is a real accessibility element, so
// VoiceOver, Switch Control and UI tests can reach it; the same words are also offered as
// custom actions on the paragraph. Words that are not marked have no gesture at all.
//
// Opening or closing a card never changes a font, a size or a width — only colours and what the
// renderer paints — so the text does not move or re-wrap (criterion 3.2).
//
// Switches, in case an API behaves differently on device (see docs/BUILD.md §8):
// - `usesTextRenderer = false`: marked words fall back to plain SwiftUI underlines.
// - `usesLayoutKey = false`: no per-word buttons; a tap anywhere on a paragraph opens its
//   first marked word (VoiceOver's custom actions are unaffected).

enum StoryTextStyle {
    /// Switch off to use the fallback (solid underline for tap words, dotted for names).
    static let usesTextRenderer = true
    /// Switch off if `Text.LayoutKey` does not report layouts as expected.
    static let usesLayoutKey = true
}

// MARK: - Attributes read by the renderer and by hit-testing

/// Marks a tap-to-see word. `emSize` is the word's font size in points.
struct TapWordAttribute: TextAttribute {
    var emSize: CGFloat
    var ref: StoryCardRef
    var state: MarkState
}

/// Marks a character's name. `ref` is nil when the character has no card (not tappable).
struct NameWordAttribute: TextAttribute {
    var emSize: CGFloat
    var color: Color
    var ref: StoryCardRef?
    var state: MarkState
}

// MARK: - What a paragraph can do

/// How a paragraph is shown while a card is open or has just been closed (§5.8).
enum ParagraphHold: Equatable {
    case none
    /// The paragraph holding the tapped word: full strength, beam and place marker.
    case held
    /// Another paragraph while a card is open: faded.
    case dimmed
    /// The paragraph the child came back to: faint wash, marker stays.
    case returned
}

/// Where VoiceOver focus should be.
enum ReaderFocus: Hashable {
    case cardTitle
    case block(BlockID)
}

/// The reader's hooks into the text. All optional, so the text can be shown inert.
struct StoryTextInteraction {
    var markState: @MainActor (StoryCardRef) -> MarkState = { _ in .idle }
    var canOpen: @MainActor (StoryCardRef) -> Bool = { _ in false }
    var actionName: @MainActor (StoryCardRef) -> String? = { _ in nil }
    /// The third value is the word's rectangle in window coordinates when the card is opened
    /// by a tap on the word (the card's opening motion starts there), else nil.
    var open: @MainActor (StoryCardRef, BlockID, CGRect?) -> Void = { _, _, _ in }
    var hold: @MainActor (BlockID) -> ParagraphHold = { _ in .none }
    /// The beam of a held paragraph brightens toward the pane's trailing edge (the card is on
    /// the trailing pane) or its leading edge.
    var beamTowardTrailingEdge = true
    /// Distance from the pane's leading edge to the text column, and the pane's width, so the
    /// beam and marker can reach beyond the column.
    var columnX: CGFloat = 0
    var paneWidth: CGFloat = 0
    var focus: AccessibilityFocusState<ReaderFocus?>.Binding?
    /// Set to measure paragraphs instead of showing them.
    var measure: (@MainActor (BlockID, CGFloat) -> Void)?
}

// MARK: - Building the text

/// Turns a story's runs into styled `Text`.
@MainActor
struct StoryTextBuilder {
    let story: Story
    /// Already scaled to the chosen text size.
    let typeScale: ReadingTypeScale
    /// The pane's scale from the reference pane.
    let scale: CGFloat
    var interaction = StoryTextInteraction()

    private var textColor: Color {
        Color(hex: story.theme.textColor, fallback: Tokens.Palette.readingTextDefault)
    }

    /// Colour of a sound word that nobody speaks: the story's own accent.
    private var popColor: Color {
        switch story.theme.accent {
        case .coral: return Color(rgba: RGBA(hex: 0xE8552B))
        case .amber: return Color(rgba: Tokens.Palette.sun)
        case .red: return Color(rgba: RGBA(hex: 0xF4503F))
        }
    }

    /// The role that sets a paragraph's line height: the lead role when the whole paragraph
    /// is a lead sentence, else the body role.
    func baseRole(for block: TextBlock) -> Tokens.TypeRole {
        let isLead = !block.runs.isEmpty && block.runs.allSatisfy(\.isLead)
        return isLead ? typeScale.lead : typeScale.body
    }

    func lineSpacing(for block: TextBlock) -> CGFloat {
        OmramoFont.lineSpacing(for: baseRole(for: block), scale: scale)
    }

    func text(for block: TextBlock) -> Text {
        var result = Text(verbatim: "")
        for run in block.runs {
            if run.showsFaceChip, let speaker = run.speaker, let character = story.character(id: speaker) {
                result = result + faceChip(for: character, beside: run)
            }
            result = result + segment(for: run)
        }
        return result
    }

    /// The card a run opens, if any.
    func cardRef(for run: TextRun) -> StoryCardRef? {
        let ref: StoryCardRef
        if let tap = run.tapTarget {
            ref = .tapTarget(tap)
        } else if let name = run.characterName {
            ref = .character(name)
        } else {
            return nil
        }
        return interaction.canOpen(ref) ? ref : nil
    }

    private func voiceColor(of id: CharacterID?) -> Color? {
        guard let id, let character = story.character(id: id) else { return nil }
        return Color(hex: character.color, fallback: Tokens.Palette.ink)
    }

    /// The font role of one run, before pane scaling.
    private func fontRole(for run: TextRun) -> Tokens.TypeRole {
        var role = run.isLead ? typeScale.lead : typeScale.body
        let marked = run.speaker != nil || run.tapTarget != nil || run.characterName != nil
        if marked {
            // Voices, tap words and names are wght 640 (a lead sentence is already heavier).
            role.weight = max(role.weight, ReadingTypeScale.emphasisWeight)
        }
        switch run.effect {
        case .pop:
            // Sound word: display face, larger, tighter.
            role = Tokens.TypeRole(
                .display,
                size: role.size * (run.scale ?? ReadingTypeScale.popDefaultScale),
                weight: ReadingTypeScale.popWeight,
                tracking: ReadingTypeScale.popTracking,
                opticalSize: ReadingTypeScale.popOpticalSize,
                width: ReadingTypeScale.popWidth
            )
        case .stretch:
            // Stretched word: italic, letter-spaced.
            role.italic = true
            role.weight = ReadingTypeScale.stretchWeight
            role.tracking = ReadingTypeScale.stretchTrackingEm * role.size
        case .none:
            break
        }
        return role
    }

    private func segment(for run: TextRun) -> Text {
        let role = fontRole(for: run)
        let emSize = CGFloat(role.size) * scale
        let ref = cardRef(for: run)
        let state: MarkState = ref.map { interaction.markState($0) } ?? .idle

        var color = textColor
        if let voice = voiceColor(of: run.speaker) {
            color = voice
        } else if run.effect == .pop {
            color = popColor
        }
        if state == .open, StoryTextStyle.usesTextRenderer {
            // On the solid sun highlight the word is always ink (§4.3 `tap.on`, `name.on`).
            color = Color(rgba: Tokens.Palette.ink)
        }

        var display = run.text
        if run.tapTarget != nil || run.characterName != nil {
            // No line break inside a marked word.
            display = display.replacingOccurrences(of: " ", with: "\u{00A0}")
        }
        if run.tapTarget != nil && StoryTextStyle.usesTextRenderer {
            // Room after the word for the spark, inside the highlight.
            display += "\u{00A0}\u{00A0}"
        }

        var text: Text = Text(verbatim: display)
            .font(OmramoFont.font(role, scale: scale))
            .tracking(CGFloat(role.tracking) * scale)
            .foregroundStyle(color)

        if let tap = run.tapTarget {
            if StoryTextStyle.usesTextRenderer {
                text = text.customAttribute(TapWordAttribute(emSize: emSize, ref: .tapTarget(tap), state: state))
            } else {
                text = text.underline(true, pattern: .solid, color: Color(hex: story.theme.tap.line))
            }
        }
        if run.characterName != nil {
            let nameColor = voiceColor(of: run.characterName) ?? color
            if StoryTextStyle.usesTextRenderer {
                text = text.customAttribute(NameWordAttribute(emSize: emSize, color: nameColor, ref: ref, state: state))
            } else {
                text = text.underline(true, pattern: .dot, color: nameColor)
            }
        }
        return text
    }

    /// The speaker's face, inline where a voice starts.
    private func faceChip(for character: StoryCharacter, beside run: TextRun) -> Text {
        // The chip is sized from the body text even beside a larger sound word.
        let base = run.isLead ? typeScale.lead : typeScale.body
        let emSize = CGFloat(base.size) * scale
        let image = FaceChipRenderer.image(for: character, storyID: story.id, em: emSize)
        return Text(Image(uiImage: image))
            .baselineOffset(emSize * CGFloat(ReadingTypeScale.faceChipBaselineEm))
    }
}

// MARK: - Drawing the marks

/// Draws story text with the tap-word highlight, underline and spark, and the dotted
/// underline of names. Marked words are never signalled by colour alone.
struct StoryTextRenderer: TextRenderer {
    var tapFill: Color
    var tapFill2: Color
    var tapLine: Color
    var tapSpark: Color
    /// The pane's scale, for stroke widths.
    var scale: CGFloat

    /// §4.3: the open word is solid sun; a seen word is quieter with an amber line and spark.
    private static let openFill = Color(rgba: Tokens.Palette.sun)
    private static let openRing = Color(rgba: Tokens.Palette.sun.opacity(0.35))
    private static let openGlow = Color(rgba: RGBA(hex: 0xFF961E, alpha: 0.35))
    private static let seenLine = Color(rgba: RGBA(hex: 0xFFB020))
    /// Seen fill is .28 where idle is .5.
    private static let seenFade = 0.56

    /// The highlight and the open word's glow reach a little outside the text's own bounds.
    var displayPadding: EdgeInsets {
        EdgeInsets(top: 10, leading: 10, bottom: 14, trailing: 10)
    }

    private struct Mark<Attribute> {
        var rect: CGRect
        var baseline: CGFloat
        var attribute: Attribute
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for line in layout {
            // A marked word may be laid out as more than one run; join neighbours on a line.
            var taps: [Mark<TapWordAttribute>] = []
            var names: [Mark<NameWordAttribute>] = []
            var openTap: Mark<TapWordAttribute>?
            var openName: Mark<NameWordAttribute>?

            for run in line {
                let bounds = run.typographicBounds
                if let attribute = run[TapWordAttribute.self] {
                    if var mark = openTap, mark.attribute.ref == attribute.ref {
                        mark.rect = mark.rect.union(bounds.rect)
                        openTap = mark
                    } else {
                        if let mark = openTap { taps.append(mark) }
                        openTap = Mark(rect: bounds.rect, baseline: bounds.origin.y, attribute: attribute)
                    }
                } else if let mark = openTap {
                    taps.append(mark)
                    openTap = nil
                }
                if let attribute = run[NameWordAttribute.self] {
                    if var mark = openName, mark.attribute.ref == attribute.ref {
                        mark.rect = mark.rect.union(bounds.rect)
                        openName = mark
                    } else {
                        if let mark = openName { names.append(mark) }
                        openName = Mark(rect: bounds.rect, baseline: bounds.origin.y, attribute: attribute)
                    }
                } else if let mark = openName {
                    names.append(mark)
                    openName = nil
                }
            }
            if let mark = openTap { taps.append(mark) }
            if let mark = openName { names.append(mark) }

            for mark in taps {
                drawTapHighlight(mark, in: &context)
            }
            for mark in names where mark.attribute.state == .open {
                drawOpenName(mark, in: &context)
            }
            for run in line {
                context.draw(run)
            }
            for mark in taps {
                drawSpark(mark, in: &context)
            }
            for mark in names where mark.attribute.state != .open {
                drawNameUnderline(mark, in: &context)
            }
        }
    }

    /// The band behind a tap word: from 8% to 92% of the line box, 0.12 em beyond the word.
    private func bandRect(for rect: CGRect, em: CGFloat) -> CGRect {
        let overhang = em * 0.12
        return CGRect(
            x: rect.minX - overhang,
            y: rect.minY + rect.height * CGFloat(ReadingTypeScale.tapBandTop),
            width: rect.width + overhang,
            height: rect.height * CGFloat(ReadingTypeScale.tapBandBottom - ReadingTypeScale.tapBandTop)
        )
    }

    /// Solid sun plate with its ring and glow (§3.6 `tapOn`).
    private func drawOpenPlate(_ shape: Path, in context: inout GraphicsContext) {
        let glow = StoryTextRenderer.openGlow
        let fill = StoryTextRenderer.openFill
        var shadowed = context
        shadowed.addFilter(.shadow(color: glow, radius: 8 * scale, x: 0, y: 6 * scale))
        shadowed.drawLayer { layer in
            layer.fill(shape, with: .color(fill))
        }
        context.stroke(shape, with: .color(StoryTextRenderer.openRing), lineWidth: 6 * scale)
        context.fill(shape, with: .color(fill))
    }

    /// Rounded band with a 2 pt underline along its bottom; solid when open, quieter when seen.
    private func drawTapHighlight(_ mark: Mark<TapWordAttribute>, in context: inout GraphicsContext) {
        let em = mark.attribute.emSize
        let band = bandRect(for: mark.rect, em: em)
        let shape = Path(roundedRect: band, cornerRadius: em * CGFloat(Tokens.Radius.tapHighlightEm), style: .continuous)

        if mark.attribute.state == .open {
            drawOpenPlate(shape, in: &context)
            return
        }
        let fade = mark.attribute.state == .seen ? StoryTextRenderer.seenFade : 1
        context.fill(
            shape,
            with: .linearGradient(
                Gradient(colors: [tapFill.opacity(fade), tapFill2.opacity(fade)]),
                startPoint: CGPoint(x: band.midX, y: band.minY),
                endPoint: CGPoint(x: band.midX, y: band.maxY)
            )
        )
        let underline = CGFloat(ReadingTypeScale.tapUnderline) * scale
        let line = mark.attribute.state == .seen ? StoryTextRenderer.seenLine : tapLine
        context.drawLayer { layer in
            layer.clip(to: shape)
            layer.fill(
                Path(CGRect(x: band.minX, y: band.maxY - underline, width: band.width, height: underline)),
                with: .color(line)
            )
        }
    }

    /// Four-point spark, 0.5 em, raised 0.5 em above the baseline, after the word.
    private func drawSpark(_ mark: Mark<TapWordAttribute>, in context: inout GraphicsContext) {
        let em = mark.attribute.emSize
        let size = em * CGFloat(ReadingTypeScale.tapSparkEm)
        let box = CGRect(
            x: mark.rect.maxX - size - em * 0.06,
            y: mark.baseline - em * CGFloat(ReadingTypeScale.tapSparkRaiseEm) - size,
            width: size,
            height: size
        )
        // polygon(50% 0, 62% 38%, 100% 50%, 62% 62%, 50% 100%, 38% 62%, 0 50%, 38% 38%)
        let points: [(CGFloat, CGFloat)] = [
            (0.50, 0.00), (0.62, 0.38), (1.00, 0.50), (0.62, 0.62),
            (0.50, 1.00), (0.38, 0.62), (0.00, 0.50), (0.38, 0.38),
        ]
        var star = Path()
        for (index, point) in points.enumerated() {
            let position = CGPoint(x: box.minX + box.width * point.0, y: box.minY + box.height * point.1)
            if index == 0 {
                star.move(to: position)
            } else {
                star.addLine(to: position)
            }
        }
        star.closeSubpath()
        let color: Color
        switch mark.attribute.state {
        case .idle: color = tapSpark
        case .seen: color = StoryTextRenderer.seenLine
        case .open: color = Color(rgba: RGBA(hex: 0xF4503F))
        }
        context.fill(star, with: .color(color))
    }

    /// The open name: solid sun plate, padding 0.2 em, no underline (§4.3 `name.on`).
    private func drawOpenName(_ mark: Mark<NameWordAttribute>, in context: inout GraphicsContext) {
        let em = mark.attribute.emSize
        let pad = em * 0.2
        let plate = CGRect(
            x: mark.rect.minX - pad,
            y: mark.rect.minY + mark.rect.height * CGFloat(ReadingTypeScale.tapBandTop),
            width: mark.rect.width + pad * 2,
            height: mark.rect.height * CGFloat(ReadingTypeScale.tapBandBottom - ReadingTypeScale.tapBandTop)
        )
        let shape = Path(roundedRect: plate, cornerRadius: em * CGFloat(Tokens.Radius.tapHighlightEm), style: .continuous)
        drawOpenPlate(shape, in: &context)
    }

    /// Dotted underline, 2 pt, 0.2 em below the baseline, in the character's colour.
    private func drawNameUnderline(_ mark: Mark<NameWordAttribute>, in context: inout GraphicsContext) {
        let em = mark.attribute.emSize
        let thickness = CGFloat(ReadingTypeScale.nameUnderline) * scale
        let y = mark.baseline + em * CGFloat(ReadingTypeScale.nameUnderlineOffsetEm)
        var path = Path()
        path.move(to: CGPoint(x: mark.rect.minX + thickness / 2, y: y))
        path.addLine(to: CGPoint(x: mark.rect.maxX - thickness / 2, y: y))
        context.stroke(
            path,
            with: .color(mark.attribute.color),
            style: StrokeStyle(lineWidth: thickness, lineCap: .round, dash: [0.01, thickness * 2.2])
        )
    }
}

// MARK: - Hit targets for marked words

private struct MarkRegion: Identifiable {
    let id: Int
    let ref: StoryCardRef
    let rect: CGRect
}

@MainActor
private enum MarkRegions {
    /// The rectangle of every tappable marked word, in the coordinate space of `proxy`.
    static func find(in layouts: [Text.LayoutKey.AnchoredLayout], proxy: GeometryProxy) -> [MarkRegion] {
        var regions: [MarkRegion] = []
        for anchored in layouts {
            let origin = proxy[anchored.origin]
            for line in anchored.layout {
                var current: (ref: StoryCardRef, rect: CGRect)?
                for run in line {
                    let tapRef: StoryCardRef? = run[TapWordAttribute.self]?.ref
                    let nameRef: StoryCardRef? = run[NameWordAttribute.self]?.ref
                    let rect = run.typographicBounds.rect
                    if let ref = tapRef ?? nameRef {
                        if let open = current, open.ref == ref {
                            current = (ref: ref, rect: open.rect.union(rect))
                        } else {
                            if let open = current {
                                regions.append(MarkRegion(id: regions.count, ref: open.ref, rect: open.rect.offsetBy(dx: origin.x, dy: origin.y)))
                            }
                            current = (ref: ref, rect: rect)
                        }
                    } else if let open = current {
                        regions.append(MarkRegion(id: regions.count, ref: open.ref, rect: open.rect.offsetBy(dx: origin.x, dy: origin.y)))
                        current = nil
                    }
                }
                if let open = current {
                    regions.append(MarkRegion(id: regions.count, ref: open.ref, rect: open.rect.offsetBy(dx: origin.x, dy: origin.y)))
                }
            }
        }
        return regions
    }
}

/// Invisible buttons over the marked words of one paragraph, each at least 44 × 44 pt (§7).
/// Neighbouring words share the room between them (`HitTargets.resolve`), so a tap always
/// opens the nearer word. Each button is `word.<cardID>` for assistive technology and tests.
private struct MarkButtons: View {
    let layouts: [Text.LayoutKey.AnchoredLayout]
    /// The paragraph's cards, in reading order: the fallback when no layout is reported.
    let refs: [StoryCardRef]
    let canOpen: @MainActor (StoryCardRef) -> Bool
    let actionName: @MainActor (StoryCardRef) -> String?
    /// The card to open and the word's rectangle in window coordinates.
    let open: @MainActor (StoryCardRef, CGRect?) -> Void

    var body: some View {
        GeometryReader { proxy in
            let regions = MarkRegions.find(in: layouts, proxy: proxy).filter { canOpen($0.ref) }
            let areas = HitTargets.resolve(
                regions.map { LayoutRect(x: Double($0.rect.minX), y: Double($0.rect.minY), width: Double($0.rect.width), height: Double($0.rect.height)) },
                minimum: Tokens.Size.minimumHitTarget
            )
            let window = proxy.frame(in: .global).origin
            if regions.isEmpty, let first = refs.first {
                // The text layout was not reported (see `usesLayoutKey`): the whole paragraph
                // opens its first marked word, so a marked word is never dead.
                wordButton(first, word: nil)
                    .frame(width: proxy.size.width, height: proxy.size.height)
            } else {
                // `areas` has one entry for each region, in the same order.
                ForEach(Array(regions.enumerated()), id: \.offset) { item in
                    let area = areas[item.offset]
                    let word = item.element.rect.offsetBy(dx: window.x, dy: window.y)
                    wordButton(item.element.ref, word: word)
                        .frame(width: CGFloat(area.width), height: CGFloat(area.height))
                        .position(x: CGFloat(area.x + area.width / 2), y: CGFloat(area.y + area.height / 2))
                }
            }
        }
    }

    private func wordButton(_ ref: StoryCardRef, word: CGRect?) -> some View {
        Button {
            open(ref, word)
        } label: {
            Color.clear.contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: actionName(ref) ?? "Show more"))
        .accessibilityIdentifier(ref.wordIdentifier)
    }
}

// MARK: - Hold state behind a paragraph (§5.8)

/// The beam (while a card is open) or the wash (after coming back), and the place marker.
private struct HoldBand: View {
    @Environment(\.pane) private var pane
    let hold: ParagraphHold
    let towardTrailingEdge: Bool
    let columnX: CGFloat
    let paneWidth: CGFloat

    var body: some View {
        let sun = Tokens.Palette.sun
        let stops: [Gradient.Stop]
        if hold == .held {
            // linear-gradient(90deg, sun 0%, sun 20% at 60%, sun 50%)
            stops = [
                .init(color: Color(rgba: sun.opacity(0)), location: 0),
                .init(color: Color(rgba: sun.opacity(0.2)), location: 0.6),
                .init(color: Color(rgba: sun.opacity(0.5)), location: 1),
            ]
        } else {
            // linear-gradient(90deg, sun 22%, sun 6% at 70%, sun 0%)
            stops = [
                .init(color: Color(rgba: sun.opacity(0.22)), location: 0),
                .init(color: Color(rgba: sun.opacity(0.06)), location: 0.7),
                .init(color: Color(rgba: sun.opacity(0)), location: 1),
            ]
        }
        // The open beam points at the card; the wash is always weighted to the marker's side.
        let flipped = hold == .held && !towardTrailingEdge
        let marker = Color(rgba: Tokens.Palette.placeMarker)
        return LinearGradient(
            gradient: Gradient(stops: stops),
            startPoint: flipped ? .trailing : .leading,
            endPoint: flipped ? .leading : .trailing
        )
        .padding(.vertical, -pane.pt(8))
        .overlay(alignment: .leading) {
            // The "keeper": 5 pt wide at x 12, with a soft halo.
            Capsule(style: .continuous)
                .fill(marker)
                .frame(width: pane.pt(5))
                .padding(.vertical, pane.pt(2))
                .background {
                    Capsule(style: .continuous)
                        .fill(marker.opacity(0.18))
                        .padding(-pane.pt(4))
                }
                .padding(.leading, pane.pt(12))
        }
        .frame(width: max(0, paneWidth))
        .offset(x: -columnX)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Text on a path (§4.3)

/// A `pathText` block: the words set letter by letter along the authored curve, with a dotted
/// echo line beneath (screen 05). The design box is 400 × 96 and overhangs the text column by
/// 12 pt on the leading side, as designed.
struct PathTextView: View {
    @Environment(\.pane) private var pane
    let story: Story
    let block: TextBlock
    /// The chosen text-size factor.
    let textScale: Double

    /// Bricolage 33 pt, wght 720, opsz 40, wdth 92, tracking +0.5.
    private static let role = Tokens.TypeRole(.display, size: 33, weight: 720, tracking: 0.5, opticalSize: 40, width: 92)
    private static let gradientStart = RGBA(hex: 0x1B4C93)
    private static let gradientEnd = RGBA(hex: 0x2F8FCB)
    private static let echo = RGBA(hex: 0x7FB9DB)
    /// The echo line runs 16 pt below the letters' curve.
    private static let echoDrop = 16.0

    var body: some View {
        let width = pane.pt(SVGPath.boxWidth)
        let height = pane.pt(SVGPath.boxHeight)
        let sampler = block.path.flatMap { SVGPath(string: $0) }.map { PathSampler(path: $0) }
        let string = block.plainText
        let dark = story.theme.chrome.leading == .dark
        // On a dark scene the designed blue would not read: use the story's text colour.
        let ink = RGBA(string: story.theme.textColor) ?? Tokens.Palette.readingTextDefault
        let start = dark ? ink : PathTextView.gradientStart
        let end = dark ? ink : PathTextView.gradientEnd
        let echo = dark ? ink.opacity(0.5) : PathTextView.echo
        let scale = pane.scale
        // Larger text sizes make the call larger too, as far as the curve has room.
        let wanted = min(textScale, 1.15)

        Canvas { context, size in
            guard let sampler, sampler.length > 0 else { return }
            let unit = size.width / CGFloat(SVGPath.boxWidth)

            // Dotted echo line.
            var echoPath = Path()
            let steps = 60
            for step in 0...steps {
                let sample = sampler.sample(at: sampler.length * Double(step) / Double(steps))
                let point = CGPoint(x: CGFloat(sample.x) * unit, y: CGFloat(sample.y + PathTextView.echoDrop) * unit)
                if step == 0 {
                    echoPath.move(to: point)
                } else {
                    echoPath.addLine(to: point)
                }
            }
            context.stroke(
                echoPath,
                with: .color(Color(rgba: echo.opacity(0.9))),
                style: StrokeStyle(lineWidth: 1.5 * unit, lineCap: .round, dash: [1 * unit, 7 * unit])
            )

            // Measure the letters, then shrink them if the words are longer than the curve.
            let characters = Array(string)
            guard !characters.isEmpty else { return }
            let available = CGFloat(sampler.length) * unit * 0.97
            var factor = CGFloat(wanted)
            var resolved: [GraphicsContext.ResolvedText] = []
            var widths: [CGFloat] = []
            var tracking: CGFloat = 0
            for _ in 0..<2 {
                let role = PathTextView.role.scaled(by: Double(factor))
                let font = OmramoFont.font(role, scale: scale)
                tracking = CGFloat(role.tracking) * scale
                resolved = []
                widths = []
                for (index, character) in characters.enumerated() {
                    let progress = characters.count > 1 ? Double(index) / Double(characters.count - 1) : 0
                    let color = RGBA(
                        red: start.red + (end.red - start.red) * progress,
                        green: start.green + (end.green - start.green) * progress,
                        blue: start.blue + (end.blue - start.blue) * progress
                    )
                    let text = context.resolve(
                        Text(verbatim: String(character)).font(font).foregroundStyle(Color(rgba: color))
                    )
                    resolved.append(text)
                    widths.append(text.measure(in: CGSize(width: 2000, height: 2000)).width)
                }
                var lettersWidth: CGFloat = 0
                for letterWidth in widths {
                    lettersWidth += letterWidth
                }
                let gaps = CGFloat(max(0, characters.count - 1))
                let total = lettersWidth + tracking * gaps
                if total <= available || total <= 0 {
                    break
                }
                factor *= available / total
            }

            // Set each letter at its own point of the curve, turned to the curve's direction.
            var distance = CGFloat(sampler.length) * unit * 0.01
            for (index, text) in resolved.enumerated() {
                let letterWidth = widths[index]
                let sample = sampler.sample(at: Double((distance + letterWidth / 2) / unit))
                let box = CGSize(width: 2000, height: 2000)
                let baseline = text.firstBaseline(in: box)
                var letter = context
                letter.translateBy(x: CGFloat(sample.x) * unit, y: CGFloat(sample.y) * unit)
                letter.rotate(by: Angle(radians: sample.angle))
                letter.draw(text, at: CGPoint(x: -letterWidth / 2, y: -baseline), anchor: .topLeading)
                distance += letterWidth + tracking
            }
        }
        .frame(width: width, height: height)
        .offset(x: -pane.pt(12))
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: string))
    }
}

// MARK: - One paragraph

private struct StoryParagraph: View {
    @Environment(\.pane) private var pane
    let block: TextBlock
    let builder: StoryTextBuilder
    let renderer: StoryTextRenderer
    let textScale: Double

    var body: some View {
        let interaction = builder.interaction
        let blockID = block.id.fragmentParent
        let hold = interaction.hold(blockID)
        let refs = openableRefs
        let open: @MainActor (StoryCardRef, CGRect?) -> Void = { ref, rect in
            interaction.open(ref, blockID, rect)
        }

        content(open: open, refs: refs, blockID: blockID)
            // Dimming is opacity only: nothing moves (45% on Low, 42% elsewhere).
            .opacity(hold == .dimmed ? (builder.story.tier == .low ? 0.45 : 0.42) : 1)
            .background(alignment: .leading) {
                if hold == .held || hold == .returned {
                    HoldBand(
                        hold: hold,
                        towardTrailingEdge: interaction.beamTowardTrailingEdge,
                        columnX: interaction.columnX,
                        paneWidth: interaction.paneWidth
                    )
                }
            }
            .modifier(MeasureModifier(blockID: block.id, measure: interaction.measure))
    }

    /// Cards this paragraph's marked words can open, in reading order, each once.
    private var openableRefs: [StoryCardRef] {
        block.cardRefs.filter { builder.interaction.canOpen($0) }
    }

    /// One accessibility element per paragraph, labelled with the plain text. Marked words
    /// are custom actions ("Show picture: Rin Gin", "About: The Monkey"); the word buttons
    /// laid over the text afterwards are separate elements (`word.<cardID>`).
    private func readable<V: View>(
        _ view: V,
        open: @escaping @MainActor (StoryCardRef, CGRect?) -> Void,
        refs: [StoryCardRef],
        blockID: BlockID
    ) -> some View {
        let interaction = builder.interaction
        return view
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: block.plainText))
            .accessibilityActions {
                ForEach(Array(refs.enumerated()), id: \.offset) { item in
                    Button(interaction.actionName(item.element) ?? "Show more") {
                        open(item.element, nil)
                    }
                }
            }
            .modifier(ReaderFocusModifier(binding: interaction.focus, value: .block(blockID)))
    }

    @ViewBuilder
    private func content(
        open: @escaping @MainActor (StoryCardRef, CGRect?) -> Void,
        refs: [StoryCardRef],
        blockID: BlockID
    ) -> some View {
        if block.kind == .pathText {
            readable(
                PathTextView(story: builder.story, block: block, textScale: textScale),
                open: open,
                refs: refs,
                blockID: blockID
            )
        } else {
            let lineSpacing = builder.lineSpacing(for: block)
            let text = builder.text(for: block)
                .lineSpacing(lineSpacing)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            Group {
                if StoryTextStyle.usesTextRenderer && StoryTextStyle.usesLayoutKey && builder.interaction.measure == nil {
                    readable(text.textRenderer(renderer), open: open, refs: refs, blockID: blockID)
                        .overlayPreferenceValue(Text.LayoutKey.self) { layouts in
                            if !refs.isEmpty {
                                MarkButtons(
                                    layouts: layouts,
                                    refs: refs,
                                    canOpen: builder.interaction.canOpen,
                                    actionName: builder.interaction.actionName,
                                    open: open
                                )
                            }
                        }
                } else if StoryTextStyle.usesTextRenderer {
                    readable(text.textRenderer(renderer), open: open, refs: refs, blockID: blockID)
                        .modifier(ParagraphTapFallback(ref: builder.interaction.measure == nil ? refs.first : nil, open: open))
                } else {
                    readable(text, open: open, refs: refs, blockID: blockID)
                        .modifier(ParagraphTapFallback(ref: builder.interaction.measure == nil ? refs.first : nil, open: open))
                }
            }
            // Half the extra leading goes above the first line, as in a CSS line box, so the
            // designed "top of text" positions hold.
            .padding(.top, lineSpacing / 2)
            .padding(.bottom, -lineSpacing / 2)
        }
    }
}

/// Fallback when per-word buttons are switched off: the whole paragraph opens its first mark.
private struct ParagraphTapFallback: ViewModifier {
    let ref: StoryCardRef?
    let open: @MainActor (StoryCardRef, CGRect?) -> Void

    func body(content: Content) -> some View {
        if let ref, !StoryTextStyle.usesLayoutKey || !StoryTextStyle.usesTextRenderer {
            content
                .contentShape(Rectangle())
                .onTapGesture { open(ref, nil) }
                .accessibilityIdentifier(ref.wordIdentifier)
        } else {
            content
        }
    }
}

private struct ReaderFocusModifier: ViewModifier {
    let binding: AccessibilityFocusState<ReaderFocus?>.Binding?
    let value: ReaderFocus

    func body(content: Content) -> some View {
        if let binding {
            content.accessibilityFocused(binding, equals: value)
        } else {
            content
        }
    }
}

/// Reports the paragraph's height when the column is being measured.
private struct MeasureModifier: ViewModifier {
    let blockID: BlockID
    let measure: (@MainActor (BlockID, CGFloat) -> Void)?

    func body(content: Content) -> some View {
        if let measure {
            content.onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                measure(blockID, height)
            }
        } else {
            content
        }
    }
}

// MARK: - The text column

/// The paragraphs of one column, at the tier's type scale and the chosen text size.
struct StoryTextView: View {
    @Environment(\.pane) private var pane
    let story: Story
    let blocks: [TextBlock]
    /// Already scaled to the chosen text size.
    let typeScale: ReadingTypeScale
    /// The chosen text-size factor (for text on a path).
    var textScale: Double = 1
    var interaction = StoryTextInteraction()

    var body: some View {
        let builder = StoryTextBuilder(story: story, typeScale: typeScale, scale: pane.scale, interaction: interaction)
        let renderer = StoryTextRenderer(
            tapFill: Color(hex: story.theme.tap.fill, fallback: Tokens.Palette.sun.opacity(0.5)),
            tapFill2: Color(hex: story.theme.tap.fill2, fallback: Tokens.Palette.sun.opacity(0.38)),
            tapLine: Color(hex: story.theme.tap.line, fallback: Tokens.Palette.sun),
            tapSpark: Color(hex: story.theme.tap.spark, fallback: Tokens.Palette.sun),
            scale: pane.scale
        )
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(blocks.enumerated()), id: \.element.id) { item in
                StoryParagraph(block: item.element, builder: builder, renderer: renderer, textScale: textScale)
                    .padding(.top, topGap(before: item.offset))
            }
        }
    }

    /// The paragraph gap; none above the first paragraph.
    private func topGap(before index: Int) -> CGFloat {
        guard index > 0 else { return 0 }
        return pane.pt(typeScale.paragraphGap)
    }
}
