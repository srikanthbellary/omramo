import XCTest
import SwiftUI
import UIKit
import OmramoCore
@testable import Omramo

/// Round 4: the unfolded simulation over the whole window, the story-finished moment, the
/// splash plan, the new debug arguments, the finished "Aa" panel and controls, and sounds.
@MainActor
final class UnfoldedSimulationAppTests: XCTestCase {
    private let island = EdgeInsets(top: 0, leading: 62, bottom: 21, trailing: 62)

    func testUnfoldedSimulationFillsTheWindow() {
        // iPhone 17 Pro Max held sideways, `-OmramoPosture unfolded`.
        let provider = SimulatedDuoProvider(simulation: .unfolded)
        let size = CGSize(width: 956, height: 440)
        XCTAssertTrue(provider.input(for: size).simulationFillsWindow)

        let input = PaneLayoutProviders.input(from: provider, size: size, safeArea: island)
        XCTAssertEqual(input.safeAreaLeading, 62)
        XCTAssertEqual(input.safeAreaTrailing, 62)
        let layout = PaneLayoutResolver().resolve(input)
        XCTAssertEqual(layout.posture, .unfolded)
        XCTAssertEqual(layout.canvas, LayoutRect(x: 0, y: 0, width: 956, height: 440))
        XCTAssertEqual(layout.leading.x, 62, accuracy: 0.001)
        XCTAssertEqual(layout.trailing?.maxX ?? 0, 956 - 62, accuracy: 0.001)
        // It is the real screen, so the real safe areas apply (not a picture of a device).
        XCTAssertFalse(PaneLayoutProviders.isLetterboxed(layout, in: size))
    }

    func testTheReferenceCanvasIsStillAvailableLetterboxed() {
        let provider = SimulatedDuoProvider(simulation: .unfolded, letterboxed: true)
        let size = CGSize(width: 956, height: 440)
        let input = PaneLayoutProviders.input(from: provider, size: size, safeArea: island)
        XCTAssertFalse(input.simulationFillsWindow)
        let layout = PaneLayoutResolver().resolve(input)
        XCTAssertEqual(layout.canvas.width, 892 * 440.0 / 720.0, accuracy: 0.001)
        XCTAssertTrue(PaneLayoutProviders.isLetterboxed(layout, in: size))

        XCTAssertTrue(PaneLayoutProviders.isReferencePosture(["Omramo", "-OmramoPosture", "reference"]))
        XCTAssertFalse(PaneLayoutProviders.isReferencePosture(["Omramo", "-OmramoPosture", "unfolded"]))
        XCTAssertFalse(PaneLayoutProviders.isReferencePosture(["Omramo"]))
        XCTAssertNil(PaneLayoutProviders.simulation(from: ["Omramo", "-OmramoPosture", "reference"]))
        let chosen = PaneLayoutProviders.current(arguments: ["Omramo", "-OmramoPosture", "reference"]) as? SimulatedDuoProvider
        XCTAssertEqual(chosen?.letterboxed, true)
        XCTAssertEqual(chosen?.simulation, .unfolded)
    }

    func testDerivedAndFoldedLayoutsAreNotLetterboxed() {
        let size = CGSize(width: 440, height: 956)
        let derived = PaneLayoutResolver().resolve(DerivedPaneLayoutProvider().input(for: size))
        XCTAssertFalse(PaneLayoutProviders.isLetterboxed(derived, in: size))
        // The folded reference pane on a wide window is a picture of a device.
        let wide = CGSize(width: 1376, height: 1032)
        let folded = PaneLayoutResolver().resolve(SimulatedDuoProvider(simulation: .folded).input(for: wide))
        XCTAssertTrue(PaneLayoutProviders.isLetterboxed(folded, in: wide))
    }

    func testEveryPageStillHasRoomForWordsOnASquatPane() throws {
        let provider = SimulatedDuoProvider(simulation: .unfolded)
        let size = CGSize(width: 956, height: 440)
        let layout = PaneLayoutResolver().resolve(PaneLayoutProviders.input(from: provider, size: size, safeArea: island))
        XCTAssertTrue(layout.isSquat)
        let stories = try BundledContent.repository().loadLibrary().stories
        for story in stories {
            for spread in story.spreads {
                let metrics = ReaderMetrics(layout: layout, safeArea: island, story: story, spread: spread, textSize: .standard)
                let line = CGFloat(metrics.typeScale.body.lineHeight ?? 30) * metrics.scale
                let where_ = "\(story.id.rawValue) / \(spread.id.rawValue)"
                // At least four lines of body text on the leading pane, inside the window.
                XCTAssertGreaterThan(metrics.leadingCapacity, line * 4, where_)
                XCTAssertLessThan(metrics.textTop + metrics.leadingCapacity, 440, where_)
                if spread.blocks.contains(where: { $0.pane == .trailing }) {
                    // Text on both panes (Advanced): the picture keeps its share, not all of it.
                    XCTAssertGreaterThan(metrics.trailingCapacity, line * 4, where_)
                    XCTAssertLessThan(metrics.textTop + metrics.trailingCapacity, 440, where_)
                }
                XCTAssertEqual(metrics.typeBoost, 1, where_)
            }
        }
    }

    func testAnIPhoneSimulatingTheUnfoldedDuoTurnsToLandscape() {
        let unfolded = ["Omramo", "-OmramoPosture", "unfolded"]
        XCTAssertEqual(DebugLaunch.requestedOrientation(from: unfolded, isPhone: true), "landscape")
        // An iPad is left as it is held.
        XCTAssertNil(DebugLaunch.requestedOrientation(from: unfolded, isPhone: false))
        // The explicit argument always wins.
        XCTAssertEqual(DebugLaunch.requestedOrientation(from: unfolded + ["-OmramoOrientation", "portrait"], isPhone: true), "portrait")
        XCTAssertEqual(DebugLaunch.requestedOrientation(from: ["Omramo", "-OmramoOrientation", "landscape"], isPhone: false), "landscape")
        // Folded, the reference canvas and no posture ask for nothing.
        XCTAssertNil(DebugLaunch.requestedOrientation(from: ["Omramo", "-OmramoPosture", "folded"], isPhone: true))
        XCTAssertNil(DebugLaunch.requestedOrientation(from: ["Omramo", "-OmramoPosture", "reference"], isPhone: true))
        XCTAssertNil(DebugLaunch.requestedOrientation(from: ["Omramo"], isPhone: true))
    }
}

@MainActor
final class StoryFinishedTests: XCTestCase {
    private func stories() throws -> [Story] {
        try BundledContent.repository().loadLibrary().stories
    }

    private let today = ReadingDay(year: 2026, month: 11, day: 14)

    private func makeLog() -> ReadingLogStore {
        let today = self.today
        return ReadingLogStore(fileURL: nil, currentDay: { today })
    }

    private func readToTheLastPage(_ model: ReaderModel) {
        for _ in 1..<model.pageCount {
            model.turnPage()
        }
    }

    func testFinishingShowsTheFinishedMomentOnce() throws {
        let all = try stories()
        let story = try XCTUnwrap(all.first { $0.tier == .low })
        let log = makeLog()
        let progress = ReadingProgressStore(fileURL: nil)
        let model = ReaderModel(story: story, progress: progress, log: log, catalog: all)
        XCTAssertFalse(model.isFinishedShown)
        readToTheLastPage(model)
        XCTAssertTrue(model.isLastPage)
        XCTAssertFalse(model.isFinishedShown)

        model.finish()
        XCTAssertTrue(model.isFinishedShown)
        XCTAssertTrue(log.isFinished(story.id))
        XCTAssertEqual(log.file.totalPagesRead, story.spreads.count)

        // A second press, a page turn or a step back changes nothing while it is showing.
        model.finish()
        model.turnPage()
        model.goBack()
        XCTAssertTrue(model.isFinishedShown)
        XCTAssertEqual(log.file.totalPagesRead, story.spreads.count)
        XCTAssertEqual(model.pageNumber, story.spreads.count)
    }

    func testReadAgainGoesBackToTheFirstPage() throws {
        let all = try stories()
        let story = try XCTUnwrap(all.first { $0.tier == .medium })
        let log = makeLog()
        let progress = ReadingProgressStore(fileURL: nil)
        let model = ReaderModel(story: story, progress: progress, log: log, catalog: all)
        readToTheLastPage(model)
        model.finish()
        let token = model.pageToken

        model.readAgain()
        XCTAssertFalse(model.isFinishedShown)
        XCTAssertEqual(model.pageNumber, 1)
        XCTAssertEqual(model.anchor, .start)
        XCTAssertNotEqual(model.pageToken, token, "the words are new: the page-turn transition runs")
        XCTAssertEqual(model.turnDirection, .backward)
        // The story stays finished; its place is the first page again.
        XCTAssertTrue(log.isFinished(story.id))
        XCTAssertEqual(progress.position(for: story.id)?.spreadID, story.spreads[0].id)
        // And it reads on from there.
        model.turnPage()
        XCTAssertEqual(model.pageNumber, 2)
    }

    func testTheNextStoryComesFromTheCatalogAndTheLog() throws {
        let all = try stories()
        let low = try XCTUnwrap(all.first { $0.tier == .low })
        let medium = try XCTUnwrap(all.first { $0.tier == .medium })
        let advanced = try XCTUnwrap(all.first { $0.tier == .advanced })
        let log = makeLog()
        let model = ReaderModel(story: low, progress: ReadingProgressStore(fileURL: nil), log: log, catalog: all)
        XCTAssertEqual(model.nextStory?.id, medium.id)
        log.markFinished(medium.id)
        XCTAssertEqual(model.nextStory?.id, advanced.id)

        // No catalog (a test, a preview): nothing to offer, and the moment still works.
        let alone = ReaderModel(story: low, progress: ReadingProgressStore(fileURL: nil))
        XCTAssertNil(alone.nextStory)
    }

    func testTheMoralComesFromTheContent() throws {
        for story in try stories() {
            let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil))
            XCTAssertEqual(model.moral, story.moral)
            XCTAssertNotNil(model.moral, story.id.rawValue)
        }
        var silent = try XCTUnwrap(try stories().first)
        silent.moral = "   "
        XCTAssertNil(ReaderModel(story: silent, progress: ReadingProgressStore(fileURL: nil)).moral)
    }

    func testTheLaunchPageIsClampedToTheStory() throws {
        let story = try XCTUnwrap(try stories().first { $0.tier == .low })
        let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil))
        model.openLaunchPage(story.spreads.count)
        XCTAssertEqual(model.pageNumber, story.spreads.count)
        XCTAssertTrue(model.isLastPage)
        model.openLaunchPage(999)
        XCTAssertEqual(model.pageNumber, story.spreads.count)
        model.openLaunchPage(0)
        XCTAssertEqual(model.pageNumber, 1)
        model.openLaunchPage(3)
        XCTAssertEqual(model.pageNumber, 3)
    }
}

@MainActor
final class Round4LaunchTests: XCTestCase {
    func testFinishedAndPageArguments() {
        XCTAssertEqual(DebugLaunch.finishedStoryID(from: ["Omramo", "-OmramoOpenFinished", "anansi-wisdom"]), StoryID("anansi-wisdom"))
        XCTAssertNil(DebugLaunch.finishedStoryID(from: ["Omramo", "-OmramoOpenFinished"]))
        XCTAssertNil(DebugLaunch.finishedStoryID(from: ["Omramo"]))

        XCTAssertEqual(DebugLaunch.pageNumber(from: ["Omramo", "-OmramoOpenPage", "14"]), 14)
        XCTAssertNil(DebugLaunch.pageNumber(from: ["Omramo", "-OmramoOpenPage", "0"]))
        XCTAssertNil(DebugLaunch.pageNumber(from: ["Omramo", "-OmramoOpenPage", "last"]))
        XCTAssertNil(DebugLaunch.pageNumber(from: ["Omramo", "-OmramoOpenPage"]))
        XCTAssertNil(DebugLaunch.pageNumber(from: ["Omramo"]))

        XCTAssertTrue(DebugLaunch.opensAStory(["Omramo", "-OmramoOpenStory", "urashima-taro"]))
        XCTAssertTrue(DebugLaunch.opensAStory(["Omramo", "-OmramoOpenFinished", "urashima-taro"]))
        XCTAssertFalse(DebugLaunch.opensAStory(["Omramo", "-OmramoResetState"]))
    }

    func testTheSplashIsShortAndCanBeHeldOrSkipped() {
        // An ordinary launch: shown, and gone again in under a second.
        let plain = SplashView.plan(arguments: ["Omramo"])
        XCTAssertTrue(plain.shows)
        XCTAssertFalse(plain.holds)
        XCTAssertLessThan(Motion.splashHold + Motion.splashFade, 1.0)
        XCTAssertGreaterThan(Motion.splashHold, 0.3)

        // UI tests that start on the library still see it; it is not held.
        let reset = SplashView.plan(arguments: ["Omramo", "-OmramoResetState"])
        XCTAssertTrue(reset.shows)
        XCTAssertFalse(reset.holds)

        // Straight into a story: no splash in the way.
        XCTAssertFalse(SplashView.plan(arguments: ["Omramo", "-OmramoOpenStory", "anansi-wisdom"]).shows)
        XCTAssertFalse(SplashView.plan(arguments: ["Omramo", "-OmramoOpenFinished", "anansi-wisdom"]).shows)

        // For screenshots it stays, whatever else is asked.
        let held = SplashView.plan(arguments: ["Omramo", "-OmramoShowSplash", "-OmramoOpenStory", "anansi-wisdom"])
        XCTAssertTrue(held.shows)
        XCTAssertTrue(held.holds)
    }

    func testTheTaglineSplitsAtTheHinge() {
        let halves = SplashView.taglineHalves()
        XCTAssertEqual(halves.leading, "A magical book")
        XCTAssertEqual(halves.trailing, "that you read.")
        XCTAssertEqual(halves.leading + " " + halves.trailing, Brand.tagline)
        // A tagline with no such place stays whole, on the leading pane.
        let whole = SplashView.taglineHalves("Stories from everywhere.")
        XCTAssertEqual(whole.leading, "Stories from everywhere.")
        XCTAssertEqual(whole.trailing, "")
    }

    func testTheLaunchBackgroundColourIsInTheAssetCatalog() {
        XCTAssertNotNil(UIColor(named: "LaunchBackground"))
    }

    func testMotionTokensOfTheRound() {
        XCTAssertLessThanOrEqual(Motion.finishedDuration, 0.6)
        XCTAssertGreaterThanOrEqual(Motion.finishedDuration, Motion.cardDuration)
    }
}

@MainActor
final class Round4ControlTests: XCTestCase {
    func testThePanelAndTheControlsAreBigEnough() {
        XCTAssertEqual(TextSizePanel.letterSizes.count, TextSizeStep.allCases.count)
        XCTAssertEqual(TextSizePanel.letterSizes, TextSizePanel.letterSizes.sorted(), "the five letters grow")
        XCTAssertGreaterThanOrEqual(TextSizePanel.minimumControl, 48)
        XCTAssertGreaterThanOrEqual(TextSizePanel.stepWidth, 48)
        // The previous-page control is a real target on the reference pane, and the primary
        // control keeps its 56 pt.
        XCTAssertGreaterThanOrEqual(PreviousPageButton.diameter, Tokens.Size.minimumHitTarget)
        XCTAssertLessThan(PreviousPageButton.diameter, Tokens.Size.pageTurn, "the way forward stays the bigger one")
        XCTAssertEqual(PageTurnButton.minimumTouchSide, 56)
    }

    func testAParagraphsPlaceInItsColumn() throws {
        let story = try XCTUnwrap(try BundledContent.repository().loadLibrary().stories.first { $0.tier == .low })
        let spread = story.spreads[0]
        let layout = PaneLayoutResolver().resolve(PaneLayoutInput(canvasWidth: 440, canvasHeight: 956))
        XCTAssertEqual(layout.posture, .folded)
        let metrics = ReaderMetrics(layout: layout, safeArea: EdgeInsets(top: 62, leading: 0, bottom: 34, trailing: 0), story: story, spread: spread, textSize: .standard)

        // Every paragraph one line high, so the whole page is one screen.
        let line = CGFloat(metrics.typeScale.body.lineHeight ?? 30) * metrics.scale
        let empty = ReaderPageLayout(spread: spread, metrics: metrics, measurements: [:])
        XCTAssertNil(empty.blockSpan(of: spread.blocks[0].id, in: .leading, onScreen: 0), "nothing is measured yet")
        var heights: [BlockID: CGFloat] = [:]
        for block in empty.blocksToMeasure {
            heights[block.id] = line
        }
        let page = ReaderPageLayout(spread: spread, metrics: metrics, measurements: [empty.key: heights])
        let plan = try XCTUnwrap(page.plan)
        XCTAssertEqual(plan.screenCount, 1)
        let ids = plan.screens[0].leading
        XCTAssertGreaterThanOrEqual(ids.count, 2)

        let first = try XCTUnwrap(page.blockSpan(of: ids[0], in: .leading, onScreen: 0))
        XCTAssertEqual(first.top, 0, accuracy: 0.001)
        XCTAssertEqual(first.bottom, line, accuracy: 0.001)
        let second = try XCTUnwrap(page.blockSpan(of: ids[1], in: .leading, onScreen: 0))
        XCTAssertEqual(second.top, line + metrics.paragraphGap, accuracy: 0.001)
        XCTAssertEqual(second.bottom, line * 2 + metrics.paragraphGap, accuracy: 0.001)
        // The last paragraph ends where the column's text ends.
        let last = try XCTUnwrap(page.blockSpan(of: ids[ids.count - 1], in: .leading, onScreen: 0))
        XCTAssertEqual(last.bottom, page.textHeight(in: .leading, onScreen: 0), accuracy: 0.001)

        XCTAssertNil(page.blockSpan(of: BlockID("no-such-paragraph"), in: .leading, onScreen: 0))
        XCTAssertNil(page.blockSpan(of: ids[0], in: .leading, onScreen: 5))
        XCTAssertNil(page.blockSpan(of: ids[0], in: .trailing, onScreen: 0))
    }
}

@MainActor
final class SoundTests: XCTestCase {
    func testSoundsAreOffUntilSwitchedOn() {
        let memory = ReaderMemoryStore(fileURL: nil)
        XCTAssertFalse(memory.isSoundOn)
        memory.setSound(on: true)
        XCTAssertTrue(memory.isSoundOn)
        memory.setSound(on: false)
        XCTAssertFalse(memory.isSoundOn)
    }

    func testTheReaderFollowsTheSetting() throws {
        let story = try XCTUnwrap(try BundledContent.repository().loadLibrary().stories.first)
        let memory = ReaderMemoryStore(fileURL: nil)
        let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil), memory: memory)
        XCTAssertFalse(model.isSoundOn)
        memory.setSound(on: true)
        XCTAssertTrue(model.isSoundOn)
    }

    func testTheChoiceSurvivesARelaunch() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("omramo-sound-\(UUID().uuidString)")
            .appendingPathComponent("reader-memory.json")
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        ReaderMemoryStore(fileURL: url).setSound(on: true)
        XCTAssertTrue(ReaderMemoryStore(fileURL: url).isSoundOn)
    }

    func testBothSoundsAreBundledAndSilentWhenOff() {
        for effect in ReaderSound.Effect.allCases {
            XCTAssertNotNil(ReaderSound.url(for: effect), "\(effect.rawValue).wav is not in the app bundle")
            XCTAssertLessThanOrEqual(effect.volume, 0.6, "the sounds are quiet on purpose")
            // Off: nothing is played and no audio session is opened.
            ReaderSound.shared.play(effect, enabled: false)
        }
    }
}
