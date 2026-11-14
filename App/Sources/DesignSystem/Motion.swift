import SwiftUI
import OmramoCore

// Motion tokens (docs/DESIGN.md §3.7), in one place.
//
// The rules: nothing moves unless the child acts; movement is short, calm and critically
// damped (no overshoot, no bounce); only transforms and opacity are animated, never layout;
// and with Reduce Motion every token becomes a plain cross-fade — no movement, no scaling.

enum Motion {
    // MARK: Durations (seconds)

    /// Button press, chip state.
    static let quickDuration: Double = 0.18
    /// A page turn, from the press to the new page at rest.
    static let pageDuration: Double = 0.42
    /// A card opening from its word, or closing back to it.
    static let cardDuration: Double = 0.38
    /// Library cover → reader, and back.
    static let heroDuration: Double = 0.45
    /// The story-finished moment arriving over the last page.
    static let finishedDuration: Double = 0.5
    /// The splash: on screen for `splashHold`, then a `splashFade` cross-fade to the library.
    /// Together under one second: the splash never keeps a child waiting.
    static let splashHold: Double = 0.65
    static let splashFade: Double = 0.3
    /// Every transition under Reduce Motion: one short cross-fade.
    static let reducedDuration: Double = 0.22
    /// The toast: appears in 0.2 s, stays 1.6 s, fades in 0.3 s.
    static let toastIn: Double = 0.2
    static let toastStay: Double = 1.6
    static let toastOut: Double = 0.3

    // MARK: Distances (reference points; multiply by the pane's scale)

    /// How far the words travel on a page turn.
    static let pageTextTravel: Double = 30
    /// How far the scene drifts when the picture changes: less than the words, so the picture
    /// reads as further away.
    static let pageSceneTravel: Double = 12
    /// A card starts this much smaller, anchored toward its word.
    static let cardStartScale: CGFloat = 0.94
    /// Pressed controls shrink to this.
    static let pressScale: CGFloat = 0.96
    /// Pressed controls under Reduce Motion dim to this instead of shrinking.
    static let pressDim: Double = 0.82

    // MARK: Animations

    static let quick = Animation.easeOut(duration: quickDuration)

    /// A critically damped spring: settles in about `duration`, never overshoots.
    private static func settle(_ duration: Double) -> Animation {
        .spring(response: duration * 0.85, dampingFraction: 1, blendDuration: 0)
    }

    private static func fade() -> Animation {
        .easeInOut(duration: reducedDuration)
    }

    static func page(reduceMotion: Bool) -> Animation {
        reduceMotion ? fade() : settle(pageDuration)
    }

    static func card(reduceMotion: Bool) -> Animation {
        reduceMotion ? fade() : settle(cardDuration)
    }

    static func hero(reduceMotion: Bool) -> Animation {
        reduceMotion ? fade() : settle(heroDuration)
    }

    static func finished(reduceMotion: Bool) -> Animation {
        reduceMotion ? fade() : settle(finishedDuration)
    }

    /// The small celebration on the story-finished moment: one slow, soft ease, played once.
    static let celebration = Animation.easeOut(duration: 1.1)

    static let splash = Animation.easeInOut(duration: splashFade)

    static let toast = Animation.easeOut(duration: toastIn)

    /// How long the page-turn controls stay locked after a press, so a second press cannot
    /// start a second turn on top of the first.
    static func pageLock(reduceMotion: Bool) -> Double {
        reduceMotion ? reducedDuration : pageDuration
    }
}

/// Which way the pages are moving.
enum TurnDirection: Equatable {
    case forward
    case backward

    /// +1 when new content comes from the trailing side, −1 from the leading side.
    var sign: CGFloat { self == .forward ? 1 : -1 }
}

// MARK: - Transitions

extension AnyTransition {
    /// Story text on a page turn: the old words slide a short way toward where the reader
    /// came from and fade; the new words arrive from the other side. Backward mirrors forward.
    static func pageText(direction: TurnDirection, travel: CGFloat, reduceMotion: Bool) -> AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .asymmetric(
            insertion: .offset(x: direction.sign * travel).combined(with: .opacity),
            removal: .offset(x: -direction.sign * travel).combined(with: .opacity)
        )
    }

    /// A scene changing under the words: a cross-fade with a shorter drift than the text, so
    /// picture and words move at slightly different depths.
    static func pageScene(direction: TurnDirection, travel: CGFloat, reduceMotion: Bool) -> AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .asymmetric(
            insertion: .offset(x: direction.sign * travel).combined(with: .opacity),
            removal: .offset(x: -direction.sign * travel).combined(with: .opacity)
        )
    }

    /// A card growing out of its word: a small scale anchored toward the word, with a fade.
    static func cardReveal(anchor: UnitPoint, reduceMotion: Bool) -> AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .scale(scale: Motion.cardStartScale, anchor: anchor).combined(with: .opacity)
    }

    /// The story-finished moment: a fade with the slightest growth (0.97 → 1), so it arrives
    /// like a breath out rather than a jump. A cross-fade with Reduce Motion.
    static func finishedReveal(reduceMotion: Bool) -> AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .scale(scale: 0.97, anchor: .center).combined(with: .opacity)
    }

    /// The folded card: rises from the bottom edge.
    static func cardRise(reduceMotion: Bool) -> AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .move(edge: .bottom).combined(with: .opacity)
    }
}

// MARK: - Word bloom (the highlight that grows into the card)

/// A sun-coloured rounded rectangle that travels from the tapped word's rectangle to the
/// card's, brightest mid-way and invisible at both ends: the word's highlight seems to open
/// into the card, and to fold back into the word when the card closes. Drawn only during the
/// transition (it is a transition's modifier), with transforms and opacity alone.
struct WordBloomModifier: ViewModifier, Animatable {
    /// 0 = at the word, 1 = at the card.
    var progress: CGFloat
    let from: CGRect
    let to: CGRect

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        let t = min(1, max(0, progress))
        let rect = CGRect(
            x: from.minX + (to.minX - from.minX) * t,
            y: from.minY + (to.minY - from.minY) * t,
            width: max(1, from.width + (to.width - from.width) * t),
            height: max(1, from.height + (to.height - from.height) * t)
        )
        // 0 at both ends, about 0.4 in the middle of the flight.
        let glow = Double(4 * t * (1 - t)) * 0.4
        let radius = 10 + 18 * t
        return content.overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color(rgba: Tokens.Palette.sun))
                .frame(width: rect.width, height: rect.height)
                .offset(x: rect.minX, y: rect.minY)
                .opacity(glow)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }
}

extension AnyTransition {
    /// The word bloom, for a clear view that exists only while a card is open.
    /// Main-actor: it builds a `ViewModifier`, whose initialiser is main-actor isolated.
    @MainActor
    static func wordBloom(from: CGRect, to: CGRect) -> AnyTransition {
        .modifier(
            active: WordBloomModifier(progress: 0, from: from, to: to),
            identity: WordBloomModifier(progress: 1, from: from, to: to)
        )
    }
}

// MARK: - Hero (library cover → reader)

/// Shows its content as if it grew out of `source` (a cover in the library): at progress 0 the
/// whole screen is scaled into the cover's rectangle and clipped to its rounded shape; at 1 it
/// fills the window. Transforms, a mask and opacity only — the reader inside is not laid out
/// again while it moves.
struct HeroModifier: ViewModifier, Animatable {
    /// 0 = at the cover, 1 = full screen.
    var progress: CGFloat
    let source: CGRect
    let container: CGSize
    let cornerRadius: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        let t = min(1, max(0, progress))
        let width = max(1, container.width)
        let height = max(1, container.height)
        let full = CGRect(x: 0, y: 0, width: width, height: height)
        let rect = CGRect(
            x: source.minX + (full.minX - source.minX) * t,
            y: source.minY + (full.minY - source.minY) * t,
            width: max(1, source.width + (full.width - source.width) * t),
            height: max(1, source.height + (full.height - source.height) * t)
        )
        // Fill the moving rectangle without squashing the picture; the mask crops the rest.
        let scale = max(rect.width / width, rect.height / height)
        let radius = cornerRadius * (1 - t)
        // The reader fades in over the first third, so the cover seems to become the scene.
        let opacity = Double(min(1, t / 0.33))
        return content
            .scaleEffect(scale, anchor: .center)
            .offset(x: rect.midX - full.midX, y: rect.midY - full.midY)
            .mask(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .frame(width: rect.width, height: rect.height)
                    .offset(x: rect.minX, y: rect.minY)
            }
            .opacity(opacity)
    }
}

extension AnyTransition {
    /// The reader opening out of a library cover, and closing back into it. Without a source
    /// rectangle (a launch argument, a cover scrolled out of sight) or with Reduce Motion it
    /// is a cross-fade. Main-actor: it builds a `ViewModifier` (see `wordBloom`).
    @MainActor
    static func hero(from source: CGRect?, in container: CGSize, cornerRadius: CGFloat, reduceMotion: Bool) -> AnyTransition {
        guard !reduceMotion, let source, source.width > 1, source.height > 1,
              container.width > 1, container.height > 1,
              source.intersects(CGRect(origin: .zero, size: container)) else {
            return .opacity
        }
        return .modifier(
            active: HeroModifier(progress: 0, source: source, container: container, cornerRadius: cornerRadius),
            identity: HeroModifier(progress: 1, source: source, container: container, cornerRadius: cornerRadius)
        )
    }
}
