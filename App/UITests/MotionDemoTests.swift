import XCTest
import UIKit

/// Slow, deterministic walks through the app's motion, for screen recordings (round 4).
/// Not assertions about the design: each test only fails when a control it needs is missing.
///
/// Record one while it runs (OmramoShots scheme; an iPhone or an iPad simulator, portrait):
///
///     xcrun simctl io <udid> recordVideo --codec h264 demo-page-turn.mov &
///     xcodebuild test -project Omramo.xcodeproj -scheme OmramoShots \
///       -destination 'platform=iOS Simulator,id=<udid>' \
///       -only-testing:OmramoUITests/MotionDemoTests/testDemoPageTurn
///     kill -INT %1
///
/// Every step waits for a control by its accessibility identifier before using it; the pauses
/// come only after a control exists and are there for the camera, not for the app. Every
/// launch uses `-OmramoResetState`, so nothing is read from or written to the simulator.
final class MotionDemoTests: XCTestCase {
    private let monkey = "monkey-and-crocodile"

    override func setUp() {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    /// Library → the Monkey story → back to the library (the cover grows into the reader and
    /// the reader closes back into it). Starts with the splash.
    func testDemoLibraryToStory() {
        let app = launch([])
        let cover = element("library.story.\(monkey)", in: app)
        XCTAssertTrue(cover.waitForExistence(timeout: 20), "the Monkey cover is not in the library")
        pause(1.5)
        cover.tap()

        let next = element("reader.next", in: app)
        XCTAssertTrue(next.waitForExistence(timeout: 10), "the reader did not open")
        pause(2)

        let library = element("reader.library", in: app)
        XCTAssertTrue(library.waitForExistence(timeout: 5), "the reader has no Library control")
        library.tap()
        XCTAssertTrue(waitUntilGone(next), "the reader did not close")
        XCTAssertTrue(cover.waitForExistence(timeout: 5), "the library did not come back")
        pause(1.5)
        app.terminate()
    }

    /// Three page turns forward, then one back.
    func testDemoPageTurn() {
        let app = launch(["-OmramoOpenStory", monkey])
        let next = element("reader.next", in: app)
        XCTAssertTrue(next.waitForExistence(timeout: 20), "the reader did not open")
        pause(1.5)
        for _ in 0..<3 {
            XCTAssertTrue(next.waitForExistence(timeout: 5))
            next.tap()
            pause(1.5)
        }
        let previous = element("reader.previous", in: app)
        XCTAssertTrue(previous.waitForExistence(timeout: 5), "there is no previous-page control after turning")
        previous.tap()
        pause(1.5)
        app.terminate()
    }

    /// A marked word opens its card; "Back to my line" closes it.
    func testDemoTapToSee() {
        let app = launch(["-OmramoOpenStory", monkey])
        let word = element("word.river-bank", in: app)
        XCTAssertTrue(word.waitForExistence(timeout: 20), "word.river-bank is not on page 1")
        pause(1.5)
        word.tap()

        let card = element("card.river-bank", in: app)
        XCTAssertTrue(card.waitForExistence(timeout: 5), "the card did not open")
        pause(2)

        let back = app.buttons["Back to my line"].firstMatch
        XCTAssertTrue(back.waitForExistence(timeout: 5), "the card has no \"Back to my line\" button")
        back.tap()
        XCTAssertTrue(waitUntilGone(card), "the card did not close")
        pause(1.5)
        app.terminate()
    }

    /// The last page, then the story-finished moment.
    func testDemoFinished() {
        // Page 14 is the last page of the Monkey story; a larger number is clamped to it.
        let app = launch(["-OmramoOpenStory", monkey, "-OmramoOpenPage", "14"])
        let next = element("reader.next", in: app)
        XCTAssertTrue(next.waitForExistence(timeout: 20), "the reader did not open")
        pause(1.5)

        // The last page may take more than one screen on a small phone: press the round
        // button until the finished moment arrives (a handful of presses at most).
        let finished = element("finished.moment", in: app)
        var presses = 0
        while !finished.exists, presses < 8 {
            XCTAssertTrue(next.waitForExistence(timeout: 5))
            next.tap()
            presses += 1
            _ = finished.waitForExistence(timeout: 1.5)
        }
        XCTAssertTrue(finished.waitForExistence(timeout: 5), "the story-finished moment did not appear")
        XCTAssertTrue(element("finished.again", in: app).waitForExistence(timeout: 5), "\"Read again\" is missing")
        XCTAssertTrue(element("finished.next", in: app).exists, "\"Next story\" is missing")
        pause(3)
        app.terminate()
    }

    // MARK: Helpers

    private func launch(_ arguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-OmramoResetState"] + arguments
        app.launch()
        return app
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    /// A pause for the camera. Only ever called after the control in question exists.
    private func pause(_ seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }

    private func waitUntilGone(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let gone = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: gone, object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}
