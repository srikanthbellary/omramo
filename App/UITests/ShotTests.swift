import XCTest
import UIKit

/// Simulator screenshots for round 3. Not part of the regular unit-test suite (see the
/// OmramoShots scheme). Writes `r3-*.png` into `OMRAMO_SHOT_DIR` (default `/tmp/omramo-shots`).
///
/// Run on an iPad simulator for the landscape and portrait sets, and on an iPhone simulator
/// for the phone set (file names carry `ipad` or `iphone`):
///
///     xcodebuild test -project Omramo.xcodeproj -scheme OmramoShots \
///       -destination 'platform=iOS Simulator,id=<udid>' -only-testing:OmramoUITests/ShotTests
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

    /// Time for a transition (0.45 s at most) and a rotation to come fully to rest.
    private let settle: TimeInterval = 1.5

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

    /// `-OmramoPosture folded` on a phone: the whole screen, not a letterboxed device picture.
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

    // MARK: Tap-to-see

    func testTapToSeeLandscape() throws {
        try XCTSkipUnless(isPad, "landscape shots are taken on an iPad")
        try tapToSee(.landscapeLeft)
    }

    func testTapToSeePortrait() throws {
        try tapToSee(.portrait)
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

    private func tapToSee(_ orientation: UIDeviceOrientation) throws {
        let side = orientation == .portrait ? "portrait" : "landscape"
        try capture(
            arguments: ["-OmramoOpenStory", "monkey-and-crocodile", "-OmramoOpenCard", "river-bank"],
            orientation: orientation,
            waitFor: "card.river-bank",
            name: "tap-to-see-\(side)"
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
        // Art, the rotation and any transition come to rest.
        Thread.sleep(forTimeInterval: settle)

        try FileManager.default.createDirectory(atPath: shotDir, withIntermediateDirectories: true)
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let url = URL(fileURLWithPath: shotDir).appendingPathComponent("r3-\(device)-\(name).png")
        try data.write(to: url)
        app.terminate()
    }
}
