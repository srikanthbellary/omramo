import Foundation
import XCTest
@testable import OmramoCore

// Milestone 3 (cards, seen state, friends met), milestone Mi (iPad layout rules) and the
// Medium and Advanced prototype stories.

enum PrototypeContent {
    static let anansiID = StoryID("anansi-wisdom")
    static let urashimaID = StoryID("urashima-taro")

    static func story(_ id: StoryID) throws -> Story {
        try SampleContent.repository().loadStory(id: id)
    }

    /// The three prototype stories of rounds 1–2, one a level, in catalog order. (The whole
    /// round-5 catalog is held to its own rules in `Round5Tests.swift`: not every planned
    /// story has a landmark, by design.)
    static func allStories() throws -> [Story] {
        let repository = try SampleContent.repository()
        return try [SampleContent.storyID, anansiID, urashimaID].map { try repository.loadStory(id: $0) }
    }
}

final class CardPlacementTests: XCTestCase {
    func testCardOpensOnThePaneFacingTheWord() {
        XCTAssertEqual(CardPlacement.resolve(posture: .unfolded, wordPane: .leading), .pane(.trailing))
    }

    func testWithTextOnBothPanesTheCardCoversThePaneWithoutTheWord() {
        // Criterion 3.4: a word tapped on the trailing pane sends the card to the leading pane.
        let placement = CardPlacement.resolve(posture: .unfolded, wordPane: .trailing)
        XCTAssertEqual(placement, .pane(.leading))
        XCTAssertTrue(placement.covers(.leading))
        XCTAssertFalse(placement.covers(.trailing))
    }

    func testFoldedIsABottomCard() {
        for pane in [TextBlock.Pane.leading, .trailing] {
            let placement = CardPlacement.resolve(posture: .folded, wordPane: pane)
            XCTAssertEqual(placement, .bottomSheet)
            XCTAssertFalse(placement.covers(.leading))
            XCTAssertFalse(placement.covers(.trailing))
        }
    }

    func testCardRePlacesItselfAcrossAPostureChange() {
        // The open card is state, not layout: the same card resolves again for the new posture.
        let card = OpenCard(ref: .tapTarget(TapTargetID("rin-gin")), blockID: BlockID("s05-b3"))
        let unfolded = CardPlacement.resolve(posture: .unfolded, wordPane: .leading)
        let folded = CardPlacement.resolve(posture: .folded, wordPane: .leading)
        XCTAssertEqual(unfolded, .pane(.trailing))
        XCTAssertEqual(folded, .bottomSheet)
        XCTAssertEqual(card.ref, .tapTarget(TapTargetID("rin-gin")))
    }

    func testPlacementFollowsWhereTheWordIsShownNow() throws {
        // A trailing-pane paragraph that a continuation screen moved to the leading column:
        // the card must cover the trailing pane, whatever the paragraph was authored for.
        let plan = ScreenPlan(screens: [
            .init(leading: [BlockID("l1")], trailing: [BlockID("l2")]),
            .init(leading: [BlockID("t1")]),
        ])
        let shownOn = try XCTUnwrap(plan.pane(of: BlockID("t1"), onScreen: 1))
        XCTAssertEqual(shownOn, .leading)
        XCTAssertEqual(CardPlacement.resolve(posture: .unfolded, wordPane: shownOn), .pane(.trailing))
    }

    func testOpenCardRemembersTheAuthoredParagraph() {
        let card = OpenCard(ref: .character(CharacterID("monkey")), blockID: BlockID("s07-b1#2"))
        XCTAssertEqual(card.blockID, BlockID("s07-b1"))
    }

    func testOppositePane() {
        XCTAssertEqual(TextBlock.Pane.leading.opposite, .trailing)
        XCTAssertEqual(TextBlock.Pane.trailing.opposite, .leading)
    }
}

final class ReaderMemoryTests: XCTestCase {
    private let story = StoryID("monkey-and-crocodile")
    private let other = StoryID("urashima-taro")

    func testSeenStateIsPerStoryAndPerCard() {
        var memory = ReaderMemoryFile()
        let riverBank = StoryCardRef.tapTarget(TapTargetID("river-bank"))
        XCTAssertFalse(memory.hasSeen(riverBank, in: story))
        XCTAssertTrue(memory.markSeen(riverBank, in: story))
        XCTAssertFalse(memory.markSeen(riverBank, in: story), "marking twice changes nothing")
        XCTAssertTrue(memory.hasSeen(riverBank, in: story))
        XCTAssertFalse(memory.hasSeen(riverBank, in: other))
        XCTAssertFalse(memory.hasSeen(.tapTarget(TapTargetID("ripe-fruit")), in: story))
        XCTAssertEqual(memory.seenTapTargets[story.rawValue], [TapTargetID("river-bank")])

        // A character card is remembered separately from a tap target with the same id.
        let monkey = StoryCardRef.character(CharacterID("river-bank"))
        XCTAssertFalse(memory.hasSeen(monkey, in: story))
        XCTAssertTrue(memory.markSeen(monkey, in: story))
        XCTAssertTrue(memory.hasSeen(monkey, in: story))
    }

    func testFriendsAreMetOnceInTheOrderTheyAppear() {
        var memory = ReaderMemoryFile()
        let monkey = CharacterID("monkey")
        let crocodile = CharacterID("crocodile")
        XCTAssertEqual(memory.recordMet([monkey, crocodile, monkey], in: story), [monkey, crocodile])
        XCTAssertEqual(memory.recordMet([crocodile], in: story), [], "already met")
        XCTAssertEqual(memory.friends(in: story), [monkey, crocodile])
        XCTAssertTrue(memory.hasMet(monkey, in: story))
        XCTAssertFalse(memory.hasMet(monkey, in: other))
        XCTAssertEqual(memory.friends(in: other), [])
    }

    func testFriendsAreMetWhenTheirFirstNamingIsShown() throws {
        // Page 1 of the sample names the Mother Crocodile; the Monkey is only described.
        let sample = try SampleContent.story()
        var memory = ReaderMemoryFile()
        let named = sample.spreads[0].blocks.flatMap(\.namedCharacters)
        XCTAssertEqual(named, [CharacterID("mother-crocodile")])
        XCTAssertEqual(memory.recordMet(named, in: sample.id), named)
        XCTAssertTrue(memory.hasMet(CharacterID("mother-crocodile"), in: sample.id))
        XCTAssertFalse(memory.hasMet(CharacterID("monkey"), in: sample.id))
    }

    func testBookmarkIsOnePerStory() {
        var memory = ReaderMemoryFile()
        XCTAssertNil(memory.bookmark(for: story))
        memory.setBookmark(ReadingPosition(storyID: story, spreadID: SpreadID("s05"), blockID: BlockID("s05-b2")))
        memory.setBookmark(ReadingPosition(storyID: other, spreadID: SpreadID("s02")))
        XCTAssertEqual(memory.bookmark(for: story)?.spreadID, SpreadID("s05"))
        XCTAssertEqual(memory.bookmark(for: story)?.anchor, .block(BlockID("s05-b2")))
        // A new bookmark in the same story replaces the old one.
        memory.setBookmark(ReadingPosition(storyID: story, spreadID: SpreadID("s09")))
        XCTAssertEqual(memory.bookmark(for: story)?.spreadID, SpreadID("s09"))
        XCTAssertEqual(memory.bookmark(for: other)?.spreadID, SpreadID("s02"))
        memory.removeBookmark(for: story)
        XCTAssertNil(memory.bookmark(for: story))
        XCTAssertNotNil(memory.bookmark(for: other))
    }

    func testMemoryRoundTripsThroughJSON() throws {
        var memory = ReaderMemoryFile()
        memory.textSize = .larger
        memory.setBookmark(ReadingPosition(storyID: story, spreadID: SpreadID("s05"), blockID: BlockID("s05-b2")))
        memory.markSeen(.tapTarget(TapTargetID("river-bank")), in: story)
        memory.markSeen(.character(CharacterID("monkey")), in: story)
        memory.recordMet([CharacterID("monkey")], in: story)

        let decoded = try JSONDecoder().decode(ReaderMemoryFile.self, from: JSONEncoder().encode(memory))
        XCTAssertEqual(decoded, memory)
        XCTAssertEqual(decoded.schemaVersion, ReaderMemoryFile.currentSchemaVersion)
        XCTAssertEqual(decoded.textSize, .larger)
        XCTAssertTrue(decoded.hasSeen(.tapTarget(TapTargetID("river-bank")), in: story))
        XCTAssertTrue(decoded.hasMet(CharacterID("monkey"), in: story))
    }

    func testAFreshMemoryHasNoTextSizeYet() {
        XCTAssertNil(ReaderMemoryFile().textSize)
    }

    func testNoTimesOrDurationsAreStored() throws {
        // The app records reading, never screen time (PRD): no key of the stored file may
        // name a time, a date or a duration.
        var memory = ReaderMemoryFile()
        memory.textSize = .large
        memory.setBookmark(ReadingPosition(storyID: story, spreadID: SpreadID("s05")))
        memory.markSeen(.tapTarget(TapTargetID("river-bank")), in: story)
        memory.recordMet([CharacterID("monkey")], in: story)
        let text = try XCTUnwrap(String(data: try JSONEncoder().encode(memory), encoding: .utf8)).lowercased()
        for word in ["time", "date", "duration", "seconds", "timestamp"] {
            XCTAssertFalse(text.contains(word), "stored reader memory mentions \"\(word)\"")
        }
    }
}

final class CardContentTests: XCTestCase {
    func testOrdinaryTapCardComesFromTheStory() throws {
        let story = try PrototypeContent.story(PrototypeContent.urashimaID)
        let landmarks = try SampleContent.landmarks()
        let target = try XCTUnwrap(story.tapTarget(id: TapTargetID("rin-gin")))
        let card = try XCTUnwrap(TapCardContent(target: target, story: story, landmarks: landmarks))
        XCTAssertEqual(card.title, "Rin Gin")
        XCTAssertEqual(card.subtitle, "Ryūgū-jō · the Dragon Palace")
        XCTAssertEqual(card.line, "A palace at the bottom of the sea, where the Dragon King lives.")
        XCTAssertEqual(card.noteLabel, "From Japan")
        XCTAssertEqual(card.background, "#06204A")
        XCTAssertEqual(card.picture.assetName, "see-rin-gin")
        XCTAssertEqual(card.pictureSource, .story(story.id))
        XCTAssertFalse(card.isLandmark)
        XCTAssertFalse(card.isFramed)
        XCTAssertEqual(card.actionName, "Show picture: Rin Gin")
    }

    func testLandmarkCardUsesTheSameCardInTheStorysTierWording() throws {
        // Criterion 3.8, for each prototype story's landmark.
        let landmarks = try SampleContent.landmarks()
        let expectations: [(StoryID, String, String, Bool)] = [
            (SampleContent.storyID, "taj-mahal-moment", "taj-mahal", true),
            (PrototypeContent.anansiID, "village-houses", "asante-traditional-buildings", false),
            (PrototypeContent.urashimaID, "skytree-moment", "tokyo-skytree", true),
        ]
        for (storyID, targetID, landmarkID, framed) in expectations {
            let story = try PrototypeContent.story(storyID)
            let target = try XCTUnwrap(story.tapTarget(id: TapTargetID(targetID)), "\(storyID)")
            let landmark = try XCTUnwrap(landmarks.landmark(id: LandmarkID(landmarkID)))
            let card = try XCTUnwrap(TapCardContent(target: target, story: story, landmarks: landmarks), "\(storyID)")

            XCTAssertTrue(card.isLandmark)
            XCTAssertEqual(card.title, landmark.name)
            XCTAssertEqual(card.line, landmark.factCards[story.tier].line, "\(storyID): fact line for the story's tier")
            XCTAssertEqual(card.pictureSource, .landmark)
            XCTAssertEqual(card.picture, landmark.art)
            XCTAssertEqual(card.isFramed, framed, "\(storyID)")
            if framed {
                let device = try XCTUnwrap(target.landmark?.framingDevice)
                XCTAssertEqual(card.noteLabel, device.label, "\(storyID): framing label")
                XCTAssertTrue(card.noteText?.hasPrefix(device.line) ?? false, "\(storyID): framing line comes first")
            } else {
                XCTAssertEqual(card.noteLabel, LandmarkCardContent.defaultNoteLabel)
            }
        }
    }

    func testAdvancedAndMediumStoriesGetTheirOwnTierWording() throws {
        let landmarks = try SampleContent.landmarks()
        let urashima = try PrototypeContent.story(PrototypeContent.urashimaID)
        let skytree = try XCTUnwrap(landmarks.landmark(id: LandmarkID("tokyo-skytree")))
        let target = try XCTUnwrap(urashima.tapTarget(id: TapTargetID("skytree-moment")))
        let card = try XCTUnwrap(TapCardContent(target: target, story: urashima, landmarks: landmarks))
        XCTAssertEqual(card.line, skytree.factCards.advanced.line)
        XCTAssertNotEqual(card.line, skytree.factCards.low.line)
        XCTAssertNotEqual(card.line, skytree.factCards.medium.line)
    }

    func testLostWonderCardSaysItIsAReconstruction() throws {
        var story = try SampleContent.story()
        let landmarks = try SampleContent.landmarks()
        let index = try SampleContent.landmarkTargetIndex(in: story)
        story.tapTargets[index].landmark?.id = LandmarkID("lighthouse-of-alexandria")
        let card = try XCTUnwrap(TapCardContent(target: story.tapTargets[index], story: story, landmarks: landmarks))
        XCTAssertEqual(card.subtitle, LandmarkCardContent.reconstructionSubtitle)
    }

    func testCardIsNilWhenItCannotBeFilled() throws {
        var story = try SampleContent.story()
        let landmarks = try SampleContent.landmarks()
        let index = try SampleContent.landmarkTargetIndex(in: story)
        story.tapTargets[index].landmark?.id = LandmarkID("not-in-the-catalog")
        XCTAssertNil(TapCardContent(target: story.tapTargets[index], story: story, landmarks: landmarks))

        var ordinary = try XCTUnwrap(story.tapTarget(id: TapTargetID("river-bank")))
        ordinary.line = nil
        XCTAssertNil(TapCardContent(target: ordinary, story: story, landmarks: landmarks))
    }

    func testCharacterCard() throws {
        let story = try SampleContent.story()
        let monkey = try XCTUnwrap(story.character(id: CharacterID("monkey")))
        let card = try XCTUnwrap(CharacterCardContent(character: monkey))
        XCTAssertEqual(card.title, "The Monkey")
        XCTAssertEqual(card.traits.count, 3)
        XCTAssertEqual(card.portrait.assetName, "char-monkey")
        XCTAssertEqual(card.actionName, "About: The Monkey")
        XCTAssertFalse(card.body.isEmpty)

        // A character without a card opens nothing, so its name is not a tap target.
        let crocodile = try XCTUnwrap(story.character(id: CharacterID("crocodile")))
        XCTAssertNil(CharacterCardContent(character: crocodile))
        XCTAssertNil(story.cardContent(for: .character(CharacterID("crocodile")), landmarks: try SampleContent.landmarks()))
    }

    func testCharacterCardShowsAtMostThreeTraits() throws {
        var monkey = try XCTUnwrap(try SampleContent.story().character(id: CharacterID("monkey")))
        let extra = try XCTUnwrap(monkey.card?.traits.first)
        monkey.card?.traits.append(contentsOf: [extra, extra])
        XCTAssertEqual(CharacterCardContent(character: monkey)?.traits.count, CharacterCardContent.maximumTraits)
    }

    func testStoryResolvesCardsAndParagraphs() throws {
        let story = try SampleContent.story()
        let landmarks = try SampleContent.landmarks()
        guard case .tap(let tap)? = story.cardContent(for: .tapTarget(TapTargetID("river-bank")), landmarks: landmarks) else {
            return XCTFail("river-bank should open a tap-to-see card")
        }
        XCTAssertEqual(tap.title, "River bank")
        guard case .character(let character)? = story.cardContent(for: .character(CharacterID("monkey")), landmarks: landmarks) else {
            return XCTFail("the Monkey should open a character card")
        }
        XCTAssertEqual(character.characterID, CharacterID("monkey"))
        XCTAssertNil(story.cardContent(for: .tapTarget(TapTargetID("nothing")), landmarks: landmarks))

        let first = story.spreads[0].blocks[0]
        XCTAssertEqual(story.block(id: first.id), first)
        XCTAssertEqual(story.block(id: first.id.fragment(2)), first)
        XCTAssertNil(story.block(id: BlockID("nowhere")))
        XCTAssertEqual(first.cardRefs, [.tapTarget(TapTargetID("river-bank"))])
    }

    func testEveryPrototypeStoryHasALandmarkATapTargetAndACharacterCard() throws {
        let landmarks = try SampleContent.landmarks()
        for story in try PrototypeContent.allStories() {
            let marked = Set(story.spreads.flatMap(\.blocks).flatMap(\.cardRefs))
            let cards = marked.compactMap { story.cardContent(for: $0, landmarks: landmarks) }
            let tapCards = cards.compactMap { content -> TapCardContent? in
                if case .tap(let tap) = content { return tap }
                return nil
            }
            XCTAssertTrue(tapCards.contains { $0.isLandmark }, "\(story.id): no landmark is marked on a word")
            XCTAssertTrue(tapCards.contains { !$0.isLandmark }, "\(story.id): no ordinary tap-to-see word")
            XCTAssertTrue(cards.contains { content in
                if case .character = content { return true }
                return false
            }, "\(story.id): no character name opens a card")
            // Every marked tap word can fill its card.
            for target in story.tapTargets {
                XCTAssertNotNil(TapCardContent(target: target, story: story, landmarks: landmarks), "\(story.id) \(target.id)")
            }
        }
    }
}

final class PrototypeStoryTests: XCTestCase {
    func testAllThreeStoriesValidateWithTextFidelity() throws {
        // Criterion 2.5.
        let repository = try SampleContent.repository()
        let landmarks = try repository.loadLandmarks()
        for id in try repository.loadCatalog().stories {
            let story = try repository.loadStory(id: id)
            let manuscript = try XCTUnwrap(try repository.loadManuscript(id: id), "\(id) has no manuscript")
            let report = StoryValidator().validate(story: story, landmarks: landmarks, manuscript: manuscript)
            XCTAssertEqual(report.errors, [], "\(id)")
            XCTAssertFalse(report.contains(.wordsPerSpread), "\(id)")
            XCTAssertFalse(report.contains(.unusedTapTarget), "\(id)")
            XCTAssertNil(TextFidelity.compare(story: story, manuscript: manuscript), "\(id)")
        }
    }

    func testOneStoryPerTierFromThreeRegions() throws {
        let stories = try PrototypeContent.allStories()
        XCTAssertEqual(stories.map(\.tier), [.low, .medium, .advanced])
        XCTAssertEqual(stories.map(\.region.id), [.indian, .african, .japanese])
        XCTAssertTrue(stories.allSatisfy { $0.provenance.textBasis == .omramoRetelling })
    }

    func testAnansiIsTheMediumStoryAsDesigned() throws {
        let story = try PrototypeContent.story(PrototypeContent.anansiID)
        XCTAssertEqual(story.title, "How Wisdom Became the Property of the Human Race")
        XCTAssertEqual(story.subtitle, "An Anansi story")
        XCTAssertEqual(story.region.label, "Akan · Ghana")
        XCTAssertEqual(story.culturalReview.level, .required)
        // Twilight forest: light text, dark chrome on every pane, amber page-turn button.
        XCTAssertEqual(story.theme.textColor, "#FBF2E2")
        XCTAssertEqual(story.theme.chrome, ChromeTheme(leading: .dark, trailing: .dark, folded: .dark))
        XCTAssertEqual(story.theme.accent, .amber)
        // Medium keeps its text on one pane.
        XCTAssertTrue(story.spreads.flatMap(\.blocks).allSatisfy { $0.pane == .leading })
        XCTAssertNotNil(story.character(id: CharacterID("anansi"))?.card)
        XCTAssertNotNil(story.character(id: CharacterID("kweku-tsin"))?.card)
        // The village's houses are part of the story's own world.
        XCTAssertEqual(story.tapTarget(id: TapTargetID("village-houses"))?.landmark?.appearance, .natural)
    }

    func testUrashimaIsTheAdvancedStoryAsDesigned() throws {
        let story = try PrototypeContent.story(PrototypeContent.urashimaID)
        XCTAssertEqual(story.title, "The Story of Urashima Taro")
        XCTAssertEqual(story.region.label, "Japan")
        XCTAssertEqual(story.theme.textColor, "#13264A")
        XCTAssertEqual(story.theme.chrome, ChromeTheme(leading: .light, trailing: .light, folded: .light))
        XCTAssertEqual(story.theme.accent, .red)

        // Advanced has text on both panes of every page, and the picture keeps the lower part
        // of the trailing pane.
        for spread in story.spreads {
            XCTAssertTrue(spread.blocks.contains { $0.pane == .leading }, "\(spread.id)")
            XCTAssertTrue(spread.blocks.contains { $0.pane == .trailing }, "\(spread.id)")
            XCTAssertEqual(spread.scene.textArea?.trailingBottom, 420, "\(spread.id)")
        }

        // The call across the water is set on the designed wave.
        let pathBlocks = story.spreads.flatMap(\.blocks).filter { $0.kind == .pathText }
        XCTAssertEqual(pathBlocks.count, 1)
        let call = try XCTUnwrap(pathBlocks.first)
        XCTAssertEqual(call.pane, .trailing)
        XCTAssertEqual(TextFidelity.normalize(call.plainText), "\"Urashima, Urashima!\"")
        XCTAssertNotNil(call.path.flatMap { SVGPath(string: $0) })

        // The modern tower is framed, never shown as part of old Japan.
        let skytree = try XCTUnwrap(story.tapTarget(id: TapTargetID("skytree-moment"))?.landmark)
        XCTAssertEqual(skytree.appearance, .framed)
        XCTAssertEqual(skytree.framingDevice?.kind, .thenAndNow)
    }

    func testNewLandmarksAreInTheCatalog() throws {
        let landmarks = try SampleContent.landmarks()
        let asante = try XCTUnwrap(landmarks.landmark(id: LandmarkID("asante-traditional-buildings")))
        XCTAssertEqual(asante.region, .african)
        XCTAssertEqual(asante.country, "Ghana")
        let skytree = try XCTUnwrap(landmarks.landmark(id: LandmarkID("tokyo-skytree")))
        XCTAssertEqual(skytree.region, .japanese)
        XCTAssertEqual(skytree.era, .contemporary)
        XCTAssertEqual(skytree.built?.from, 2008)
        XCTAssertTrue(StoryValidator().validate(landmarks: landmarks).isValid)
    }

    func testAModernLandmarkMarkedNaturalInOldJapanIsRefused() throws {
        var story = try PrototypeContent.story(PrototypeContent.urashimaID)
        let index = try XCTUnwrap(story.tapTargets.firstIndex { $0.id == TapTargetID("skytree-moment") })
        story.tapTargets[index].landmark?.appearance = .natural
        story.tapTargets[index].landmark?.framingDevice = nil
        let manuscript = try XCTUnwrap(try SampleContent.repository().loadManuscript(id: story.id))
        let report = StoryValidator().validate(story: story, landmarks: try SampleContent.landmarks(), manuscript: manuscript)
        assertError(report, .landmarkAnachronism)
    }

    func testEveryVoiceAndNameResolvesInEveryStory() throws {
        for story in try PrototypeContent.allStories() {
            for run in story.spreads.flatMap(\.blocks).flatMap(\.runs) {
                if let speaker = run.speaker {
                    XCTAssertNotNil(story.character(id: speaker), "\(story.id)")
                }
                if let name = run.characterName {
                    XCTAssertNotNil(story.character(id: name), "\(story.id)")
                }
                if let tap = run.tapTarget {
                    XCTAssertNotNil(story.tapTarget(id: tap), "\(story.id)")
                }
            }
        }
    }
}

final class TabletLayoutTests: XCTestCase {
    private let resolver = PaneLayoutResolver()

    private func layout(_ width: Double, _ height: Double) -> PaneLayout {
        resolver.resolve(PaneLayoutInput(canvasWidth: width, canvasHeight: height))
    }

    func testFullSizeTabletsInLandscapeUseTwoPanes() {
        // iPad Pro 11-inch and 13-inch, landscape (points).
        for (width, height) in [(1194.0, 834.0), (1210.0, 834.0), (1366.0, 1024.0), (1376.0, 1032.0)] {
            let result = layout(width, height)
            XCTAssertEqual(result.posture, .unfolded, "\(width) × \(height)")
            XCTAssertEqual(result.hinge?.width, 28)
            XCTAssertEqual((result.leading.width) * 2 + 28, width, accuracy: 0.001)
        }
    }

    func testThirteenInchPortraitUsesTwoPanesAndElevenInchOne() {
        // Wide enough for two generous panes…
        XCTAssertEqual(layout(1024, 1366).posture, .unfolded)
        XCTAssertEqual(layout(1032, 1376).posture, .unfolded)
        // …an 11-inch iPad in portrait is not: one well-padded pane.
        XCTAssertEqual(layout(834, 1194).posture, .folded)
        XCTAssertEqual(layout(834, 1210).posture, .folded)
        XCTAssertEqual(layout(820, 1180).posture, .folded)
    }

    func testSplitViewAndStageManagerWindows() {
        // 13-inch landscape, half and half: each window is narrow → single pane.
        XCTAssertEqual(layout(678, 1024).posture, .folded)
        // Two-thirds of a 13-inch landscape screen is wide enough for two panes.
        XCTAssertEqual(layout(981, 1024).posture, .unfolded)
        // Slide Over / the narrowest Split View column.
        XCTAssertEqual(layout(320, 1024).posture, .folded)
        XCTAssertEqual(layout(375, 834).posture, .folded)
        // A wide but very short Stage Manager window is one pane, not two squashed ones.
        XCTAssertEqual(layout(1000, 500).posture, .folded)
    }

    func testResizingAcrossTheThresholdSwitchesLayoutAtOnePoint() {
        // Criterion i.3 starts here: the switch is a pure function of the window size.
        XCTAssertEqual(layout(747.9, 700).posture, .folded)
        XCTAssertEqual(layout(748, 700).posture, .unfolded)
        XCTAssertEqual(layout(979, 1300).posture, .folded)
        XCTAssertEqual(layout(980, 1300).posture, .unfolded)
    }

    func testTheDesignIsNotBlownUpOnALargeWindow() {
        // 13-inch landscape: a pane is 669 × 1024, which would fit the design at 1.42 ×.
        let big = layout(1366, 1024)
        XCTAssertEqual(big.maximumReferenceScale, 1.3)
        XCTAssertEqual(big.referenceScale, 1.3, accuracy: 0.0001)
        XCTAssertEqual(big.contentWidth, 432 * 1.3, accuracy: 0.0001)
        XCTAssertLessThan(big.contentWidth, big.leading.width)

        // 11-inch portrait, one pane 834 wide: capped as well, never a stretched phone.
        let portrait = layout(834, 1210)
        XCTAssertEqual(portrait.referenceScale, 1.3, accuracy: 0.0001)
        XCTAssertLessThan(portrait.contentWidth, portrait.leading.width)

        // 11-inch landscape fits the design at about 1.16 ×, under the cap.
        let eleven = layout(1194, 834)
        XCTAssertEqual(eleven.referenceScale, 834.0 / 720.0, accuracy: 0.0001)
    }

    func testPhonesAndTheDuoAreNotCapped() {
        // An ordinary iPhone scales down with its width, as before.
        let phone = layout(393, 852)
        XCTAssertEqual(phone.referenceScale, 393.0 / 432.0, accuracy: 0.0001)
        XCTAssertEqual(phone.contentWidth, 393, accuracy: 0.0001)

        // A system-reported hinge (the real Duo) and the simulated canvas carry no limit.
        let duo = resolver.resolve(PaneLayoutInput(
            canvasWidth: 1784,
            canvasHeight: 1440,
            reportedHinge: LayoutRect(x: 864, y: 0, width: 56, height: 1440)
        ))
        XCTAssertNil(duo.maximumReferenceScale)
        XCTAssertEqual(duo.referenceScale, 2, accuracy: 0.0001)
        let simulated = resolver.resolve(PaneLayoutInput(canvasWidth: 2000, canvasHeight: 1800, simulation: .unfolded))
        XCTAssertNil(simulated.maximumReferenceScale)
        XCTAssertGreaterThan(simulated.referenceScale, 1.3)
    }

    func testNarrowWindowKeepsReadableType() {
        // Criterion i.2: in the narrowest window the Advanced body text stays above 11 pt.
        let narrow = layout(320, 1024)
        let advanced = Tier.advanced.readingScale(posture: .folded).body.size * narrow.referenceScale
        XCTAssertGreaterThan(advanced, 11)
    }
}
