import XCTest
@testable import OmramoCore

final class AppearanceModeTests: XCTestCase {
    func testStoredValuesRoundTrip() {
        for mode in AppearanceMode.allCases {
            XCTAssertEqual(AppearanceMode(stored: mode.rawValue), mode)
        }
    }

    func testUnknownOrMissingFallsBackToSystem() {
        XCTAssertEqual(AppearanceMode(stored: nil), .system)
        XCTAssertEqual(AppearanceMode(stored: "sepia"), .system)
        XCTAssertEqual(AppearanceMode(stored: ""), .system)
    }

    func testOrderAndTitlesAreStable() {
        XCTAssertEqual(AppearanceMode.allCases, [.system, .light, .dark])
        XCTAssertEqual(AppearanceMode.allCases.map(\.title), ["System", "Light", "Dark"])
    }

    func testLegalLinksLiveOnTheBrandDomain() {
        XCTAssertEqual(Brand.privacyURL.host, Brand.domain)
        XCTAssertEqual(Brand.termsURL.host, Brand.domain)
        XCTAssertEqual(Brand.privacyURL.path, "/privacy")
        XCTAssertEqual(Brand.termsURL.path, "/terms")
    }
}
