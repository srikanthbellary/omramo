import XCTest
import SwiftUI
import UIKit
import OmramoCore
@testable import Omramo

/// Round 5 (the stories round): every catalog story has a registered painter and every picture
/// it names is drawn by it at the shapes the app uses (not the stand-in); an unknown picture
/// never crashes; the library's shelves and the crowded story map; the new tagline.
@MainActor
final class StoryArtRegistryTests: XCTestCase {
    private final class Results {
        var known: [Bool] = []
    }

    /// Draws one picture off screen and says whether a painter knew its name (nil when the
    /// renderer drew nothing in this environment).
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

    /// The Advanced prototype: its painter and reader have their own round-2 to round-4 tests.
    static let urashima = StoryID("urashima-taro")

    private func bundledLibrary() throws -> Library {
        try BundledContent.repository().loadLibrary()
    }

    func testEveryCatalogStoryHasARegisteredPainter() throws {
        let library = try bundledLibrary()
        XCTAssertEqual(library.stories.count, 32)
        for story in library.stories {
            XCTAssertTrue(ArtLibrary.hasPainter(for: story.id), "\(story.id.rawValue) has no painter in ArtLibrary.storyPainter")
        }
        XCTAssertFalse(ArtLibrary.hasPainter(for: StoryID("no-such-story")))
        XCTAssertNil(ArtLibrary.storyPainter(for: ""))
    }

    func testEveryPainterKnowsEveryPictureItsStoryNames() throws {
        // Asked of the painters directly (no rendering needed): a throw-away context from a
        // tiny canvas is enough to learn whether the name is known.
        let library = try bundledLibrary()
        var missing: [String] = []
        var asked = 0
        for story in library.stories {
            var wanted: [(String, ArtRole, CGSize)] = [(story.cover.assetName, .cover, CGSize(width: 300, height: 346))]
            var scenes = Set<String>()
            for spread in story.spreads where scenes.insert(spread.scene.unfolded.assetName).inserted {
                wanted.append((spread.scene.unfolded.assetName, .sceneUnfolded, CGSize(width: 892, height: 720)))
                wanted.append((spread.scene.folded.assetName, .sceneFolded, CGSize(width: 432, height: 340)))
            }
            for character in story.characters {
                wanted.append((character.face.assetName, .face, CGSize(width: 100, height: 100)))
                if let card = character.card {
                    wanted.append((card.portrait.assetName, .portrait, CGSize(width: 432, height: 400)))
                }
            }
            for target in story.tapTargets {
                if let picture = target.picture {
                    wanted.append((picture.assetName, .picture, CGSize(width: 432, height: 404)))
                }
            }
            for item in wanted {
                guard let known = draw(item.0, source: .story(story.id), role: item.1, size: item.2) else { continue }
                asked += 1
                if !known {
                    missing.append("\(story.id.rawValue): \(item.0) (\(item.1))")
                }
            }
        }
        try XCTSkipIf(asked == 0, "ImageRenderer did not draw the canvases in this environment")
        XCTAssertEqual(missing, [], "pictures with no painter")
    }

    func testTheNewStoriesDrawAtEveryShapeTheAppUses() throws {
        // The shapes of ART_DIRECTION §5a: the designed Duo, a squat phone held sideways, a
        // tall iPad portrait; the folded band from very short to tall; the wide and the tall
        // cover. Drawing must not crash and the painter must know the name at every shape.
        let library = try bundledLibrary()
        let unfolded: [CGSize] = [
            CGSize(width: 892, height: 720), CGSize(width: 892, height: 412), CGSize(width: 892, height: 560),
            CGSize(width: 516, height: 688), CGSize(width: 446, height: 650),
        ]
        let folded: [CGSize] = [
            CGSize(width: 432, height: 240), CGSize(width: 432, height: 340), CGSize(width: 432, height: 420), CGSize(width: 432, height: 520),
        ]
        let covers: [CGSize] = [CGSize(width: 116, height: 134), CGSize(width: 372, height: 186), CGSize(width: 300, height: 375)]
        var drawn = 0
        var missing: [String] = []
        for story in library.stories where story.id != StoryArtRegistryTests.urashima {
            let source = ArtSource.story(story.id)
            var scenes = Set<String>()
            for spread in story.spreads where scenes.insert(spread.scene.unfolded.assetName).inserted {
                for size in unfolded {
                    guard let known = draw(spread.scene.unfolded.assetName, source: source, role: .sceneUnfolded, size: size) else { continue }
                    drawn += 1
                    if !known { missing.append("\(story.id.rawValue) \(spread.scene.unfolded.assetName) unfolded \(size)") }
                }
                for size in folded {
                    guard let known = draw(spread.scene.folded.assetName, source: source, role: .sceneFolded, size: size) else { continue }
                    drawn += 1
                    if !known { missing.append("\(story.id.rawValue) \(spread.scene.folded.assetName) folded \(size)") }
                }
            }
            for size in covers {
                guard let known = draw(story.cover.assetName, source: source, role: .cover, size: size) else { continue }
                drawn += 1
                if !known { missing.append("\(story.id.rawValue) cover \(size)") }
            }
        }
        try XCTSkipIf(drawn == 0, "ImageRenderer did not draw the canvases in this environment")
        XCTAssertEqual(missing, [])
    }

    func testEveryLandmarkOfTheCatalogHasAPicture() throws {
        let library = try bundledLibrary()
        var drawn = 0
        var missing: [String] = []
        for landmark in library.landmarks.landmarks {
            for size in [CGSize(width: 432, height: 404), CGSize(width: 372, height: 300)] {
                guard let known = draw(landmark.art.assetName, source: .landmark, role: .picture, size: size) else { continue }
                drawn += 1
                if !known { missing.append(landmark.id.rawValue) }
            }
        }
        try XCTSkipIf(drawn == 0, "ImageRenderer did not draw the canvases in this environment")
        XCTAssertEqual(missing, [])
        XCTAssertEqual(library.landmarks.landmarks.count, 37)
    }

    func testAnUnknownPictureOfAKnownStoryGetsTheStandInAndNeverCrashes() throws {
        let library = try bundledLibrary()
        let roles: [(ArtRole, CGSize)] = [
            (.sceneUnfolded, CGSize(width: 892, height: 720)), (.sceneFolded, CGSize(width: 432, height: 340)),
            (.picture, CGSize(width: 432, height: 404)), (.portrait, CGSize(width: 432, height: 400)),
            (.face, CGSize(width: 100, height: 100)), (.cover, CGSize(width: 300, height: 346)),
        ]
        for story in library.stories {
            for (role, size) in roles {
                let known = draw("no-such-picture", source: .story(story.id), role: role, size: size) ?? false
                XCTAssertFalse(known, "\(story.id.rawValue) \(role)")
            }
            // A real name asked in the wrong role is not known either.
            let wrong = draw("cover", source: .story(story.id), role: .face, size: CGSize(width: 100, height: 100)) ?? false
            XCTAssertFalse(wrong, story.id.rawValue)
        }
        // The views built on the stand-in still make an image.
        let view = CodeArtView(name: "no-such-picture", source: .story(StoryID("the-snow-house")), role: .picture, colors: ["#CDE8F6", "#FFE9C4", "#F4FAFF"])
            .frame(width: 120, height: 110)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        _ = renderer.uiImage
    }

    func testFaceChipsRenderForEveryNewCharacter() throws {
        let library = try bundledLibrary()
        for story in library.stories where story.id != StoryArtRegistryTests.urashima {
            XCTAssertGreaterThanOrEqual(story.characters.count, 2, story.id.rawValue)
            for character in story.characters {
                let chip = FaceChipRenderer.image(for: character, storyID: story.id, em: 23.5)
                XCTAssertGreaterThan(chip.size.width, chip.size.height, "\(story.id) \(character.id)")
            }
        }
    }
}

@MainActor
final class BiggerLibraryTests: XCTestCase {
    func testACardHasOneHeightSoShelvesAndGridsStayEven() {
        // Cover 134, a three-line title, the origin line.
        XCTAssertGreaterThan(StoryCardView.height, Tokens.Size.storyCoverHeight + 60)
        XCTAssertLessThan(StoryCardView.height, Tokens.Size.storyCoverHeight + 90)
        // Three covers and two gaps are exactly the card width of the design.
        XCTAssertEqual(Tokens.Size.storyCoverWidth * 3 + StoryCardView.gap * 2, Tokens.Spacing.cardWidth, accuracy: 0.001)
    }

    func testTheMapNamesOnlyTheStoryBeingReadOnceItIsCrowded() throws {
        let library = try BundledContent.repository().loadLibrary()
        let quiet = StoryMapPin.pins(for: library, readingNow: nil)
        XCTAssertEqual(quiet.count, library.stories.filter { $0.region.pin != nil }.count)
        XCTAssertGreaterThan(quiet.count, StoryMapRules.labelledPinLimit)
        XCTAssertTrue(quiet.allSatisfy { !$0.showsLabel })
        XCTAssertEqual(Set(quiet.map(\.id)).count, quiet.count)

        let reading = StoryID("tongue-cut-sparrow")
        let pins = StoryMapPin.pins(for: library, readingNow: reading)
        XCTAssertEqual(pins.count, quiet.count)
        // The story being read is drawn last (on top), ringed and named.
        XCTAssertEqual(pins.last?.id, reading)
        XCTAssertEqual(pins.last?.state, .readingNow)
        XCTAssertEqual(pins.last?.showsLabel, true)
        XCTAssertEqual(pins.filter(\.showsLabel).count, 1)
        XCTAssertEqual(pins.last?.label, "Japan")
    }

    func testASmallCatalogStillNamesEveryPin() throws {
        let library = try BundledContent.repository().loadLibrary()
        let three = Library(
            catalogVersion: 1,
            stories: Array(library.stories.prefix(3)),
            landmarks: library.landmarks
        )
        let pins = StoryMapPin.pins(for: three, readingNow: nil)
        XCTAssertEqual(pins.count, 3)
        XCTAssertTrue(pins.allSatisfy(\.showsLabel))
    }

    func testTheDemoStateStillFillsTheLibraryWithTheBiggerCatalog() throws {
        let library = try BundledContent.repository().loadLibrary()
        let today = ReadingDay(year: 2026, month: 11, day: 18)
        let demo = DebugLaunch.demoState(for: library, today: today)
        let shelf = ShelfState(stories: library.stories, progress: demo.progress, log: demo.log)
        XCTAssertEqual(shelf.finished, [StoryID("monkey-and-crocodile")])
        XCTAssertEqual(shelf.keepReading?.storyID, library.stories.last?.id)
        // The next story after the finished Low one is another Low story.
        let next = NextStory.suggestion(after: StoryID("monkey-and-crocodile"), in: library.stories, finished: Set(demo.log.finished))
        XCTAssertEqual(next?.tier, .low)
        XCTAssertEqual(next?.id, StoryID("shipwrecked-sailor"))
    }

    func testEveryNewStoryOpensAndReadsToItsMoral() throws {
        let library = try BundledContent.repository().loadLibrary()
        for story in library.stories where story.id != StoryArtRegistryTests.urashima {
            let model = ReaderModel(story: story, progress: ReadingProgressStore(fileURL: nil), catalog: library.stories)
            XCTAssertEqual(model.pageNumber, 1, story.id.rawValue)
            while !model.isLastPage {
                model.turnPage()
            }
            XCTAssertEqual(model.pageNumber, story.spreads.count, story.id.rawValue)
            XCTAssertEqual(model.moral, story.moral, story.id.rawValue)
            XCTAssertNotNil(model.nextStory, story.id.rawValue)
            XCTAssertNotEqual(model.nextStory?.id, story.id, story.id.rawValue)
        }
    }

    func testTheMediumShelfIsFullAndEveryMediumStoryHasItsPainter() throws {
        // Batch 2: eleven Medium stories, each with a registered painter of its own.
        let library = try BundledContent.repository().loadLibrary()
        let medium = library.stories.filter { $0.tier == .medium }
        XCTAssertEqual(medium.count, 11)
        for story in medium {
            XCTAssertTrue(ArtLibrary.hasPainter(for: story.id), story.id.rawValue)
        }
        let shelf = try XCTUnwrap(library.shelves().first { $0.tier == .medium })
        XCTAssertEqual(shelf.stories.map(\.id), medium.map(\.id))
        // Light stories and dark ones: the chrome follows the story's own theme.
        XCTAssertTrue(medium.contains { $0.theme.chrome.leading == .dark })
        XCTAssertTrue(medium.contains { $0.theme.chrome.leading == .light })
    }

    func testTheAdvancedShelfIsFullAndEveryAdvancedStoryHasItsPainter() throws {
        // Batch 3: ten Advanced stories (the catalog's 32), each with a painter of its own.
        let library = try BundledContent.repository().loadLibrary()
        let advanced = library.stories.filter { $0.tier == .advanced }
        XCTAssertEqual(advanced.count, 10)
        XCTAssertEqual(library.shelves().map(\.stories.count), [11, 11, 10])
        for story in advanced {
            XCTAssertTrue(ArtLibrary.hasPainter(for: story.id), story.id.rawValue)
        }
        let shelf = try XCTUnwrap(library.shelves().first { $0.tier == .advanced })
        XCTAssertEqual(shelf.stories.map(\.id), advanced.map(\.id))
        // Advanced pages carry words on both panes; the reader turns through every one.
        for story in advanced where story.id != StoryArtRegistryTests.urashima {
            XCTAssertTrue(story.spreads.allSatisfy { spread in spread.blocks.contains { $0.pane == .trailing } }, story.id.rawValue)
        }
        // Light stories and a dark one.
        XCTAssertTrue(advanced.contains { $0.theme.chrome.leading == .dark })
        XCTAssertTrue(advanced.contains { $0.theme.chrome.leading == .light })
    }

    func testTheTaglineOfRoundFive() {
        XCTAssertEqual(Brand.tagline, "Turn the page. See the world.")
        let halves = SplashView.taglineHalves()
        XCTAssertEqual(halves.leading, "Turn the page.")
        XCTAssertEqual(halves.trailing, "See the world.")
        // The old tagline, should it ever come back, would stay whole on the leading pane.
        let old = SplashView.taglineHalves("A magical book that you read.")
        XCTAssertEqual(old.leading, "A magical book that you read.")
        XCTAssertEqual(old.trailing, "")
    }
}
