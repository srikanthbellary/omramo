import SwiftUI
import OmramoCore

/// Library home (docs/DESIGN.md §6, screen 02) — the M1 subset.
///
/// Implemented: wordmark, "Keep reading" card when a position is saved, "Stories by level"
/// filter, story cards from the catalog, the tab bar (Library only), and the story map with
/// real pins from the catalog.
///
/// Not in M1 (TODO(M4)): streak chip and card, shelf card, friends row, finished ticks,
/// the My shelf and Grown-ups tabs. They need the reading log and the grown-up gate.
struct LibraryScreen: View {
    @Environment(AppRouter.self) private var router
    @Environment(ReadingProgressStore.self) private var progress
    let library: Library
    @State private var filter: LibraryFilter = .all

    var body: some View {
        let keepReading = KeepReading(library: library, position: progress.lastPosition)
        let stories = library.stories.filter { filter.includes($0.tier) }
        let open: @MainActor (StoryID) -> Void = { router.open($0) }

        TwoPane {
            AuroraBackdrop(aurora: .light)
        } leading: {
            LibraryMainPane(keepReading: keepReading, stories: stories, filter: $filter, open: open) {
                EmptyView()
            }
        } trailing: {
            LibrarySidePane(library: library, readingNow: keepReading?.story.id)
        } folded: {
            // One pane: the same column, scrolling, with the story map after the stories.
            LibraryMainPane(keepReading: keepReading, stories: stories, filter: $filter, open: open) {
                StoryMapSection(library: library, readingNow: keepReading?.story.id)
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

// MARK: - Main column (leading pane, or the whole folded pane)

private struct LibraryMainPane<Extra: View>: View {
    @Environment(\.pane) private var pane
    let keepReading: KeepReading?
    let stories: [Story]
    @Binding var filter: LibraryFilter
    let open: @MainActor (StoryID) -> Void
    /// Extra sections after the stories (the story map, when folded).
    @ViewBuilder var extra: () -> Extra

    var body: some View {
        let inset = pane.pt(Tokens.Spacing.insetText)
        let cardWidth = min(pane.pt(Tokens.Spacing.cardWidth), pane.size.width - inset * 2)
        let tabBarClearance = pane.bottomInset(22) + pane.pt(Tokens.Size.tabBarHeight) + pane.pt(16)

        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                WordmarkView()
                    .padding(.leading, inset)
                // TODO(M4): streak chip ("5 days") at the top right.

                if let keepReading {
                    SectionLabel(text: "Keep reading")
                        .padding(.leading, inset)
                        .padding(.top, pane.pt(26))
                    Button {
                        open(keepReading.story.id)
                    } label: {
                        KeepReadingCard(keepReading: keepReading)
                            .frame(width: cardWidth, height: pane.pt(Tokens.Size.keepReadingHeight))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                    .padding(.leading, inset)
                    .padding(.top, pane.pt(9))
                    .accessibilityLabel(Text(verbatim: "Continue \(keepReading.story.title), page \(keepReading.page) of \(keepReading.pageCount)"))
                }

                SectionLabel(text: "Stories by level")
                    .padding(.leading, inset)
                    .padding(.top, pane.pt(keepReading == nil ? 26 : 16))
                LevelFilterView(selection: $filter)
                    .frame(width: cardWidth)
                    .padding(.leading, inset)
                    .padding(.top, pane.pt(9))

                if stories.isEmpty {
                    // Estimate: the designs show no empty state for a level (gap G10).
                    Text(verbatim: "No stories at this level yet.")
                        .typeRole(Tokens.UIType.bodySmall)
                        .foregroundStyle(Color(rgba: Tokens.Palette.textSecondary))
                        .padding(.leading, inset)
                        .padding(.top, pane.pt(20))
                } else {
                    // The design shows three cards; more scroll sideways (estimate).
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: pane.pt(12)) {
                            ForEach(stories) { story in
                                Button {
                                    open(story.id)
                                } label: {
                                    StoryCardView(story: story)
                                }
                                .buttonStyle(PressScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal, inset)
                        .padding(.top, pane.pt(14))
                        .padding(.bottom, pane.pt(28))
                    }
                    .scrollIndicators(.hidden)
                }

                extra()
            }
            .padding(.top, max(pane.pt(56), pane.safeArea.top + pane.pt(8)))
            .padding(.bottom, tabBarClearance)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .overlay(alignment: .bottom) {
            LibraryTabBar()
                .padding(.bottom, pane.bottomInset(22))
        }
    }
}

// MARK: - Side column (trailing pane)

private struct LibrarySidePane: View {
    @Environment(\.pane) private var pane
    let library: Library
    let readingNow: StoryID?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StoryMapSection(library: library, readingNow: readingNow)
            // TODO(M4): streak card (top 312), shelf card (top 430), "Friends you have met"
            // (top 580). Omitted in M1: they need the reading log (listed deviation).
            Spacer(minLength: 0)
        }
        // The label sits at top 60; StoryMapSection adds its own 26 pt above the label.
        .padding(.top, max(pane.pt(60 - 26), pane.safeArea.top + pane.pt(8) - pane.pt(26)))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

/// "Where the stories come from" label and the map card.
private struct StoryMapSection: View {
    @Environment(\.pane) private var pane
    let library: Library
    let readingNow: StoryID?

    var body: some View {
        let inset = pane.pt(Tokens.Spacing.insetText)
        let cardWidth = min(pane.pt(Tokens.Spacing.cardWidth), pane.size.width - inset * 2)
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
