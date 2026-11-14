import SwiftUI
import UIKit
import OmramoCore

// The library's side column under the map (docs/DESIGN.md §6, screen 02, right pane): the
// streak card, the shelf card and "Friends you have met". The M4 subset — no "My shelf" tab,
// no grown-up gate, no parent view.
//
// Tone: gentle. A streak is something a child has, never something they are about to lose;
// there is no countdown, no warning and no word for a missed day. Nothing here shows a time of
// day, a duration or a timer.

// MARK: - Hero source

/// Tells the router where a library element is on screen, so a story can open out of it and
/// close back into it (`Motion.hero`).
private struct HeroSourceModifier: ViewModifier {
    @Environment(AppRouter.self) private var router
    let source: HeroSource

    func body(content: Content) -> some View {
        let router = self.router
        let source = self.source
        return content.onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { frame in
            router.report(frame, for: source)
        }
    }
}

extension View {
    func heroSource(_ source: HeroSource) -> some View {
        modifier(HeroSourceModifier(source: source))
    }
}

// MARK: - The cards together

/// Streak card, shelf card (two panes only) and the friends row, at the library's card width.
struct LibrarySideCards: View {
    @Environment(\.pane) private var pane
    let home: LibraryHome
    /// False on one pane, where the large "Keep reading" card already leads the column.
    let showsShelf: Bool

    var body: some View {
        let inset = pane.contentInset + pane.pt(Tokens.Spacing.insetText)
        let cardWidth = max(0, min(pane.pt(Tokens.Spacing.cardWidth), pane.size.width - inset * 2))
        VStack(alignment: .leading, spacing: pane.pt(Tokens.Spacing.cardGap)) {
            StreakCard(streak: home.streak)
                .frame(width: cardWidth, alignment: .leading)
            if showsShelf {
                ShelfCard(home: home)
                    .frame(width: cardWidth, alignment: .leading)
            }
            FriendsSection(friends: home.friends, width: cardWidth)
                .padding(.top, pane.pt(8))
        }
        .padding(.leading, inset)
    }
}

// MARK: - Streak

/// The chip beside the wordmark: a flame and "5 days".
struct StreakChip: View {
    @Environment(\.pane) private var pane
    let text: String

    var body: some View {
        HStack(spacing: pane.pt(7)) {
            OmramoIcon(name: .flame, multiplier: 0.9)
                .foregroundStyle(LinearGradient(vertical: Tokens.Gradients.streakDay))
            Text(verbatim: text)
                .typeRole(Tokens.UIType.chip.scaled(by: 14.0 / 12.0))
                .foregroundStyle(Color(rgba: Tokens.Palette.ink))
                .lineLimit(1)
        }
        .padding(.leading, pane.pt(11))
        .padding(.trailing, pane.pt(13))
        .frame(height: pane.pt(34))
        .glass(.light, fill: RGBA(hex: 0xFFFFFF, alpha: 0.82), in: Capsule(style: .continuous))
        .fixedSize()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Reading days in a row: \(text)"))
        .accessibilityIdentifier("library.streakChip")
    }
}

/// "3 days in a row" and this week's seven days. A day that was read has a tick; today has a
/// ring; every other day is simply empty.
struct StreakCard: View {
    @Environment(\.pane) private var pane
    let streak: StreakSummary

    var body: some View {
        let ink = Color(rgba: Tokens.Palette.ink)
        let secondary = Color(rgba: Tokens.Palette.textSecondary)
        let title = Text(verbatim: streak.title)
            .typeRole(Tokens.UIType.cardHeading)
            .foregroundStyle(ink)
            .lineLimit(1)
        let caption = Text(verbatim: StreakSummary.caption)
            .typeRole(Tokens.UIType.bodySmall.scaled(by: 12.0 / 13.0))
            .foregroundStyle(secondary)
            .lineLimit(1)

        VStack(alignment: .leading, spacing: pane.pt(12)) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: pane.pt(8)) {
                    title
                    Spacer(minLength: pane.pt(8))
                    caption
                }
                VStack(alignment: .leading, spacing: pane.pt(3)) {
                    title
                    caption
                }
            }
            HStack(spacing: 0) {
                ForEach(streak.week) { day in
                    dayView(day)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, pane.pt(18))
        .padding(.top, pane.pt(16))
        .padding(.bottom, pane.pt(14))
        .frame(maxWidth: .infinity, alignment: .leading)
        .omramoCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: accessibilitySummary))
        .accessibilityIdentifier("library.streak")
    }

    private var accessibilitySummary: String {
        let read = streak.week.filter(\.isRead).count
        let week = read == 1 ? "1 day read this week" : "\(read) days read this week"
        return "\(streak.title). \(StreakSummary.caption). \(week)."
    }

    private func dayView(_ day: StreakDay) -> some View {
        let side = pane.pt(30)
        let ring = Color(rgba: RGBA(hex: 0xFF7A3D))
        return VStack(spacing: pane.pt(6)) {
            ZStack {
                if day.isRead {
                    Circle().fill(LinearGradient(vertical: Tokens.Gradients.streakDay))
                    OmramoIcon(name: .check)
                        .foregroundStyle(Color.white)
                } else {
                    Circle().fill(Color(rgba: Tokens.Palette.ink.opacity(0.06)))
                }
                if day.isToday {
                    // Today: a ring, read or not. An invitation, not a reminder.
                    Circle()
                        .strokeBorder(ring.opacity(day.isRead ? 0.9 : 0.55), lineWidth: pane.pt(2))
                        .padding(-pane.pt(3.5))
                }
            }
            .frame(width: side, height: side)
            Text(verbatim: day.letter)
                .typeRole(Tokens.UIType.tabLabel)
                .foregroundStyle(Color(rgba: Tokens.Palette.ink.opacity(day.isToday ? 0.8 : 0.45)))
        }
    }
}

// MARK: - Shelf

/// "My shelf": the story to keep reading, as one large button that opens it at the saved
/// place, and the stories finished. With nothing read yet it says so kindly.
struct ShelfCard: View {
    @Environment(\.pane) private var pane
    let home: LibraryHome

    var body: some View {
        let ink = Color(rgba: Tokens.Palette.ink)
        let secondary = Color(rgba: Tokens.Palette.textSecondary)
        let shelf = home.shelf
        let finished = shelf.finished.compactMap { home.library.story(id: $0) }

        VStack(alignment: .leading, spacing: pane.pt(12)) {
            HStack(alignment: .firstTextBaseline, spacing: pane.pt(8)) {
                Text(verbatim: "My shelf")
                    .typeRole(Tokens.UIType.cardHeading)
                    .foregroundStyle(ink)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: pane.pt(8))
                if let summary = shelf.summary {
                    Text(verbatim: summary)
                        .typeRole(Tokens.UIType.bodySmall.scaled(by: 12.0 / 13.0))
                        .foregroundStyle(secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }

            if let keep = shelf.keepReading, let story = home.library.story(id: keep.storyID) {
                keepReadingRow(story: story, keep: keep)
            }

            if !finished.isEmpty {
                HStack(spacing: pane.pt(10)) {
                    ForEach(finished) { story in
                        finishedCover(story)
                    }
                    Spacer(minLength: 0)
                }
            }

            if shelf.keepReading == nil && finished.isEmpty {
                Text(verbatim: "Stories you start will wait here, with your place kept.")
                    .typeRole(Tokens.UIType.bodySmall)
                    .foregroundStyle(secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("library.shelf.empty")
            }
        }
        .padding(.horizontal, pane.pt(18))
        .padding(.top, pane.pt(16))
        .padding(.bottom, pane.pt(16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .omramoCard()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("library.shelf")
    }

    /// Cover, title and "Page 5 of 16": one big tap target that opens the story at its place.
    private func keepReadingRow(story: Story, keep: ShelfState.InProgress) -> some View {
        let ink = Color(rgba: Tokens.Palette.ink)
        let open = home.open
        let coverShape = RoundedRectangle(cornerRadius: pane.pt(Tokens.Radius.shelfCover), style: .continuous)
        return Button {
            open(story.id, .shelf(story.id))
        } label: {
            HStack(spacing: pane.pt(12)) {
                CoverArtView(story: story)
                    .frame(width: pane.pt(58), height: pane.pt(68))
                    .clipShape(coverShape)
                    .overlay(coverShape.strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5))
                    .shadow(color: Color(rgba: Tokens.Surfaces.coverShadow.opacity(0.18)), radius: pane.pt(5), x: 0, y: pane.pt(4))
                    .heroSource(.shelf(story.id))

                VStack(alignment: .leading, spacing: pane.pt(4)) {
                    Text(verbatim: "Keep reading")
                        .typeRole(Tokens.UIType.sectionLabel)
                        .foregroundStyle(Color(rgba: Tokens.Palette.textLabel))
                    Text(verbatim: story.title)
                        .typeRole(Tokens.UIType.storyCardTitle.scaled(by: 14.5 / 13.0))
                        .foregroundStyle(ink)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: pane.pt(8)) {
                        Text(verbatim: "Page \(keep.page) of \(keep.pageCount)")
                            .typeRole(Tokens.UIType.chip)
                            .foregroundStyle(Color(rgba: Tokens.Palette.violetStrong))
                            .lineLimit(1)
                            .fixedSize()
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color(rgba: Tokens.Palette.ink.opacity(0.1)))
                                Capsule().fill(Color(rgba: Tokens.Palette.violetStrong))
                                    .frame(width: max(proxy.size.height, proxy.size.width * CGFloat(keep.fraction)))
                            }
                        }
                        .frame(height: pane.pt(5))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                OmramoIcon(name: .chevronRight)
                    .foregroundStyle(Color(rgba: Tokens.Palette.ink.opacity(0.45)))
            }
            .padding(pane.pt(8))
            .frame(maxWidth: .infinity, minHeight: max(56, pane.pt(84)), alignment: .leading)
            .background(
                Color(rgba: Tokens.Palette.violet.opacity(0.07)),
                in: RoundedRectangle(cornerRadius: pane.pt(18), style: .continuous)
            )
            .contentShape(RoundedRectangle(cornerRadius: pane.pt(18), style: .continuous))
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel(Text(verbatim: "Keep reading \(story.title), page \(keep.page) of \(keep.pageCount)"))
        .accessibilityIdentifier("library.shelf.keepReading")
    }

    /// A finished story's cover with its tick. Tapping it opens the story again from page 1.
    private func finishedCover(_ story: Story) -> some View {
        let open = home.open
        let shape = RoundedRectangle(cornerRadius: pane.pt(Tokens.Radius.shelfCover), style: .continuous)
        let width = max(CGFloat(Tokens.Size.minimumHitTarget), pane.pt(48))
        return Button {
            open(story.id, .shelf(story.id))
        } label: {
            CoverArtView(story: story)
                .frame(width: width, height: width * 56 / 48)
                .clipShape(shape)
                .overlay(shape.strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5))
                .overlay(alignment: .bottomTrailing) {
                    FinishedTick(diameter: 18)
                        .padding(pane.pt(3))
                }
                .shadow(color: Color(rgba: Tokens.Surfaces.coverShadow.opacity(0.18)), radius: pane.pt(4), x: 0, y: pane.pt(3))
                .heroSource(.shelf(story.id))
                .contentShape(shape)
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel(Text(verbatim: "\(story.title). Finished. Read it again."))
    }
}

/// The white disc with a green tick on a finished story's cover.
struct FinishedTick: View {
    @Environment(\.pane) private var pane
    /// Reference points: 24 on a library cover, smaller on the shelf.
    var diameter: Double = 24

    var body: some View {
        let side = pane.pt(diameter)
        ZStack {
            Circle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.18), radius: pane.pt(2), x: 0, y: pane.pt(1))
            OmramoIcon(name: .check, multiplier: CGFloat(diameter / 24))
                .foregroundStyle(Color(rgba: Tokens.Palette.finishedCheck))
        }
        .frame(width: side, height: side)
        .accessibilityHidden(true)
    }
}

// MARK: - Friends

/// "Friends you have met": the face of every character whose name the child has read.
struct FriendsSection: View {
    @Environment(\.pane) private var pane
    let friends: [FriendMet]
    let width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: pane.pt(10)) {
            SectionLabel(text: "Friends you have met")
            if friends.isEmpty {
                HStack(spacing: pane.pt(12)) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(Color(rgba: Tokens.Palette.ink.opacity(0.05)))
                            .overlay(
                                Circle().strokeBorder(
                                    Color(rgba: Tokens.Palette.ink.opacity(0.18)),
                                    style: StrokeStyle(lineWidth: pane.pt(1.5), dash: [pane.pt(4), pane.pt(4)])
                                )
                            )
                            .frame(width: pane.pt(52), height: pane.pt(52))
                    }
                    Text(verbatim: "Friends you meet in stories will wait here.")
                        .typeRole(Tokens.UIType.bodySmall)
                        .foregroundStyle(Color(rgba: Tokens.Palette.textSecondary))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: width, alignment: .leading)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("library.friends.empty")
            } else {
                // More friends than fit scroll sideways; the row never wraps or shrinks.
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: pane.pt(10)) {
                        ForEach(friends) { friend in
                            FriendChip(friend: friend)
                        }
                    }
                    .padding(.vertical, pane.pt(4))
                    .padding(.horizontal, pane.pt(4))
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
                .frame(width: width + pane.pt(8), alignment: .leading)
                .padding(.leading, -pane.pt(4))
                .accessibilityIdentifier("library.friends")
            }
        }
    }
}

/// A friend's face in a ring of their own colour, with their name beneath.
struct FriendChip: View {
    @Environment(\.pane) private var pane
    let friend: FriendMet

    var body: some View {
        let character = friend.character
        let side = pane.pt(56)
        let ring = Color(hex: character.color, fallback: Tokens.Palette.ink)
        let background = Color(rgba: character.chipBackground.flatMap { RGBA(string: $0) } ?? RGBA(hex: 0xFFFFFF))
        let face = FaceChipRenderer.face(for: character, storyID: friend.storyID)

        VStack(spacing: pane.pt(6)) {
            ZStack {
                Circle().fill(background)
                if let face {
                    Image(uiImage: face)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                } else {
                    Circle().fill(ring.opacity(0.35)).padding(pane.pt(10))
                }
                Circle().strokeBorder(ring, lineWidth: pane.pt(3))
                Circle().strokeBorder(Color.white.opacity(0.9), lineWidth: pane.pt(1.5)).padding(pane.pt(3))
            }
            .frame(width: side, height: side)
            .shadow(color: Color(rgba: Tokens.Surfaces.coverShadow.opacity(0.16)), radius: pane.pt(4), x: 0, y: pane.pt(3))

            Text(verbatim: friend.shortName)
                .typeRole(Tokens.UIType.storyCardPlace)
                .foregroundStyle(Color(rgba: Tokens.Palette.ink.opacity(0.75)))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(width: side + pane.pt(8))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: character.name))
        .accessibilityIdentifier("library.friend.\(character.id.rawValue)")
    }
}
