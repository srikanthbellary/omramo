import XCTest
@testable import OmramoCore

final class SpreadLayoutTests: XCTestCase {
    private let policy = SpreadLayoutPolicy.standard

    func testCompactWidthIsAlwaysSinglePane() {
        XCTAssertEqual(policy.arrangement(availableWidth: 900, isRegularWidth: false), .single)
        XCTAssertEqual(policy.arrangement(availableWidth: 390, isRegularWidth: false), .single)
    }

    func testRegularWidthNeedsRoomForTwoPages() {
        XCTAssertEqual(policy.arrangement(availableWidth: 400, isRegularWidth: true), .single)
        XCTAssertEqual(policy.arrangement(availableWidth: 820, isRegularWidth: true), .dual(spineWidth: policy.spineWidth))
    }

    func testPageWidthLeavesRoomForTheSpine() {
        let dual = policy.arrangement(availableWidth: 828, isRegularWidth: true)
        XCTAssertEqual(policy.pageWidth(availableWidth: 828, arrangement: dual), 400)
        XCTAssertEqual(policy.pageWidth(availableWidth: 390, arrangement: .single), 390)
        XCTAssertEqual(policy.pageWidth(availableWidth: 10, arrangement: .dual(spineWidth: 28)), 0)
    }

    func testFacingPagesKeepEvenIndexOnTheLeft() {
        let dual = PaneArrangement.dual(spineWidth: 28)
        XCTAssertEqual(SpreadPager.spread(containing: 0, pageCount: 10, arrangement: dual, mode: .facingPages), Spread(leftIndex: 0, rightIndex: 1))
        XCTAssertEqual(SpreadPager.spread(containing: 1, pageCount: 10, arrangement: dual, mode: .facingPages), Spread(leftIndex: 0, rightIndex: 1))
        XCTAssertEqual(SpreadPager.spread(containing: 5, pageCount: 10, arrangement: dual, mode: .facingPages), Spread(leftIndex: 4, rightIndex: 5))
    }

    func testOddPageCountEndsOnLeftPage() {
        let dual = PaneArrangement.dual(spineWidth: 28)
        XCTAssertEqual(SpreadPager.spread(containing: 8, pageCount: 9, arrangement: dual, mode: .facingPages), Spread(leftIndex: 8, rightIndex: nil))
    }

    func testSyncedAndIllustratedModesShowOnePageAcrossBothPanes() {
        let dual = PaneArrangement.dual(spineWidth: 28)
        XCTAssertEqual(SpreadPager.spread(containing: 3, pageCount: 10, arrangement: dual, mode: .synced(secondary: .english)), Spread(leftIndex: 3, rightIndex: nil))
        XCTAssertEqual(SpreadPager.spread(containing: 3, pageCount: 10, arrangement: dual, mode: .illustrated), Spread(leftIndex: 3, rightIndex: nil))
    }

    func testSinglePaneIgnoresMode() {
        XCTAssertEqual(SpreadPager.spread(containing: 7, pageCount: 10, arrangement: .single, mode: .facingPages), Spread(leftIndex: 7, rightIndex: nil))
    }

    func testOutOfRangeReturnsNil() {
        XCTAssertNil(SpreadPager.spread(containing: -1, pageCount: 10, arrangement: .single, mode: .facingPages))
        XCTAssertNil(SpreadPager.spread(containing: 10, pageCount: 10, arrangement: .single, mode: .facingPages))
        XCTAssertNil(SpreadPager.spread(containing: 0, pageCount: 0, arrangement: .single, mode: .facingPages))
    }

    func testTurningPagesStopsAtTheCovers() {
        let first = Spread(leftIndex: 0, rightIndex: 1)
        XCTAssertNil(SpreadPager.previousPageIndex(from: first))
        XCTAssertEqual(SpreadPager.nextPageIndex(from: first, pageCount: 10), 2)

        let last = Spread(leftIndex: 8, rightIndex: 9)
        XCTAssertNil(SpreadPager.nextPageIndex(from: last, pageCount: 10))
        XCTAssertEqual(SpreadPager.previousPageIndex(from: last), 7)

        let single = Spread(leftIndex: 4, rightIndex: nil)
        XCTAssertEqual(SpreadPager.nextPageIndex(from: single, pageCount: 10), 5)
    }

    func testAvailableModesFollowBundledEditions() {
        let bilingual = Book(
            id: BookID("b"),
            title: LocalizedText([.telugu: "అ"]),
            author: LocalizedText([.telugu: "అ"]),
            description: LocalizedText([.telugu: "అ"]),
            poster: Artwork(motif: .stars, colors: []),
            pageCount: 1,
            editions: [
                EditionManifest(language: .telugu, status: .ready, file: "te.json"),
                EditionManifest(language: .english, status: .ready, file: "en.json"),
                EditionManifest(language: .hindi, status: .planned)
            ],
            sample: SampleSpec(pageCount: 1)
        )
        XCTAssertEqual(SpreadMode.available(for: bilingual), [.facingPages, .synced(secondary: .english), .illustrated])
        XCTAssertEqual(SpreadMode.synced(secondary: .english).title, "తెలుగు | English")
    }
}
