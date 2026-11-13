import SwiftUI
import UIKit
import OmramoCore

// Story text (docs/ARCHITECTURE.md §8.2, docs/DESIGN.md §4.2–4.3).
//
// One `Text` per paragraph, built by joining a styled `Text` for each run. Tap-to-see words
// and character names carry a custom `TextAttribute`; `StoryTextRenderer` (a `TextRenderer`,
// iOS 18) draws the highlight band, underline, spark and dotted underline around them.
//
// M1: the marks are drawn but are not interactive. TODO(M3): report each marked run's
// rectangle upward and overlay ≥ 44 pt buttons that open the tap-to-see / character card.
//
// UNVERIFIED (nothing was compiled on the dev box): that `TextRenderer` gives per-run
// rectangles as used here. If it does not, set `StoryTextStyle.usesTextRenderer` to false:
// marked words then fall back to plain SwiftUI underlines. See docs/BUILD.md.

enum StoryTextStyle {
    /// Switch off to use the fallback (solid underline for tap words, dotted for names).
    static let usesTextRenderer = true
}

// MARK: - Attributes read by the renderer

/// Marks a tap-to-see word. `emSize` is the word's font size in points.
struct TapWordAttribute: TextAttribute {
    var emSize: CGFloat
}

/// Marks a character's name.
struct NameWordAttribute: TextAttribute {
    var emSize: CGFloat
    var color: Color
}

// MARK: - Building the text

/// Turns a story's runs into styled `Text`.
@MainActor
struct StoryTextBuilder {
    let story: Story
    let typeScale: ReadingTypeScale
    /// The pane's scale from the reference pane.
    let scale: CGFloat

    private var textColor: Color {
        Color(hex: story.theme.textColor, fallback: Tokens.Palette.readingTextDefault)
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

        var color = textColor
        if let voice = voiceColor(of: run.speaker) {
            color = voice
        } else if run.effect == .pop {
            color = Color(rgba: Tokens.Palette.coral)
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

        if run.tapTarget != nil {
            if StoryTextStyle.usesTextRenderer {
                text = text.customAttribute(TapWordAttribute(emSize: emSize))
            } else {
                text = text.underline(true, pattern: .solid, color: Color(hex: story.theme.tap.line))
            }
        }
        if run.characterName != nil {
            let nameColor = voiceColor(of: run.characterName) ?? color
            if StoryTextStyle.usesTextRenderer {
                text = text.customAttribute(NameWordAttribute(emSize: emSize, color: nameColor))
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
        let image = FaceChipRenderer.image(for: character, em: emSize)
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

    /// The highlight reaches a little outside the text's own bounds.
    var displayPadding: EdgeInsets {
        EdgeInsets(top: 6, leading: 8, bottom: 8, trailing: 8)
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
                    if var mark = openTap {
                        mark.rect = mark.rect.union(bounds.rect)
                        openTap = mark
                    } else {
                        openTap = Mark(rect: bounds.rect, baseline: bounds.origin.y, attribute: attribute)
                    }
                } else if let mark = openTap {
                    taps.append(mark)
                    openTap = nil
                }
                if let attribute = run[NameWordAttribute.self] {
                    if var mark = openName {
                        mark.rect = mark.rect.union(bounds.rect)
                        openName = mark
                    } else {
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
            for run in line {
                context.draw(run)
            }
            for mark in taps {
                drawSpark(mark, in: &context)
            }
            for mark in names {
                drawNameUnderline(mark, in: &context)
            }
        }
    }

    /// Rounded band from 8% to 92% of the line box, with a 2 pt underline along its bottom.
    private func drawTapHighlight(_ mark: Mark<TapWordAttribute>, in context: inout GraphicsContext) {
        let em = mark.attribute.emSize
        let rect = mark.rect
        let overhang = em * 0.12
        let band = CGRect(
            x: rect.minX - overhang,
            y: rect.minY + rect.height * CGFloat(ReadingTypeScale.tapBandTop),
            width: rect.width + overhang,
            height: rect.height * CGFloat(ReadingTypeScale.tapBandBottom - ReadingTypeScale.tapBandTop)
        )
        let shape = Path(roundedRect: band, cornerRadius: em * CGFloat(Tokens.Radius.tapHighlightEm), style: .continuous)
        context.fill(
            shape,
            with: .linearGradient(
                Gradient(colors: [tapFill, tapFill2]),
                startPoint: CGPoint(x: band.midX, y: band.minY),
                endPoint: CGPoint(x: band.midX, y: band.maxY)
            )
        )
        let underline = CGFloat(ReadingTypeScale.tapUnderline) * scale
        let line = tapLine
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
        context.fill(star, with: .color(tapSpark))
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

// MARK: - The text column

/// The paragraphs of one pane, at the tier's type scale.
struct StoryTextView: View {
    @Environment(\.pane) private var pane
    let story: Story
    let blocks: [TextBlock]
    let typeScale: ReadingTypeScale

    var body: some View {
        let builder = StoryTextBuilder(story: story, typeScale: typeScale, scale: pane.scale)
        let renderer = StoryTextRenderer(
            tapFill: Color(hex: story.theme.tap.fill, fallback: Tokens.Palette.sun.opacity(0.5)),
            tapFill2: Color(hex: story.theme.tap.fill2, fallback: Tokens.Palette.sun.opacity(0.38)),
            tapLine: Color(hex: story.theme.tap.line, fallback: Tokens.Palette.sun),
            tapSpark: Color(hex: story.theme.tap.spark, fallback: Tokens.Palette.sun),
            scale: pane.scale
        )
        VStack(alignment: .leading, spacing: pane.pt(typeScale.paragraphGap)) {
            ForEach(blocks) { block in
                paragraph(block, builder: builder, renderer: renderer)
            }
        }
    }

    @ViewBuilder
    private func paragraph(_ block: TextBlock, builder: StoryTextBuilder, renderer: StoryTextRenderer) -> some View {
        // TODO(M2): `pathText` blocks (text on a curve) are drawn as ordinary paragraphs for now.
        let lineSpacing = builder.lineSpacing(for: block)
        let text = builder.text(for: block)
            .lineSpacing(lineSpacing)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            // Half the extra leading goes above the first line, as in a CSS line box, so the
            // designed "top of text" positions hold.
            .padding(.top, lineSpacing / 2)
            .padding(.bottom, -lineSpacing / 2)
            // One accessibility element per paragraph, labelled with the plain text.
            // TODO(M3): expose tap words and names as custom actions.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: block.plainText))
        if StoryTextStyle.usesTextRenderer {
            text.textRenderer(renderer)
        } else {
            text
        }
    }
}
