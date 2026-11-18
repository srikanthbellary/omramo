import Foundation
import SwiftUI
import OmramoCore

// The splash (docs/DESIGN.md §5.20 and §6 "01 Splash"; screen `01-splash.png`).
//
// Brief and calm: the dark aurora, the OMRAMO wordmark with the warm light on "RA", the
// tagline, a few still motes. With two panes the wordmark is set across the hinge as designed
// (OMR | AMO, the hinge through the middle of "RA", a warm seam on each pane's hinge edge);
// on one pane the whole word sits on one line with the same warm light behind "RA".
//
// It is on screen for `Motion.splashHold` and cross-fades to the library in
// `Motion.splashFade` — under a second together — and never waits for anything. Nothing on it
// moves, so Reduce Motion needs no other path: the only change is the cross-fade.

/// The splash itself. `RootView` shows it over the first screen and removes it.
struct SplashView: View {
    var body: some View {
        TwoPane {
            AuroraBackdrop(aurora: .dark)
                .overlay { SplashMotes() }
        } leading: {
            SplashHalf(side: .leading)
        } trailing: {
            SplashHalf(side: .trailing)
        } folded: {
            SplashSingle()
        }
        // Opaque to touches for its short life: nothing underneath is pressed by accident.
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: Brand.displayName))
        .accessibilityIdentifier("splash")
    }

    /// The tagline in two halves for the two panes: "A magical book" | "that you read."
    static func taglineHalves(_ tagline: String = Brand.tagline) -> (leading: String, trailing: String) {
        guard let cut = tagline.range(of: " that ") else { return (tagline, "") }
        let leading = String(tagline[tagline.startIndex..<cut.lowerBound])
        let trailing = String(tagline[cut.lowerBound...]).trimmingCharacters(in: .whitespaces)
        return (leading, trailing)
    }

    /// Whether the splash is shown at launch, and whether it stays (`-OmramoShowSplash`).
    /// A launch that goes straight to a story (a debug argument) skips it.
    static func plan(arguments: [String] = ProcessInfo.processInfo.arguments) -> (shows: Bool, holds: Bool) {
        #if DEBUG
        if DebugLaunch.hasFlag(DebugLaunch.showSplashArgument, in: arguments) {
            return (true, true)
        }
        if DebugLaunch.opensAStory(arguments) {
            return (false, false)
        }
        #endif
        return (true, false)
    }
}

/// The wordmark's letters, white with the `wordmark.ra` gradient on the middle pair.
private struct SplashLetters: View {
    let plain: String
    let warm: String
    /// True when the warm letters come first ("A" + "MO").
    let warmFirst: Bool
    let role: Tokens.TypeRole

    var body: some View {
        let warmText = Text(verbatim: warm)
            .foregroundStyle(LinearGradient(vertical: Tokens.Gradients.wordmarkRA))
        let plainText = Text(verbatim: plain)
            .foregroundStyle(Color.white)
        HStack(spacing: 0) {
            if warmFirst {
                warmText
                plainText
            } else {
                plainText
                warmText
            }
        }
        .typeRole(role)
        .lineLimit(1)
        .fixedSize()
    }
}

/// One pane of the two-pane splash: half the wordmark and half the tagline against the hinge
/// edge, with the warm edge glow and the seam line.
private struct SplashHalf: View {
    @Environment(\.pane) private var pane
    let side: PaneContext.Side

    var body: some View {
        let isLeading = side == .leading
        let mark = FoldMark()
        let middle = Array(mark.middle)
        let half = middle.count / 2
        let warm = isLeading ? String(middle[0..<half]) : String(middle[half...])
        let plain = isLeading ? mark.leading : mark.trailing
        let tagline = SplashView.taglineHalves()
        let alignment: Alignment = isLeading ? .trailing : .leading
        let hingeEdge: Alignment = isLeading ? .trailing : .leading
        // §5.20: the wordmark at top 214 and the tagline at top 404 of the 720 pt pane. On a
        // pane of another shape the pair keeps that place in proportion.
        let unit = pane.size.height / CGFloat(ReferenceCanvas.paneHeight)
        let wordTop = 214 * min(unit, pane.scale * 1.6)
        // A pane too narrow for half the word at full size (a narrow window) scales it down.
        let fit = min(1, Double((pane.size.width - pane.pt(9) - pane.pt(12)) / max(1, pane.pt(336))))
        let role = Tokens.UIType.splashWordmark.scaled(by: max(0.3, fit))

        VStack(alignment: isLeading ? .trailing : .leading, spacing: pane.pt(32) * CGFloat(max(0.3, fit))) {
            SplashLetters(plain: plain, warm: warm, warmFirst: !isLeading, role: role)
            Text(verbatim: isLeading ? tagline.leading : tagline.trailing)
                .typeRole(Tokens.UIType.splashTagline)
                .foregroundStyle(Color.white.opacity(0.82))
                .lineLimit(1)
                // The tagline is inset 13 pt more than the wordmark (22 pt from the hinge edge).
                .padding(isLeading ? .trailing : .leading, pane.pt(13))
        }
        .padding(isLeading ? .trailing : .leading, pane.pt(9))
        .padding(.top, wordTop)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: isLeading ? .topTrailing : .topLeading)
        .background(alignment: hingeEdge) {
            // The warm light at the fold: a 60 pt glow and a 2 pt seam on the hinge edge.
            ZStack(alignment: alignment) {
                LinearGradient(
                    colors: [
                        Color(rgba: RGBA(red: 1, green: 150.0 / 255, blue: 90.0 / 255, alpha: 0.22)),
                        Color(rgba: RGBA(red: 1, green: 150.0 / 255, blue: 90.0 / 255, alpha: 0)),
                    ],
                    startPoint: isLeading ? .trailing : .leading,
                    endPoint: isLeading ? .leading : .trailing
                )
                .frame(width: pane.pt(60))
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(rgba: RGBA(hex: 0xFFC46B, alpha: 0)), location: 0),
                        Gradient.Stop(color: Color(rgba: RGBA(hex: 0xFFC46B)), location: 0.3),
                        Gradient.Stop(color: Color(rgba: RGBA(hex: 0xFF7A4D)), location: 0.7),
                        Gradient.Stop(color: Color(rgba: RGBA(hex: 0xFF7A4D, alpha: 0)), location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: max(1.5, pane.pt(2)))
                .padding(.vertical, min(pane.pt(150), pane.size.height * 0.2))
            }
            .accessibilityHidden(true)
        }
    }
}

/// The one-pane splash: the whole word on one line, a warm light behind "RA", the tagline.
private struct SplashSingle: View {
    @Environment(\.pane) private var pane

    var body: some View {
        let mark = FoldMark()
        // Six letters at 158 pt are about 660 pt wide; this fits them inside the text insets.
        let available = max(1, pane.contentWidth - pane.pt(Tokens.Spacing.insetText) * 2)
        let factor = min(1, Double(available / max(1, pane.pt(668))))
        let role = Tokens.UIType.splashWordmark.scaled(by: max(0.2, factor))
        let glow = pane.pt(190)

        VStack(spacing: pane.pt(18)) {
            HStack(spacing: 0) {
                Text(verbatim: mark.leading)
                    .foregroundStyle(Color.white)
                Text(verbatim: mark.middle)
                    .foregroundStyle(LinearGradient(vertical: Tokens.Gradients.wordmarkRA))
                Text(verbatim: mark.trailing)
                    .foregroundStyle(Color.white)
            }
            .typeRole(role)
            .lineLimit(1)
            .fixedSize()
            .background {
                // The warm light, where the hinge would be.
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(rgba: RGBA(red: 1, green: 150.0 / 255, blue: 90.0 / 255, alpha: 0.3)),
                                Color(rgba: RGBA(red: 1, green: 150.0 / 255, blue: 90.0 / 255, alpha: 0)),
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: glow
                        )
                    )
                    .frame(width: glow * 2, height: glow * 2)
                    .accessibilityHidden(true)
            }

            Text(verbatim: Brand.tagline)
                .typeRole(Tokens.UIType.splashTagline)
                .foregroundStyle(Color.white.opacity(0.82))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, pane.pt(Tokens.Spacing.insetText))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // A little above the middle, where the eye rests.
        .offset(y: -pane.size.height * 0.04)
    }
}

/// The design's small four-point motes in `#FFD25A`: still, ten of them, in fixed places.
private struct SplashMotes: View {
    /// Position (fractions of the canvas) and radius (points on the reference canvas).
    private static let motes: [(x: Double, y: Double, r: Double, spark: Bool)] = [
        (0.08, 0.21, 6, true), (0.37, 0.165, 2.2, false), (0.045, 0.555, 2, false),
        (0.123, 0.777, 2.2, false), (0.28, 0.846, 6, true), (0.616, 0.152, 2.2, false),
        (0.919, 0.236, 6, true), (0.964, 0.583, 2, false), (0.852, 0.777, 2.2, false),
        (0.684, 0.86, 5, true),
    ]

    var body: some View {
        let motes = SplashMotes.motes
        return Canvas { context, size in
            let unit = min(size.width / CGFloat(ReferenceCanvas.unfoldedWidth), size.height / CGFloat(ReferenceCanvas.paneHeight))
            let color = Color(rgba: RGBA(hex: 0xFFD25A))
            for mote in motes {
                let cx = size.width * CGFloat(mote.x)
                let cy = size.height * CGFloat(mote.y)
                let r = CGFloat(mote.r) * max(0.6, unit)
                context.fill(Art.circle(cx, cy, r * 1.9), with: .color(color.opacity(0.16)))
                if mote.spark {
                    context.fill(Art.spark(cx, cy, r), with: .color(color))
                } else {
                    context.fill(Art.circle(cx, cy, r * 0.7), with: .color(color.opacity(0.9)))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
