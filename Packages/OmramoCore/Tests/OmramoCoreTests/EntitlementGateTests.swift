import XCTest
@testable import OmramoCore

final class EntitlementGateTests: XCTestCase {
    private func makeBook(samplePages: Int = 2) -> Book {
        Book(
            id: BookID("test"),
            title: LocalizedText([.telugu: "పరీక్ష"]),
            author: LocalizedText([.telugu: "రచయిత"]),
            description: LocalizedText([.telugu: "వివరణ"]),
            poster: Artwork(motif: .river, colors: [HexColor(red: 0, green: 0, blue: 0)]),
            pageCount: 10,
            editions: [EditionManifest(language: .telugu, status: .ready, file: "t.json")],
            sample: SampleSpec(pageCount: samplePages)
        )
    }

    func testUnknownWaitsInsteadOfFlashingPaywall() {
        XCTAssertEqual(EntitlementGate.decision(for: .unknown), .wait)
    }

    func testNotSubscribedHitsHardPaywall() {
        XCTAssertEqual(EntitlementGate.decision(for: .notSubscribed), .showPaywall)
    }

    func testAnyPlanUnlocksEverything() {
        XCTAssertEqual(EntitlementGate.decision(for: .subscribed(plan: .monthly, renewsOn: nil)), .allow)
        XCTAssertEqual(EntitlementGate.decision(for: .subscribed(plan: .yearly, renewsOn: Date())), .allow)
        XCTAssertEqual(EntitlementGate.decision(for: .subscribed(plan: nil, renewsOn: nil)), .allow)
    }

    func testSamplePagesAreFreeAndTheRestAreNot() {
        let book = makeBook(samplePages: 2)
        XCTAssertTrue(EntitlementGate.canRead(pageIndex: 0, in: book, state: .notSubscribed))
        XCTAssertTrue(EntitlementGate.canRead(pageIndex: 1, in: book, state: .notSubscribed))
        XCTAssertFalse(EntitlementGate.canRead(pageIndex: 2, in: book, state: .notSubscribed))
        XCTAssertFalse(EntitlementGate.canRead(pageIndex: 2, in: book, state: .unknown))
        XCTAssertTrue(EntitlementGate.canRead(pageIndex: 9, in: book, state: .subscribed(plan: .monthly, renewsOn: nil)))
    }

    func testProductIdentifiersRoundTrip() {
        for plan in SubscriptionPlan.allCases {
            XCTAssertEqual(SubscriptionPlan(productID: plan.productID), plan)
        }
        XCTAssertNil(SubscriptionPlan(productID: "com.omramo.book.single"))
        XCTAssertEqual(SubscriptionPlan.productIDs.count, 2)
    }
}
