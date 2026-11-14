import Foundation
import XCTest
@testable import OmramoCore

final class LandmarkTests: XCTestCase {

    // MARK: Catalog decoding

    func testLandmarkCatalogDecodes() throws {
        let catalog = try SampleContent.landmarks()
        XCTAssertEqual(catalog.schemaVersion, 1)
        let taj = try XCTUnwrap(catalog.landmark(id: LandmarkID("taj-mahal")))
        XCTAssertEqual(taj.name, "Taj Mahal")
        XCTAssertEqual(taj.era, .earlyModern)
        XCTAssertEqual(taj.built?.from, 1632)
        XCTAssertEqual(taj.built?.to, 1653)
        XCTAssertEqual(taj.built?.circa, true)
        XCTAssertEqual(taj.status, .standing)
        XCTAssertEqual(taj.depiction, .asIs)
        XCTAssertEqual(taj.country, "India")
        XCTAssertEqual(taj.coordinates, GeoPoint(lat: 27.175, lon: 78.042))
        XCTAssertEqual(taj.region, .indian)
        XCTAssertEqual(taj.lists, [.new7Wonders])
        XCTAssertEqual(taj.art.assetName, "taj-mahal")
        XCTAssertFalse(taj.art.alt.isEmpty)

        let lighthouse = try XCTUnwrap(catalog.landmark(id: LandmarkID("lighthouse-of-alexandria")))
        XCTAssertEqual(lighthouse.built?.from, -280)
        XCTAssertNil(lighthouse.built?.to)
        XCTAssertEqual(lighthouse.status, .lost)
        XCTAssertEqual(lighthouse.depiction, .reconstruction)
        XCTAssertEqual(lighthouse.lists, [.ancientSeven])
    }

    func testLandmarkCatalogValidates() throws {
        let report = StoryValidator().validate(landmarks: try SampleContent.landmarks())
        XCTAssertTrue(report.isValid, "\(report.errors.map(\.description))")
    }

    func testLandmarkMissingATierFactCardIsRefused() throws {
        let data = try SampleContent.json(try SampleContent.landmarksJSON(), replacing: "\"advanced\": {", with: "\"advancedX\": {")
        XCTAssertThrowsError(try ContentDecoder.decodeLandmarks(data)) { error in
            guard case ContentError.malformed(_, let detail) = error else {
                return XCTFail("wrong error: \(error)")
            }
            XCTAssertTrue(detail.contains("factCards.advanced"), detail)
        }
    }

    func testUnknownEraIsRefused() throws {
        let data = try SampleContent.json(try SampleContent.landmarksJSON(), replacing: "\"era\": \"earlyModern\"", with: "\"era\": \"jurassic\"")
        XCTAssertThrowsError(try ContentDecoder.decodeLandmarks(data)) { error in
            guard case ContentError.malformed = error else {
                return XCTFail("wrong error: \(error)")
            }
        }
    }

    // MARK: Every landmark a story points to resolves

    func testEveryLandmarkReferencedByABundledStoryResolves() throws {
        let repository = try SampleContent.repository()
        let landmarks = try repository.loadLandmarks()
        let catalog = try repository.loadCatalog()
        var referenced = 0
        for id in catalog.stories {
            let story = try repository.loadStory(id: id)
            for landmarkID in story.landmarkIDs {
                referenced += 1
                XCTAssertNotNil(
                    landmarks.landmark(id: landmarkID),
                    "story \(id) points to landmark \(landmarkID), which is not in landmarks.json"
                )
            }
        }
        XCTAssertGreaterThan(referenced, 0, "the sample story should reference at least one landmark")
    }

    func testSampleReferencesTheTajMahalFramedThenAndNow() throws {
        let story = try SampleContent.story()
        XCTAssertEqual(story.landmarkIDs, [LandmarkID("taj-mahal")])
        let target = story.tapTargets[try SampleContent.landmarkTargetIndex(in: story)]
        let ref = try XCTUnwrap(target.landmark)
        XCTAssertEqual(ref.appearance, .framed)
        XCTAssertEqual(ref.framingDevice?.kind, .thenAndNow)
        XCTAssertNil(target.title)
        XCTAssertNil(target.line)
        XCTAssertNil(target.picture)

        // It is attached to a word of the story text.
        let tapped = story.spreads.flatMap { $0.blocks.flatMap(\.runs) }.filter { $0.tapTarget == target.id }
        XCTAssertEqual(tapped.map(\.text), ["river"])
    }

    // MARK: Story → landmark rules

    func testDanglingLandmarkID() throws {
        var story = try SampleContent.story()
        let index = try SampleContent.landmarkTargetIndex(in: story)
        story.tapTargets[index].landmark?.id = LandmarkID("atlantis")
        assertError(try SampleContent.report(for: story), .danglingLandmark)
    }

    func testLaterBuiltLandmarkMarkedNaturalIsAnAnachronism() throws {
        var story = try SampleContent.story()
        let index = try SampleContent.landmarkTargetIndex(in: story)
        story.tapTargets[index].landmark?.appearance = .natural
        story.tapTargets[index].landmark?.framingDevice = nil
        assertError(try SampleContent.report(for: story), .landmarkAnachronism)
    }

    func testLandmarkFromTheStorysOwnTimeMayBeNatural() throws {
        var story = try SampleContent.story()
        let index = try SampleContent.landmarkTargetIndex(in: story)
        story.setting.latestYear = 1700      // pretend the story is set after the Taj Mahal was built
        story.tapTargets[index].landmark?.appearance = .natural
        story.tapTargets[index].landmark?.framingDevice = nil
        let report = try SampleContent.report(for: story)
        XCTAssertFalse(report.contains(.landmarkAnachronism))
        XCTAssertFalse(report.contains(.landmarkOutOfRegion))
    }

    func testFramedWithoutDevice() throws {
        var story = try SampleContent.story()
        let index = try SampleContent.landmarkTargetIndex(in: story)
        story.tapTargets[index].landmark?.framingDevice = nil
        assertError(try SampleContent.report(for: story), .framedWithoutDevice)
    }

    func testOutOfRegionLandmarkNeedsWorldLinkOrMapMoment() throws {
        var story = try SampleContent.story()
        let index = try SampleContent.landmarkTargetIndex(in: story)
        // An Egyptian landmark in an Indian story: "then and now" is not enough.
        story.tapTargets[index].landmark?.id = LandmarkID("lighthouse-of-alexandria")
        assertError(try SampleContent.report(for: story), .landmarkOutOfRegion)

        story.tapTargets[index].landmark?.framingDevice?.kind = .worldLink
        XCTAssertFalse(try SampleContent.report(for: story).contains(.landmarkOutOfRegion))

        story.tapTargets[index].landmark?.framingDevice?.kind = .mapMoment
        XCTAssertFalse(try SampleContent.report(for: story).contains(.landmarkOutOfRegion))
    }

    func testLandmarkOutsideTheTenRegionsCountsAsOutOfRegion() throws {
        var story = try SampleContent.story()
        var landmarks = try SampleContent.landmarks()
        landmarks.landmarks[0].region = nil
        assertError(try SampleContent.report(for: story, landmarks: landmarks), .landmarkOutOfRegion)

        let index = try SampleContent.landmarkTargetIndex(in: story)
        story.tapTargets[index].landmark?.framingDevice?.kind = .worldLink
        XCTAssertFalse(try SampleContent.report(for: story, landmarks: landmarks).contains(.landmarkOutOfRegion))
    }

    func testLandmarkTargetMustNotCarryItsOwnCardCopy() throws {
        var story = try SampleContent.story()
        let index = try SampleContent.landmarkTargetIndex(in: story)
        story.tapTargets[index].title = "Taj Mahal"
        assertError(try SampleContent.report(for: story), .landmarkTargetShape)
    }

    func testLandmarkKindNeedsAReference() throws {
        var story = try SampleContent.story()
        let index = try SampleContent.landmarkTargetIndex(in: story)
        story.tapTargets[index].landmark = nil
        assertError(try SampleContent.report(for: story), .landmarkTargetShape)
    }

    func testOrdinaryTargetNeedsTitleLineAndPicture() throws {
        var story = try SampleContent.story()
        let index = try XCTUnwrap(story.tapTargets.firstIndex { $0.kind == .place })
        story.tapTargets[index].line = nil
        assertError(try SampleContent.report(for: story), .tapTargetIncomplete)
    }

    func testMoreThanTwoLandmarksIsAWarning() throws {
        var story = try SampleContent.story()
        let index = try SampleContent.landmarkTargetIndex(in: story)
        for copy in 1...2 {
            var extra = story.tapTargets[index]
            extra.id = TapTargetID("extra-\(copy)")
            story.tapTargets.append(extra)
        }
        XCTAssertTrue(try SampleContent.report(for: story).contains(.tooManyLandmarks, severity: .warning))
    }

    // MARK: Landmark catalog rules

    func testLostLandmarkMustBeAReconstruction() throws {
        var landmarks = try SampleContent.landmarks()
        let index = try XCTUnwrap(landmarks.landmarks.firstIndex { $0.status == .lost })
        landmarks.landmarks[index].depiction = .asIs
        assertError(StoryValidator().validate(landmarks: landmarks), .landmarkNotReconstruction)

        landmarks.landmarks[index].status = .unproven
        assertError(StoryValidator().validate(landmarks: landmarks), .landmarkNotReconstruction)
    }

    func testLandmarkCatalogRules() throws {
        var landmarks = try SampleContent.landmarks()
        landmarks.landmarks[0].factCards.low.line = " "
        assertError(StoryValidator().validate(landmarks: landmarks), .landmarkFactCard)

        landmarks = try SampleContent.landmarks()
        landmarks.landmarks[0].coordinates = GeoPoint(lat: 27, lon: 200)
        assertError(StoryValidator().validate(landmarks: landmarks), .landmarkCoordinates)

        landmarks = try SampleContent.landmarks()
        landmarks.landmarks[0].lists = []
        assertError(StoryValidator().validate(landmarks: landmarks), .landmarkNoList)

        landmarks = try SampleContent.landmarks()
        landmarks.landmarks[0].built = nil
        assertError(StoryValidator().validate(landmarks: landmarks), .landmarkBuilt)

        landmarks = try SampleContent.landmarks()
        landmarks.landmarks[0].built?.to = 1600
        assertError(StoryValidator().validate(landmarks: landmarks), .landmarkBuilt)

        landmarks = try SampleContent.landmarks()
        landmarks.landmarks.append(landmarks.landmarks[0])
        assertError(StoryValidator().validate(landmarks: landmarks), .duplicateID)

        landmarks = try SampleContent.landmarks()
        landmarks.landmarks[0].art.alt = ""
        assertError(StoryValidator().validate(landmarks: landmarks), .missingAlt)
    }

    func testNaturalLandmarkNeedsNoBuiltYear() throws {
        var landmarks = try SampleContent.landmarks()
        landmarks.landmarks[0].era = .natural
        landmarks.landmarks[0].status = .natural
        landmarks.landmarks[0].built = nil
        XCTAssertFalse(StoryValidator().validate(landmarks: landmarks).contains(.landmarkBuilt))
    }

    // MARK: Per-tier fact cards

    func testFactCardSubscriptPicksTheTierWording() throws {
        let taj = try XCTUnwrap(try SampleContent.landmarks().landmark(id: LandmarkID("taj-mahal")))
        XCTAssertEqual(taj.factCards[.low], taj.factCards.low)
        XCTAssertEqual(taj.factCards[.medium], taj.factCards.medium)
        XCTAssertEqual(taj.factCards[.advanced], taj.factCards.advanced)
        XCTAssertNotEqual(taj.factCards.low.line, taj.factCards.medium.line)
        XCTAssertNotEqual(taj.factCards.medium.line, taj.factCards.advanced.line)
    }

    func testCardForALowStoryUsesTheLowWordingAndTheFramingDevice() throws {
        let story = try SampleContent.story()
        XCTAssertEqual(story.tier, .low)
        let library = try SampleContent.repository().loadLibrary()
        let target = story.tapTargets[try SampleContent.landmarkTargetIndex(in: story)]
        let landmark = try XCTUnwrap(library.landmark(for: target))
        let card = try XCTUnwrap(LandmarkCardContent(target: target, landmark: landmark, tier: story.tier))

        XCTAssertEqual(card.title, "Taj Mahal")
        XCTAssertEqual(card.line, landmark.factCards.low.line)
        XCTAssertEqual(card.noteLabel, "LONG AFTER THIS STORY")
        XCTAssertEqual(card.noteText, target.landmark?.framingDevice?.line)
        XCTAssertEqual(card.subtitle, "Agra, on the River Yamuna")
        XCTAssertEqual(card.background, target.background)

        let medium = try XCTUnwrap(LandmarkCardContent(target: target, landmark: landmark, tier: .medium))
        XCTAssertEqual(medium.line, landmark.factCards.medium.line)
        XCTAssertTrue((medium.noteText ?? "").hasSuffix("It took about 20 years to build."))
    }

    func testCardForALostWonderSaysItIsAReconstruction() throws {
        let story = try SampleContent.story()
        var target = story.tapTargets[try SampleContent.landmarkTargetIndex(in: story)]
        target.landmark?.id = LandmarkID("lighthouse-of-alexandria")
        let lighthouse = try XCTUnwrap(try SampleContent.landmarks().landmark(id: LandmarkID("lighthouse-of-alexandria")))
        let card = try XCTUnwrap(LandmarkCardContent(target: target, landmark: lighthouse, tier: .low))
        XCTAssertEqual(card.subtitle, LandmarkCardContent.reconstructionSubtitle)
    }

    func testCardIsNilForAnOrdinaryTarget() throws {
        let story = try SampleContent.story()
        let place = try XCTUnwrap(story.tapTargets.first { $0.kind == .place })
        let taj = try XCTUnwrap(try SampleContent.landmarks().landmark(id: LandmarkID("taj-mahal")))
        XCTAssertNil(LandmarkCardContent(target: place, landmark: taj, tier: .low))
    }
}
