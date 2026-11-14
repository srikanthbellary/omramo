import Foundation
import XCTest
@testable import OmramoCore

final class PaneLayoutResolverTests: XCTestCase {
    private let resolver = PaneLayoutResolver()

    func testOrdinaryPhoneInPortraitIsFolded() {
        let layout = resolver.resolve(PaneLayoutInput(canvasWidth: 393, canvasHeight: 852))
        XCTAssertEqual(layout.posture, .folded)
        XCTAssertEqual(layout.source, .derived)
        XCTAssertEqual(layout.leading, LayoutRect(x: 0, y: 0, width: 393, height: 852))
        XCTAssertNil(layout.trailing)
        XCTAssertNil(layout.hinge)
    }

    func testWideLandscapeCanvasDerivesTwoPanesWithAVirtualGutter() {
        let layout = resolver.resolve(PaneLayoutInput(canvasWidth: 892, canvasHeight: 720))
        XCTAssertEqual(layout.posture, .unfolded)
        XCTAssertEqual(layout.source, .derived)
        XCTAssertEqual(layout.leading, LayoutRect(x: 0, y: 0, width: 432, height: 720))
        XCTAssertEqual(layout.hinge, LayoutRect(x: 432, y: 0, width: 28, height: 720))
        XCTAssertEqual(layout.trailing, LayoutRect(x: 460, y: 0, width: 432, height: 720))
        XCTAssertEqual(layout.referenceScale, 1, accuracy: 0.0001)
    }

    func testDerivedThresholds() {
        // Exactly wide enough: 2 × 360 + 28.
        XCTAssertEqual(resolver.resolve(PaneLayoutInput(canvasWidth: 748, canvasHeight: 600)).posture, .unfolded)
        // One point too narrow.
        XCTAssertEqual(resolver.resolve(PaneLayoutInput(canvasWidth: 747, canvasHeight: 600)).posture, .folded)
        // An ordinary iPhone in landscape: wide enough, but too short for two panes.
        XCTAssertEqual(resolver.resolve(PaneLayoutInput(canvasWidth: 956, canvasHeight: 440)).posture, .folded)
        // Wide enough but taller than wide (a big portrait window).
        XCTAssertEqual(resolver.resolve(PaneLayoutInput(canvasWidth: 800, canvasHeight: 1100)).posture, .folded)
    }

    func testReportedHingeWins() {
        let input = PaneLayoutInput(
            canvasWidth: 900,
            canvasHeight: 700,
            reportedHinge: LayoutRect(x: 440, y: 0, width: 20, height: 700)
        )
        let layout = resolver.resolve(input)
        XCTAssertEqual(layout.posture, .unfolded)
        XCTAssertEqual(layout.source, .system)
        XCTAssertEqual(layout.leading.width, 440)
        XCTAssertEqual(layout.hinge?.width, 20)
        XCTAssertEqual(layout.trailing, LayoutRect(x: 460, y: 0, width: 440, height: 700))
    }

    func testReportedPostureWithoutHinge() {
        let unfolded = resolver.resolve(PaneLayoutInput(canvasWidth: 600, canvasHeight: 700, reportedPosture: .unfolded))
        XCTAssertEqual(unfolded.posture, .unfolded)
        XCTAssertEqual(unfolded.source, .system)
        XCTAssertEqual(unfolded.hinge?.width, 0)
        XCTAssertEqual(unfolded.leading.width, 300)
        XCTAssertEqual(unfolded.trailing?.x, 300)

        // The system says folded even though the canvas is wide.
        let folded = resolver.resolve(PaneLayoutInput(canvasWidth: 1000, canvasHeight: 700, reportedPosture: .folded))
        XCTAssertEqual(folded.posture, .folded)
        XCTAssertNil(folded.trailing)
    }

    func testSimulatedUnfoldedIsTheReferenceCanvasLetterboxed() {
        // iPhone landscape-sized window: the 892 × 720 canvas is scaled to the height.
        let layout = resolver.resolve(PaneLayoutInput(canvasWidth: 956, canvasHeight: 440, simulation: .unfolded))
        let scale = 440.0 / 720.0
        XCTAssertEqual(layout.posture, .unfolded)
        XCTAssertEqual(layout.source, .simulated)
        XCTAssertEqual(layout.canvas.height, 440, accuracy: 0.001)
        XCTAssertEqual(layout.canvas.width, 892 * scale, accuracy: 0.001)
        XCTAssertEqual(layout.canvas.x, (956 - 892 * scale) / 2, accuracy: 0.001)
        XCTAssertEqual(layout.leading.width, 432 * scale, accuracy: 0.001)
        XCTAssertEqual(layout.hinge?.width ?? 0, 28 * scale, accuracy: 0.001)
        XCTAssertEqual(layout.trailing?.maxX ?? 0, layout.canvas.maxX, accuracy: 0.001)
        XCTAssertEqual(layout.referenceScale, scale, accuracy: 0.001)
    }

    func testSimulationWinsOverSystemReports() {
        let input = PaneLayoutInput(
            canvasWidth: 393,
            canvasHeight: 852,
            reportedPosture: .unfolded,
            simulation: .folded
        )
        let layout = resolver.resolve(input)
        XCTAssertEqual(layout.posture, .folded)
        XCTAssertEqual(layout.source, .simulated)
        let scale = 393.0 / 432.0
        XCTAssertEqual(layout.leading.width, 393, accuracy: 0.001)
        XCTAssertEqual(layout.leading.height, 720 * scale, accuracy: 0.001)
        XCTAssertEqual(layout.leading.y, (852 - 720 * scale) / 2, accuracy: 0.001)
    }

    func testEmptyCanvasDoesNotCrash() {
        let layout = resolver.resolve(PaneLayoutInput(canvasWidth: 0, canvasHeight: 0))
        XCTAssertEqual(layout.posture, .folded)
        XCTAssertEqual(layout.referenceScale, 1)
        XCTAssertEqual(resolver.resolve(PaneLayoutInput(canvasWidth: 0, canvasHeight: 0, simulation: .unfolded)).posture, .unfolded)
    }

    func testHingeOutsideTheCanvasIsIgnored() {
        let input = PaneLayoutInput(
            canvasWidth: 393,
            canvasHeight: 852,
            reportedHinge: LayoutRect(x: 500, y: 0, width: 20, height: 852)
        )
        XCTAssertEqual(resolver.resolve(input).posture, .folded)
    }
}

final class PagerTests: XCTestCase {
    private let ids = ["s01", "s02", "s03"].map { SpreadID($0) }

    func testNextAndPreviousWithinBounds() {
        let pager = Pager(spreadIDs: ids)
        XCTAssertEqual(pager.pageCount, 3)
        XCTAssertEqual(pager.first, ids[0])
        XCTAssertEqual(pager.next(after: ids[0]), ids[1])
        XCTAssertEqual(pager.next(after: ids[1]), ids[2])
        XCTAssertEqual(pager.previous(before: ids[2]), ids[1])
        XCTAssertEqual(pager.pageNumber(of: ids[2]), 3)
    }

    func testBounds() {
        let pager = Pager(spreadIDs: ids)
        XCTAssertNil(pager.next(after: ids[2]))
        XCTAssertNil(pager.previous(before: ids[0]))
        XCTAssertTrue(pager.isLast(ids[2]))
        XCTAssertFalse(pager.isLast(ids[0]))
        XCTAssertNil(pager.next(after: SpreadID("unknown")))
        XCTAssertNil(pager.previous(before: SpreadID("unknown")))
        XCTAssertNil(pager.pageNumber(of: SpreadID("unknown")))
    }

    func testEmptyStory() {
        let pager = Pager(spreadIDs: [])
        XCTAssertNil(pager.first)
        XCTAssertNil(pager.resume(from: nil))
    }

    func testResume() {
        let pager = Pager(spreadIDs: ids)
        let story = StoryID("a")
        XCTAssertEqual(pager.resume(from: nil), ids[0])
        XCTAssertEqual(pager.resume(from: ReadingPosition(storyID: story, spreadID: ids[1])), ids[1])
        // A saved spread that no longer exists falls back to page 1.
        XCTAssertEqual(pager.resume(from: ReadingPosition(storyID: story, spreadID: SpreadID("gone"))), ids[0])
    }

    func testPagerWalksTheWholeSampleStory() throws {
        let story = try SampleContent.story()
        let pager = Pager(story: story)
        var current = try XCTUnwrap(pager.first)
        var visited = [current]
        while let next = pager.next(after: current) {
            visited.append(next)
            current = next
        }
        XCTAssertEqual(visited, story.spreads.map(\.id))
        XCTAssertTrue(pager.isLast(current))
        XCTAssertEqual(pager.pageNumber(of: current), 14)
    }

    func testReadingProgressFileRoundTrip() throws {
        var file = ReadingProgressFile()
        let story = StoryID("monkey-and-crocodile")
        file.record(ReadingPosition(storyID: story, spreadID: SpreadID("s05"), blockID: BlockID("s05-b1")))
        XCTAssertEqual(file.lastStoryID, story)

        let data = try JSONEncoder().encode(file)
        let decoded = try JSONDecoder().decode(ReadingProgressFile.self, from: data)
        XCTAssertEqual(decoded, file)
        XCTAssertEqual(decoded.position(for: story)?.spreadID, SpreadID("s05"))
        XCTAssertEqual(decoded.schemaVersion, ReadingProgressFile.currentSchemaVersion)

        file.clear(storyID: story)
        XCTAssertNil(file.position(for: story))
        XCTAssertNil(file.lastStoryID)
    }

    func testPageDashes() {
        // Short story: one dash a page.
        let short = PageDashes(page: 3, pageCount: 6)
        XCTAssertEqual(short.states, [.done, .done, .current, .upcoming, .upcoming, .upcoming])

        // Long story: at most nine dashes, the current page mapped proportionally.
        let first = PageDashes(page: 1, pageCount: 14)
        XCTAssertEqual(first.states.count, 9)
        XCTAssertEqual(first.states.first, .current)

        let last = PageDashes(page: 14, pageCount: 14)
        XCTAssertEqual(last.states.last, .current)
        XCTAssertEqual(last.states.filter { $0 == .done }.count, 8)

        // Out-of-range input is clamped.
        XCTAssertEqual(PageDashes(page: 0, pageCount: 0).states, [.current])
        XCTAssertEqual(PageDashes(page: 99, pageCount: 3).states, [.done, .done, .current])
    }
}
