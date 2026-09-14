import XCTest
@testable import OmramoCore

final class SpreadLayoutTests: XCTestCase {
    private let policy = SpreadLayoutPolicy.standard

    func testNarrowCompactIsARealSinglePaneReader() {
        XCTAssertEqual(policy.arrangement(availableWidth: 390, isRegularWidth: false), .single)
        XCTAssertEqual(policy.arrangement(availableWidth: 699, isRegularWidth: false), .single)
    }

    func testWideCompactCanvasIsNeverOneStretchedColumn() {
        XCTAssertEqual(policy.arrangement(availableWidth: 700, isRegularWidth: false), .dual(spineWidth: policy.spineWidth))
        XCTAssertEqual(policy.arrangement(availableWidth: 900, isRegularWidth: false), .dual(spineWidth: policy.spineWidth))
    }

    func testRegularWidthGetsTwoPanesInAnyOrientation() {
        // Inner display portrait and landscape are both regular width; no
        // rotation is ever required to see a spread.
        XCTAssertEqual(policy.arrangement(availableWidth: 520, isRegularWidth: true), .dual(spineWidth: policy.spineWidth))
        XCTAssertEqual(policy.arrangement(availableWidth: 820, isRegularWidth: true), .dual(spineWidth: policy.spineWidth))
        XCTAssertEqual(policy.arrangement(availableWidth: 1024, isRegularWidth: true), .dual(spineWidth: policy.spineWidth))
        XCTAssertEqual(policy.arrangement(availableWidth: 380, isRegularWidth: true), .single, "only degenerate frames fall back")
    }

    func testReadingPositionSurvivesArrangementChanges() {
        // Reader is on page 6 (index 5) with two panes: spread 4 | 5.
        let dual = PaneArrangement.dual(spineWidth: 28)
        let position = ReadingPosition(pageIndex: 5, mode: .facingPages)
        XCTAssertEqual(SpreadPager.spread(containing: position.pageIndex, pageCount: 10, arrangement: dual, mode: position.mode), Spread(leftIndex: 4, rightIndex: 5))
        // Fold closes: same index, one pane, still page 6.
        XCTAssertEqual(SpreadPager.spread(containing: position.pageIndex, pageCount: 10, arrangement: .single, mode: position.mode), Spread(leftIndex: 5, rightIndex: nil))
        // Fold opens again: back to the same spread, nothing lost.
        XCTAssertEqual(SpreadPager.spread(containing: position.pageIndex, pageCount: 10, arrangement: dual, mode: position.mode), Spread(leftIndex: 4, rightIndex: 5))
    }

    func testReadingPositionValidationClampsAndDropsUnavailableModes() {
        let teluguOnly = Book(
            id: BookID("t"),
            title: LocalizedText([.telugu: "అ"]),
            author: LocalizedText([.telugu: "అ"]),
            description: LocalizedText([.telugu: "అ"]),
            poster: Artwork(motif: .river, colors: []),
            pageCount: 4,
            editions: [EditionManifest(language: .telugu, status: .ready, file: "te.json")],
            sample: SampleSpec(pageCount: 2)
        )
        let restored = ReadingPosition(pageIndex: 9, mode: .synced(secondary: .english)).validated(for: teluguOnly)
        XCTAssertEqual(restored, ReadingPosition(pageIndex: 3, mode: .facingPages))
        XCTAssertEqual(ReadingPosition(pageIndex: -2, mode: .illustrated).validated(for: teluguOnly), ReadingPosition(pageIndex: 0, mode: .illustrated))
    }

    func testSpreadModeStorageKeyRoundTrips() {
        for mode in [SpreadMode.facingPages, .synced(secondary: .english), .synced(secondary: .hindi), .illustrated] {
            XCTAssertEqual(SpreadMode(storageKey: mode.storageKey), mode)
        }
        XCTAssertNil(SpreadMode(storageKey: "synced:xx"))
        XCTAssertNil(SpreadMode(storageKey: "garbage"))
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
