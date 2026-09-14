import XCTest
@testable import OmramoCore

final class ModelTests: XCTestCase {
    func testLocalizedTextFallsBackToTelugu() throws {
        let text = LocalizedText([.telugu: "గోదావరి"])
        XCTAssertEqual(text.resolved(in: .english), "గోదావరి")
        XCTAssertNil(text[.english])
    }

    func testLocalizedTextRequiresPrimaryLanguage() {
        let json = Data(#"{"en": "Only English"}"#.utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(LocalizedText.self, from: json))
    }

    func testLocalizedTextRoundTripsAsObject() throws {
        let text = LocalizedText([.telugu: "నావ", .english: "Boat"])
        let data = try JSONEncoder().encode(text)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: String])
        XCTAssertEqual(object, ["te": "నావ", "en": "Boat"])
        XCTAssertEqual(try JSONDecoder().decode(LocalizedText.self, from: data), text)
    }

    func testHexColorParsing() {
        XCTAssertEqual(HexColor("#F4A259"), HexColor(red: 0xF4, green: 0xA2, blue: 0x59))
        XCTAssertEqual(HexColor("0b2e4f")?.description, "#0B2E4F")
        XCTAssertNil(HexColor("#FFF"))
        XCTAssertNil(HexColor("nope"))
    }

    func testArtworkRejectsBadColour() {
        let json = Data(##"{"motif": "river", "colors": ["#12"]}"##.utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(Artwork.self, from: json))
    }

    func testEditionValidatesNumbering() {
        let good = Edition(bookID: BookID("x"), language: .telugu, pages: [
            Page(number: 1, text: "అ"), Page(number: 2, text: "ఆ")
        ])
        XCTAssertNoThrow(try good.validateNumbering())

        let bad = Edition(bookID: BookID("x"), language: .telugu, pages: [
            Page(number: 1, text: "అ"), Page(number: 3, text: "ఆ")
        ])
        XCTAssertThrowsError(try bad.validateNumbering()) { error in
            XCTAssertEqual(error as? ContentError, .invalidPageNumbering(bookID: BookID("x"), language: .telugu, expected: 2, found: 3))
        }
    }

    func testLoadStateAccessors() {
        let loaded: LoadState<Int> = .loaded(3)
        XCTAssertEqual(loaded.value, 3)
        XCTAssertFalse(loaded.isLoading)
        XCTAssertNil(loaded.failure)

        let failed: LoadState<Int> = .failed(LoadFailure(message: "no"))
        XCTAssertNil(failed.value)
        XCTAssertEqual(failed.failure?.message, "no")
        XCTAssertTrue(LoadState<Int>.loading.isLoading)
    }
}
