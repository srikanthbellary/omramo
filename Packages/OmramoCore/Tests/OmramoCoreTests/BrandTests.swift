import XCTest
@testable import OmramoCore

final class BrandTests: XCTestCase {
    func testCurrentBrandIsOmramoWithOmRaMoMark() {
        XCTAssertEqual(Brand.displayName, "Omramo")
        XCTAssertEqual(Brand.domain, "omramo.com")
        XCTAssertEqual(Brand.mark, FoldMark(left: "OM", spine: "RA", right: "MO"))
        XCTAssertEqual(Brand.mark.closed, "OMRAMO")
        XCTAssertEqual(Brand.websiteURL.absoluteString, "https://omramo.com")
    }

    func testMarkDerivationKeepsSpineNarrowest() {
        XCTAssertEqual(FoldMark.derived(from: "Omramo"), FoldMark(left: "OM", spine: "RA", right: "MO"))
        XCTAssertEqual(FoldMark.derived(from: "Kathalu"), FoldMark(left: "KAT", spine: "HA", right: "LU"))
        XCTAssertEqual(FoldMark.derived(from: "Book"), FoldMark(left: "BO", spine: "O", right: "K"))
        XCTAssertEqual(FoldMark.derived(from: "Two Words"), FoldMark(left: "TWO", spine: "WO", right: "RDS"))
        XCTAssertEqual(FoldMark.derived(from: "Om"), FoldMark(left: "O", spine: "M", right: "·"))
    }

    /// The bundle display name comes from `Configuration/Brand.xcconfig`. The
    /// two must agree or the home screen and the in app copy would disagree.
    func testXcconfigDisplayNameMatchesBrand() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // OmramoCoreTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // OmramoCore
        let xcconfig = packageRoot
            .deletingLastPathComponent() // Packages
            .deletingLastPathComponent() // repo root
            .appendingPathComponent("Configuration/Brand.xcconfig")
        guard let contents = try? String(contentsOf: xcconfig, encoding: .utf8) else {
            throw XCTSkip("Brand.xcconfig not found next to the package; running outside the repo.")
        }
        let line = contents
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { $0.hasPrefix("BRAND_DISPLAY_NAME") }
        let value = try XCTUnwrap(line?.split(separator: "=", maxSplits: 1).last?.trimmingCharacters(in: .whitespaces))
        XCTAssertEqual(value, Brand.displayName)
    }
}
