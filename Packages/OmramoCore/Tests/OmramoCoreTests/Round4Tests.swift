import Foundation
import XCTest
@testable import OmramoCore

// Round 4: the simulated unfolded Duo over the whole window, the folded card that leaves the
// tapped line in view, the story's moral, the choice of the next story, and the sound setting.

// MARK: - The simulated unfolded Duo fills the window

final class FilledSimulationTests: XCTestCase {
    private let resolver = PaneLayoutResolver()

    private func filled(_ width: Double, _ height: Double, leading: Double = 0, trailing: Double = 0) -> PaneLayout {
        resolver.resolve(PaneLayoutInput(
            canvasWidth: width,
            canvasHeight: height,
            simulation: .unfolded,
            simulationFillsWindow: true,
            safeAreaLeading: leading,
            safeAreaTrailing: trailing
        ))
    }

    func testAnIPhoneHeldSidewaysIsTwoPanesOverTheWholeScreen() {
        // iPhone 17 Pro Max in landscape: 956 × 440, 62 pt insets beside the Dynamic Island.
        let layout = filled(956, 440, leading: 62, trailing: 62)
        XCTAssertEqual(layout.posture, .unfolded)
        XCTAssertEqual(layout.source, .simulated)
        // The scene is full-bleed: the canvas is the window, not a letterboxed picture.
        XCTAssertEqual(layout.canvas, LayoutRect(x: 0, y: 0, width: 956, height: 440))
        // A thin gutter in the middle; each pane starts inside the side inset.
        XCTAssertEqual(layout.hinge, LayoutRect(x: 472, y: 0, width: 12, height: 440))
        XCTAssertEqual(layout.leading, LayoutRect(x: 62, y: 0, width: 410, height: 440))
        XCTAssertEqual(layout.trailing, LayoutRect(x: 484, y: 0, width: 410, height: 440))
        XCTAssertEqual(layout.trailing?.maxX ?? 0, 956 - 62, accuracy: 0.001)
        XCTAssertNil(layout.maximumReferenceScale)
    }

    func testASquatWindowKeepsAReadableScale() {
        let layout = filled(956, 440, leading: 62, trailing: 62)
        // Fitting the whole 720 pt pane into 440 pt would be 0.61 ×. The design is held at
        // 440 / 520 instead, and each screen shows less of a page.
        XCTAssertEqual(layout.minimumReferenceScale ?? 0, 440.0 / 520.0, accuracy: 0.0001)
        XCTAssertEqual(layout.referenceScale, 440.0 / 520.0, accuracy: 0.0001)
        XCTAssertGreaterThan(layout.referenceScale, 440.0 / 720.0)
        XCTAssertTrue(layout.isSquat)
        // The round page-turn button (60 reference points) is still about 51 pt across.
        XCTAssertGreaterThan(Tokens.Size.pageTurn * layout.referenceScale, 50)
        // And the design's pane is narrower than the real one: content is centred in it.
        XCTAssertLessThan(layout.contentWidth, layout.leading.width)
    }

    func testWithoutInsetsThePanesReachTheEdges() {
        let layout = filled(956, 440)
        XCTAssertEqual(layout.leading, LayoutRect(x: 0, y: 0, width: 472, height: 440))
        XCTAssertEqual(layout.trailing, LayoutRect(x: 484, y: 0, width: 472, height: 440))
    }

    func testUnequalInsetsStillGiveEqualPanes() {
        let layout = filled(956, 440, leading: 59, trailing: 0)
        XCTAssertEqual(layout.leading.x, 59, accuracy: 0.001)
        XCTAssertEqual(layout.leading.width, layout.trailing?.width ?? 0, accuracy: 0.001)
        XCTAssertEqual(layout.trailing?.maxX ?? 0, 956 - 59, accuracy: 0.001)
    }

    func testATallWindowFillsToo() {
        // 13-inch iPad in portrait.
        let layout = filled(1032, 1376)
        XCTAssertEqual(layout.canvas, LayoutRect(x: 0, y: 0, width: 1032, height: 1376))
        XCTAssertEqual(layout.leading.width, 510, accuracy: 0.001)
        XCTAssertEqual(layout.leading.height, 1376, accuracy: 0.001)
        // Limited by the width, as on any tall pane; the floor of 1 changes nothing here.
        XCTAssertEqual(layout.referenceScale, 510.0 / 432.0, accuracy: 0.0001)
        XCTAssertFalse(layout.isSquat)
    }

    func testTheScaleFloorNeverExceedsWhatTheWidthAllows() {
        // An iPhone in portrait that was not turned: two narrow panes, scale by width.
        let portrait = filled(440, 956)
        XCTAssertEqual(portrait.leading.width, 214, accuracy: 0.001)
        XCTAssertEqual(portrait.referenceScale, 214.0 / 432.0, accuracy: 0.0001)
        XCTAssertFalse(portrait.isSquat)

        let narrow = PaneLayout(
            posture: .unfolded,
            canvas: LayoutRect(x: 0, y: 0, width: 412, height: 300),
            leading: LayoutRect(x: 0, y: 0, width: 200, height: 300),
            trailing: LayoutRect(x: 212, y: 0, width: 200, height: 300),
            hinge: LayoutRect(x: 200, y: 0, width: 12, height: 300),
            source: .simulated,
            minimumReferenceScale: 1
        )
        XCTAssertEqual(narrow.referenceScale, 200.0 / 432.0, accuracy: 0.0001)
    }

    func testTheLetterboxedReferenceCanvasIsStillTheDefault() {
        // Not asking to fill gives exactly the round 1–3 layout (the locked screens' canvas).
        let input = PaneLayoutInput(canvasWidth: 956, canvasHeight: 440, simulation: .unfolded)
        XCTAssertFalse(input.simulationFillsWindow)
        let layout = resolver.resolve(input)
        let scale = 440.0 / 720.0
        XCTAssertEqual(layout.canvas.width, 892 * scale, accuracy: 0.001)
        XCTAssertEqual(layout.referenceScale, scale, accuracy: 0.001)
        XCTAssertNil(layout.minimumReferenceScale)
        XCTAssertFalse(layout.isSquat)
    }

    func testFillingAppliesOnlyToTheUnfoldedSimulation() {
        // Folded: the flag is ignored (the app lays a folded phone out as the real screen).
        let folded = resolver.resolve(PaneLayoutInput(
            canvasWidth: 393,
            canvasHeight: 852,
            simulation: .folded,
            simulationFillsWindow: true
        ))
        XCTAssertEqual(folded.posture, .folded)
        XCTAssertEqual(folded.leading.height, 720 * 393.0 / 432.0, accuracy: 0.001)
        XCTAssertNil(folded.minimumReferenceScale)

        // No simulation: the flag and the insets mean nothing; the size decides.
        let plain = resolver.resolve(PaneLayoutInput(
            canvasWidth: 956,
            canvasHeight: 440,
            simulationFillsWindow: true,
            safeAreaLeading: 62,
            safeAreaTrailing: 62
        ))
        XCTAssertEqual(plain.source, .derived)
        XCTAssertEqual(plain.posture, .folded)
        XCTAssertEqual(plain.leading, LayoutRect(x: 0, y: 0, width: 956, height: 440))
    }

    func testOtherLayoutsAreNeverSquat() {
        for size in [(892.0, 720.0), (1376.0, 1032.0), (1032.0, 1376.0), (440.0, 956.0), (956.0, 440.0)] {
            let layout = resolver.resolve(PaneLayoutInput(canvasWidth: size.0, canvasHeight: size.1))
            XCTAssertNil(layout.minimumReferenceScale)
            XCTAssertFalse(layout.isSquat, "\(size)")
        }
        let duo = resolver.resolve(PaneLayoutInput(
            canvasWidth: 1784,
            canvasHeight: 1440,
            reportedHinge: LayoutRect(x: 864, y: 0, width: 56, height: 1440)
        ))
        XCTAssertFalse(duo.isSquat)
    }

    func testAnEmptyWindowDoesNotCrash() {
        let layout = filled(0, 0)
        XCTAssertEqual(layout.posture, .unfolded)
        XCTAssertEqual(layout.referenceScale, 1)
        XCTAssertEqual(layout.leading.width, 0)
        // Insets wider than the window leave empty panes, not negative ones.
        let tiny = filled(100, 300, leading: 80, trailing: 80)
        XCTAssertGreaterThanOrEqual(tiny.leading.width, 0)
        XCTAssertGreaterThanOrEqual(tiny.trailing?.width ?? -1, 0)
    }
}

// MARK: - The folded card leaves the tapped line in view

final class FoldedCardFitTests: XCTestCase {
    func testTheCardTakesAboutSixTenthsOfAPhone() {
        // iPhone 17 Pro Max: 956 pt tall, the top controls end about 120 pt down.
        let height = PageFit.foldedCardHeight(paneHeight: 956, topReserved: 120, lineBand: 98)
        XCTAssertEqual(height, 574)
        XCTAssertGreaterThanOrEqual(height / 956, 0.55)
        XCTAssertLessThanOrEqual(height / 956, 0.65)
        // The reference pane.
        XCTAssertEqual(PageFit.foldedCardHeight(paneHeight: 720, topReserved: 110, lineBand: 96), 432)
    }

    func testAShortPaneKeepsRoomForTheLine() {
        // 60% would leave under 98 pt between the controls and the card: the card gives way.
        XCTAssertEqual(PageFit.foldedCardHeight(paneHeight: 500, topReserved: 120, lineBand: 98), 282)
        // But a card stays a card: never under 45% of the pane.
        XCTAssertEqual(PageFit.foldedCardHeight(paneHeight: 300, topReserved: 120, lineBand: 98), 135)
        XCTAssertEqual(PageFit.foldedCardHeight(paneHeight: 0, topReserved: 120, lineBand: 98), 0)
    }

    func testTheLineIsMovedJustAboveTheCard() {
        // The card's top edge is at 382; the line sits at 500…540, under the card.
        let shift = PageFit.foldedLineShift(lineTop: 500, lineBottom: 540, visibleTop: 120, cardTop: 382, margin: 14)
        XCTAssertEqual(shift, 172)
        // After the move the line's bottom is one margin above the card.
        XCTAssertEqual(540 - shift, 382 - 14)
        // And its top is still below the top controls.
        XCTAssertGreaterThan(500 - shift, 120)
    }

    func testALineAlreadyInViewDoesNotMove() {
        XCTAssertEqual(PageFit.foldedLineShift(lineTop: 260, lineBottom: 300, visibleTop: 120, cardTop: 382, margin: 14), 0)
        // Exactly one margin above the card: still no move.
        XCTAssertEqual(PageFit.foldedLineShift(lineTop: 328, lineBottom: 368, visibleTop: 120, cardTop: 382, margin: 14), 0)
    }

    func testATallParagraphShowsItsFirstLines() {
        // A paragraph taller than the gap cannot fit: it moves until its top meets the strip
        // under the top controls, and no further.
        let shift = PageFit.foldedLineShift(lineTop: 200, lineBottom: 700, visibleTop: 120, cardTop: 382, margin: 14)
        XCTAssertEqual(shift, 66)
        XCTAssertEqual(200 - shift, 120 + 14)
        // Already at (or above) the strip: it stays.
        XCTAssertEqual(PageFit.foldedLineShift(lineTop: 100, lineBottom: 700, visibleTop: 120, cardTop: 382, margin: 14), 0)
    }

    func testEveryLineOnAPhonePageEndsAboveTheCard() {
        // Any single line (44 pt tall) anywhere under the picture on a 956 pt phone.
        let cardTop = 956 - PageFit.foldedCardHeight(paneHeight: 956, topReserved: 120, lineBand: 98)
        var top = 420.0
        while top < 860 {
            let shift = PageFit.foldedLineShift(lineTop: top, lineBottom: top + 44, visibleTop: 120, cardTop: cardTop, margin: 14)
            XCTAssertLessThanOrEqual(top + 44 - shift, cardTop - 14 + 0.5, "line at \(top)")
            XCTAssertGreaterThanOrEqual(top - shift, 120 + 14 - 0.5, "line at \(top)")
            top += 37
        }
    }
}

// MARK: - The moral

final class MoralTests: XCTestCase {
    func testOneShortSentenceIsFine() {
        XCTAssertNil(MoralRule.problem(in: "When you are in trouble, stay calm and think."))
        XCTAssertNil(MoralRule.problem(in: "Is it kind?"))
        XCTAssertNil(MoralRule.problem(in: "Stay calm!"))
        XCTAssertNil(MoralRule.problem(in: "  Be kind.  "))
        // A closing quote after the full stop still ends the sentence.
        XCTAssertNil(MoralRule.problem(in: "\u{201C}Think first.\u{201D}"))
        XCTAssertNil(MoralRule.problem(in: String(repeating: "a", count: MoralRule.maximumLength - 1) + "."))
    }

    func testMissingEmptyLongAndManySentencesAreProblems() {
        XCTAssertNotNil(MoralRule.problem(in: nil))
        XCTAssertNotNil(MoralRule.problem(in: ""))
        XCTAssertNotNil(MoralRule.problem(in: "   \n"))
        // No closing mark: not a finished sentence.
        XCTAssertNotNil(MoralRule.problem(in: "Be kind"))
        XCTAssertNotNil(MoralRule.problem(in: "Be kind. Be brave."))
        XCTAssertNotNil(MoralRule.problem(in: "Be kind! And think."))
        XCTAssertNotNil(MoralRule.problem(in: String(repeating: "a", count: MoralRule.maximumLength) + "."))
    }

    func testSentenceCount() {
        XCTAssertEqual(MoralRule.sentenceCount("One."), 1)
        XCTAssertEqual(MoralRule.sentenceCount("One. Two."), 2)
        XCTAssertEqual(MoralRule.sentenceCount("One? Two! Three."), 3)
        XCTAssertEqual(MoralRule.sentenceCount("No end"), 0)
        // A full stop inside a number is not the end of a sentence.
        XCTAssertEqual(MoralRule.sentenceCount("It took 2.5 days."), 1)
    }

    func testEveryBundledStoryHasAMoralOfOneSentence() throws {
        let library = try SampleContent.repository().loadLibrary()
        XCTAssertEqual(library.stories.count, 3)
        for story in library.stories {
            XCTAssertNil(MoralRule.problem(in: story.moral), story.id.rawValue)
            let moral = try XCTUnwrap(story.moral, story.id.rawValue)
            XCTAssertEqual(moral, moral.trimmingCharacters(in: .whitespacesAndNewlines), story.id.rawValue)
        }
        // Three stories, three different things to remember.
        XCTAssertEqual(Set(library.stories.compactMap(\.moral)).count, 3)
    }

    func testTheValidatorRequiresTheMoral() throws {
        var story = try SampleContent.story()
        XCTAssertFalse(try SampleContent.report(for: story).contains(.moralIncomplete))

        story.moral = nil
        assertError(try SampleContent.report(for: story), .moralIncomplete)
        story.moral = "  "
        assertError(try SampleContent.report(for: story), .moralIncomplete)
        story.moral = "Think first. Then act."
        assertError(try SampleContent.report(for: story), .moralIncomplete)
        story.moral = "Think first, then act."
        XCTAssertFalse(try SampleContent.report(for: story).contains(.moralIncomplete))
        XCTAssertEqual(ValidationCode.moralIncomplete.rawValue, "moral-incomplete")
    }

    func testAStoryFileWithoutAMoralStillDecodes() throws {
        // The field is optional in the file format (schema version 1 is unchanged); the
        // validator is what requires it.
        let text = try SampleContent.storyJSON()
        let data = try SampleContent.json(
            text,
            replacing: "\"moral\": \"When you are in trouble, stay calm and think.\",",
            with: ""
        )
        let story = try ContentDecoder.decodeStory(data)
        XCTAssertNil(story.moral)
        assertError(try SampleContent.report(for: story), .moralIncomplete)
    }

    func testTheMoralSurvivesEncoding() throws {
        let story = try SampleContent.story()
        let decoded = try JSONDecoder().decode(Story.self, from: try JSONEncoder().encode(story))
        XCTAssertEqual(decoded.moral, "When you are in trouble, stay calm and think.")
    }
}

// MARK: - Which story next

final class NextStoryTests: XCTestCase {
    private func catalog() throws -> (low: Story, medium: Story, advanced: Story, all: [Story]) {
        let stories = try SampleContent.repository().loadLibrary().stories
        let low = try XCTUnwrap(stories.first { $0.tier == .low })
        let medium = try XCTUnwrap(stories.first { $0.tier == .medium })
        let advanced = try XCTUnwrap(stories.first { $0.tier == .advanced })
        return (low, medium, advanced, stories)
    }

    private func copy(_ story: Story, id: String) -> Story {
        var other = story
        other.id = StoryID(id)
        return other
    }

    func testTheNearestLevelIsOfferedAndUpBeforeDown() throws {
        let books = try catalog()
        // Nothing read before: one level up from Low, not two.
        XCTAssertEqual(NextStory.suggestion(after: books.low.id, in: books.all, finished: [])?.id, books.medium.id)
        // From Medium: up to Advanced rather than down to Low.
        XCTAssertEqual(NextStory.suggestion(after: books.medium.id, in: books.all, finished: [])?.id, books.advanced.id)
        // From Advanced there is only down: the nearer level first.
        XCTAssertEqual(NextStory.suggestion(after: books.advanced.id, in: books.all, finished: [])?.id, books.medium.id)
    }

    func testAnUnreadStoryComesBeforeOneAlreadyFinished() throws {
        let books = try catalog()
        let next = NextStory.suggestion(after: books.low.id, in: books.all, finished: [books.low.id, books.medium.id])
        XCTAssertEqual(next?.id, books.advanced.id)
        // Everything read: back to the nearest level.
        let again = NextStory.suggestion(
            after: books.low.id,
            in: books.all,
            finished: [books.low.id, books.medium.id, books.advanced.id]
        )
        XCTAssertEqual(again?.id, books.medium.id)
    }

    func testTheSameLevelComesFirst() throws {
        let books = try catalog()
        let second = copy(books.low, id: "another-low-story")
        // The other Low story is last in the catalog and still wins over Medium.
        let stories = [books.low, books.medium, books.advanced, second]
        XCTAssertEqual(NextStory.suggestion(after: books.low.id, in: stories, finished: [])?.id, second.id)
        // Unless it has been read and the Medium one has not.
        XCTAssertEqual(NextStory.suggestion(after: books.low.id, in: stories, finished: [second.id])?.id, books.medium.id)
    }

    func testCatalogOrderBreaksTiesAndWrapsRound() throws {
        let books = try catalog()
        let a = copy(books.low, id: "low-a")
        let b = copy(books.low, id: "low-b")
        let c = copy(books.low, id: "low-c")
        let stories = [a, b, c]
        XCTAssertEqual(NextStory.suggestion(after: a.id, in: stories, finished: [])?.id, b.id)
        XCTAssertEqual(NextStory.suggestion(after: b.id, in: stories, finished: [])?.id, c.id)
        XCTAssertEqual(NextStory.suggestion(after: c.id, in: stories, finished: [])?.id, a.id)
    }

    func testNoOtherStoryMeansNoSuggestion() throws {
        let books = try catalog()
        XCTAssertNil(NextStory.suggestion(after: books.low.id, in: [books.low], finished: []))
        XCTAssertNil(NextStory.suggestion(after: books.low.id, in: [], finished: []))
        // A story that is not in the catalog (it was removed): the first one, never itself.
        let unknown = StoryID("gone")
        XCTAssertEqual(NextStory.suggestion(after: unknown, in: books.all, finished: [])?.id, books.all.first?.id)
    }

    func testTheSuggestionIsNeverTheStoryJustFinished() throws {
        let books = try catalog()
        for story in books.all {
            for finished in [Set<StoryID>(), Set(books.all.map(\.id))] {
                let next = NextStory.suggestion(after: story.id, in: books.all, finished: finished)
                XCTAssertNotNil(next)
                XCTAssertNotEqual(next?.id, story.id)
            }
        }
    }

    func testTierDistance() {
        XCTAssertEqual(NextStory.tierDistance(from: .low, to: .low), 0)
        XCTAssertEqual(NextStory.tierDistance(from: .low, to: .medium), 1)
        XCTAssertEqual(NextStory.tierDistance(from: .medium, to: .low), 2)
        XCTAssertEqual(NextStory.tierDistance(from: .low, to: .advanced), 3)
        XCTAssertEqual(NextStory.tierDistance(from: .advanced, to: .low), 4)
    }
}

// MARK: - The sound setting

final class SoundSettingTests: XCTestCase {
    func testSoundsAreNotChosenUntilSomeoneChooses() throws {
        XCTAssertNil(ReaderMemoryFile().soundOn)
        // A file written before round 4 has no such key and still reads.
        let old = Data("{\"schemaVersion\":1,\"bookmarks\":{},\"seenTapTargets\":{},\"seenCharacterCards\":{},\"friendsMet\":{}}".utf8)
        let decoded = try JSONDecoder().decode(ReaderMemoryFile.self, from: old)
        XCTAssertNil(decoded.soundOn)
        XCTAssertNil(decoded.textSize)
    }

    func testTheChoiceIsKept() throws {
        var memory = ReaderMemoryFile()
        memory.soundOn = true
        memory.textSize = .large
        let decoded = try JSONDecoder().decode(ReaderMemoryFile.self, from: try JSONEncoder().encode(memory))
        XCTAssertEqual(decoded.soundOn, true)
        XCTAssertEqual(decoded.textSize, .large)
        XCTAssertEqual(decoded, memory)
    }
}
