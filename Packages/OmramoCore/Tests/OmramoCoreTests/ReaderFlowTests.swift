import Foundation
import XCTest
@testable import OmramoCore

// Milestone 2: continuation screens, reading-position restore, text-size steps, sentence
// splitting and text on a path.

final class ContinuationPagerTests: XCTestCase {
    private let ids = ["s01", "s02", "s03"].map { SpreadID($0) }

    func testForwardGoesThroughContinuationScreensBeforeTheNextPage() {
        let pager = Pager(spreadIDs: ids)
        XCTAssertEqual(pager.forward(from: ids[0], screen: 0, screenCount: 3), .screen(1))
        XCTAssertEqual(pager.forward(from: ids[0], screen: 1, screenCount: 3), .screen(2))
        XCTAssertEqual(pager.forward(from: ids[0], screen: 2, screenCount: 3), .spread(ids[1], .start))
        // A page that fits has one screen.
        XCTAssertEqual(pager.forward(from: ids[1], screen: 0, screenCount: 1), .spread(ids[2], .start))
    }

    func testForwardStopsAtTheEndOfTheStory() {
        let pager = Pager(spreadIDs: ids)
        XCTAssertEqual(pager.forward(from: ids[2], screen: 0, screenCount: 2), .screen(1))
        XCTAssertNil(pager.forward(from: ids[2], screen: 1, screenCount: 2))
        XCTAssertNil(pager.forward(from: SpreadID("unknown"), screen: 0, screenCount: 1))
        XCTAssertTrue(pager.isAtEnd(ids[2], screen: 1, screenCount: 2))
        XCTAssertFalse(pager.isAtEnd(ids[2], screen: 0, screenCount: 2))
        XCTAssertFalse(pager.isAtEnd(ids[1], screen: 0, screenCount: 1))
    }

    func testBackwardGoesToTheLastScreenOfThePageBefore() {
        let pager = Pager(spreadIDs: ids)
        XCTAssertEqual(pager.backward(from: ids[1], screen: 2, screenCount: 3), .screen(1))
        XCTAssertEqual(pager.backward(from: ids[1], screen: 1, screenCount: 3), .screen(0))
        XCTAssertEqual(pager.backward(from: ids[1], screen: 0, screenCount: 3), .spread(ids[0], .end))
        XCTAssertNil(pager.backward(from: ids[0], screen: 0, screenCount: 1))
        XCTAssertTrue(pager.isAtStart(ids[0], screen: 0))
        XCTAssertFalse(pager.isAtStart(ids[0], screen: 1))
        XCTAssertFalse(pager.isAtStart(ids[1], screen: 0))
    }

    func testAScreenIndexBeyondAShrunkenPlanIsClamped() {
        // The layout changed and the page now has fewer screens than the index we held.
        let pager = Pager(spreadIDs: ids)
        XCTAssertEqual(pager.backward(from: ids[1], screen: 5, screenCount: 2), .screen(1))
        XCTAssertEqual(pager.forward(from: ids[1], screen: 5, screenCount: 2), .spread(ids[2], .start))
        // A count of zero (nothing measured yet) behaves as one screen.
        XCTAssertEqual(pager.forward(from: ids[0], screen: 0, screenCount: 0), .spread(ids[1], .start))
    }

    func testEveryScreenOfEveryPageCanBeReachedAndLeft() {
        // Criterion 2.7: walk forward over pages with 1, 3 and 2 screens, then all the way back.
        let pager = Pager(spreadIDs: ids)
        let counts: [SpreadID: Int] = [ids[0]: 1, ids[1]: 3, ids[2]: 2]
        var spread = ids[0]
        var screen = 0
        var visited: [String] = ["\(spread)/\(screen)"]
        while let move = pager.forward(from: spread, screen: screen, screenCount: counts[spread] ?? 1) {
            switch move {
            case .screen(let index):
                screen = index
            case .spread(let id, _):
                spread = id
                screen = 0
            }
            visited.append("\(spread)/\(screen)")
        }
        XCTAssertEqual(visited, ["s01/0", "s02/0", "s02/1", "s02/2", "s03/0", "s03/1"])

        var back: [String] = []
        while let move = pager.backward(from: spread, screen: screen, screenCount: counts[spread] ?? 1) {
            switch move {
            case .screen(let index):
                screen = index
            case .spread(let id, let anchor):
                XCTAssertEqual(anchor, .end)
                spread = id
                screen = (counts[id] ?? 1) - 1
            }
            back.append("\(spread)/\(screen)")
        }
        XCTAssertEqual(back, ["s03/0", "s02/2", "s02/1", "s02/0", "s01/0"])
    }
}

final class PageDashLimitTests: XCTestCase {
    func testFoldedFooterDrawsFewerDashes() {
        // Screen 10 draws seven dashes for fourteen pages.
        let folded = PageDashes(page: 5, pageCount: 14, maximumDashes: 7)
        XCTAssertEqual(folded.states.count, 7)
        XCTAssertEqual(folded.states.filter { $0 == .current }.count, 1)
        XCTAssertEqual(folded.states.firstIndex(of: .current), 2)
        // The default is unchanged, and a nonsense limit still draws one dash.
        XCTAssertEqual(PageDashes(page: 5, pageCount: 14).states.count, 9)
        XCTAssertEqual(PageDashes(page: 5, pageCount: 14, maximumDashes: 0).states, [.current])
        // The last page always lands on the last dash.
        XCTAssertEqual(PageDashes(page: 16, pageCount: 16, maximumDashes: 7).states.last, .current)
    }
}

final class ScreenPlannerTests: XCTestCase {
    private func item(_ id: String, _ height: Double, pane: TextBlock.Pane = .leading, keep: Bool = false, joins: Bool = false) -> FlowItem {
        FlowItem(id: BlockID(id), height: height, pane: pane, keepWithNext: keep, joinsPrevious: joins)
    }

    private func ids(_ names: String...) -> [BlockID] {
        names.map { BlockID($0) }
    }

    func testAPageThatFitsIsOneScreen() {
        let plan = ScreenPlanner.plan(
            items: [item("a", 100), item("b", 100), item("c", 100)],
            gap: 10,
            columns: FlowColumns(leading: 320)
        )
        XCTAssertEqual(plan.screenCount, 1)
        XCTAssertEqual(plan.screens[0].leading, ids("a", "b", "c"))
        XCTAssertTrue(plan.screens[0].trailing.isEmpty)
        XCTAssertTrue(plan.oversize.isEmpty)
    }

    func testOverflowContinuesOnAnotherScreenOfTheSamePage() {
        // 100 + 10 + 100 = 210 fits 250; the third paragraph does not.
        let plan = ScreenPlanner.plan(
            items: [item("a", 100), item("b", 100), item("c", 100), item("d", 100), item("e", 100)],
            gap: 10,
            columns: FlowColumns(leading: 250)
        )
        XCTAssertEqual(plan.screens.map(\.leading), [ids("a", "b"), ids("c", "d"), ids("e")])
    }

    func testEveryItemIsPlacedOnceAndInOrder() {
        let items = (1...17).map { item("b\($0)", Double(40 + ($0 * 37) % 90)) }
        for capacity in [60.0, 130, 200, 333, 5000] {
            let plan = ScreenPlanner.plan(items: items, gap: 12, columns: FlowColumns(leading: capacity, trailing: capacity / 2))
            XCTAssertEqual(plan.screens.flatMap(\.blocks), items.map(\.id), "capacity \(capacity)")
            XCTAssertFalse(plan.screens.contains { $0.isEmpty }, "capacity \(capacity)")
        }
    }

    func testNothingIsLostWhenAParagraphIsTallerThanTheScreen() {
        let plan = ScreenPlanner.plan(
            items: [item("a", 100), item("huge", 900), item("c", 100)],
            gap: 10,
            columns: FlowColumns(leading: 300)
        )
        XCTAssertEqual(plan.screens.map(\.leading), [ids("a"), ids("huge"), ids("c")])
        XCTAssertEqual(plan.oversize, [BlockID("huge")])
    }

    func testTheGapIsNotChargedAtTheTopOfAColumn() {
        // Two paragraphs of exactly half the column each cannot share it (there is a gap),
        // but each fits alone exactly.
        let plan = ScreenPlanner.plan(items: [item("a", 150), item("b", 150)], gap: 10, columns: FlowColumns(leading: 300))
        XCTAssertEqual(plan.screenCount, 2)
        let exact = ScreenPlanner.plan(items: [item("a", 145), item("b", 145)], gap: 10, columns: FlowColumns(leading: 300))
        XCTAssertEqual(exact.screenCount, 1)
    }

    func testALeadSentenceIsNotLeftAloneAtTheBottom() {
        // "lead" would fit under "a", but its paragraph would not: both move on together.
        let plan = ScreenPlanner.plan(
            items: [item("a", 200), item("lead", 60, keep: true), item("b", 150)],
            gap: 10,
            columns: FlowColumns(leading: 300)
        )
        XCTAssertEqual(plan.screens.map(\.leading), [ids("a"), ids("lead", "b")])
    }

    func testTextOnBothPanesStaysAsAuthoredWhenItFits() {
        let plan = ScreenPlanner.plan(
            items: [item("l1", 100), item("l2", 100), item("t1", 80, pane: .trailing), item("t2", 80, pane: .trailing)],
            gap: 10,
            columns: FlowColumns(leading: 500, trailing: 200)
        )
        XCTAssertEqual(plan.screenCount, 1)
        XCTAssertEqual(plan.screens[0].leading, ids("l1", "l2"))
        XCTAssertEqual(plan.screens[0].trailing, ids("t1", "t2"))
    }

    func testOverflowOnBothPanesFlowsInReadingOrder() {
        // The leading text overflows into the trailing column, then onto a second screen;
        // the text authored for the trailing pane follows it. Reading order never changes.
        let plan = ScreenPlanner.plan(
            items: [item("l1", 200), item("l2", 200), item("l3", 200), item("t1", 150, pane: .trailing), item("t2", 150, pane: .trailing)],
            gap: 10,
            columns: FlowColumns(leading: 420, trailing: 220)
        )
        XCTAssertEqual(plan.screens.flatMap(\.blocks), ids("l1", "l2", "l3", "t1", "t2"))
        XCTAssertEqual(plan.screens[0].leading, ids("l1", "l2"))
        XCTAssertEqual(plan.screens[0].trailing, ids("l3"))
        XCTAssertEqual(plan.screens[1].leading, ids("t1", "t2"))
        XCTAssertEqual(plan.screenCount, 2)
    }

    func testOneColumnIgnoresTheAuthoredPane() {
        // Folded: blocks flow in order whatever pane they were authored for.
        let plan = ScreenPlanner.plan(
            items: [item("l1", 100), item("t1", 100, pane: .trailing), item("t2", 100, pane: .trailing)],
            gap: 10,
            columns: FlowColumns(leading: 220)
        )
        XCTAssertEqual(plan.screens.map(\.leading), [ids("l1", "t1"), ids("t2")])
        XCTAssertTrue(plan.screens.allSatisfy { $0.trailing.isEmpty })
    }

    func testSentenceGroupsOfOneParagraphHaveNoGapBetweenThem() {
        let plan = ScreenPlanner.plan(
            items: [item("p#1", 100), item("p#2", 100, joins: true), item("p#3", 100, joins: true)],
            gap: 30,
            columns: FlowColumns(leading: 200)
        )
        XCTAssertEqual(plan.screens.map(\.leading), [ids("p#1", "p#2"), ids("p#3")])
    }

    func testNoItemsStillGivesOneScreen() {
        let plan = ScreenPlanner.plan(items: [], gap: 10, columns: FlowColumns(leading: 100))
        XCTAssertEqual(plan.screenCount, 1)
        XCTAssertTrue(plan.screens[0].isEmpty)
        XCTAssertEqual(plan.index(for: .end), 0)
    }

    // MARK: Anchors: the same paragraph after the layout changes (criteria 2.3, i.3)

    func testAnchorFindsTheScreenThatShowsTheParagraph() {
        let plan = ScreenPlan(screens: [
            .init(leading: ids("a", "b")),
            .init(leading: ids("c"), trailing: ids("d")),
            .init(leading: ids("e")),
        ])
        XCTAssertEqual(plan.index(for: .start), 0)
        XCTAssertEqual(plan.index(for: .end), 2)
        XCTAssertEqual(plan.index(for: .block(BlockID("d"))), 1)
        XCTAssertEqual(plan.index(for: .block(BlockID("gone"))), 0)
        XCTAssertEqual(plan.anchor(forScreen: 0), .start)
        XCTAssertEqual(plan.anchor(forScreen: 1), .block(BlockID("c")))
        XCTAssertEqual(plan.anchor(forScreen: 9), .start)
        XCTAssertEqual(plan.pane(of: BlockID("d"), onScreen: 1), .trailing)
        XCTAssertEqual(plan.pane(of: BlockID("c"), onScreen: 1), .leading)
        XCTAssertNil(plan.pane(of: BlockID("a"), onScreen: 1))
    }

    func testPostureChangeKeepsTheParagraphThatWasFirstOnScreen() {
        // Unfolded, the page fits on one screen. Folded, the same paragraphs need three.
        let items = ["a", "b", "c", "d", "e"].map { item($0, 100) }
        let unfolded = ScreenPlanner.plan(items: items, gap: 10, columns: FlowColumns(leading: 600))
        let folded = ScreenPlanner.plan(items: items, gap: 10, columns: FlowColumns(leading: 220))
        XCTAssertEqual(unfolded.screenCount, 1)
        XCTAssertEqual(folded.screenCount, 3)

        // Reading the second folded screen ("c" first), then unfolding: still the same page,
        // and the paragraph is on the screen shown.
        let anchor = folded.anchor(forScreen: 1)
        XCTAssertEqual(anchor, .block(BlockID("c")))
        let afterUnfold = unfolded.index(for: anchor)
        XCTAssertTrue(unfolded.screens[afterUnfold].blocks.contains(BlockID("c")))

        // And folding again from the unfolded screen returns to the start of the page.
        XCTAssertEqual(folded.index(for: unfolded.anchor(forScreen: 0)), 0)
    }

    func testAnchorSurvivesAParagraphBeingSplitIntoSentencesAndBack() {
        let whole = ScreenPlan(screens: [.init(leading: ids("a")), .init(leading: ids("p")), .init(leading: ids("z"))])
        let split = ScreenPlan(screens: [.init(leading: ids("a", "p#1")), .init(leading: ids("p#2", "p#3")), .init(leading: ids("z"))])
        // From a sentence group to the whole paragraph…
        XCTAssertEqual(whole.index(for: .block(BlockID("p#2"))), 1)
        // …and from the whole paragraph to its first sentence group.
        XCTAssertEqual(split.index(for: .block(BlockID("p"))), 0)
        // A group that no longer exists falls back to a sibling.
        XCTAssertEqual(split.index(for: .block(BlockID("p#9"))), 0)
        XCTAssertEqual(split.pane(of: BlockID("p"), onScreen: 1), .leading)
    }

    func testUnmeasuredPlanShowsThePageAsAuthored() throws {
        let story = try SampleContent.story()
        let blocks = story.spreads[0].blocks
        let one = ScreenPlan(unmeasured: blocks, twoColumns: false)
        XCTAssertEqual(one.screens, [.init(leading: blocks.map(\.id))])
        let two = ScreenPlan(unmeasured: blocks, twoColumns: true)
        XCTAssertEqual(two.screens[0].leading, blocks.filter { $0.pane == .leading }.map(\.id))
        XCTAssertEqual(two.screens[0].trailing, blocks.filter { $0.pane == .trailing }.map(\.id))
    }
}

final class ReadingPositionRestoreTests: XCTestCase {
    func testPositionAnchor() {
        let story = StoryID("a")
        XCTAssertEqual(ReadingPosition(storyID: story, spreadID: SpreadID("s02")).anchor, .start)
        XCTAssertEqual(
            ReadingPosition(storyID: story, spreadID: SpreadID("s02"), blockID: BlockID("s02-b3")).anchor,
            .block(BlockID("s02-b3"))
        )
    }

    func testRestoreFindsThePageAndTheScreenOfTheSavedParagraph() throws {
        let story = try SampleContent.story()
        let pager = Pager(story: story)
        let spread = story.spreads[4]
        let saved = ReadingPosition(storyID: story.id, spreadID: spread.id, blockID: spread.blocks.last?.id)

        XCTAssertEqual(pager.resume(from: saved), spread.id)
        // The saved paragraph is on the second screen in a small layout…
        let items = spread.blocks.map { FlowItem(id: $0.id, height: 100) }
        XCTAssertGreaterThanOrEqual(items.count, 2)
        let small = ScreenPlanner.plan(items: items, gap: 0, columns: FlowColumns(leading: 100 * Double(items.count - 1)))
        XCTAssertEqual(small.screenCount, 2)
        XCTAssertEqual(small.index(for: saved.anchor), 1)
        // …and on the only screen in a roomy one.
        let roomy = ScreenPlanner.plan(items: items, gap: 10, columns: FlowColumns(leading: 10_000))
        XCTAssertEqual(roomy.index(for: saved.anchor), 0)
    }

    func testRestoreFallsBackWhenTheSavedPlaceIsGone() {
        let pager = Pager(spreadIDs: [SpreadID("s01"), SpreadID("s02")])
        let stale = ReadingPosition(storyID: StoryID("a"), spreadID: SpreadID("gone"), blockID: BlockID("gone-b1"))
        XCTAssertEqual(pager.resume(from: stale), SpreadID("s01"))
        let plan = ScreenPlan(screens: [.init(leading: [BlockID("s01-b1")]), .init(leading: [BlockID("s01-b2")])])
        XCTAssertEqual(plan.index(for: stale.anchor), 0)
    }

    func testPositionWithABlockRoundTripsThroughTheProgressFile() throws {
        var file = ReadingProgressFile()
        let position = ReadingPosition(storyID: StoryID("urashima-taro"), spreadID: SpreadID("s05"), blockID: BlockID("s05-b4"))
        file.record(position)
        let decoded = try JSONDecoder().decode(ReadingProgressFile.self, from: JSONEncoder().encode(file))
        XCTAssertEqual(decoded.position(for: StoryID("urashima-taro")), position)
        XCTAssertEqual(decoded.position(for: StoryID("urashima-taro"))?.anchor, .block(BlockID("s05-b4")))
    }
}

final class TextSizeTests: XCTestCase {
    func testStepsAreOrderedAndStandardIsTheDesignedSize() {
        XCTAssertEqual(TextSizeStep.allCases.map(\.scale), [0.9, 1.0, 1.15, 1.3, 1.5])
        XCTAssertEqual(TextSizeStep.standard.scale, 1)
        XCTAssertEqual(TextSizeStep.allCases, TextSizeStep.allCases.sorted())
        XCTAssertNil(TextSizeStep.small.smaller)
        XCTAssertNil(TextSizeStep.largest.bigger)
        XCTAssertEqual(TextSizeStep.standard.bigger, .large)
        XCTAssertEqual(TextSizeStep.standard.smaller, .small)
    }

    func testInitialStepFollowsTheSystemTextSize() {
        XCTAssertEqual(TextSizeStep.initial(systemSizeIndex: 0), .standard)
        XCTAssertEqual(TextSizeStep.initial(systemSizeIndex: 3), .standard)
        XCTAssertEqual(TextSizeStep.initial(systemSizeIndex: 4), .large)
        XCTAssertEqual(TextSizeStep.initial(systemSizeIndex: 6), .larger)
        XCTAssertEqual(TextSizeStep.initial(systemSizeIndex: 7), .largest)
        XCTAssertEqual(TextSizeStep.initial(systemSizeIndex: 11), .largest)
    }

    func testScalingKeepsTheProportionsOfTheTier() {
        let base = Tier.low.readingScale()
        let big = base.scaled(to: .largest)
        XCTAssertEqual(big.body.size, 23.5 * 1.5, accuracy: 0.0001)
        XCTAssertEqual(big.body.lineHeight ?? 0, 37 * 1.5, accuracy: 0.0001)
        XCTAssertEqual(big.lead.size, 32 * 1.5, accuracy: 0.0001)
        XCTAssertEqual(big.paragraphGap, 17 * 1.5, accuracy: 0.0001)
        // The column and its position do not move.
        XCTAssertEqual(big.column, base.column)
        XCTAssertEqual(big.textTop, base.textTop)
        // Weight and family are untouched.
        XCTAssertEqual(big.body.weight, base.body.weight)
        XCTAssertEqual(base.scaled(to: .standard), base)
    }

    func testTierOrderHoldsAtEveryStep() {
        for step in TextSizeStep.allCases {
            let low = Tier.low.readingScale().scaled(to: step).body.size
            let medium = Tier.medium.readingScale().scaled(to: step).body.size
            let advanced = Tier.advanced.readingScale().scaled(to: step).body.size
            XCTAssertGreaterThan(low, medium, "\(step)")
            XCTAssertGreaterThan(medium, advanced, "\(step)")
        }
    }

    func testStepRoundTripsThroughJSON() throws {
        let data = try JSONEncoder().encode([TextSizeStep.larger])
        XCTAssertEqual(try JSONDecoder().decode([TextSizeStep].self, from: data), [.larger])
    }
}

final class SentenceFragmentTests: XCTestCase {
    private func block(_ runs: [TextRun], id: String = "s01-b1") -> TextBlock {
        TextBlock(id: BlockID(id), pane: .leading, runs: runs)
    }

    func testFragmentIDs() {
        let id = BlockID("s03-b2")
        XCTAssertEqual(id.fragment(2), BlockID("s03-b2#2"))
        XCTAssertEqual(id.fragment(2).fragmentParent, id)
        XCTAssertTrue(id.fragment(1).isFragment)
        XCTAssertFalse(id.isFragment)
        XCTAssertEqual(id.fragmentParent, id)
        // A "#" that is not followed by a number is part of an ordinary id.
        XCTAssertEqual(BlockID("a#b").fragmentParent, BlockID("a#b"))
    }

    func testSplitsAtSentenceEndsAndLosesNothing() {
        let paragraph = block([TextRun(text: "He sat still. He thought fast! Would it work? It did.")])
        let pieces = paragraph.sentenceFragments()
        XCTAssertEqual(pieces.map(\.plainText), ["He sat still. ", "He thought fast! ", "Would it work? ", "It did."])
        XCTAssertEqual(pieces.map(\.id), (1...4).map { paragraph.id.fragment($0) })
        XCTAssertEqual(pieces.map(\.plainText).joined(), paragraph.plainText)
    }

    func testSpeechFollowedByALowerCaseWordIsOneSentence() {
        let paragraph = block([
            TextRun(text: "“Stop, stop!”", speaker: CharacterID("monkey"), showsFaceChip: true),
            TextRun(text: " he cried. "),
            TextRun(text: "“Why are you going under?”", speaker: CharacterID("monkey")),
        ])
        let pieces = paragraph.sentenceFragments()
        XCTAssertEqual(pieces.map(\.plainText), ["“Stop, stop!” he cried. ", "“Why are you going under?”"])
        // Styles stay on their words, and the chip is drawn once.
        XCTAssertEqual(pieces[0].runs.first?.speaker, CharacterID("monkey"))
        XCTAssertEqual(pieces[0].runs.first?.showsFaceChip, true)
        XCTAssertEqual(pieces[1].runs.first?.speaker, CharacterID("monkey"))
        XCTAssertEqual(pieces[1].runs.first?.showsFaceChip, false)
    }

    func testARunCutInTwoKeepsItsStyleButOnlyOneChip() {
        let paragraph = block([
            TextRun(text: "“I can. Sit on my back.”", speaker: CharacterID("crocodile"), showsFaceChip: true),
        ])
        let pieces = paragraph.sentenceFragments()
        XCTAssertEqual(pieces.count, 2)
        XCTAssertEqual(pieces.map { $0.runs[0].showsFaceChip }, [true, false])
        XCTAssertEqual(pieces.map { $0.runs[0].speaker }, [CharacterID("crocodile"), CharacterID("crocodile")])
        XCTAssertEqual(pieces.map(\.plainText).joined(), paragraph.plainText)
    }

    func testOneSentenceAndPathTextAreNotSplit() {
        let one = block([TextRun(text: "A single sentence, with a comma.")])
        XCTAssertEqual(one.sentenceFragments(), [one])
        let path = TextBlock(id: BlockID("p"), pane: .trailing, kind: .pathText, runs: [TextRun(text: "“Urashima! Urashima!”")], path: "M0,0 L10,10")
        XCTAssertEqual(path.sentenceFragments(), [path])
    }

    func testRejoiningNeighboursGivesTheParagraphBack() {
        let paragraph = block([TextRun(text: "One. Two. Three.")])
        let other = block([TextRun(text: "Another paragraph.")], id: "s01-b2")
        let pieces = paragraph.sentenceFragments()
        let shown = TextBlock.rejoiningFragments([pieces[1], pieces[2], other])
        XCTAssertEqual(shown.count, 2)
        XCTAssertEqual(shown[0].plainText, "Two. Three.")
        XCTAssertEqual(shown[0].id, paragraph.id.fragment(2))
        XCTAssertEqual(shown[1], other)
    }

    func testEveryBundledParagraphSurvivesSplitting() throws {
        // Text fidelity at any text size: sentence groups, joined, are the paragraph exactly.
        let repository = try SampleContent.repository()
        for id in try repository.loadCatalog().stories {
            let story = try repository.loadStory(id: id)
            for block in story.spreads.flatMap(\.blocks) {
                let pieces = block.sentenceFragments()
                XCTAssertEqual(pieces.map(\.plainText).joined(), block.plainText, "\(id) \(block.id)")
                XCTAssertFalse(pieces.contains { $0.runs.isEmpty || $0.plainText.isEmpty }, "\(id) \(block.id)")
                XCTAssertEqual(TextBlock.rejoiningFragments(pieces).map(\.plainText), [block.plainText], "\(id) \(block.id)")
                XCTAssertEqual(
                    pieces.flatMap(\.runs).filter(\.showsFaceChip).count,
                    block.runs.filter(\.showsFaceChip).count,
                    "\(id) \(block.id)"
                )
            }
        }
    }
}

final class SVGPathTests: XCTestCase {
    private let wave = "M14,66 C70,22 120,84 190,52 C250,26 300,70 388,30"

    func testParsesTheDesignedWave() throws {
        let path = try XCTUnwrap(SVGPath(string: wave))
        XCTAssertEqual(path.start, SVGPath.Point(x: 14, y: 66))
        XCTAssertEqual(path.segments.count, 2)
        XCTAssertEqual(
            path.segments[1],
            .cubic(control1: .init(x: 250, y: 26), control2: .init(x: 300, y: 70), to: .init(x: 388, y: 30))
        )
    }

    func testParsesLinesQuadsAndLooseSpacing() throws {
        let path = try XCTUnwrap(SVGPath(string: "M0 0 10 0 L 20,5 Q30,-5 40.5,0"))
        XCTAssertEqual(path.segments, [
            .line(to: .init(x: 10, y: 0)),
            .line(to: .init(x: 20, y: 5)),
            .quad(control: .init(x: 30, y: -5), to: .init(x: 40.5, y: 0)),
        ])
    }

    func testRejectsWhatTheAppCannotDraw() {
        XCTAssertNil(SVGPath(string: ""))
        XCTAssertNil(SVGPath(string: "M10,10"))                 // nothing drawn
        XCTAssertNil(SVGPath(string: "L10,10 20,20"))           // no starting point
        XCTAssertNil(SVGPath(string: "M0,0 c10,10 20,20 30,0")) // relative commands
        XCTAssertNil(SVGPath(string: "M0,0 A5,5 0 0 1 10,10"))  // arcs
        XCTAssertNil(SVGPath(string: "M0,0 C10,10 20,20"))      // too few numbers
        XCTAssertNil(SVGPath(string: "M0,0 L10,10 M20,20 L30,30")) // two curves
        XCTAssertNil(SVGPath(string: "M0,0 L10,ten"))
    }

    func testSamplerWalksAStraightLineByDistance() throws {
        let path = try XCTUnwrap(SVGPath(string: "M0,0 L30,40"))
        let sampler = PathSampler(path: path)
        XCTAssertEqual(sampler.length, 50, accuracy: 0.0001)
        let middle = sampler.sample(at: 25)
        XCTAssertEqual(middle.x, 15, accuracy: 0.0001)
        XCTAssertEqual(middle.y, 20, accuracy: 0.0001)
        XCTAssertEqual(middle.angle, atan2(40, 30), accuracy: 0.0001)
        // Clamped at both ends.
        XCTAssertEqual(sampler.sample(at: -5).x, 0, accuracy: 0.0001)
        XCTAssertEqual(sampler.sample(at: 500).x, 30, accuracy: 0.0001)
    }

    func testSamplerFollowsTheWave() throws {
        let sampler = PathSampler(path: try XCTUnwrap(SVGPath(string: wave)))
        // Longer than the straight line between its ends, shorter than its control polygon.
        XCTAssertGreaterThan(sampler.length, 376)
        XCTAssertLessThan(sampler.length, 520)
        let start = sampler.sample(at: 0)
        XCTAssertEqual(start.x, 14, accuracy: 0.0001)
        XCTAssertEqual(start.y, 66, accuracy: 0.0001)
        let end = sampler.sample(at: sampler.length)
        XCTAssertEqual(end.x, 388, accuracy: 0.0001)
        XCTAssertEqual(end.y, 30, accuracy: 0.0001)
        // x never runs backwards along this curve, so letters keep their order.
        var lastX = -Double.infinity
        for step in 0...40 {
            let x = sampler.sample(at: sampler.length * Double(step) / 40).x
            XCTAssertGreaterThanOrEqual(x, lastX)
            lastX = x
        }
    }

    func testPathTextRulesInTheValidator() throws {
        var story = try SampleContent.story()
        // A paragraph must not carry a path…
        story.spreads[0].blocks[0].path = wave
        assertError(try SampleContent.report(for: story), .pathTextIncomplete)
        // …and a pathText block needs one the app can draw. (Fidelity is unaffected: the text
        // is the same.)
        story.spreads[0].blocks[0].kind = .pathText
        XCTAssertFalse(try SampleContent.report(for: story).contains(.pathTextIncomplete))
        story.spreads[0].blocks[0].path = "M0,0 a5,5 0 0 1 10,10"
        assertError(try SampleContent.report(for: story), .pathTextIncomplete)
        story.spreads[0].blocks[0].path = nil
        assertError(try SampleContent.report(for: story), .pathTextIncomplete)
    }

    func testTextAreaRuleInTheValidator() throws {
        var story = try SampleContent.story()
        story.spreads[0].scene.textArea = Spread.Scene.TextArea(trailingBottom: 420)
        XCTAssertFalse(try SampleContent.report(for: story).contains(.textAreaRange))
        story.spreads[0].scene.textArea = Spread.Scene.TextArea(leadingBottom: 90)
        assertError(try SampleContent.report(for: story), .textAreaRange)
        story.spreads[0].scene.textArea = Spread.Scene.TextArea(trailingBottom: 900)
        assertError(try SampleContent.report(for: story), .textAreaRange)
    }
}
