import SwiftUI
import OmramoCore

/// Library home (docs/DESIGN.md §6, screen 02).
///
/// Leading pane: wordmark and streak chip, "Keep reading", "Stories by level" with the filter
/// and the covers (finished stories carry a tick), the tab bar. Trailing pane: the story map,
/// the streak card, the shelf card (keep reading at the saved place, stories finished) and
/// "Friends you have met". One pane (an iPhone, the folded Duo): the same column with "Keep
/// reading" on top, then the map, the streak card and the friends.
///
/// Every number comes from the stores (`ReadingProgressStore`, `ReadingLogStore`,
/// `ReaderMemoryStore`); with empty stores each card shows its empty state.
///
/// Still stubbed (M4): the "My shelf" and "Grown-ups" tabs, the grown-up gate and the parent
/// view. Nothing here shows a time of day, a duration or a timer.
struct LibraryScreen: View {
    @Environment(AppRouter.self) private var router
    @Environment(ReadingProgressStore.self) private var progress
    @Environment(ReaderMemoryStore.self) private var memory
    @Environment(ReadingLogStore.self) private var log
    let library: Library
    @State private var filter: LibraryFilter = .all

    var body: some View {
        let router = self.router
        let home = LibraryHome(
            library: library,
            keepReading: KeepReading(library: library, position: progress.lastPosition),
            shelf: ShelfState(stories: library.stories, progress: progress.file, log: log.file),
            streak: log.streak,
            friends: FriendMet.all(stories: library.stories, memory: memory.file),
            finished: Set(log.file.finished),
            open: { storyID, source in router.open(storyID, from: source) }
        )
        let shelves = library.shelves(matching: filter)

        TwoPane {
            AuroraBackdrop(aurora: .light)
        } leading: {
            LibraryMainPane(home: home, shelves: shelves, filter: $filter) {
                EmptyView()
            }
        } trailing: {
            LibrarySidePane(home: home)
        } folded: {
            // One pane: the same column, scrolling, with the map, the streak card and the
            // friends after the stories. "Keep reading" is already on top.
            LibraryMainPane(home: home, shelves: shelves, filter: $filter) {
                StoryMapSection(library: library, readingNow: home.keepReading?.story.id)
                LibrarySideCards(home: home, showsShelf: false)
                    .padding(.top, 14)
            }
        }
    }
}

/// The story to offer under "Keep reading": the one read most recently, with its page.
struct KeepReading {
    let story: Story
    let page: Int
    let pageCount: Int

    init?(library: Library, position: ReadingPosition?) {
        guard let position, let story = library.story(id: position.storyID) else { return nil }
        let pager = Pager(story: story)
        guard let page = pager.pageNumber(of: position.spreadID) else { return nil }
        self.story = story
        self.page = page
        self.pageCount = pager.pageCount
    }

    var fraction: Double {
        pageCount > 0 ? Double(page) / Double(pageCount) : 0
    }
}

/// Everything the library shows, read from the stores once per render.
struct LibraryHome {
    let library: Library
    let keepReading: KeepReading?
    let shelf: ShelfState
    let streak: StreakSummary
    let friends: [FriendMet]
    let finished: Set<StoryID>
    /// Opens a story at its saved place, growing out of the thing that was tapped.
    let open: @MainActor (StoryID, HeroSource) -> Void
}

// MARK: - Main column (leading pane, or the whole folded pane)

private struct LibraryMainPane<Extra: View>: View {
    @Environment(\.pane) private var pane
    let home: LibraryHome
    /// The stories to show, level by level (one shelf when a level is chosen).
    let shelves: [LibraryShelf]
    @Binding var filter: LibraryFilter
    /// Extra sections after the stories (the map and cards, when folded).
    @ViewBuilder var extra: () -> Extra

    var body: some View {
        let inset = pane.contentInset + pane.pt(Tokens.Spacing.insetText)
        let cardWidth = max(0, min(pane.pt(Tokens.Spacing.cardWidth), pane.size.width - inset * 2))
        let fade = pane.pt(18)

        VStack(spacing: 0) {
            column(inset: inset, cardWidth: cardWidth, fade: fade)

            // The tab bar has its own strip — 62 pt high, 22 pt above the bottom edge or above
            // the home indicator, whichever is higher — so nothing in the column (the map
            // legend least of all) is ever hidden behind it.
            LibraryTabBar()
                .padding(.top, pane.pt(6))
                .padding(.bottom, pane.bottomInset(22))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func column(inset: CGFloat, cardWidth: CGFloat, fade: CGFloat) -> some View {
        let keepReading = home.keepReading
        let open = home.open
        return ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    WordmarkView()
                    Spacer(minLength: pane.pt(8))
                    if let text = home.streak.chipText {
                        StreakChip(text: text)
                    }
                }
                .frame(width: cardWidth)
                .padding(.leading, inset)

                if let keepReading {
                    SectionLabel(text: "Keep reading")
                        .padding(.leading, inset)
                        .padding(.top, pane.pt(22))
                    Button {
                        open(keepReading.story.id, .keepReading)
                    } label: {
                        KeepReadingCard(keepReading: keepReading)
                            .frame(width: cardWidth, height: pane.pt(Tokens.Size.keepReadingHeight))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                    .heroSource(.keepReading)
                    .padding(.leading, inset)
                    .padding(.top, pane.pt(9))
                    .accessibilityLabel(Text(verbatim: "Continue \(keepReading.story.title), page \(keepReading.page) of \(keepReading.pageCount)"))
                    .accessibilityIdentifier("library.keepReading")
                }

                SectionLabel(text: "Stories by level")
                    .padding(.leading, inset)
                    .padding(.top, pane.pt(keepReading == nil ? 26 : 16))
                LevelFilterView(selection: $filter)
                    .frame(width: cardWidth)
                    .padding(.leading, inset)
                    .padding(.top, pane.pt(9))

                if shelves.isEmpty {
                    // Estimate: the designs show no empty state for a level (gap G10).
                    Text(verbatim: "No stories at this level yet.")
                        .typeRole(Tokens.UIType.bodySmall)
                        .foregroundStyle(Color(rgba: Tokens.Palette.textSecondary))
                        .padding(.leading, inset)
                        .padding(.top, pane.pt(20))
                } else if filter == .all {
                    // Every level: one shelf a level, each scrolling sideways (round 5; the
                    // design's single row of three covers is one such shelf).
                    ForEach(shelves) { shelf in
                        ShelfHeader(shelf: shelf)
                            .frame(width: cardWidth, alignment: .leading)
                            .padding(.leading, inset)
                            .padding(.top, pane.pt(16))
                        ScrollView(.horizontal) {
                            LazyHStack(alignment: .top, spacing: pane.pt(StoryCardView.gap)) {
                                ForEach(shelf.stories) { story in
                                    storyButton(story)
                                }
                            }
                            .padding(.horizontal, inset)
                            .padding(.top, pane.pt(10))
                            .padding(.bottom, pane.pt(16))
                        }
                        .scrollIndicators(.hidden)
                    }
                } else {
                    // One level: all of its covers at once, three to a row at the design width.
                    ForEach(shelves) { shelf in
                        ShelfHeader(shelf: shelf)
                            .frame(width: cardWidth, alignment: .leading)
                            .padding(.leading, inset)
                            .padding(.top, pane.pt(16))
                        LazyVGrid(columns: gridColumns(cardWidth: cardWidth), alignment: .leading, spacing: pane.pt(10)) {
                            ForEach(shelf.stories) { story in
                                storyButton(story)
                            }
                        }
                        .frame(width: cardWidth, alignment: .leading)
                        .padding(.leading, inset)
                        .padding(.top, pane.pt(10))
                        .padding(.bottom, pane.pt(16))
                    }
                }

                extra()
            }
            .padding(.top, max(pane.pt(56), pane.safeArea.top + pane.pt(8)))
            .padding(.bottom, fade + pane.pt(6))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        // The column ends above the tab bar and fades out softly there: cards scroll out of
        // sight instead of sliding underneath the bar.
        .mask {
            VStack(spacing: 0) {
                Color.black
                LinearGradient(colors: [Color.black, Color.black.opacity(0)], startPoint: .top, endPoint: .bottom)
                    .frame(height: fade)
            }
        }
    }
}

extension LibraryMainPane {
    /// One cover that opens its story, growing out of the cover.
    fileprivate func storyButton(_ story: Story) -> some View {
        let open = home.open
        return Button {
            open(story.id, .cover(story.id))
        } label: {
            StoryCardView(story: story, isFinished: home.finished.contains(story.id))
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityIdentifier("library.story.\(story.id.rawValue)")
    }

    /// As many cover-wide columns as fit the card width: three at the design width.
    fileprivate func gridColumns(cardWidth: CGFloat) -> [GridItem] {
        let cover = pane.pt(Tokens.Size.storyCoverWidth)
        let gap = pane.pt(StoryCardView.gap)
        let count = max(2, Int((cardWidth + gap) / max(1, cover + gap)))
        return Array(repeating: GridItem(.fixed(cover), spacing: gap, alignment: .topLeading), count: count)
    }
}

/// The name of a level above its shelf, with how many stories it holds.
private struct ShelfHeader: View {
    @Environment(\.pane) private var pane
    let shelf: LibraryShelf

    var body: some View {
        let tint = Color(rgba: Tokens.TierColors.colors(for: shelf.tier).pillText)
        HStack(spacing: pane.pt(6)) {
            TierGlyph(tier: shelf.tier, color: tint)
            Text(verbatim: shelf.tier.displayName)
                .typeRole(Tokens.UIType.segmentLabel)
                .foregroundStyle(tint)
            Text(verbatim: "· " + shelf.countText)
                .typeRole(Tokens.UIType.storyCardPlace)
                .foregroundStyle(Color(rgba: Tokens.Palette.ink.opacity(0.6)))
            Spacer(minLength: 0)
        }
        .lineLimit(1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Level: \(shelf.tier.displayName), \(shelf.countText)"))
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("library.shelf.\(shelf.tier.rawValue)")
    }
}

// MARK: - Side column (trailing pane)

private struct LibrarySidePane: View {
    @Environment(\.pane) private var pane
    let home: LibraryHome

    var body: some View {
        // The column scrolls only if it must (a short window, the largest text): on the Duo
        // and on an iPad the map, the streak, the shelf and the friends fit as designed.
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                StoryMapSection(library: home.library, readingNow: home.keepReading?.story.id)
                LibrarySideCards(home: home, showsShelf: true)
                    .padding(.top, pane.pt(Tokens.Spacing.cardGap))
            }
            // The label sits at top 60; StoryMapSection adds its own 26 pt above the label.
            .padding(.top, max(pane.pt(60 - 26), pane.safeArea.top + pane.pt(8) - pane.pt(26)))
            .padding(.bottom, pane.bottomInset(22))
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

/// "Where the stories come from" label and the map card.
private struct StoryMapSection: View {
    @Environment(\.pane) private var pane
    let library: Library
    let readingNow: StoryID?

    var body: some View {
        let inset = pane.contentInset + pane.pt(Tokens.Spacing.insetText)
        let cardWidth = max(0, min(pane.pt(Tokens.Spacing.cardWidth), pane.size.width - inset * 2))
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "Where the stories come from")
                .padding(.top, pane.pt(26))
            StoryMapCard(pins: StoryMapPin.pins(for: library, readingNow: readingNow))
                .frame(width: cardWidth, height: cardWidth * CGFloat(Tokens.Size.mapCardHeight / Tokens.Spacing.cardWidth))
                .padding(.top, pane.pt(11))
        }
        .padding(.leading, inset)
    }
}
