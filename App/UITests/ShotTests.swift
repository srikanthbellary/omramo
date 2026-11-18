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
        name: String
    ) throws {
        XCUIDevice.shared.orientation = orientation
        let app = XCUIApplication()
        app.launchArguments = (reset ? ["-OmramoResetState"] : []) + arguments
        app.launch()

        let landmark = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
        XCTAssertTrue(landmark.waitForExistence(timeout: 20), "\(identifier) never appeared for \(name)")
        // Art, the rotation, the splash and any transition come to rest.
        Thread.sleep(forTimeInterval: settle)

        try FileManager.default.createDirectory(atPath: shotDir, withIntermediateDirectories: true)
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let url = URL(fileURLWithPath: shotDir).appendingPathComponent("r4-\(device)-\(name).png")
        try data.write(to: url)
        app.terminate()
    }
}
