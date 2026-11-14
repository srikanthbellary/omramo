import XCTest
import SwiftUI
import UIKit
import OmramoCore
@testable import Omramo

/// Reader behaviour that needs the app's own types: the model (M2, M3), the reader's geometry
/// on phone, Duo and iPad windows (Mi), and the code-drawn art.
@MainActor
final class ReaderModelTests: XCTestCase {
    private func bundledLibrary() throws -> Library {
        try BundledContent.repository().loadLibrary()
    }

    private func bundledStory(_ id: String) throws -> Story {
        try XCTUnwrap(try bundledLibrary().story(id: StoryID(id)))
    }

    private func temporaryFile(_ name: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("omramo-tests-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent(name)
    }

    /// A plan that puts each paragraph of the page on its own screen.
    private func oneParagraphPerScreen(_ spread: Spread) -> ScreenPlan {
        ScreenPlan(screens: spread.blocks.map { ScreenPlan.Screen(leading: [$0.id]) })
    }

    // MARK: M2 — continuation screens, back, position

    func testRoundButtonWalksContinuationScreensThenTurnsThePage() throws {
        let story = try bundledStory("monkey-and-crocodile")
        let progress = ReadingProgressStore(fileURL: nil)
        let model = ReaderModel(story: story, progress: progress)
        let first = story.spreads[0]
        let plan = oneParagraphPerScreen(first)
        XCTAssertGreaterThan(plan.screenCount, 2)

        // Same page number on every continuation screen.
        for screen in 1..<plan.screenCount {
            model.turnPage(in: plan)
            XCTAssertEqual(model.pageNumber, 1)
            XCTAssertEqual(plan.index(for: model.anchor), screen)
            XCTAssertEqual(progress.position(for: story.id)?.blockID, first.blocks[screen].id)
        }
        // One more press leaves the page.
        model.turnPage(in: plan)
        XCTAssertEqual(model.pageNumber, 2)
        XCTAssertEqual(model.anchor, .start)
    }

    func testBackGoesToTheLastScreenOfThePageBefore() throws {
        let story = try bundledStory("monkey-and-crocodile")
        let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil))
        XCTAssertTrue(model.isAtStart(screen: 0))
        model.goBack()
        XCTAssertEqual(model.pageNumber, 1, "nothing before the first page")

        model.turnPage()
        XCTAssertEqual(model.pageNumber, 2)
        model.goBack()
        XCTAssertEqual(model.pageNumber, 1)
        XCTAssertEqual(model.anchor, .end)

        // Once laid out, "the end" settles on the paragraph first on that screen.
        let plan = oneParagraphPerScreen(story.spreads[0])
        let last = plan.index(for: model.anchor)
        XCTAssertEqual(last, plan.screenCount - 1)
        model.didShow(screen: last, of: plan)
        XCTAssertEqual(model.anchor, .block(story.spreads[0].blocks[last].id))

        // And back again steps through that page's screens.
        model.goBack(in: plan)
        XCTAssertEqual(plan.index(for: model.anchor), last - 1)
        XCTAssertEqual(model.pageNumber, 1)
    }

    func testEveryPageOfEveryStoryCanBeReachedAndLeft() throws {
        // Criterion 2.7, with the on-screen controls' own model calls.
        for story in try bundledLibrary().stories {
            let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil))
            var seen = [model.pageNumber]
            while !model.isLastPage {
                model.turnPage()
                seen.append(model.pageNumber)
            }
            XCTAssertEqual(seen, Array(1...story.spreads.count), "\(story.id)")
            XCTAssertTrue(model.isAtEnd(screen: 0, screenCount: 1))
            while model.pageNumber > 1 {
                model.goBack()
            }
            XCTAssertTrue(model.isAtStart(screen: 0), "\(story.id)")
        }
    }

    func testPositionRestoresThePageAndTheParagraph() throws {
        let story = try bundledStory("urashima-taro")
        let progress = ReadingProgressStore(fileURL: nil)
        let model = ReaderModel(story: story, progress: progress)
        model.turnPage()
        model.turnPage()
        let spread = story.spreads[2]
        let plan = oneParagraphPerScreen(spread)
        model.turnPage(in: plan)
        XCTAssertEqual(model.pageNumber, 3)

        // A new reader (relaunch, or the same story opened again) is on the same screen.
        let reopened = ReaderModel(story: story, progress: progress)
        XCTAssertEqual(reopened.pageNumber, 3)
        XCTAssertEqual(reopened.anchor, .block(spread.blocks[1].id))
        XCTAssertEqual(plan.index(for: reopened.anchor), 1)
        // In a layout where the page fits on one screen, that is the screen shown.
        let roomy = ScreenPlan(unmeasured: spread.blocks, twoColumns: true)
        XCTAssertEqual(roomy.index(for: reopened.anchor), 0)
    }

    func testCrumbSubtitle() throws {
        let anansi = ReaderModel(story: try bundledStory("anansi-wisdom"), progress: ReadingProgressStore(fileURL: nil))
        XCTAssertEqual(anansi.crumbSubtitle, "An Anansi story")
        let monkey = ReaderModel(story: try bundledStory("monkey-and-crocodile"), progress: ReadingProgressStore(fileURL: nil))
        XCTAssertEqual(monkey.crumbSubtitle, "Part I")
        let urashima = ReaderModel(story: try bundledStory("urashima-taro"), progress: ReadingProgressStore(fileURL: nil))
        XCTAssertEqual(urashima.crumbSubtitle, "The Fisher Lad")
    }

    // MARK: M2 — text size and bookmark

    func testTextSizeIsRememberedAndStartsFromTheSystemSize() throws {
        let url = temporaryFile("reader-memory.json")
        let memory = ReaderMemoryStore(fileURL: url)
        let story = try bundledStory("monkey-and-crocodile")
        let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil), memory: memory)
        XCTAssertEqual(model.textSize, .standard)

        // The first time only, the system's text size decides.
        model.adoptSystemTextSize(index: 5)
        XCTAssertEqual(model.textSize, .larger)
        model.setTextSize(.largest)
        model.adoptSystemTextSize(index: 0)
        XCTAssertEqual(model.textSize, .largest, "a choice once made is kept")

        // Persisted.
        XCTAssertEqual(ReaderMemoryStore(fileURL: url).textSize, .largest)
    }

    func testBookmarkSavesAndRestoresAPlace() throws {
        let url = temporaryFile("reader-memory.json")
        let memory = ReaderMemoryStore(fileURL: url)
        let story = try bundledStory("anansi-wisdom")
        let progress = ReadingProgressStore(fileURL: nil)
        let model = ReaderModel(story: story, progress: progress, memory: memory)
        XCTAssertNil(model.bookmark)
        XCTAssertFalse(model.isCurrentPageBookmarked)

        model.turnPage()
        model.turnPage()
        model.toggleBookmark()
        XCTAssertTrue(model.isCurrentPageBookmarked)
        XCTAssertEqual(model.bookmarkPage, 3)
        XCTAssertEqual(model.toast, .bookmarkSaved)

        // Read on, then come back to the bookmark.
        model.turnPage()
        model.turnPage()
        XCTAssertFalse(model.isCurrentPageBookmarked)
        XCTAssertEqual(model.bookmarkPage, 3)
        model.goToBookmark()
        XCTAssertEqual(model.pageNumber, 3)
        XCTAssertTrue(model.isCurrentPageBookmarked)

        // The bookmark survives a relaunch…
        let later = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil), memory: ReaderMemoryStore(fileURL: url))
        XCTAssertEqual(later.pageNumber, 1)
        XCTAssertEqual(later.bookmarkPage, 3)
        later.goToBookmark()
        XCTAssertEqual(later.pageNumber, 3)

        // …and pressing the control on the bookmarked page removes it.
        later.toggleBookmark()
        XCTAssertNil(later.bookmark)
        XCTAssertEqual(later.toast, .bookmarkRemoved)
        XCTAssertNil(ReaderMemoryStore(fileURL: url).bookmark(for: story.id))
    }

    // MARK: M3 — cards

    func testOpeningACardHoldsThePageAndClosingMarksItSeen() throws {
        let library = try bundledLibrary()
        let story = try XCTUnwrap(library.story(id: StoryID("monkey-and-crocodile")))
        let url = temporaryFile("reader-memory.json")
        let memory = ReaderMemoryStore(fileURL: url)
        let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil), memory: memory, landmarks: library.landmarks)
        let block = story.spreads[0].blocks[0]
        let riverBank = StoryCardRef.tapTarget(TapTargetID("river-bank"))

        XCTAssertEqual(model.markState(for: riverBank), .idle)
        XCTAssertTrue(model.canOpen(riverBank))
        model.open(riverBank, from: block.id)
        XCTAssertEqual(model.openCard?.ref, riverBank)
        XCTAssertEqual(model.openCard?.blockID, block.id)
        XCTAssertEqual(model.markState(for: riverBank), .open)
        XCTAssertEqual(model.openCardContent?.title, "River bank")

        // Criterion 3.5: the page cannot be turned, backed, re-sized or bookmarked meanwhile.
        model.turnPage()
        XCTAssertEqual(model.pageNumber, 1)
        model.goBack()
        XCTAssertEqual(model.pageNumber, 1)
        model.setTextSize(.largest)
        XCTAssertEqual(model.textSize, .standard)
        model.toggleBookmark()
        XCTAssertNil(model.bookmark)

        // Criterion 3.3: a card cannot open another card.
        model.open(.character(CharacterID("monkey")), from: block.id)
        XCTAssertEqual(model.openCard?.ref, riverBank)

        model.closeCard()
        XCTAssertNil(model.openCard)
        XCTAssertEqual(model.returnedCard?.blockID, block.id)
        XCTAssertEqual(model.toast, .backAtLine)
        XCTAssertEqual(model.markState(for: riverBank), .seen)

        // Criterion 3.6: still opens, and the seen state survives a relaunch.
        XCTAssertTrue(model.canOpen(riverBank))
        XCTAssertTrue(ReaderMemoryStore(fileURL: url).hasSeen(riverBank, in: story.id))

        // The place marker clears when the child moves on.
        model.turnPage()
        XCTAssertNil(model.returnedCard)
        XCTAssertEqual(model.pageNumber, 2)
    }

    func testLandmarkAndCharacterCardsOpenAndNamesWithoutCardsDoNot() throws {
        let library = try bundledLibrary()
        let story = try XCTUnwrap(library.story(id: StoryID("monkey-and-crocodile")))
        let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil), landmarks: library.landmarks)

        // The landmark card is the tap-to-see card, in the Low wording, framed.
        guard case .tap(let taj)? = model.cardContent(for: .tapTarget(TapTargetID("taj-mahal-moment"))) else {
            return XCTFail("the Taj Mahal moment should open a card")
        }
        XCTAssertTrue(taj.isLandmark)
        XCTAssertTrue(taj.isFramed)
        XCTAssertEqual(taj.noteLabel, "LONG AFTER THIS STORY")
        XCTAssertEqual(taj.line, library.landmarks.landmark(id: LandmarkID("taj-mahal"))?.factCards.low.line)

        XCTAssertTrue(model.canOpen(.character(CharacterID("monkey"))))
        XCTAssertFalse(model.canOpen(.character(CharacterID("crocodile"))), "no card, so the name is not a tap target")
        model.open(.character(CharacterID("crocodile")), from: story.spreads[0].blocks[0].id)
        XCTAssertNil(model.openCard)
    }

    func testOpenCardKeepsItsScreenWhenTheLayoutChanges() throws {
        let library = try bundledLibrary()
        let story = try XCTUnwrap(library.story(id: StoryID("urashima-taro")))
        let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil), landmarks: library.landmarks)
        let spread = story.spreads[0]
        let last = try XCTUnwrap(spread.blocks.last)
        // A card opened from the last paragraph while the page is on one screen…
        model.open(.character(CharacterID("urashima")), from: last.id)
        XCTAssertNotNil(model.openCard)
        // …then the window shrinks and the page needs several screens. The reader follows the
        // paragraph holding the word, and the card stays open.
        let narrow = oneParagraphPerScreen(spread)
        let screen = narrow.index(for: .block(last.id))
        XCTAssertEqual(screen, narrow.screenCount - 1)
        model.didShow(screen: screen, of: narrow)
        XCTAssertNotNil(model.openCard)
        XCTAssertEqual(narrow.index(for: model.anchor), screen)
        model.closeCard()
        XCTAssertEqual(narrow.index(for: model.anchor), screen)
    }

    func testFriendsAreMetWhenTheirNamesAreShown() throws {
        let story = try bundledStory("monkey-and-crocodile")
        let memory = ReaderMemoryStore(fileURL: nil)
        let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil), memory: memory)
        XCTAssertEqual(memory.friends(in: story.id), [])
        let plan = ScreenPlan(unmeasured: story.spreads[0].blocks, twoColumns: false)
        model.didShow(screen: 0, of: plan)
        XCTAssertEqual(memory.friends(in: story.id), [CharacterID("mother-crocodile")])
        // Shown again: still met once.
        model.didShow(screen: 0, of: plan)
        XCTAssertEqual(memory.friends(in: story.id).count, 1)
    }
}

/// Mi: the reader's geometry on real window sizes. Text, chrome, the page-turn button and the
/// footer never overlap, on any of them.
@MainActor
final class ReaderGeometryTests: XCTestCase {
    private struct Window {
        var name: String
        var width: Double
        var height: Double
        var top: CGFloat
        var bottom: CGFloat
    }

    /// Points, with the safe areas those devices report (status bar / home indicator).
    private let windows: [Window] = [
        Window(name: "Duo reference", width: 892, height: 720, top: 0, bottom: 0),
        Window(name: "iPhone SE", width: 375, height: 667, top: 20, bottom: 0),
        Window(name: "iPhone 17 Pro Max", width: 440, height: 956, top: 62, bottom: 34),
        Window(name: "iPad Pro 11 landscape", width: 1210, height: 834, top: 24, bottom: 20),
        Window(name: "iPad Pro 11 portrait", width: 834, height: 1210, top: 24, bottom: 20),
        Window(name: "iPad Pro 13 landscape", width: 1376, height: 1032, top: 24, bottom: 20),
        Window(name: "iPad Pro 13 portrait", width: 1032, height: 1376, top: 24, bottom: 20),
        Window(name: "Split View half (13 landscape)", width: 678, height: 1024, top: 24, bottom: 20),
        Window(name: "Split View two thirds (13 landscape)", width: 981, height: 1024, top: 24, bottom: 20),
        Window(name: "Slide Over", width: 320, height: 1000, top: 0, bottom: 20),
        Window(name: "Stage Manager small", width: 760, height: 620, top: 0, bottom: 0),
    ]

    func testTextNeverMeetsTheChromeOnAnyWindow() throws {
        let library = try BundledContent.repository().loadLibrary()
        let resolver = PaneLayoutResolver()
        for window in windows {
            let layout = resolver.resolve(PaneLayoutInput(canvasWidth: window.width, canvasHeight: window.height))
            let safeArea = EdgeInsets(top: window.top, leading: 0, bottom: window.bottom, trailing: 0)
            for story in library.stories {
                for step in TextSizeStep.allCases {
                    let spread = story.spreads[0]
                    let metrics = ReaderMetrics(layout: layout, safeArea: safeArea, story: story, spread: spread, textSize: step)
                    let label = "\(window.name), \(story.id), \(step)"
                    let s = metrics.scale
                    let paneWidth = metrics.paneSize.width
                    let paneHeight = metrics.paneSize.height

                    // The top controls clear the status bar, and text starts below them.
                    XCTAssertGreaterThanOrEqual(metrics.controlTop, window.top, label)
                    XCTAssertGreaterThan(metrics.textTop, metrics.controlTop + 40 * s, label)

                    // The column is inside the pane with a margin on both sides.
                    XCTAssertGreaterThanOrEqual(metrics.columnX, 30 * s - 0.01, label)
                    XCTAssertLessThanOrEqual(metrics.columnX + metrics.columnWidth, paneWidth - 20 * s + 0.01, label)
                    XCTAssertGreaterThan(metrics.columnWidth, 200 * s, label)

                    // Text ends above the footer chrome and the home indicator.
                    XCTAssertGreaterThan(metrics.leadingCapacity, 0, label)
                    let leadingBottom = metrics.textTop + metrics.leadingCapacity
                    if metrics.posture == .unfolded {
                        let chipsTop = paneHeight - max(29 * s, window.bottom + 6 * s) - 28 * s
                        XCTAssertLessThanOrEqual(leadingBottom, chipsTop, label)
                        let pageTurnTop = paneHeight - max(24 * s, window.bottom + 6 * s) - 60 * s
                        XCTAssertLessThanOrEqual(metrics.textTop + metrics.trailingCapacity, pageTurnTop, label)
                        XCTAssertEqual(metrics.pictureHeight, 0, label)
                    } else {
                        let pageTurnTop = paneHeight - max(22 * s, window.bottom + 6 * s) - 54 * s
                        XCTAssertLessThanOrEqual(leadingBottom, pageTurnTop, label)
                        // The picture band holds the top controls and leaves the words room.
                        XCTAssertGreaterThanOrEqual(metrics.pictureHeight, metrics.controlTop + 40 * s, label)
                        XCTAssertLessThan(metrics.pictureHeight, paneHeight * 0.62, label)
                    }

                    // Never a stretched phone: the design is not blown up past 1.3 ×.
                    if layout.source == .derived {
                        XCTAssertLessThanOrEqual(s, 1.3 + 0.0001, label)
                    }
                }
            }
        }
    }

    func testTheReferenceDuoMatchesTheDesignedPositions() throws {
        let library = try BundledContent.repository().loadLibrary()
        let layout = PaneLayoutResolver().resolve(PaneLayoutInput(canvasWidth: 892, canvasHeight: 720))
        XCTAssertEqual(layout.posture, .unfolded)
        let low = try XCTUnwrap(library.story(id: StoryID("monkey-and-crocodile")))
        let lowMetrics = ReaderMetrics(layout: layout, safeArea: EdgeInsets(), story: low, spread: low.spreads[0], textSize: .standard)
        // DESIGN.md §3.5: controls at top 50; Low text at left 30, top 106, width 374.
        XCTAssertEqual(lowMetrics.controlTop, 50, accuracy: 0.001)
        XCTAssertEqual(lowMetrics.textTop, 106, accuracy: 0.001)
        XCTAssertEqual(lowMetrics.columnX, 30, accuracy: 0.001)
        XCTAssertEqual(lowMetrics.columnWidth, 374, accuracy: 0.001)

        let advanced = try XCTUnwrap(library.story(id: StoryID("urashima-taro")))
        let advancedMetrics = ReaderMetrics(layout: layout, safeArea: EdgeInsets(), story: advanced, spread: advanced.spreads[0], textSize: .standard)
        XCTAssertEqual(advancedMetrics.textTop, 108, accuracy: 0.001)
        // The picture keeps the lower part of the trailing pane: text stops at y 420.
        XCTAssertEqual(advancedMetrics.textTop + advancedMetrics.trailingCapacity, 420, accuracy: 0.001)

        // Screen 10: folded picture to y 340, text from y 366.
        let folded = PaneLayoutResolver().resolve(PaneLayoutInput(canvasWidth: 432, canvasHeight: 720))
        let foldedMetrics = ReaderMetrics(layout: folded, safeArea: EdgeInsets(), story: low, spread: low.spreads[0], textSize: .standard)
        XCTAssertEqual(foldedMetrics.pictureHeight, 340, accuracy: 0.001)
        XCTAssertEqual(foldedMetrics.textTop, 366, accuracy: 0.001)
        XCTAssertEqual(foldedMetrics.columnWidth, 376, accuracy: 0.001)
        XCTAssertEqual(foldedMetrics.typeScale.body.size, 22.5, accuracy: 0.001)
    }

    func testLargestTextNeverLosesAParagraph() throws {
        // Criterion 2.4, as far as it can be checked without drawing: whatever the measured
        // heights, every paragraph of every page of every story lands on exactly one screen,
        // in order, at every text size and on every window.
        let library = try BundledContent.repository().loadLibrary()
        let resolver = PaneLayoutResolver()
        for window in windows {
            let layout = resolver.resolve(PaneLayoutInput(canvasWidth: window.width, canvasHeight: window.height))
            let safeArea = EdgeInsets(top: window.top, leading: 0, bottom: window.bottom, trailing: 0)
            for story in library.stories {
                for spread in story.spreads {
                    let metrics = ReaderMetrics(layout: layout, safeArea: safeArea, story: story, spread: spread, textSize: .largest)
                    // Pretend heights: a line for every 30 characters at the scaled line height.
                    let line = CGFloat(metrics.typeScale.body.lineHeight ?? 30) * metrics.scale
                    var page = ReaderPageLayout(spread: spread, metrics: metrics, measurements: [:])
                    var heights: [BlockID: CGFloat] = [:]
                    // Two passes: the second measures the sentence groups of oversize paragraphs.
                    for _ in 0..<3 {
                        for block in page.blocksToMeasure {
                            heights[block.id] = line * CGFloat(max(1, (block.plainText.count + 29) / 30))
                        }
                        page = ReaderPageLayout(spread: spread, metrics: metrics, measurements: [page.key: heights])
                    }
                    let plan = try XCTUnwrap(page.plan, "\(window.name) \(story.id) \(spread.id): never finished planning")
                    var shown = ""
                    for index in 0..<plan.screenCount {
                        shown += page.blocks(in: .leading, onScreen: index).map(\.plainText).joined()
                        shown += page.blocks(in: .trailing, onScreen: index).map(\.plainText).joined()
                    }
                    XCTAssertEqual(shown, spread.blocks.map(\.plainText).joined(), "\(window.name) \(story.id) \(spread.id)")
                }
            }
        }
    }

    func testAnOversizeParagraphIsSplitIntoSentences() throws {
        let library = try BundledContent.repository().loadLibrary()
        let story = try XCTUnwrap(library.story(id: StoryID("urashima-taro")))
        let spread = story.spreads[0]
        let layout = PaneLayoutResolver().resolve(PaneLayoutInput(canvasWidth: 375, canvasHeight: 667))
        let metrics = ReaderMetrics(layout: layout, safeArea: EdgeInsets(), story: story, spread: spread, textSize: .largest)
        let empty = ReaderPageLayout(spread: spread, metrics: metrics, measurements: [:])
        XCTAssertNil(empty.plan, "nothing measured yet")
        XCTAssertEqual(empty.blocksToMeasure.map(\.id), spread.blocks.map(\.id))

        // Every paragraph of more than one sentence measures taller than the column.
        var heights: [BlockID: CGFloat] = [:]
        for block in spread.blocks {
            let sentences = block.sentenceFragments().count
            heights[block.id] = sentences > 1 ? metrics.leadingCapacity * 2 : metrics.leadingCapacity / 4
        }
        XCTAssertTrue(spread.blocks.contains { $0.sentenceFragments().count > 1 })
        let second = ReaderPageLayout(spread: spread, metrics: metrics, measurements: [empty.key: heights])
        XCTAssertNil(second.plan, "sentence groups still to measure")
        XCTAssertTrue(second.blocksToMeasure.contains { $0.id.isFragment })

        for block in second.blocksToMeasure where block.id.isFragment {
            heights[block.id] = metrics.leadingCapacity / 3
        }
        let third = ReaderPageLayout(spread: spread, metrics: metrics, measurements: [empty.key: heights])
        let plan = try XCTUnwrap(third.plan)
        XCTAssertGreaterThan(plan.screenCount, 1)
        XCTAssertTrue(plan.oversize.isEmpty)
    }
}

/// The code-drawn concept art: every picture the content names has a painter, and drawing it
/// does not crash at the sizes the app uses.
@MainActor
final class ArtCoverageTests: XCTestCase {
    private final class Results {
        var known: [Bool] = []
    }

    /// Draws one picture off screen and says whether a painter knew its name.
    private func draw(_ name: String, source: ArtSource, role: ArtRole, size: CGSize) -> Bool? {
        let results = Results()
        let view = ArtCanvas(name: name, role: role) { name, role, context, size in
            results.known.append(ArtLibrary.paint(name, source: source, role: role, in: &context, size: size))
            return true
        }
        .frame(width: size.width, height: size.height)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        _ = renderer.uiImage
        return results.known.last
    }

    func testEveryPictureNamedByTheContentHasAPainter() throws {
        let library = try BundledContent.repository().loadLibrary()
        var drawn = 0
        var missing: [String] = []

        func check(_ art: ArtRef, _ source: ArtSource, _ role: ArtRole, _ size: CGSize, _ owner: String) {
            guard let known = draw(art.assetName, source: source, role: role, size: size) else { return }
            drawn += 1
            if !known {
                missing.append("\(owner): \(art.assetName) (\(role))")
            }
        }

        for story in library.stories {
            let source = ArtSource.story(story.id)
            let owner = story.id.rawValue
            check(story.cover, source, .cover, CGSize(width: 116, height: 134), owner)
            check(story.cover, source, .cover, CGSize(width: 372, height: 186), owner)
            var scenes = Set<String>()
            for spread in story.spreads where scenes.insert(spread.scene.unfolded.assetName).inserted {
                // The reference Duo, a short landscape window and a tall portrait iPad.
                check(spread.scene.unfolded, source, .sceneUnfolded, CGSize(width: 892, height: 720), owner)
                check(spread.scene.unfolded, source, .sceneUnfolded, CGSize(width: 892, height: 520), owner)
                check(spread.scene.unfolded, source, .sceneUnfolded, CGSize(width: 516, height: 688), owner)
                check(spread.scene.folded, source, .sceneFolded, CGSize(width: 432, height: 340), owner)
                check(spread.scene.folded, source, .sceneFolded, CGSize(width: 432, height: 240), owner)
            }
            for character in story.characters {
                check(character.face, source, .face, CGSize(width: 96, height: 96), owner)
                if let card = character.card {
                    check(card.portrait, source, .portrait, CGSize(width: 432, height: 400), owner)
                }
            }
            for target in story.tapTargets {
                if let picture = target.picture {
                    check(picture, source, .picture, CGSize(width: 432, height: 404), owner)
                }
            }
        }
        for landmark in library.landmarks.landmarks {
            check(landmark.art, .landmark, .picture, CGSize(width: 432, height: 404), "landmark")
        }

        try XCTSkipIf(drawn == 0, "ImageRenderer did not draw the canvases in this environment")
        XCTAssertEqual(missing, [], "pictures with no painter")
    }

    func testAnUnknownPictureGetsTheCalmStandIn() {
        XCTAssertEqual(draw("no-such-picture", source: .story(StoryID("no-such-story")), role: .picture, size: CGSize(width: 100, height: 100)) ?? false, false)
        XCTAssertEqual(draw("no-such-landmark", source: .landmark, role: .picture, size: CGSize(width: 100, height: 100)) ?? false, false)
    }

    func testFaceChipsRender() throws {
        let library = try BundledContent.repository().loadLibrary()
        for story in library.stories {
            for character in story.characters {
                let chip = FaceChipRenderer.image(for: character, storyID: story.id, em: 23.5)
                XCTAssertGreaterThan(chip.size.width, chip.size.height, "\(story.id) \(character.id): chip has its trailing margin")
                XCTAssertEqual(chip.size.height, 23.5 * CGFloat(ReadingTypeScale.faceChipSizeEm), accuracy: 0.5)
            }
        }
    }

    func testSVGPathDataFromTheDesignSources() {
        // Absolute and relative commands, shorthand curves, and numbers without a leading zero.
        let path = Art.svg("M-6,7 q4,3.5 8,.5 L10 10 h5 v-5 c1,1 2,2 3,0 s2,-2 3,0 t4,0 Z")
        XCTAssertFalse(path.isEmpty)
        let box = path.boundingRect
        XCTAssertEqual(box.minX, -6, accuracy: 0.01)
        XCTAssertGreaterThan(box.maxX, 20)
        // An unsupported command ends the path instead of crashing.
        XCTAssertFalse(Art.svg("M0,0 L10,10 A5,5 0 0 1 20,20").isEmpty)
        XCTAssertTrue(Art.svg("").isEmpty)
    }

    func testDesignRandomNumbersAreStable() {
        // The generator of the design source: the same seed always gives the same picture.
        var a = ArtRandom(7)
        var b = ArtRandom(7)
        let first = (0..<5).map { _ in a.next() }
        let second = (0..<5).map { _ in b.next() }
        XCTAssertEqual(first, second)
        XCTAssertTrue(first.allSatisfy { $0 >= 0 && $0 < 1 })
        XCTAssertEqual(Set(first).count, 5)
    }
}
