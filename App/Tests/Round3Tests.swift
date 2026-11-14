import XCTest
import SwiftUI
import UIKit
import OmramoCore
@testable import Omramo

/// Round 3: tall-window page fit, the natural folded phone, the reading log behind the
/// library's side column, the hero route, and the motion tokens.
@MainActor
final class PageFitAppTests: XCTestCase {
    private func library() throws -> Library {
        try BundledContent.repository().loadLibrary()
    }

    private func layout(_ width: Double, _ height: Double) -> PaneLayout {
        PaneLayoutResolver().resolve(PaneLayoutInput(canvasWidth: width, canvasHeight: height))
    }

    private let safeArea = EdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0)

    /// A page layout whose paragraphs all measure `lineCount` lines of the tier's body text.
    private func measured(_ spread: Spread, _ metrics: ReaderMetrics, lines lineCount: Int) -> ReaderPageLayout {
        let line = CGFloat(metrics.typeScale.body.lineHeight ?? 30) * metrics.scale
        let empty = ReaderPageLayout(spread: spread, metrics: metrics, measurements: [:])
        var heights: [BlockID: CGFloat] = [:]
        for block in empty.blocksToMeasure {
            heights[block.id] = line * CGFloat(lineCount)
        }
        return ReaderPageLayout(spread: spread, metrics: metrics, measurements: [empty.key: heights])
    }

    func testTypeGrowsOnAThirteenInchPortraitAndNowhereDesigned() throws {
        let stories = try library().stories
        let low = try XCTUnwrap(stories.first { $0.tier == .low })
        let advanced = try XCTUnwrap(stories.first { $0.tier == .advanced })

        let portrait = layout(1032, 1376)
        let grown = ReaderMetrics(layout: portrait, safeArea: safeArea, story: low, spread: low.spreads[0], textSize: .standard)
        XCTAssertEqual(grown.posture, .unfolded)
        XCTAssertGreaterThan(grown.typeBoost, 1.05)
        XCTAssertGreaterThan(grown.extraHeight, 500)
        XCTAssertEqual(grown.typeScale.body.size, 23.5 * Double(grown.typeBoost), accuracy: 0.001)
        // Type on screen never passes 1.3 × the design.
        XCTAssertLessThanOrEqual(grown.typeBoost * grown.scale, 1.3 + 0.0001)
        // The oldest tier keeps its long line instead of growing.
        let quiet = ReaderMetrics(layout: portrait, safeArea: safeArea, story: advanced, spread: advanced.spreads[0], textSize: .standard)
        XCTAssertLessThan(quiet.typeBoost, 1.03)

        for (width, height) in [(892.0, 720.0), (1376.0, 1032.0), (1210.0, 834.0), (834.0, 1210.0), (440.0, 956.0)] {
            let metrics = ReaderMetrics(layout: layout(width, height), safeArea: EdgeInsets(), story: low, spread: low.spreads[0], textSize: .standard)
            XCTAssertEqual(metrics.typeBoost, 1, "\(width) × \(height)")
        }
    }

    func testAChosenTextSizeStillMultipliesTheBoost() throws {
        let low = try XCTUnwrap(try library().stories.first { $0.tier == .low })
        let portrait = layout(1032, 1376)
        let standard = ReaderMetrics(layout: portrait, safeArea: safeArea, story: low, spread: low.spreads[0], textSize: .standard)
        let largest = ReaderMetrics(layout: portrait, safeArea: safeArea, story: low, spread: low.spreads[0], textSize: .largest)
        XCTAssertEqual(largest.typeScale.body.size, standard.typeScale.body.size * 1.5, accuracy: 0.001)
        // A different boost or text size is a different measuring key: heights are never reused.
        let a = ReaderPageLayout(spread: low.spreads[0], metrics: standard, measurements: [:]).key
        let b = ReaderPageLayout(spread: low.spreads[0], metrics: largest, measurements: [:]).key
        XCTAssertNotEqual(a, b)
        let plain = ReaderMetrics(layout: layout(892, 720), safeArea: EdgeInsets(), story: low, spread: low.spreads[0], textSize: .standard)
        XCTAssertNotEqual(a, ReaderPageLayout(spread: low.spreads[0], metrics: plain, measurements: [:]).key)
    }

    func testAShortPageSitsLowerOnATallWindowAndStaysInItsColumn() throws {
        let stories = try library().stories
        let portrait = layout(1032, 1376)
        for story in stories {
            let spread = story.spreads[0]
            let metrics = ReaderMetrics(layout: portrait, safeArea: safeArea, story: story, spread: spread, textSize: .standard)
            let page = measured(spread, metrics, lines: 2)
            let plan = try XCTUnwrap(page.plan)
            XCTAssertEqual(plan.screenCount, 1, "\(story.id)")
            let offset = page.balancedOffset(onScreen: 0)
            XCTAssertGreaterThan(offset, 40, "\(story.id): a short page must not float at the top")
            // Never more than half of the extra height, and the text still ends inside its area.
            XCTAssertLessThanOrEqual(offset, metrics.extraHeight / 2 + 0.5, "\(story.id)")
            XCTAssertLessThanOrEqual(offset + page.textHeight(in: .leading, onScreen: 0), metrics.leadingCapacity + 0.5, "\(story.id)")
            if page.twoColumns {
                XCTAssertLessThanOrEqual(offset + page.textHeight(in: .trailing, onScreen: 0), metrics.trailingCapacity + 0.5, "\(story.id)")
            }
        }
    }

    func testTextNeverLeavesItsAreaWhateverItsLength() throws {
        // The balanced offset can only use space the text leaves free: for every story, every
        // window and paragraphs from one line to very long, text plus offset fits the column
        // it was planned into, on every screen of the page.
        let windows: [(Double, Double)] = [(1032, 1376), (1024, 1366), (981, 1024), (1376, 1032), (1210, 834), (892, 720), (760, 620)]
        for story in try library().stories {
            let spread = story.spreads[0]
            for (width, height) in windows {
                let window = layout(width, height)
                guard window.posture == .unfolded else { continue }
                let metrics = ReaderMetrics(layout: window, safeArea: safeArea, story: story, spread: spread, textSize: .standard)
                for lines in [1, 3, 6, 12] {
                    let page = measured(spread, metrics, lines: lines)
                    guard let plan = page.plan else { continue }
                    for screen in 0..<plan.screenCount {
                        let offset = page.balancedOffset(onScreen: screen)
                        XCTAssertGreaterThanOrEqual(offset, 0)
                        if page.needsScrolling(in: .leading, onScreen: screen) || page.needsScrolling(in: .trailing, onScreen: screen) {
                            XCTAssertEqual(offset, 0)
                            continue
                        }
                        let label = "\(story.id) \(width) × \(height), \(lines) lines, screen \(screen)"
                        XCTAssertLessThanOrEqual(offset + page.textHeight(in: .leading, onScreen: screen), metrics.leadingCapacity + 1, label)
                        if page.twoColumns, !plan.screens[screen].trailing.isEmpty {
                            XCTAssertLessThanOrEqual(offset + page.textHeight(in: .trailing, onScreen: screen), metrics.trailingCapacity + 1, label)
                        }
                    }
                }
            }
        }
    }

    func testTheDesignedLayoutsKeepTheDesignedTop() throws {
        let low = try XCTUnwrap(try library().stories.first { $0.tier == .low })
        let spread = low.spreads[0]
        // The reference Duo, 11-inch landscape, and one pane: no extra height is used for an offset.
        for (width, height) in [(892.0, 720.0), (1210.0, 834.0), (834.0, 1210.0), (440.0, 956.0)] {
            let metrics = ReaderMetrics(layout: layout(width, height), safeArea: EdgeInsets(), story: low, spread: spread, textSize: .standard)
            let page = measured(spread, metrics, lines: 1)
            for screen in 0..<(page.plan?.screenCount ?? 1) {
                XCTAssertEqual(page.balancedOffset(onScreen: screen), 0, "\(width) × \(height)")
            }
        }
        // Nothing measured yet: no offset.
        let metrics = ReaderMetrics(layout: layout(1032, 1376), safeArea: safeArea, story: low, spread: spread, textSize: .standard)
        XCTAssertEqual(ReaderPageLayout(spread: spread, metrics: metrics, measurements: [:]).balancedOffset(onScreen: 0), 0)
    }

    func testFoldedPictureUsesATallPhonesHeight() throws {
        let low = try XCTUnwrap(try library().stories.first { $0.tier == .low })
        let phone = layout(440, 956)
        XCTAssertEqual(phone.posture, .folded)
        let metrics = ReaderMetrics(
            layout: phone,
            safeArea: EdgeInsets(top: 62, leading: 0, bottom: 34, trailing: 0),
            story: low,
            spread: low.spreads[0],
            textSize: .standard
        )
        // More than the designed 340-point band at this scale, less than half the screen.
        XCTAssertGreaterThan(metrics.pictureHeight, 340 * metrics.scale + 60)
        XCTAssertLessThan(metrics.pictureHeight, 956 * 0.5)
        // The words keep at least the room the design gives them (366 → about 640 of 720).
        XCTAssertGreaterThan(metrics.leadingCapacity, 274 * metrics.scale)
        XCTAssertEqual(metrics.typeBoost, 1)
    }
}

@MainActor
final class FoldedSimulationTests: XCTestCase {
    func testFoldedSimulationOnAPhoneIsTheRealScreen() {
        // iPhone 17 Pro Max, `-OmramoPosture folded`: not a letterboxed picture of a device.
        let provider = SimulatedDuoProvider(simulation: .folded)
        let input = provider.input(for: CGSize(width: 440, height: 956))
        XCTAssertNil(input.simulation)
        let layout = PaneLayoutResolver().resolve(input)
        XCTAssertEqual(layout.posture, .folded)
        XCTAssertEqual(layout.source, .derived)
        XCTAssertEqual(layout.canvas, LayoutRect(x: 0, y: 0, width: 440, height: 956))
        XCTAssertEqual(layout.leading, layout.canvas)
        // The same on a small phone and on an 11-inch iPad in portrait (one pane anyway).
        XCTAssertNil(provider.input(for: CGSize(width: 375, height: 667)).simulation)
        XCTAssertNil(provider.input(for: CGSize(width: 834, height: 1210)).simulation)
    }

    func testFoldedSimulationOnAWideWindowIsStillTheReferencePane() {
        // An iPad in landscape would be two panes: there the simulated folded pane is drawn,
        // for comparison with screen 10.
        let provider = SimulatedDuoProvider(simulation: .folded)
        let input = provider.input(for: CGSize(width: 1376, height: 1032))
        XCTAssertEqual(input.simulation, .folded)
        let layout = PaneLayoutResolver().resolve(input)
        XCTAssertEqual(layout.source, .simulated)
        XCTAssertEqual(layout.posture, .folded)
        XCTAssertEqual(layout.leading.width / layout.leading.height, 432.0 / 720.0, accuracy: 0.0001)
    }

    func testUnfoldedSimulationIsUnchanged() {
        let provider = SimulatedDuoProvider(simulation: .unfolded)
        for size in [CGSize(width: 956, height: 440), CGSize(width: 440, height: 956), CGSize(width: 1376, height: 1032)] {
            let input = provider.input(for: size)
            XCTAssertEqual(input.simulation, .unfolded)
            XCTAssertEqual(PaneLayoutResolver().resolve(input).posture, .unfolded)
        }
    }
}

@MainActor
final class ReadingLogAppTests: XCTestCase {
    private func bundledStory(_ id: String) throws -> Story {
        try XCTUnwrap(try BundledContent.repository().loadLibrary().story(id: StoryID(id)))
    }

    private let today = ReadingDay(year: 2026, month: 11, day: 14)

    private func makeLog() -> ReadingLogStore {
        let today = self.today
        return ReadingLogStore(fileURL: nil, currentDay: { today })
    }

    func testAForwardTurnRecordsThePageJustRead() throws {
        let story = try bundledStory("monkey-and-crocodile")
        let log = makeLog()
        let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil), log: log)
        // Opening a story is not reading a page.
        model.didOpen()
        XCTAssertEqual(log.file.totalPagesRead, 0)

        model.turnPage()
        XCTAssertEqual(log.file.entries, [PageRead(day: today, storyID: story.id, spreadID: story.spreads[0].id)])
        model.turnPage()
        XCTAssertEqual(log.file.totalPagesRead, 2)
        XCTAssertEqual(log.file.entries.last?.spreadID, story.spreads[1].id)
        XCTAssertEqual(log.streak.count, 1)
        XCTAssertTrue(log.streak.readToday)
    }

    func testContinuationScreensAndGoingBackAreNotPages() throws {
        let story = try bundledStory("monkey-and-crocodile")
        let log = makeLog()
        let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil), log: log)
        let first = story.spreads[0]
        let plan = ScreenPlan(screens: first.blocks.map { ScreenPlan.Screen(leading: [$0.id]) })
        XCTAssertGreaterThan(plan.screenCount, 2)

        // Through the screens of page 1: still page 1, nothing recorded.
        for _ in 1..<plan.screenCount {
            model.turnPage(in: plan)
        }
        XCTAssertEqual(model.pageNumber, 1)
        XCTAssertEqual(log.file.totalPagesRead, 0)
        // Leaving the page: one page, once.
        model.turnPage(in: plan)
        XCTAssertEqual(model.pageNumber, 2)
        XCTAssertEqual(log.file.totalPagesRead, 1)
        // Going back records nothing.
        model.goBack()
        XCTAssertEqual(model.pageNumber, 1)
        XCTAssertEqual(log.file.totalPagesRead, 1)
    }

    func testFinishingRecordsTheLastPageAndTheStory() throws {
        let story = try bundledStory("anansi-wisdom")
        let log = makeLog()
        let progress = ReadingProgressStore(fileURL: nil)
        let model = ReaderModel(story: story, progress: progress, log: log)
        for _ in 1..<story.spreads.count {
            model.turnPage()
        }
        XCTAssertTrue(model.isLastPage)
        XCTAssertFalse(log.isFinished(story.id))
        XCTAssertEqual(log.file.totalPagesRead, story.spreads.count - 1)

        model.finish()
        XCTAssertTrue(log.isFinished(story.id))
        XCTAssertEqual(log.file.totalPagesRead, story.spreads.count)
        XCTAssertNil(progress.position(for: story.id), "a finished story has no place to keep")

        // The shelf shows it finished, with every page counted.
        let stories = try BundledContent.repository().loadLibrary().stories
        let shelf = ShelfState(stories: stories, progress: progress.file, log: log.file)
        XCTAssertEqual(shelf.finished, [story.id])
        XCTAssertEqual(shelf.pagesRead, story.spreads.count)
    }

    func testTheLogSurvivesARelaunchAndStoresNoTime() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("omramo-tests-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("reading-log.json")
        let today = self.today
        let first = ReadingLogStore(fileURL: url, currentDay: { today })
        first.recordPageRead(storyID: StoryID("monkey-and-crocodile"), spreadID: SpreadID("s01"))
        first.markFinished(StoryID("monkey-and-crocodile"))

        let second = ReadingLogStore(fileURL: url, currentDay: { today.adding(days: 1) })
        XCTAssertEqual(second.file, first.file)
        XCTAssertEqual(second.streak.count, 1, "yesterday's day still stands before today's page")
        XCTAssertEqual(second.today, today.adding(days: 1))

        let text = try XCTUnwrap(String(data: try Data(contentsOf: url), encoding: .utf8)).lowercased()
        for banned in ["time", "hour", "minute", "second", "duration", "timer", "stamp"] {
            XCTAssertFalse(text.contains(banned), "reading-log.json mentions \"\(banned)\"")
        }
    }

    func testTurnsMoveThePageTokenAndRememberTheirDirection() throws {
        let story = try bundledStory("monkey-and-crocodile")
        let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil))
        let start = model.pageToken
        XCTAssertEqual(model.turnDirection, .forward)
        model.turnPage()
        XCTAssertEqual(model.pageToken, start + 1)
        XCTAssertEqual(model.turnDirection, .forward)
        model.goBack()
        XCTAssertEqual(model.pageToken, start + 2)
        XCTAssertEqual(model.turnDirection, .backward)
        // Nothing to go back to: nothing moves.
        model.goBack()
        XCTAssertEqual(model.pageToken, start + 2)
        // Measuring text is not a page turn.
        let key = TextMeasureKey(spreadID: story.spreads[0].id, columnWidth: 374, textSize: .standard, paneScale: 1, posture: .unfolded)
        model.report(height: 100, of: story.spreads[0].blocks[0].id, for: key)
        XCTAssertEqual(model.pageToken, start + 2)
    }

    func testTheTurnLockIsSetByTheControlsOnly() throws {
        let story = try bundledStory("monkey-and-crocodile")
        let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil))
        XCTAssertFalse(model.isTurning)
        // The model's own page functions stay immediate (tests and restore use them).
        model.turnPage()
        XCTAssertFalse(model.isTurning)
        model.beginTurn(lockFor: 5)
        XCTAssertTrue(model.isTurning)
    }

    func testACardRemembersWhereItsWordWas() throws {
        let library = try BundledContent.repository().loadLibrary()
        let story = try XCTUnwrap(library.story(id: StoryID("monkey-and-crocodile")))
        let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil), landmarks: library.landmarks)
        let ref = StoryCardRef.tapTarget(TapTargetID("river-bank"))
        let block = try XCTUnwrap(story.spreads[0].blocks.first { $0.cardRefs.contains(ref) })
        let origin = CardOrigin(rect: CGRect(x: 40, y: 200, width: 120, height: 36), key: nil)
        model.open(ref, from: block.id, origin: origin)
        XCTAssertEqual(model.openCard?.ref, ref)
        XCTAssertEqual(model.cardOrigin, origin)
        model.closeCard()
        XCTAssertNil(model.openCard)
        // Opened without a tap on the word (VoiceOver, a launch argument): no origin.
        model.open(ref, from: block.id)
        XCTAssertNil(model.cardOrigin)
    }
}

@MainActor
final class RouterAndLaunchTests: XCTestCase {
    func testOpeningFromACoverRemembersItsRectangle() {
        let router = AppRouter()
        let story = StoryID("monkey-and-crocodile")
        let cover = CGRect(x: 30, y: 400, width: 116, height: 134)
        router.report(cover, for: .cover(story))
        router.open(story, from: .cover(story))
        XCTAssertEqual(router.route, .reader(story))
        XCTAssertEqual(router.heroRect, cover)
        // The cover has not moved: the reader closes straight back into it.
        router.showLibrary()
        XCTAssertEqual(router.route, .library)
        XCTAssertEqual(router.heroRect, cover)
    }

    func testOpeningWithoutASourceIsAPlainFade() {
        let router = AppRouter()
        router.open(StoryID("anansi-wisdom"))
        XCTAssertEqual(router.route, .reader(StoryID("anansi-wisdom")))
        XCTAssertNil(router.heroRect)
        router.showLibrary()
        XCTAssertEqual(router.route, .library)
    }

    func testClosingAfterTheCoverMovedTargetsItsNewPlace() async throws {
        let router = AppRouter()
        let story = StoryID("urashima-taro")
        router.report(CGRect(x: 30, y: 400, width: 116, height: 134), for: .cover(story))
        router.open(story, from: .cover(story))
        // The window was rotated while reading: the library reports the cover's new frame.
        let moved = CGRect(x: 300, y: 250, width: 150, height: 174)
        router.report(moved, for: .cover(story))
        router.showLibrary()
        XCTAssertEqual(router.heroRect, moved)
        // The route follows a moment later, once the reader has been drawn with the new target.
        try await Task.sleep(for: .milliseconds(200))
        XCTAssertEqual(router.route, .library)
    }

    func testHeroTransitionFallsBackToAFadeWhenItCannotGrowFromACover() {
        let window = CGSize(width: 440, height: 956)
        // These only need to build without trapping; the fall-back cases must not divide by zero.
        _ = AnyTransition.hero(from: nil, in: window, cornerRadius: 20, reduceMotion: false)
        _ = AnyTransition.hero(from: CGRect(x: 0, y: 0, width: 0, height: 0), in: window, cornerRadius: 20, reduceMotion: false)
        _ = AnyTransition.hero(from: CGRect(x: 900, y: 2000, width: 100, height: 100), in: window, cornerRadius: 20, reduceMotion: false)
        _ = AnyTransition.hero(from: CGRect(x: 20, y: 300, width: 116, height: 134), in: .zero, cornerRadius: 20, reduceMotion: false)
        _ = AnyTransition.hero(from: CGRect(x: 20, y: 300, width: 116, height: 134), in: window, cornerRadius: 20, reduceMotion: true)
        _ = AnyTransition.hero(from: CGRect(x: 20, y: 300, width: 116, height: 134), in: window, cornerRadius: 20, reduceMotion: false)
    }

    func testMotionTokensAreCalm() {
        // Page, card and hero: 0.3 to 0.5 s; press and Reduce Motion fades shorter.
        for duration in [Motion.pageDuration, Motion.cardDuration, Motion.heroDuration] {
            XCTAssertGreaterThanOrEqual(duration, 0.3)
            XCTAssertLessThanOrEqual(duration, 0.5)
        }
        XCTAssertLessThan(Motion.quickDuration, 0.3)
        XCTAssertLessThan(Motion.reducedDuration, 0.3)
        // The picture moves less than the words (it is further away), and neither moves far.
        XCTAssertLessThan(Motion.pageSceneTravel, Motion.pageTextTravel)
        XCTAssertLessThanOrEqual(Motion.pageTextTravel, 40)
        // Nothing shrinks or grows by more than a few per cent.
        XCTAssertGreaterThanOrEqual(Motion.cardStartScale, 0.9)
        XCTAssertGreaterThanOrEqual(Motion.pressScale, 0.94)
        // The controls stay locked for the whole turn, and no longer.
        XCTAssertEqual(Motion.pageLock(reduceMotion: false), Motion.pageDuration)
        XCTAssertEqual(Motion.pageLock(reduceMotion: true), Motion.reducedDuration)
        XCTAssertEqual(TurnDirection.forward.sign, 1)
        XCTAssertEqual(TurnDirection.backward.sign, -1)
    }

    func testThePrimaryControlIsAtLeastFiftySixPoints() {
        XCTAssertGreaterThanOrEqual(PageTurnButton.minimumTouchSide, 56)
        XCTAssertGreaterThanOrEqual(Tokens.Size.minimumHitTarget, 44)
    }

    func testStateLaunchFlags() {
        XCTAssertTrue(DebugLaunch.hasFlag(DebugLaunch.resetStateArgument, in: ["Omramo", "-OmramoResetState"]))
        XCTAssertTrue(DebugLaunch.hasFlag(DebugLaunch.demoStateArgument, in: ["Omramo", "-OmramoOpenStory", "anansi-wisdom", "-OmramoDemoState"]))
        XCTAssertFalse(DebugLaunch.hasFlag(DebugLaunch.resetStateArgument, in: ["Omramo"]))
        // A flag without a value does not swallow the value of the flag before it.
        XCTAssertEqual(DebugLaunch.storyID(from: ["Omramo", "-OmramoOpenStory", "anansi-wisdom", "-OmramoResetState"]), StoryID("anansi-wisdom"))
        XCTAssertNil(DebugLaunch.storyID(from: ["Omramo", "-OmramoOpenStory", "-OmramoResetState"]))
    }

    func testDemoStateFillsEveryLibraryCardWithRealIDs() throws {
        let library = try BundledContent.repository().loadLibrary()
        let today = ReadingDay(year: 2026, month: 11, day: 14)
        let demo = DebugLaunch.demoState(for: library, today: today)

        let streak = StreakSummary(log: demo.log, today: today)
        XCTAssertEqual(streak.count, 3)
        XCTAssertEqual(streak.title, "3 days in a row")

        let shelf = ShelfState(stories: library.stories, progress: demo.progress, log: demo.log)
        XCTAssertEqual(shelf.finished, [library.stories[0].id])
        XCTAssertEqual(shelf.keepReading?.storyID, library.stories.last?.id)
        XCTAssertEqual(shelf.keepReading?.page, 5)
        XCTAssertNotNil(shelf.summary)

        let friends = FriendMet.all(stories: library.stories, memory: demo.memory)
        XCTAssertGreaterThanOrEqual(friends.count, 4)
        // Every friend is a real character with a face that can be drawn.
        for friend in friends {
            XCTAssertNotNil(library.story(id: friend.storyID)?.character(id: friend.character.id))
        }
    }
}
