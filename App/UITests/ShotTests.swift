import XCTest
import UIKit

/// Simulator screenshots for round 4. Not part of the regular unit-test suite (see the
/// OmramoShots scheme). Writes `r4-*.png` into `OMRAMO_SHOT_DIR` (default `/tmp/omramo-shots`).
///
/// Run on an iPad simulator for the landscape and portrait sets, and on an iPhone simulator
/// for the phone set (file names carry `ipad` or `iphone`):
///
///     xcodebuild test -project Omramo.xcodeproj -scheme OmramoShots \
///       -destination 'platform=iOS Simulator,id=<udid>' -only-testing:OmramoUITests/ShotTests
///
/// The matrix is round 3's — library (empty and with a reading history), the three stories and
/// tap-to-see, iPad landscape and portrait, iPhone portrait, the folded posture on an iPhone —
/// plus, new in round 4: the story-finished moment and the splash on both devices, and the
/// unfolded posture on an iPhone (library, the three stories, tap-to-see), which now fills the
/// screen in landscape.
///
/// Every shot starts from `-OmramoResetState` (empty, in-memory stores), so page 1 of each
/// story is what is photographed, whatever was read on that simulator before. Each waits for
/// a known accessibility identifier, then a fixed moment for the transition to come to rest.
///
/// Round 5 (the stories round) adds the `testR5…` methods, which write `r5-*.png`: the library
/// with the bigger catalog (all levels, and the Low level's grid) and every new story's reader
/// — its first page and one page of each later scene — on an iPad (landscape and portrait)
/// and an iPhone (portrait and the folded posture), plus one new tap-to-see card, one landmark
/// card, one character card and one story-finished moment. The round-4 methods above them
/// still write the `r4-*.png` set.
final class ShotTests: XCTestCase {
    private var shotDir: String {
        ProcessInfo.processInfo.environment["OMRAMO_SHOT_DIR"] ?? "/tmp/omramo-shots"
    }

    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    private var device: String {
        isPad ? "ipad" : "iphone"
    }

    /// Time for the splash (under 1 s on a launch that shows it), a transition (0.5 s at
    /// most) and a rotation to come fully to rest.
    private let settle: TimeInterval = 2.2

    override func setUp() {
        continueAfterFailure = false
    }

    override func tearDown() {
        XCUIDevice.shared.orientation = .portrait
    }

    // MARK: Library

    func testLibraryLandscape() throws {
        try XCTSkipUnless(isPad, "landscape shots are taken on an iPad")
        try capture(arguments: [], orientation: .landscapeLeft, waitFor: "library.streak", name: "library-landscape")
    }

    func testLibraryPortrait() throws {
        try capture(arguments: [], orientation: .portrait, waitFor: "library.streak", name: "library-portrait")
    }

    /// The same screens with a small made-up reading history, so the cards are filled.
    func testLibraryWithReadingLandscape() throws {
        try XCTSkipUnless(isPad, "landscape shots are taken on an iPad")
        try capture(arguments: ["-OmramoDemoState"], reset: false, orientation: .landscapeLeft, waitFor: "library.streak", name: "library-reading-landscape")
    }

    func testLibraryWithReadingPortrait() throws {
        try capture(arguments: ["-OmramoDemoState"], reset: false, orientation: .portrait, waitFor: "library.streak", name: "library-reading-portrait")
    }

    // MARK: Reader

    func testReaderMonkeyLandscape() throws {
        try reader("monkey-and-crocodile", "monkey", .landscapeLeft)
    }

    func testReaderMonkeyPortrait() throws {
        try reader("monkey-and-crocodile", "monkey", .portrait)
    }

    func testReaderAnansiLandscape() throws {
        try reader("anansi-wisdom", "anansi", .landscapeLeft)
    }

    func testReaderAnansiPortrait() throws {
        try reader("anansi-wisdom", "anansi", .portrait)
    }

    func testReaderUrashimaLandscape() throws {
        try reader("urashima-taro", "urashima", .landscapeLeft)
    }

    func testReaderUrashimaPortrait() throws {
        try reader("urashima-taro", "urashima", .portrait)
    }

    // MARK: Folded posture on an iPhone (the real screen, edge to edge)

    func testReaderMonkeyFoldedPosture() throws {
        try XCTSkipIf(isPad, "the folded-posture shot is taken on an iPhone")
        try capture(
            arguments: ["-OmramoOpenStory", "monkey-and-crocodile", "-OmramoPosture", "folded"],
            orientation: .portrait,
            waitFor: "reader.next",
            name: "reader-monkey-folded"
        )
    }

    func testLibraryFoldedPosture() throws {
        try XCTSkipIf(isPad, "the folded-posture shot is taken on an iPhone")
        try capture(arguments: ["-OmramoPosture", "folded"], orientation: .portrait, waitFor: "library.streak", name: "library-folded")
    }

    /// The partial card: the tapped line stays in view above it.
    func testTapToSeeFoldedPosture() throws {
        try XCTSkipIf(isPad, "the folded-posture shot is taken on an iPhone")
        try capture(
            arguments: ["-OmramoOpenStory", "monkey-and-crocodile", "-OmramoOpenCard", "river-bank", "-OmramoPosture", "folded"],
            orientation: .portrait,
            waitFor: "card.river-bank",
            name: "tap-to-see-folded"
        )
    }

    // MARK: Unfolded posture on an iPhone (round 4: two panes over the whole screen, landscape)

    func testLibraryUnfoldedPosture() throws {
        try XCTSkipIf(isPad, "the unfolded-posture shots are taken on an iPhone")
        try capture(arguments: ["-OmramoPosture", "unfolded"], orientation: .landscapeLeft, waitFor: "library.streak", name: "library-unfolded")
    }

    func testReaderMonkeyUnfoldedPosture() throws {
        try unfoldedReader("monkey-and-crocodile", "monkey")
    }

    func testReaderAnansiUnfoldedPosture() throws {
        try unfoldedReader("anansi-wisdom", "anansi")
    }

    func testReaderUrashimaUnfoldedPosture() throws {
        try unfoldedReader("urashima-taro", "urashima")
    }

    func testTapToSeeUnfoldedPosture() throws {
        try XCTSkipIf(isPad, "the unfolded-posture shots are taken on an iPhone")
        try capture(
            arguments: ["-OmramoOpenStory", "monkey-and-crocodile", "-OmramoOpenCard", "river-bank", "-OmramoPosture", "unfolded"],
            orientation: .landscapeLeft,
            waitFor: "card.river-bank",
            name: "tap-to-see-unfolded"
        )
    }

    // MARK: Tap-to-see

    func testTapToSeeLandscape() throws {
        try XCTSkipUnless(isPad, "landscape shots are taken on an iPad")
        try tapToSee(.landscapeLeft)
    }

    func testTapToSeePortrait() throws {
        try tapToSee(.portrait)
    }

    // MARK: Story finished (round 4)

    func testFinishedLandscape() throws {
        try XCTSkipUnless(isPad, "landscape shots are taken on an iPad")
        try finished(.landscapeLeft)
    }

    func testFinishedPortrait() throws {
        try finished(.portrait)
    }

    // MARK: Splash (round 4)

    func testSplashLandscape() throws {
        try XCTSkipUnless(isPad, "landscape shots are taken on an iPad")
        try capture(arguments: ["-OmramoShowSplash"], orientation: .landscapeLeft, waitFor: "splash", name: "splash-landscape")
    }

    func testSplashPortrait() throws {
        try capture(arguments: ["-OmramoShowSplash"], orientation: .portrait, waitFor: "splash", name: "splash-portrait")
    }

    /// The wordmark across the hinge on an iPhone simulating the unfolded Duo.
    func testSplashUnfoldedPosture() throws {
        try XCTSkipIf(isPad, "the unfolded-posture shots are taken on an iPhone")
        try capture(
            arguments: ["-OmramoShowSplash", "-OmramoPosture", "unfolded"],
            orientation: .landscapeLeft,
            waitFor: "splash",
            name: "splash-unfolded"
        )
    }

    // MARK: Round 5 — the bigger catalog and the new stories (`r5-*.png`)

    /// The stories added in round 5, batch 1, with the short name used in file names. Later
    /// batches add theirs here.
    private static let newStories: [(id: String, short: String)] = [
        ("shipwrecked-sailor", "sailor"),
        ("tongue-cut-sparrow", "sparrow"),
        ("old-man-who-moved-mountains", "mountains"),
        ("why-possums-tail-is-bare", "possum"),
        ("the-snow-house", "snow-house"),
        ("peasant-and-bear", "peasant-bear"),
        ("bremen-town-musicians", "bremen"),
        ("north-wind-and-sun", "wind-sun"),
        ("why-sun-and-moon-live-in-sky", "sun-moon"),
        ("lion-and-hare", "lion-hare"),
    ]

    /// Pages photographed for each new story besides page 1: with four scenes over 12 to 14
    /// pages, these land in the later scenes.
    private static let laterPages = [5, 9, 12]

    func testR5LibraryPortrait() throws {
        try capture(arguments: [], orientation: .portrait, waitFor: "library.shelf.low", name: "library-portrait", round: "r5")
    }

    func testR5LibraryLandscape() throws {
        try XCTSkipUnless(isPad, "landscape shots are taken on an iPad")
        try capture(arguments: [], orientation: .landscapeLeft, waitFor: "library.shelf.low", name: "library-landscape", round: "r5")
    }

    func testR5LibraryWithReadingPortrait() throws {
        try capture(arguments: ["-OmramoDemoState"], reset: false, orientation: .portrait, waitFor: "library.shelf.low", name: "library-reading-portrait", round: "r5")
    }

    func testR5LibraryWithReadingLandscape() throws {
        try XCTSkipUnless(isPad, "landscape shots are taken on an iPad")
        try capture(arguments: ["-OmramoDemoState"], reset: false, orientation: .landscapeLeft, waitFor: "library.shelf.low", name: "library-reading-landscape", round: "r5")
    }

    func testR5LibraryFoldedPosture() throws {
        try XCTSkipIf(isPad, "the folded-posture shot is taken on an iPhone")
        try capture(arguments: ["-OmramoPosture", "folded"], orientation: .portrait, waitFor: "library.shelf.low", name: "library-folded", round: "r5")
    }

    func testR5LibraryUnfoldedPosture() throws {
        try XCTSkipIf(isPad, "the unfolded-posture shots are taken on an iPhone")
        try capture(arguments: ["-OmramoPosture", "unfolded"], orientation: .landscapeLeft, waitFor: "library.shelf.low", name: "library-unfolded", round: "r5")
    }

    /// The Low level on its own: the grid of all eleven covers.
    func testR5LibraryLowLevelPortrait() throws {
        try capture(arguments: [], orientation: .portrait, waitFor: "library.shelf.low", name: "library-low-portrait", round: "r5", tapping: "Level: Low")
    }

    func testR5LibraryLowLevelLandscape() throws {
        try XCTSkipUnless(isPad, "landscape shots are taken on an iPad")
        try capture(arguments: [], orientation: .landscapeLeft, waitFor: "library.shelf.low", name: "library-low-landscape", round: "r5", tapping: "Level: Low")
    }

    /// Page 1 of every new story: iPad and iPhone, held upright.
    func testR5ReadersPortrait() throws {
        for story in ShotTests.newStories {
            try capture(
                arguments: ["-OmramoOpenStory", story.id],
                orientation: .portrait,
                waitFor: "reader.next",
                name: "reader-\(story.short)-portrait",
                round: "r5"
            )
        }
    }

    /// Page 1 of every new story on an iPad held sideways (two panes).
    func testR5ReadersLandscape() throws {
        try XCTSkipUnless(isPad, "landscape shots are taken on an iPad")
        for story in ShotTests.newStories {
            try capture(
                arguments: ["-OmramoOpenStory", story.id],
                orientation: .landscapeLeft,
                waitFor: "reader.next",
                name: "reader-\(story.short)-landscape",
                round: "r5"
            )
        }
    }

    /// Page 1 of every new story in the folded posture on an iPhone (the picture band).
    func testR5ReadersFoldedPosture() throws {
        try XCTSkipIf(isPad, "the folded-posture shots are taken on an iPhone")
        for story in ShotTests.newStories {
            try capture(
                arguments: ["-OmramoOpenStory", story.id, "-OmramoPosture", "folded"],
                orientation: .portrait,
                waitFor: "reader.next",
                name: "reader-\(story.short)-folded",
                round: "r5"
            )
        }
    }

    /// Page 1 of every new story as the unfolded Duo on an iPhone held sideways.
    func testR5ReadersUnfoldedPosture() throws {
        try XCTSkipIf(isPad, "the unfolded-posture shots are taken on an iPhone")
        for story in ShotTests.newStories {
            try capture(
                arguments: ["-OmramoOpenStory", story.id, "-OmramoPosture", "unfolded"],
                orientation: .landscapeLeft,
                waitFor: "reader.next",
                name: "reader-\(story.short)-unfolded",
                round: "r5"
            )
        }
    }

    /// The later scenes of every new story: an iPad sideways, an iPhone upright.
    func testR5LaterScenes() throws {
        let orientation: UIDeviceOrientation = isPad ? .landscapeLeft : .portrait
        let side = isPad ? "landscape" : "portrait"
        for story in ShotTests.newStories {
            for page in ShotTests.laterPages {
                try capture(
                    arguments: ["-OmramoOpenStory", story.id, "-OmramoOpenPage", String(page)],
                    orientation: orientation,
                    waitFor: "reader.next",
                    name: "reader-\(story.short)-p\(page)-\(side)",
                    round: "r5"
                )
            }
        }
    }

    /// The later scenes of every new story on an iPad held upright (the tall recomposition).
    func testR5LaterScenesTall() throws {
        try XCTSkipUnless(isPad, "the tall shots are taken on an iPad")
        for story in ShotTests.newStories {
            for page in ShotTests.laterPages {
                try capture(
                    arguments: ["-OmramoOpenStory", story.id, "-OmramoOpenPage", String(page)],
                    orientation: .portrait,
                    waitFor: "reader.next",
                    name: "reader-\(story.short)-p\(page)-portrait",
                    round: "r5"
                )
            }
        }
    }

    /// One new tap-to-see card, one new landmark card and one new character card.
    func testR5Cards() throws {
        let orientation: UIDeviceOrientation = isPad ? .landscapeLeft : .portrait
        let side = isPad ? "landscape" : "portrait"
        let cards: [(story: String, card: String, name: String)] = [
            ("tongue-cut-sparrow", "bamboo-grove", "tap-to-see-bamboo-grove"),
            ("the-snow-house", "nunavut", "tap-to-see-nunavut"),
            ("bremen-town-musicians", "bremen-moment", "landmark-bremen"),
            ("tongue-cut-sparrow", "himeji-moment", "landmark-himeji"),
            ("peasant-and-bear", "bear", "character-bear"),
            ("why-possums-tail-is-bare", "possum", "character-possum"),
        ]
        for card in cards {
            try capture(
                arguments: ["-OmramoOpenStory", card.story, "-OmramoOpenCard", card.card],
                orientation: orientation,
                waitFor: "card.\(card.card)",
                name: "\(card.name)-\(side)",
                round: "r5"
            )
        }
    }

    /// The story-finished moment of one new story, with its polished moral.
    func testR5Finished() throws {
        let orientation: UIDeviceOrientation = isPad ? .landscapeLeft : .portrait
        let side = isPad ? "landscape" : "portrait"
        try capture(
            arguments: ["-OmramoOpenFinished", "the-snow-house"],
            orientation: orientation,
            waitFor: "finished.moment",
            name: "finished-snow-house-\(side)",
            round: "r5"
        )
    }

    /// The splash with the round-5 tagline.
    func testR5Splash() throws {
        let orientation: UIDeviceOrientation = isPad ? .landscapeLeft : .portrait
        let side = isPad ? "landscape" : "portrait"
        try capture(arguments: ["-OmramoShowSplash"], orientation: orientation, waitFor: "splash", name: "splash-\(side)", round: "r5")
    }

    // MARK: Round 5, batch 2 — the Medium stories (`r5-*.png`)

    /// The ten Medium stories added in batch 2, with the short name used in file names.
    private static let mediumStories: [(id: String, short: String)] = [
        ("tiger-brahman-jackal", "tiger"),
        ("khufu-and-the-magician", "khufu"),
        ("bamboo-cutter-and-moon-child", "moon-child"),
        ("herd-boy-and-weaving-maiden", "weaver"),
        ("iktomi-and-the-muskrat", "iktomi"),
        ("long-day-at-fish-camp", "fish-camp"),
        ("sadko", "sadko"),
        ("androcles-and-the-lion", "androcles"),
        ("horse-and-the-olive", "olive"),
        ("sindbad-second-voyage", "sindbad"),
    ]

    /// Pages photographed for each Medium story besides page 1: with four scenes over nine or
    /// ten pages, these land in the later scenes.
    private static let mediumLaterPages = [4, 7, 9]

    /// The Medium level on its own: the grid of all eleven covers.
    func testR5LibraryMediumLevelPortrait() throws {
        try capture(arguments: [], orientation: .portrait, waitFor: "library.shelf.low", name: "library-medium-portrait", round: "r5", tapping: "Level: Medium")
    }

    func testR5LibraryMediumLevelLandscape() throws {
        try XCTSkipUnless(isPad, "landscape shots are taken on an iPad")
        try capture(arguments: [], orientation: .landscapeLeft, waitFor: "library.shelf.low", name: "library-medium-landscape", round: "r5", tapping: "Level: Medium")
    }

    /// Page 1 of every Medium story: iPad and iPhone, held upright.
    func testR5MediumReadersPortrait() throws {
        for story in ShotTests.mediumStories {
            try capture(
                arguments: ["-OmramoOpenStory", story.id],
                orientation: .portrait,
                waitFor: "reader.next",
                name: "reader-\(story.short)-portrait",
                round: "r5"
            )
        }
    }

    /// Page 1 of every Medium story on an iPad held sideways (two panes).
    func testR5MediumReadersLandscape() throws {
        try XCTSkipUnless(isPad, "landscape shots are taken on an iPad")
        for story in ShotTests.mediumStories {
            try capture(
                arguments: ["-OmramoOpenStory", story.id],
                orientation: .landscapeLeft,
                waitFor: "reader.next",
                name: "reader-\(story.short)-landscape",
                round: "r5"
            )
        }
    }

    /// Page 1 of every Medium story in the folded posture on an iPhone (the picture band).
    func testR5MediumReadersFoldedPosture() throws {
        try XCTSkipIf(isPad, "the folded-posture shots are taken on an iPhone")
        for story in ShotTests.mediumStories {
            try capture(
                arguments: ["-OmramoOpenStory", story.id, "-OmramoPosture", "folded"],
                orientation: .portrait,
                waitFor: "reader.next",
                name: "reader-\(story.short)-folded",
                round: "r5"
            )
        }
    }

    /// Page 1 of every Medium story as the unfolded Duo on an iPhone held sideways.
    func testR5MediumReadersUnfoldedPosture() throws {
        try XCTSkipIf(isPad, "the unfolded-posture shots are taken on an iPhone")
        for story in ShotTests.mediumStories {
            try capture(
                arguments: ["-OmramoOpenStory", story.id, "-OmramoPosture", "unfolded"],
                orientation: .landscapeLeft,
                waitFor: "reader.next",
                name: "reader-\(story.short)-unfolded",
                round: "r5"
            )
        }
    }

    /// The later scenes of every Medium story: an iPad sideways, an iPhone upright.
    func testR5MediumLaterScenes() throws {
        let orientation: UIDeviceOrientation = isPad ? .landscapeLeft : .portrait
        let side = isPad ? "landscape" : "portrait"
        for story in ShotTests.mediumStories {
            for page in ShotTests.mediumLaterPages {
                try capture(
                    arguments: ["-OmramoOpenStory", story.id, "-OmramoOpenPage", String(page)],
                    orientation: orientation,
                    waitFor: "reader.next",
                    name: "reader-\(story.short)-p\(page)-\(side)",
                    round: "r5"
                )
            }
        }
    }

    /// The later scenes of every Medium story on an iPad held upright (the tall recomposition).
    func testR5MediumLaterScenesTall() throws {
        try XCTSkipUnless(isPad, "the tall shots are taken on an iPad")
        for story in ShotTests.mediumStories {
            for page in ShotTests.mediumLaterPages {
                try capture(
                    arguments: ["-OmramoOpenStory", story.id, "-OmramoOpenPage", String(page)],
                    orientation: .portrait,
                    waitFor: "reader.next",
                    name: "reader-\(story.short)-p\(page)-portrait",
                    round: "r5"
                )
            }
        }
    }

    /// Batch 2 cards: tap-to-see, landmarks (a standing one, a natural one, a lost wonder and
    /// the unproven one) and character cards, from a light story and a dark one.
    func testR5MediumCards() throws {
        let orientation: UIDeviceOrientation = isPad ? .landscapeLeft : .portrait
        let side = isPad ? "landscape" : "portrait"
        let cards: [(story: String, card: String, name: String)] = [
            ("long-day-at-fish-camp", "drying-rack", "tap-to-see-drying-rack"),
            ("sadko", "gusli", "tap-to-see-gusli"),
            ("khufu-and-the-magician", "pyramid-moment", "landmark-pyramid"),
            ("bamboo-cutter-and-moon-child", "fuji-moment", "landmark-fuji"),
            ("horse-and-the-olive", "zeus-moment", "landmark-zeus"),
            ("sindbad-second-voyage", "baghdad-moment", "landmark-hanging-gardens"),
            ("iktomi-and-the-muskrat", "iktomi", "character-iktomi"),
            ("herd-boy-and-weaving-maiden", "zhinu", "character-zhinu"),
        ]
        for card in cards {
            try capture(
                arguments: ["-OmramoOpenStory", card.story, "-OmramoOpenCard", card.card],
                orientation: orientation,
                waitFor: "card.\(card.card)",
                name: "\(card.name)-\(side)",
                round: "r5"
            )
        }
    }

    /// The story-finished moment of two Medium stories (a light one and a dark one).
    func testR5MediumFinished() throws {
        let orientation: UIDeviceOrientation = isPad ? .landscapeLeft : .portrait
        let side = isPad ? "landscape" : "portrait"
        for story in [("long-day-at-fish-camp", "fish-camp"), ("sadko", "sadko")] {
            try capture(
                arguments: ["-OmramoOpenFinished", story.0],
                orientation: orientation,
                waitFor: "finished.moment",
                name: "finished-\(story.1)-\(side)",
                round: "r5"
            )
        }
    }

    // MARK: Helpers

    private func reader(_ storyID: String, _ short: String, _ orientation: UIDeviceOrientation) throws {
        if orientation != .portrait {
            try XCTSkipUnless(isPad, "landscape shots are taken on an iPad")
        }
        let side = orientation == .portrait ? "portrait" : "landscape"
        try capture(
            arguments: ["-OmramoOpenStory", storyID],
            orientation: orientation,
            waitFor: "reader.next",
            name: "reader-\(short)-\(side)"
        )
    }

    private func unfoldedReader(_ storyID: String, _ short: String) throws {
        try XCTSkipIf(isPad, "the unfolded-posture shots are taken on an iPhone")
        try capture(
            arguments: ["-OmramoOpenStory", storyID, "-OmramoPosture", "unfolded"],
            orientation: .landscapeLeft,
            waitFor: "reader.next",
            name: "reader-\(short)-unfolded"
        )
    }

    private func tapToSee(_ orientation: UIDeviceOrientation) throws {
        let side = orientation == .portrait ? "portrait" : "landscape"
        try capture(
            arguments: ["-OmramoOpenStory", "monkey-and-crocodile", "-OmramoOpenCard", "river-bank"],
            orientation: orientation,
            waitFor: "card.river-bank",
            name: "tap-to-see-\(side)"
        )
    }

    private func finished(_ orientation: UIDeviceOrientation) throws {
        let side = orientation == .portrait ? "portrait" : "landscape"
        try capture(
            arguments: ["-OmramoOpenFinished", "monkey-and-crocodile"],
            orientation: orientation,
            waitFor: "finished.moment",
            name: "finished-\(side)"
        )
    }

    private func capture(
        arguments: [String],
        reset: Bool = true,
        orientation: UIDeviceOrientation,
        waitFor identifier: String,
        name: String,
        round: String = "r4",
        tapping label: String? = nil
    ) throws {
        XCUIDevice.shared.orientation = orientation
        let app = XCUIApplication()
        app.launchArguments = (reset ? ["-OmramoResetState"] : []) + arguments
        app.launch()

        let landmark = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
        XCTAssertTrue(landmark.waitForExistence(timeout: 20), "\(identifier) never appeared for \(name)")
        if let label {
            // A control to press first (a level of the library's filter), found by its label.
            let control = app.buttons[label].firstMatch
            XCTAssertTrue(control.waitForExistence(timeout: 5), "no button “\(label)” for \(name)")
            control.tap()
        }
        // Art, the rotation, the splash and any transition come to rest.
        Thread.sleep(forTimeInterval: settle)

        try FileManager.default.createDirectory(atPath: shotDir, withIntermediateDirectories: true)
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let url = URL(fileURLWithPath: shotDir).appendingPathComponent("\(round)-\(device)-\(name).png")
        try data.write(to: url)
        app.terminate()
    }
}
