import SwiftUI
import OmramoCore

// Tap-to-see, landmark and character cards (docs/DESIGN.md §5.9–5.10; screens 06 and 07).
//
// One picture answer at a time: a card has a close button and "Back to my line" and no other
// control. Nothing on a card opens another card (criterion 3.3) — the cards below are given
// only a close action, never the reader's `open`.
//
// With two panes a card fills the pane facing the tapped word. Folded, the same card rises
// from the bottom of the pane as a partial sheet (`CardSheet`, about 60% of the height), and
// the page slides so the tapped line stays in view above it (round 4; was design gap G4).

// MARK: - Wrapping row (trait pills)

/// Lays views out in rows, wrapping to a new row when the width runs out.
struct WrappingRow: Layout {
    var spacing: CGFloat
    var rowSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        let rows = arrange(subviews, width: width)
        let height = rows.last.map { $0.y + $0.height } ?? 0
        let widest = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? widest, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for row in arrange(subviews, width: bounds.width) {
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: bounds.minX + item.x, y: bounds.minY + row.y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: item.width, height: row.height)
                )
            }
        }
    }

    private struct Row {
        var y: CGFloat
        var height: CGFloat = 0
        var width: CGFloat = 0
        var items: [(index: Int, x: CGFloat, width: CGFloat)] = []
    }

    private func arrange(_ subviews: Subviews, width: CGFloat) -> [Row] {
        var rows: [Row] = []
        var current = Row(y: 0)
        var x: CGFloat = 0
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let itemWidth = min(size.width, width)
            if !current.items.isEmpty, x + itemWidth > width {
                rows.append(current)
                current = Row(y: current.y + current.height + rowSpacing)
                x = 0
            }
            current.items.append((index, x, itemWidth))
            current.height = max(current.height, size.height)
            current.width = x + itemWidth
            x += itemWidth + spacing
        }
        if !current.items.isEmpty {
            rows.append(current)
        }
        return rows
    }
}

// MARK: - Tap-to-see and landmark card (§5.9)

/// The picture card for a marked word. A landmark uses this same card, filled from the
/// landmark catalog in the story's tier wording, with the framing label in the note box.
struct TapToSeeCard: View {
    @Environment(\.pane) private var pane
    let content: TapCardContent
    /// True when the card is the folded bottom sheet rather than a whole pane.
    var isSheet = false
    let focus: AccessibilityFocusState<ReaderFocus?>.Binding
    let onClose: @MainActor () -> Void

    var body: some View {
        let background = Color(hex: content.background, fallback: Tokens.Palette.night)
        let tint = (RGBA(string: content.background) ?? Tokens.Palette.night).opacity(0.5)
        let source: ArtSource = {
            switch content.pictureSource {
            case .story(let id): return .story(id)
            case .landmark: return .landmark
            }
        }()

        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            // The picture is 432 × 404 on the reference pane and fades into the card.
            let pictureHeight = min(width * 404 / 432, height * (isSheet ? 0.46 : 0.6))
            let side = pane.contentInset
            let buttonZone = pane.bottomInset(26) + pane.pt(Tokens.Size.primaryButtonHeight) + pane.pt(18)

            ZStack(alignment: .top) {
                background

                CardArtView(art: content.picture, source: source, role: .picture, colors: [content.background])
                    .frame(width: width, height: pictureHeight)
                    .clipped()
                    .overlay(alignment: .bottom) {
                        LinearGradient(colors: [background.opacity(0), background], startPoint: .top, endPoint: .bottom)
                            .frame(height: pictureHeight * 0.27)
                            .accessibilityHidden(true)
                    }

                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(verbatim: content.title)
                            .typeRole(Tokens.UIType.cardHeroTitle)
                            .foregroundStyle(Color.white)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityFocused(focus, equals: .cardTitle)

                        if let subtitle = content.subtitle, !subtitle.isEmpty {
                            Text(verbatim: subtitle)
                                .typeRole(Tokens.UIType.cardSubtitle)
                                .foregroundStyle(Color(rgba: RGBA(hex: 0x8FE3E8)))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, pane.pt(8))
                        }

                        Text(verbatim: content.line)
                            .typeRole(Tokens.UIType.cardLine)
                            .foregroundStyle(Color(rgba: RGBA(hex: 0xF2F8FF)))
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, pane.pt(content.subtitle == nil ? 16 : 10))

                        if let note = content.noteText, !note.isEmpty {
                            noteBox(label: content.noteLabel, text: note)
                                .padding(.top, pane.pt(18))
                                // The note box is inset 20 where the text is inset 30.
                                .padding(.horizontal, -pane.pt(10))
                        }
                    }
                    .padding(.horizontal, side + pane.pt(Tokens.Spacing.insetText))
                    .padding(.top, pictureHeight - pane.pt(32))
                    .padding(.bottom, buttonZone)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
            .overlay(alignment: .topLeading) {
                RoundGlassButton(icon: .close, chrome: .dark, label: "Close", fill: tint, action: onClose)
                    .keyboardShortcut(.cancelAction)
                    .padding(.leading, pane.pt(Tokens.Spacing.insetControl))
                    .padding(.top, isSheet ? pane.pt(16) : pane.controlTop())
            }
            .overlay(alignment: .bottom) {
                Button(action: onClose) {
                    CardButtonLabel(title: "Back to my line", style: .sun)
                }
                .buttonStyle(PressScaleButtonStyle())
                .keyboardShortcut(.defaultAction)
                .padding(.horizontal, side + pane.pt(20))
                .padding(.bottom, pane.bottomInset(26))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
        .accessibilityIdentifier(StoryCardRef.tapTarget(content.targetID).cardIdentifier)
    }

    /// The culture note, or — for a landmark outside the story's time or place — the framing
    /// device's label and bridging line.
    private func noteBox(label: String?, text: String) -> some View {
        let shape = RoundedRectangle(cornerRadius: pane.pt(Tokens.Radius.cultureNote), style: .continuous)
        let labelColor = Color(rgba: RGBA(hex: 0xFFB3A8))
        return VStack(alignment: .leading, spacing: pane.pt(8)) {
            if let label, !label.isEmpty {
                HStack(spacing: pane.pt(7)) {
                    PinIcon(color: labelColor, width: 9)
                    Text(verbatim: label)
                        .typeRole(Tokens.UIType.cultureNoteLabel)
                        .foregroundStyle(labelColor)
                }
            }
            Text(verbatim: text)
                .typeRole(Tokens.UIType.cultureNoteBody)
                .foregroundStyle(Color(rgba: RGBA(hex: 0xDDEBFF)))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(pane.pt(16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.10), in: shape)
        .overlay(shape.strokeBorder(Color.white.opacity(0.22), lineWidth: 0.5))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Character card (§5.10)

struct CharacterCard: View {
    @Environment(\.pane) private var pane
    let content: CharacterCardContent
    let storyID: StoryID
    var isSheet = false
    let focus: AccessibilityFocusState<ReaderFocus?>.Binding
    let onClose: @MainActor () -> Void

    private static let sheetFill = RGBA(hex: 0xFFFBF4)
    private static let ink = RGBA(hex: 0x2A1408)
    private static let labelInk = RGBA(hex: 0xC2571C)

    var body: some View {
        let colors = content.background.map { Color(hex: $0, fallback: Tokens.Palette.sun) }
        let gradient = colors.count > 1 ? colors : [Color(rgba: Tokens.Palette.sun), Color(rgba: Tokens.Palette.coral)]

        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            // The portrait is 432 × 400 on the reference pane; the sheet starts 28 pt up into it.
            let portraitHeight = min(width * 400 / 432, height * (isSheet ? 0.42 : 0.58))
            let side = pane.contentInset
            let buttonZone = pane.bottomInset(26) + pane.pt(Tokens.Size.primaryButtonHeight) + pane.pt(18)
            let sheetShape = UnevenRoundedRectangle(
                topLeadingRadius: pane.pt(Tokens.Radius.characterSheet),
                topTrailingRadius: pane.pt(Tokens.Radius.characterSheet),
                style: .continuous
            )

            ZStack(alignment: .top) {
                Color(rgba: CharacterCard.sheetFill)

                LinearGradient(colors: gradient, startPoint: .top, endPoint: .bottom)
                    .frame(width: width, height: portraitHeight)
                    .overlay {
                        CardArtView(art: content.portrait, source: .story(storyID), role: .portrait, colors: content.background)
                    }
                    .clipped()

                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(verbatim: content.label)
                            .typeRole(Tokens.UIType.cultureNoteLabel.scaled(by: 11.5 / 12))
                            .foregroundStyle(Color(rgba: CharacterCard.labelInk))
                            .fixedSize(horizontal: false, vertical: true)

                        Text(verbatim: content.title)
                            .typeRole(Tokens.UIType.characterNameTitle)
                            .foregroundStyle(Color(rgba: CharacterCard.ink))
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, pane.pt(12))
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityFocused(focus, equals: .cardTitle)

                        if !content.traits.isEmpty {
                            WrappingRow(spacing: pane.pt(8), rowSpacing: pane.pt(8)) {
                                ForEach(Array(content.traits.enumerated()), id: \.offset) { item in
                                    Text(verbatim: item.element.text)
                                        .typeRole(Tokens.UIType.traitPill)
                                        .foregroundStyle(Color(hex: item.element.ink, fallback: CharacterCard.ink))
                                        .lineLimit(1)
                                        .padding(.horizontal, pane.pt(14))
                                        .frame(height: pane.pt(30))
                                        .background(
                                            Color(hex: item.element.fill, fallback: Tokens.Palette.cloud),
                                            in: Capsule(style: .continuous)
                                        )
                                }
                            }
                            .padding(.top, pane.pt(16))
                            .accessibilityElement(children: .combine)
                        }

                        Text(verbatim: content.body)
                            .typeRole(Tokens.TypeRole(.reading, size: 19, lineHeight: 29, weight: 470))
                            .foregroundStyle(Color(rgba: CharacterCard.ink))
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, pane.pt(20))
                    }
                    .padding(.horizontal, side + pane.pt(28))
                    .padding(.top, pane.pt(26))
                    .padding(.bottom, buttonZone)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                .background {
                    sheetShape
                        .fill(Color(rgba: CharacterCard.sheetFill))
                        .shadow(color: Color(rgba: RGBA(red: 160.0 / 255, green: 60.0 / 255, blue: 0, alpha: 0.18)), radius: pane.pt(15), x: 0, y: -pane.pt(10))
                }
                .padding(.top, portraitHeight - pane.pt(28))
            }
            .overlay(alignment: .topLeading) {
                RoundGlassButton(icon: .close, chrome: .light, label: "Close", fill: RGBA(hex: 0xFFFFFF, alpha: 0.55), action: onClose)
                    .keyboardShortcut(.cancelAction)
                    .padding(.leading, pane.pt(Tokens.Spacing.insetControl))
                    .padding(.top, isSheet ? pane.pt(16) : pane.controlTop())
            }
            .overlay(alignment: .bottom) {
                Button(action: onClose) {
                    CardButtonLabel(title: "Back to my line", style: .coral)
                }
                .buttonStyle(PressScaleButtonStyle())
                .keyboardShortcut(.defaultAction)
                .padding(.horizontal, side + pane.pt(20))
                .padding(.bottom, pane.bottomInset(26))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
        .accessibilityIdentifier(StoryCardRef.character(content.characterID).cardIdentifier)
    }
}

// MARK: - Any card

/// The card for whatever marked word was tapped.
struct OpenCardView: View {
    let content: StoryCardContent
    let storyID: StoryID
    var isSheet = false
    let focus: AccessibilityFocusState<ReaderFocus?>.Binding
    let onClose: @MainActor () -> Void

    var body: some View {
        switch content {
        case .tap(let tap):
            TapToSeeCard(content: tap, isSheet: isSheet, focus: focus, onClose: onClose)
        case .character(let character):
            CharacterCard(content: character, storyID: storyID, isSheet: isSheet, focus: focus, onClose: onClose)
        }
    }
}

// MARK: - Folded: the card as a partial bottom sheet (assumption A2)

/// One pane: the card rises from the bottom to `height` (about 60% of the pane) and the page
/// above it stays in view — the tapped line with its beam and place marker, the other
/// paragraphs dimmed by the text itself. The rest of the pane does not respond, so the page
/// cannot be turned and no other word can be tapped while the card is open. The card has its
/// close button and "Back to my line", and nothing else.
struct CardSheet: View {
    @Environment(\.pane) private var pane
    let content: StoryCardContent
    let storyID: StoryID
    /// Height of the card, from the bottom of the pane.
    let height: CGFloat
    let focus: AccessibilityFocusState<ReaderFocus?>.Binding
    let onClose: @MainActor () -> Void

    var body: some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: pane.pt(Tokens.Radius.characterSheet),
            topTrailingRadius: pane.pt(Tokens.Radius.characterSheet),
            style: .continuous
        )
        ZStack(alignment: .bottom) {
            // No dim over the page: the tapped line must stay bright. This clear layer only
            // takes the touches, so nothing behind the card can be pressed.
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {}
                .accessibilityHidden(true)

            OpenCardView(content: content, storyID: storyID, isSheet: true, focus: focus, onClose: onClose)
                .frame(height: max(0, height))
                .clipShape(shape)
                .shadow(color: Color(rgba: RGBA(red: 12.0 / 255, green: 8.0 / 255, blue: 40.0 / 255, alpha: 0.3)), radius: pane.pt(14), x: 0, y: -pane.pt(6))
        }
    }
}
