import SwiftUI
import OmramoCore

// Shared components of docs/DESIGN.md §5. All sizes are DESIGN.md values scaled by the pane.

// MARK: - Glass (§3.6)

private struct GlassModifier<S: InsettableShape>: ViewModifier {
    let glass: Tokens.Glass
    let fill: RGBA?
    let shape: S

    func body(content: Content) -> some View {
        content.background {
            ZStack {
                // Estimate of the design's "blur 18 pt, saturation 180%" backdrop: a system
                // material under the tinted fill. To be matched by eye on a Mac.
                shape.fill(.ultraThinMaterial)
                shape.fill(Color(rgba: fill ?? glass.fill))
                shape.strokeBorder(Color(rgba: glass.edge), lineWidth: 0.5)
            }
            .shadow(color: Color(rgba: glass.shadow), radius: 9, x: 0, y: 6)
            .shadow(color: Color.black.opacity(0.08), radius: 1, x: 0, y: 1)
        }
    }
}

extension View {
    /// Glass background in the light or dark variant. `fill` overrides the tint (footer chips,
    /// tab bar).
    func glass<S: InsettableShape>(_ chrome: ChromeStyle, fill: RGBA? = nil, in shape: S) -> some View {
        modifier(GlassModifier(glass: Tokens.Glass.style(chrome), fill: fill, shape: shape))
    }
}

/// Press feedback: scale to 0.96 (§3.7, proposal). TODO(M6): haptic and Reduce Motion variant.
struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

// MARK: - Icons (§5.23)

/// The design's hand-drawn icons, ported from `base.js` as SVG assets (not SF Symbols).
struct OmramoIcon: View {
    enum Name: String {
        case back = "icon-back"
        case forward = "icon-fwd"
        case bookmark = "icon-bookmark"
        case check = "icon-check"
        case book = "icon-book"
        case home = "icon-home"
        case shelf = "icon-shelf"
        case lock = "icon-lock"
        case close = "icon-x"
        case spark = "icon-spark"

        /// Size in the design, in reference points.
        var size: CGSize {
            switch self {
            case .back: return CGSize(width: 12, height: 20)
            case .forward: return CGSize(width: 26, height: 22)
            case .bookmark: return CGSize(width: 14, height: 19)
            case .check: return CGSize(width: 13, height: 11)
            case .book: return CGSize(width: 20, height: 17)
            case .home: return CGSize(width: 19, height: 18)
            case .shelf: return CGSize(width: 19, height: 18)
            case .lock: return CGSize(width: 13, height: 16)
            case .close: return CGSize(width: 13, height: 13)
            case .spark: return CGSize(width: 14, height: 14)
            }
        }
    }

    @Environment(\.pane) private var pane
    let name: Name
    /// Extra scale on top of the pane scale (e.g. 54/60 for the folded page-turn arrow).
    var multiplier: CGFloat = 1

    var body: some View {
        Image(name.rawValue)
            .renderingMode(.template)
            .resizable()
            .frame(
                width: name.size.width * pane.scale * multiplier,
                height: name.size.height * pane.scale * multiplier
            )
            .accessibilityHidden(true)
    }
}

/// The map pin: a tinted body with a white dot (two colours, so not a single template image).
struct PinIcon: View {
    @Environment(\.pane) private var pane
    let color: Color
    /// Width in reference points; the height is 1.25 × the width.
    var width: Double = 10

    var body: some View {
        let w = pane.pt(width)
        let h = w * 1.25
        Image("icon-pin")
            .renderingMode(.template)
            .resizable()
            .foregroundStyle(color)
            .frame(width: w, height: h)
            .overlay(alignment: .topLeading) {
                // Dot at (8, 7.6) with radius 3 in the icon's 16 × 20 box.
                Circle()
                    .fill(Color.white)
                    .frame(width: w * 6 / 16, height: w * 6 / 16)
                    .offset(x: w * 5 / 16, y: h * 4.6 / 20)
            }
            .accessibilityHidden(true)
    }
}

// MARK: - Tier glyph (§5.4)

/// Three bars; the bars above the tier are faint.
struct TierGlyph: View {
    @Environment(\.pane) private var pane
    let tier: Tier
    let color: Color
    var multiplier: CGFloat = 1

    var body: some View {
        let unit = pane.scale * multiplier
        HStack(alignment: .bottom, spacing: 2 * unit) {
            ForEach(1...3, id: \.self) { bar in
                RoundedRectangle(cornerRadius: 1.5 * unit, style: .continuous)
                    .fill(color.opacity(bar <= tier.level ? 1 : 0.28))
                    .frame(width: 3.5 * unit, height: CGFloat(2 + bar * 3) * unit)
            }
        }
        .frame(height: 11 * unit, alignment: .bottom)
        .accessibilityHidden(true)
    }
}

// MARK: - Chips (§5.3)

/// A 28 pt glass chip for the reader footer.
struct GlassChip<Content: View>: View {
    @Environment(\.pane) private var pane
    let chrome: ChromeStyle
    let fill: RGBA?
    let foreground: Color
    var leadingPadding: Double = 9
    var trailingPadding: Double = 11
    var spacing: Double = 6
    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack(spacing: pane.pt(spacing)) {
            content()
        }
        .typeRole(Tokens.UIType.chip)
        .foregroundStyle(foreground)
        .lineLimit(1)
        .padding(.leading, pane.pt(leadingPadding))
        .padding(.trailing, pane.pt(trailingPadding))
        .frame(height: pane.pt(Tokens.Size.chipHeight))
        .glass(chrome, fill: fill, in: Capsule(style: .continuous))
    }
}

/// Solid tier pill on covers and the "Keep reading" card.
struct TierPill: View {
    @Environment(\.pane) private var pane
    let tier: Tier
    /// 22 on small covers, 24 on the "Keep reading" card.
    var height: Double = Tokens.Size.pillHeightSmall

    var body: some View {
        let colors = Tokens.TierColors.colors(for: tier)
        let small = height <= Tokens.Size.pillHeightSmall
        HStack(spacing: pane.pt(6)) {
            TierGlyph(tier: tier, color: Color(rgba: colors.pillText))
            Text(verbatim: tier.displayName)
        }
        .typeRole(Tokens.UIType.chip.scaled(by: (small ? 10.5 : 11) / 12))
        .foregroundStyle(Color(rgba: colors.pillText))
        .padding(.leading, pane.pt(small ? 7 : 9))
        .padding(.trailing, pane.pt(small ? 8 : 11))
        .frame(height: pane.pt(height))
        .background(Color(rgba: colors.pillBackground), in: Capsule(style: .continuous))
        .shadow(color: Color.black.opacity(0.18), radius: pane.pt(3), x: 0, y: pane.pt(2))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Level: \(tier.displayName)"))
    }
}

// MARK: - Page dashes (§5.5)

struct PageDashesView: View {
    @Environment(\.pane) private var pane
    let dashes: PageDashes
    let color: Color
    let accent: Color

    var body: some View {
        HStack(spacing: pane.pt(3)) {
            ForEach(Array(dashes.states.enumerated()), id: \.offset) { item in
                Capsule(style: .continuous)
                    .fill(fill(for: item.element))
                    .frame(width: pane.pt(item.element == .current ? 20 : 10), height: pane.pt(4))
            }
        }
        .accessibilityHidden(true)
    }

    private func fill(for state: PageDashes.State) -> Color {
        switch state {
        case .done: return color.opacity(0.6)
        case .current: return accent
        case .upcoming: return color.opacity(0.22)
        }
    }
}

// MARK: - Round glass button (§5.1)

struct RoundGlassButton: View {
    @Environment(\.pane) private var pane
    let icon: OmramoIcon.Name
    let chrome: ChromeStyle
    let label: String
    let action: @MainActor () -> Void

    var body: some View {
        let size = pane.pt(Tokens.Size.roundGlassButton)
        Button(action: action) {
            OmramoIcon(name: icon)
                .foregroundStyle(Color(rgba: Tokens.Glass.style(chrome).content))
                .frame(width: size, height: size)
                .glass(chrome, in: Circle())
                // Hit area of at least 44 × 44 pt even when the pane is scaled down.
                .frame(minWidth: CGFloat(Tokens.Size.minimumHitTarget), minHeight: CGFloat(Tokens.Size.minimumHitTarget))
                .contentShape(Rectangle())
        }
        .buttonStyle(PressScaleButtonStyle())
        .frame(width: size, height: size)
        .accessibilityLabel(Text(verbatim: label))
    }
}

// MARK: - Round page-turn button (§5.6)

/// The only forward control. A page turns only when the child presses it.
struct PageTurnButton: View {
    @Environment(\.pane) private var pane
    let accent: StoryTheme.Accent
    /// 60 unfolded, 54 folded.
    var diameter: Double = Tokens.Size.pageTurn
    var icon: OmramoIcon.Name = .forward
    let label: String
    let value: String
    let action: @MainActor () -> Void

    var body: some View {
        let size = pane.pt(diameter)
        let shadow = Tokens.Gradients.pageTurnShadow(accent)
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(tokens: Tokens.Gradients.pageTurn(accent)),
                            center: UnitPoint(x: CGFloat(Tokens.Gradients.pageTurnCenter.x), y: CGFloat(Tokens.Gradients.pageTurnCenter.y)),
                            startRadius: 0,
                            endRadius: size
                        )
                    )
                    .overlay {
                        // Inner top highlight (estimate of the design's inset shadows).
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.55), Color.white.opacity(0)],
                                    startPoint: .top,
                                    endPoint: .center
                                ),
                                lineWidth: pane.pt(1.5)
                            )
                    }
                    .shadow(color: Color(rgba: shadow), radius: pane.pt(11), x: 0, y: pane.pt(10))
                    .shadow(color: Color.black.opacity(0.18), radius: pane.pt(2), x: 0, y: pane.pt(2))
                // Outer ring, 6 pt outside the button.
                Circle()
                    .strokeBorder(Color.white.opacity(0.55), lineWidth: pane.pt(2))
                    .frame(width: size + pane.pt(12), height: size + pane.pt(12))
                OmramoIcon(name: icon, multiplier: CGFloat(diameter / Tokens.Size.pageTurn))
                    .foregroundStyle(Color(rgba: Tokens.Gradients.pageTurnArrow(accent)))
            }
            .frame(width: size, height: size)
            .frame(minWidth: CGFloat(Tokens.Size.minimumHitTarget), minHeight: CGFloat(Tokens.Size.minimumHitTarget))
            .contentShape(Circle())
        }
        .buttonStyle(PressScaleButtonStyle())
        .frame(width: size, height: size)
        .accessibilityLabel(Text(verbatim: label))
        .accessibilityValue(Text(verbatim: value))
    }
}

// MARK: - Primary button (§5.11)

/// Coral gradient capsule ("Continue"). Height 52 by default; 42 on the "Keep reading" card.
struct PrimaryButtonLabel: View {
    @Environment(\.pane) private var pane
    let title: String
    var icon: OmramoIcon.Name?
    var height: Double = Tokens.Size.primaryButtonHeight
    var fontSize: Double = 17

    var body: some View {
        HStack(spacing: pane.pt(9)) {
            if let icon {
                OmramoIcon(name: icon)
            }
            Text(verbatim: title)
        }
        .typeRole(Tokens.UIType.buttonLabel.scaled(by: fontSize / 17))
        .foregroundStyle(Color.white)
        .padding(.leading, pane.pt(16))
        .padding(.trailing, pane.pt(18))
        .frame(height: pane.pt(height))
        .background(LinearGradient(vertical: Tokens.Gradients.buttonPrimary), in: Capsule(style: .continuous))
        .shadow(color: Color(rgba: RGBA(hex: 0xE8432B, alpha: 0.34)), radius: pane.pt(11), x: 0, y: pane.pt(10))
        .shadow(color: Color.black.opacity(0.14), radius: pane.pt(2), x: 0, y: pane.pt(2))
    }
}

// MARK: - Card (§5.12) and section label

private struct CardModifier: ViewModifier {
    @Environment(\.pane) private var pane
    let fill: RGBA

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: pane.pt(Tokens.Radius.card), style: .continuous)
        content
            .background(Color(rgba: fill), in: shape)
            .overlay(shape.strokeBorder(Color.white.opacity(0.9), lineWidth: 0.5))
            .clipShape(shape)
            .shadow(color: Color(rgba: Tokens.Surfaces.cardShadow), radius: pane.pt(17), x: 0, y: pane.pt(14))
            .shadow(color: Color(rgba: Tokens.Surfaces.cardShadow.opacity(0.06)), radius: pane.pt(3), x: 0, y: pane.pt(2))
    }
}

extension View {
    func omramoCard(fill: RGBA = Tokens.Surfaces.card) -> some View {
        modifier(CardModifier(fill: fill))
    }
}

/// Small uppercase section label ("KEEP READING").
struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(verbatim: text)
            .typeRole(Tokens.UIType.sectionLabel)
            .foregroundStyle(Color(rgba: Tokens.Palette.textLabel))
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Aurora backdrop (§3.3)

/// Base fill with five heavily blurred circles. Drawn across the whole canvas.
/// TODO(M6): grain overlay (fractal noise, soft-light) to match the screenshots.
struct AuroraBackdrop: View {
    let aurora: Tokens.Aurora

    var body: some View {
        GeometryReader { proxy in
            let sx = proxy.size.width / CGFloat(ReferenceCanvas.unfoldedWidth)
            let sy = proxy.size.height / CGFloat(ReferenceCanvas.paneHeight)
            let unit = min(sx, sy)
            ZStack {
                Color(rgba: aurora.base)
                Canvas { context, _ in
                    for blob in aurora.blobs {
                        let radius = CGFloat(blob.radius) * unit
                        let rect = CGRect(
                            x: CGFloat(blob.x) * sx - radius,
                            y: CGFloat(blob.y) * sy - radius,
                            width: radius * 2,
                            height: radius * 2
                        )
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(Color(rgba: blob.color).opacity(blob.opacity))
                        )
                    }
                }
                .blur(radius: CGFloat(aurora.blur) * unit)
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }
}
