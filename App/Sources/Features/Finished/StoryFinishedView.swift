import Foundation
import SwiftUI
import OmramoCore

// The story-finished moment (round 4; docs/DESIGN.md §6 "Story finished").
//
// After the last page: the story's cover with a tick and a few slow sparks, "The end", the
// story's moral in one sentence, and three plain choices — "Next story" (the primary one),
// "Read again" and "Library". Warm, short and calm: one soft movement, played once, and a
// cross-fade only with Reduce Motion. No score, no stars to earn, no timer, no streak talk.
//
// It lies over the reader, on the same panes (`TwoPane`): the words on the leading pane, the
// choices on the trailing one; on one pane the two are stacked.

/// The moment itself. Shown by `ReaderContent` while `ReaderModel.isFinishedShown`.
struct StoryFinishedView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let model: ReaderModel
    let router: AppRouter
    /// Set once the view is on screen: starts the small celebration and the haptic.
    @State private var arrived = false

    init(model: ReaderModel, router: AppRouter) {
        self.model = model
        self.router = router
    }

    var body: some View {
        let actions = FinishedActions(
            next: model.nextStory,
            openNext: { [router] story in router.open(story.id) },
            readAgain: { [model, reduceMotion] in
                withAnimation(Motion.finished(reduceMotion: reduceMotion)) {
                    model.readAgain()
                }
            },
            library: { [router] in router.showLibrary() }
        )

        TwoPane {
            FinishedBackdrop()
        } leading: {
            FinishedPane {
                FinishedMessage(story: model.story, moral: model.moral, arrived: arrived)
            }
        } trailing: {
            FinishedPane {
                FinishedChoices(actions: actions)
            }
        } folded: {
            FinishedSinglePane(story: model.story, moral: model.moral, arrived: arrived, actions: actions)
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
        .accessibilityIdentifier("finished.moment")
        // One light, warm tap under the finger as the moment arrives.
        .sensoryFeedback(.success, trigger: arrived)
        .onAppear {
            guard !arrived else { return }
            // The sparks settle once, slowly; with Reduce Motion they simply fade in.
            withAnimation(reduceMotion ? Animation.easeInOut(duration: Motion.reducedDuration) : Motion.celebration.delay(0.12)) {
                arrived = true
            }
            AccessibilityNotification.ScreenChanged().post()
        }
    }
}

/// What the three buttons do.
@MainActor
struct FinishedActions {
    /// The story to offer, or nil when the library holds no other story.
    let next: Story?
    let openNext: @MainActor (Story) -> Void
    let readAgain: @MainActor () -> Void
    let library: @MainActor () -> Void
}

// MARK: - Backdrop

/// The last scene stays where it was, softened and deepened into the brand's night colour, so
/// the moment reads as the same place at rest and the words on it are easy to read.
private struct FinishedBackdrop: View {
    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial)
            LinearGradient(
                colors: [
                    Color(rgba: Tokens.Palette.night2.opacity(0.78)),
                    Color(rgba: Tokens.Palette.night.opacity(0.9)),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            // The one warm light, low and to the upper left, as in every picture.
            RadialGradient(
                colors: [Color(rgba: RGBA(hex: 0xFFD9A0, alpha: 0.2)), Color(rgba: RGBA(hex: 0xFFD9A0, alpha: 0))],
                center: UnitPoint(x: 0.22, y: 0.2),
                startRadius: 0,
                endRadius: 520
            )
        }
        .accessibilityHidden(true)
    }
}

// MARK: - The words

/// Cover with a tick and sparks, "The end", the title and the moral.
private struct FinishedMessage: View {
    @Environment(\.pane) private var pane
    let story: Story
    let moral: String?
    let arrived: Bool

    var body: some View {
        let width = max(0, min(pane.pt(Tokens.Spacing.cardWidth), pane.size.width - pane.pt(Tokens.Spacing.insetText) * 2))
        VStack(spacing: 0) {
            FinishedEmblem(story: story, arrived: arrived)

            Text(verbatim: "The end")
                .typeRole(Tokens.UIType.sectionLabel.scaled(by: 13.0 / 11.0))
                .foregroundStyle(Color(rgba: Tokens.Palette.sun))
                .padding(.top, pane.pt(18))

            Text(verbatim: story.title)
                .typeRole(Tokens.UIType.screenTitle)
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, pane.pt(8))
                .accessibilityAddTraits(.isHeader)

            if let moral {
                Text(verbatim: moral)
                    .typeRole(Tokens.UIType.cardLine)
                    .foregroundStyle(Color(rgba: RGBA(hex: 0xF4F0FF)))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, pane.pt(18))
                    .padding(.vertical, pane.pt(16))
                    .frame(maxWidth: .infinity)
                    .background(
                        Color.white.opacity(0.1),
                        in: RoundedRectangle(cornerRadius: pane.pt(Tokens.Radius.cultureNote), style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: pane.pt(Tokens.Radius.cultureNote), style: .continuous)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
                    .padding(.top, pane.pt(18))
                    .accessibilityIdentifier("finished.moral")
            }
        }
        .frame(width: width)
    }
}

/// The small, calm celebration: the cover, a sun-coloured tick on its corner, a soft glow and
/// seven sparks that drift a few points outward once and stay. Nothing loops, nothing falls.
private struct FinishedEmblem: View {
    @Environment(\.pane) private var pane
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let story: Story
    let arrived: Bool

    /// Angle (degrees, 0 = right, clockwise), distance (in cover heights) and size of a spark.
    private static let sparks: [(angle: Double, distance: Double, size: Double)] = [
        (-152, 0.86, 1.0), (-118, 1.02, 0.7), (-74, 0.92, 1.15), (-34, 1.0, 0.8),
        (8, 0.9, 0.65), (172, 0.92, 0.75), (148, 1.08, 0.55),
    ]

    var body: some View {
        let coverWidth = pane.pt(96)
        let coverHeight = pane.pt(120)
        let badge = pane.pt(38)
        let sun = Color(rgba: Tokens.Palette.sun)
        // With Reduce Motion nothing travels or grows: the sparks only fade in where they stay.
        let travel: CGFloat = arrived || reduceMotion ? 1 : 0.78

        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [sun.opacity(0.42), sun.opacity(0)],
                        center: .center,
                        startRadius: coverHeight * 0.2,
                        endRadius: coverHeight * 1.05
                    )
                )
                .frame(width: coverHeight * 2.1, height: coverHeight * 2.1)
                .scaleEffect(arrived || reduceMotion ? 1 : 0.88)
                .opacity(arrived ? 1 : 0)

            ForEach(0..<FinishedEmblem.sparks.count, id: \.self) { index in
                let spark = FinishedEmblem.sparks[index]
                let radians = spark.angle * Double.pi / 180
                let reach = coverHeight * CGFloat(spark.distance) * travel
                OmramoIcon(name: .spark, multiplier: CGFloat(spark.size))
                    .foregroundStyle(sun)
                    .offset(x: CGFloat(cos(radians)) * reach, y: CGFloat(sin(radians)) * reach)
                    .opacity(arrived ? 0.95 : 0)
            }

            CoverView(story: story, radius: 16)
                .frame(width: coverWidth, height: coverHeight)
                .rotationEffect(.degrees(-4))
                .overlay(alignment: .bottomTrailing) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(vertical: Tokens.Gradients.buttonSun))
                            .overlay(Circle().strokeBorder(Color.white, lineWidth: pane.pt(2.5)))
                            .shadow(color: Color.black.opacity(0.22), radius: pane.pt(4), x: 0, y: pane.pt(3))
                        OmramoIcon(name: .check, multiplier: 1.25)
                            .foregroundStyle(Color(rgba: Tokens.Palette.pageTurnAmberArrow))
                    }
                    .frame(width: badge, height: badge)
                    .offset(x: badge * 0.34, y: badge * 0.28)
                }
        }
        .frame(width: coverHeight * 2.1, height: coverHeight * 1.34)
        .accessibilityHidden(true)
    }
}

// MARK: - The choices

/// "Next story" (primary), then "Read again" and "Library".
private struct FinishedChoices: View {
    @Environment(\.pane) private var pane
    let actions: FinishedActions

    var body: some View {
        let width = max(0, min(pane.pt(Tokens.Spacing.cardWidth), pane.size.width - pane.pt(Tokens.Spacing.insetText) * 2))
        VStack(spacing: pane.pt(14)) {
            if let next = actions.next {
                nextCard(next)
            }
            HStack(spacing: pane.pt(12)) {
                QuietChoiceButton(title: "Read again", icon: .returnArrow, action: actions.readAgain)
                    .accessibilityIdentifier("finished.again")
                if actions.next != nil {
                    QuietChoiceButton(title: "Library", icon: .home, action: actions.library)
                        .accessibilityLabel(Text(verbatim: "Back to the library"))
                        .accessibilityIdentifier("finished.library")
                }
            }
            if actions.next == nil {
                // Nothing else to read yet: the library is the way on.
                Button(action: actions.library) {
                    FinishedPrimaryLabel(title: "Back to the library", icon: .home)
                }
                .buttonStyle(PressScaleButtonStyle())
                .keyboardShortcut(.defaultAction)
                .accessibilityIdentifier("finished.library")
            }
        }
        .frame(width: width)
    }

    /// The primary control: 56 pt on the reference pane.
    static let primaryHeight: Double = 56

    private func nextCard(_ story: Story) -> some View {
        let open = actions.openNext
        let ink = Color(rgba: Tokens.Palette.ink)
        return VStack(alignment: .leading, spacing: pane.pt(14)) {
            HStack(alignment: .center, spacing: pane.pt(14)) {
                CoverView(story: story, radius: 14)
                    .frame(width: pane.pt(72), height: pane.pt(90))
                VStack(alignment: .leading, spacing: pane.pt(7)) {
                    Text(verbatim: "Next story")
                        .typeRole(Tokens.UIType.sectionLabel)
                        .foregroundStyle(Color(rgba: Tokens.Palette.textLabel))
                    Text(verbatim: story.title)
                        .typeRole(Tokens.UIType.cardHeading.scaled(by: 19.0 / 17.0))
                        .foregroundStyle(ink)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: pane.pt(8)) {
                        TierPill(tier: story.tier)
                        Text(verbatim: story.region.label)
                            .typeRole(Tokens.UIType.storyCardPlace)
                            .foregroundStyle(Color(rgba: Tokens.Palette.textSecondary))
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
            }
            Button {
                open(story)
            } label: {
                FinishedPrimaryLabel(title: "Next story", icon: .book)
            }
            .buttonStyle(PressScaleButtonStyle())
            .keyboardShortcut(.defaultAction)
            .accessibilityLabel(Text(verbatim: "Next story: \(story.title)"))
            .accessibilityIdentifier("finished.next")
        }
        .padding(pane.pt(16))
        .omramoCard(fill: RGBA(hex: 0xFFFFFF, alpha: 0.94))
    }
}

/// The primary choice: the coral capsule of §5.11 at the full width of its column, 56 pt high
/// on the reference pane and never less than 56 pt to touch.
private struct FinishedPrimaryLabel: View {
    @Environment(\.pane) private var pane
    let title: String
    let icon: OmramoIcon.Name

    var body: some View {
        HStack(spacing: pane.pt(10)) {
            OmramoIcon(name: icon)
            Text(verbatim: title)
                .lineLimit(1)
        }
        .typeRole(Tokens.UIType.buttonLabel.scaled(by: 18.0 / 17.0))
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity)
        .frame(height: max(PageTurnButton.minimumTouchSide, pane.pt(FinishedChoices.primaryHeight)))
        .background(LinearGradient(vertical: Tokens.Gradients.buttonPrimary), in: Capsule(style: .continuous))
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(
                    LinearGradient(colors: [Color.white.opacity(0.5), Color.white.opacity(0)], startPoint: .top, endPoint: .center),
                    lineWidth: pane.pt(1.5)
                )
        }
        .shadow(color: Color(rgba: RGBA(hex: 0xE8432B, alpha: 0.34)), radius: pane.pt(11), x: 0, y: pane.pt(10))
        .shadow(color: Color.black.opacity(0.14), radius: pane.pt(2), x: 0, y: pane.pt(2))
        .contentShape(Capsule(style: .continuous))
    }
}

/// A secondary choice: a glass capsule with an icon and a word, 48 pt high on the reference
/// pane and never less than 44 pt to touch.
private struct QuietChoiceButton: View {
    @Environment(\.pane) private var pane
    let title: String
    let icon: OmramoIcon.Name
    let action: @MainActor () -> Void

    var body: some View {
        let minimum = CGFloat(Tokens.Size.minimumHitTarget)
        Button(action: action) {
            HStack(spacing: pane.pt(8)) {
                OmramoIcon(name: icon, multiplier: 0.9)
                Text(verbatim: title)
                    .typeRole(Tokens.UIType.buttonLabel.scaled(by: 15.5 / 17))
                    .lineLimit(1)
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, pane.pt(14))
            .frame(maxWidth: .infinity)
            .frame(height: max(minimum, pane.pt(48)))
            .glass(.dark, in: Capsule(style: .continuous))
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(PressScaleButtonStyle())
        .hoverEffect(.lift)
    }
}

// MARK: - Two panes

/// One pane of the two-pane moment: its content centred, clear of the status bar and the home
/// indicator, and scrolling only if the pane is too short for it (the simulated Duo on an
/// iPhone held sideways, the largest text).
private struct FinishedPane<Content: View>: View {
    @Environment(\.pane) private var pane
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                content()
                    .padding(.top, max(pane.pt(20), pane.safeArea.top + pane.pt(8)))
                    .padding(.bottom, pane.bottomInset(20))
                    .frame(maxWidth: .infinity)
                    // Centred when it fits; from the top when it has to scroll.
                    .frame(minHeight: proxy.size.height)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

// MARK: - One pane

/// The words, then the choices, in one column that scrolls only if it must (the largest text
/// on the smallest phone).
private struct FinishedSinglePane: View {
    @Environment(\.pane) private var pane
    let story: Story
    let moral: String?
    let arrived: Bool
    let actions: FinishedActions

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack(spacing: pane.pt(26)) {
                    FinishedMessage(story: story, moral: moral, arrived: arrived)
                    FinishedChoices(actions: actions)
                }
                .padding(.top, max(pane.pt(40), pane.safeArea.top + pane.pt(12)))
                .padding(.bottom, pane.bottomInset(26))
                .frame(maxWidth: .infinity)
                // Centred when it fits; from the top when it has to scroll.
                .frame(minHeight: proxy.size.height)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}
