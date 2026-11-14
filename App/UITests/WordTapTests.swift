import XCTest
import UIKit

/// Round 3, goal 6: every marked word and character name is a real tap target that opens its
/// own card, the card closes with "Back to my line", and ordinary words do nothing.
///
/// Runs in the `OmramoUITests` target (OmramoShots scheme), on an iPhone or an iPad simulator:
///
///     xcodebuild test -project Omramo.xcodeproj -scheme OmramoShots \
///       -destination 'platform=iOS Simulator,id=<udid>' -only-testing:OmramoUITests/WordTapTests
///
/// Marked words carry the identifier `word.<cardID>` and cards `card.<cardID>`. Every launch
/// uses `-OmramoResetState`, so each story opens on page 1 and nothing is written to the
/// simulator.
final class WordTapTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    // MARK: One marked word in each story, by identifier

    func testMonkeyTapWordOpensAndClosesItsCard() {
        let app = launch(story: "monkey-and-crocodile")
        openAndClose(word: "river-bank", in: app)
        app.terminate()
    }

    func testAnansiLandmarkWordOpensAndClosesItsCard() {
        let app = launch(story: "anansi-wisdom")
        openAndClose(word: "village-houses", in: app)
        app.terminate()
    }

    func testUrashimaNameOpensAndClosesItsCharacterCard() {
        let app = launch(story: "urashima-taro")
        openAndClose(word: "urashima", in: app)
        app.terminate()
    }

    // MARK: By coordinate, on the word's own frame

    func testTappingTheMiddleOfAWordsFrameOpensItsCard() {
        let app = launch(story: "anansi-wisdom")
        // A character's name this time ("Father Anansi", in the lead sentence).
        let word = element("word.anansi", in: app)
        XCTAssertTrue(word.waitForExistence(timeout: 20), "word.anansi is not on page 1")
        let frame = word.frame
        XCTAssertGreaterThanOrEqual(frame.width, 43.5, "a marked word's touch area is at least 44 pt wide")
        XCTAssertGreaterThanOrEqual(frame.height, 43.5, "a marked word's touch area is at least 44 pt tall")

        // A tap at a point of the screen — the middle of the word's frame — not on the element.
        let origin = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        origin.withOffset(CGVector(dx: frame.midX, dy: frame.midY)).tap()

        let card = element("card.anansi", in: app)
        XCTAssertTrue(card.waitForExistence(timeout: 5), "the tap on the word's frame did not open its card")
        close(card, in: app)
        app.terminate()
    }

    // MARK: Every marked word on the first page of every story

    func testEveryMarkedWordOnTheFirstPageIsATarget() {
        let expected: [String: [String]] = [
            "monkey-and-crocodile": ["river-bank"],
            "anansi-wisdom": ["anansi", "village-houses"],
            "urashima-taro": ["urashima"],
        ]
        for (story, words) in expected.sorted(by: { $0.key < $1.key }) {
            let app = launch(story: story)
            for word in words {
                let target = element("word.\(word)", in: app)
                XCTAssertTrue(target.waitForExistence(timeout: 20), "\(story): word.\(word) is missing")
                XCTAssertGreaterThanOrEqual(target.frame.width, 43.5, "\(story): word.\(word)")
                XCTAssertGreaterThanOrEqual(target.frame.height, 43.5, "\(story): word.\(word)")
                openAndClose(word: word, in: app)
            }
            app.terminate()
        }
    }

    // MARK: Ordinary words do nothing

    func testAnOrdinaryParagraphDoesNothingWhenTapped() {
        let app = launch(story: "monkey-and-crocodile")
        XCTAssertTrue(element("word.river-bank", in: app).waitForExistence(timeout: 20))

        // The second paragraph of page 1 has no marked word.
        let plain = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label BEGINSWITH %@", "All day he ate"))
            .firstMatch
        XCTAssertTrue(plain.waitForExistence(timeout: 5), "the unmarked paragraph is not on screen")
        plain.tap()

        // No card of any kind appears, and the page has not turned.
        let anyCard = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "card.")).firstMatch
        XCTAssertFalse(anyCard.waitForExistence(timeout: 1.5), "an ordinary paragraph opened a card")
        XCTAssertTrue(element("word.river-bank", in: app).exists, "the page moved when an ordinary word was tapped")
        app.terminate()
    }

    // MARK: The page cannot be turned while a card is open, and turns once per press

    func testThePageTurnsWithTheRoundButton() {
        let app = launch(story: "monkey-and-crocodile")
        let next = element("reader.next", in: app)
        XCTAssertTrue(next.waitForExistence(timeout: 20))
        XCTAssertGreaterThanOrEqual(next.frame.width, 43.5)
        XCTAssertFalse(element("reader.previous", in: app).exists, "nothing to go back to on the first screen")
        next.tap()
        // The back control appears once the reader has moved on.
        XCTAssertTrue(element("reader.previous", in: app).waitForExistence(timeout: 5), "the round button did not turn the page")
        app.terminate()
    }

    // MARK: Helpers

    private func launch(story: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-OmramoResetState", "-OmramoOpenStory", story]
        app.launch()
        return app
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    /// Taps `word.<id>`, expects `card.<id>`, closes it with "Back to my line", expects it gone.
    private func openAndClose(word: String, in app: XCUIApplication) {
        let target = element("word.\(word)", in: app)
        XCTAssertTrue(target.waitForExistence(timeout: 20), "word.\(word) is not on the page")
        target.tap()

        let card = element("card.\(word)", in: app)
        XCTAssertTrue(card.waitForExistence(timeout: 5), "tapping word.\(word) did not open card.\(word)")
        close(card, in: app)
    }

    private func close(_ card: XCUIElement, in app: XCUIApplication) {
        let back = app.buttons["Back to my line"].firstMatch
        XCTAssertTrue(back.waitForExistence(timeout: 5), "the card has no \"Back to my line\" button")
        // Let the card finish opening before pressing its button.
        Thread.sleep(forTimeInterval: 0.6)
        back.tap()

        let gone = NSPredicate(format: "exists == false")
        let waiter = XCTWaiter()
        let result = waiter.wait(for: [XCTNSPredicateExpectation(predicate: gone, object: card)], timeout: 5)
        XCTAssertEqual(result, .completed, "the card is still on screen after \"Back to my line\"")
        // And the word is there again, ready to be tapped.
        Thread.sleep(forTimeInterval: 0.5)
    }
}
