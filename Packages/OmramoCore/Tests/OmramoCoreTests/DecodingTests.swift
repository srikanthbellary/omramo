import Foundation
import XCTest
@testable import OmramoCore

final class DecodingTests: XCTestCase {

    // MARK: The bundled sample

    func testBundledContentFolderExists() throws {
        let root = try XCTUnwrap(BundledContent.rootURL, "Content is missing from the OmramoCore resource bundle")
        XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent("catalog.json").path))
    }

    func testCatalogDecodes() throws {
        let catalog = try SampleContent.repository().loadCatalog()
        XCTAssertEqual(catalog.schemaVersion, 1)
        // M2 added the Medium and Advanced prototype stories after the Low sample.
        // Round 5: the catalog grew (13 stories after batch 1); the three prototypes keep their order.
        XCTAssertEqual(catalog.stories.first, SampleContent.storyID)
        let prototypes = [SampleContent.storyID, StoryID("anansi-wisdom"), StoryID("urashima-taro")]
        XCTAssertEqual(catalog.stories.filter { prototypes.contains($0) }, prototypes)
    }

    func testSampleStoryDecodes() throws {
        let story = try SampleContent.story()
        XCTAssertEqual(story.id, SampleContent.storyID)
        XCTAssertEqual(story.schemaVersion, 1)
        XCTAssertEqual(story.title, "The Monkey and the Crocodile")
        XCTAssertEqual(story.tier, .low)
        XCTAssertEqual(story.language, "en")
        XCTAssertEqual(story.parts.map(\.title), ["Part I", "Part II"])
        XCTAssertEqual(story.spreads.count, 14)
        XCTAssertEqual(story.sample.freeSpreads, 2)
        XCTAssertEqual(story.theme.accent, .coral)
        XCTAssertEqual(story.theme.chrome.leading, .light)
        XCTAssertEqual(story.theme.chrome.trailing, .dark)
        XCTAssertEqual(Set(story.characters.map(\.id)), [CharacterID("monkey"), CharacterID("crocodile"), CharacterID("mother-crocodile")])
        XCTAssertNotNil(story.character(id: CharacterID("monkey"))?.card)
    }

    func testSampleStoryCarriesRegionAndProvenance() throws {
        let story = try SampleContent.story()
        XCTAssertEqual(story.region.id, .indian)
        XCTAssertEqual(story.region.culture, "Buddhist Jataka tradition")
        XCTAssertEqual(story.region.label, "Ancient India")
        XCTAssertEqual(story.region.pin, GeoPoint(lat: 23, lon: 79))
        XCTAssertEqual(story.setting.latestYear, -200)

        XCTAssertEqual(story.provenance.kind, .publicDomainRetelling)
        XCTAssertEqual(story.provenance.textBasis, .omramoRetelling)
        let source = try XCTUnwrap(story.provenance.sources?.first)
        XCTAssertEqual(source.author, "Ellen C. Babbitt")
        XCTAssertEqual(source.year, 1912)
        XCTAssertEqual(source.gutenbergId, 62514)
        XCTAssertTrue(source.verified)

        XCTAssertEqual(story.culturalReview.level, .required)
        XCTAssertEqual(story.culturalReview.status, .pending)
        XCTAssertFalse((story.culturalReview.reason ?? "").isEmpty)
    }

    func testSampleStoryCarriesEducationMetadata() throws {
        let education = try SampleContent.story().education
        XCTAssertFalse(education.geography.lesson.isEmpty)
        XCTAssertFalse(education.culture.lesson.isEmpty)
        XCTAssertFalse(education.moral.lesson.isEmpty)
        XCTAssertFalse((education.moral.reflectionQuestion ?? "").isEmpty)
        XCTAssertEqual(education.geography.factCards, [TapTargetID("river-bank"), TapTargetID("taj-mahal-moment")])
    }

    func testTextRunsDecodeShortKeys() throws {
        let story = try SampleContent.story()
        let first = story.spreads[0].blocks[0]
        XCTAssertEqual(first.plainText, "High in a tree on a river bank lived a clever Monkey.")
        XCTAssertTrue(first.runs.allSatisfy(\.isLead))
        XCTAssertEqual(first.runs[1].tapTarget, TapTargetID("river-bank"))

        let speech = try XCTUnwrap(story.spreads[0].blocks[3].runs.first)
        XCTAssertEqual(speech.speaker, CharacterID("mother-crocodile"))
        XCTAssertTrue(speech.showsFaceChip)
        XCTAssertFalse(speech.isLead)

        let allRuns = story.spreads.flatMap { $0.blocks.flatMap(\.runs) }
        XCTAssertTrue(allRuns.contains { $0.effect == .pop && $0.scale == 1.42 })
        XCTAssertTrue(allRuns.contains { $0.effect == .stretch })
        XCTAssertTrue(allRuns.contains { $0.characterName == CharacterID("monkey") })
    }

    func testTextRunRoundTripsThroughJSON() throws {
        let run = TextRun(text: "ripe fruit", speaker: CharacterID("crocodile"), tapTarget: TapTargetID("ripe-fruit"))
        let data = try JSONEncoder().encode(run)
        let text = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertTrue(text.contains("\"t\""))
        XCTAssertFalse(text.contains("lead"), "false flags are left out of the JSON")
        XCTAssertEqual(try JSONDecoder().decode(TextRun.self, from: data), run)
    }

    func testStoryRoundTripsThroughJSON() throws {
        let story = try SampleContent.story()
        let data = try JSONEncoder().encode(story)
        XCTAssertEqual(try ContentDecoder.decodeStory(data), story)
    }

    func testArtRefAssetName() {
        let art = ArtRef(file: "art/scene-river.unfolded.heic", alt: "x", width: 1, height: 1)
        XCTAssertEqual(art.assetName, "scene-river")
        XCTAssertEqual(ArtRef(file: "cover.heic", alt: "x", width: 1, height: 1).assetName, "cover")
    }

    func testLibraryLoadsAndListsTheSample() throws {
        let library = try SampleContent.repository().loadLibrary()
        // M2: three prototype stories, one per tier; the Low sample is still first.
        // Round 5: the catalog grows toward the plan's 32 stories (13 after batch 1).
        XCTAssertEqual(library.stories.count, try SampleContent.repository().loadCatalog().stories.count)
        XCTAssertGreaterThanOrEqual(library.stories.count, 13)
        let entry = try XCTUnwrap(library.entries.first)
        XCTAssertEqual(entry.title, "The Monkey and the Crocodile")
        XCTAssertEqual(entry.tier, .low)
        XCTAssertEqual(entry.originLabel, "Ancient India")
        XCTAssertEqual(entry.spreadCount, 14)

        XCTAssertEqual(library.entries(matching: .all).count, library.stories.count)
        // Round 5, batch 1: all eleven Low stories of the plan.
        XCTAssertEqual(library.entries(matching: .low).count, 11)
        XCTAssertTrue(library.entries(matching: .medium).map(\.id).contains(StoryID("anansi-wisdom")))
        XCTAssertTrue(library.entries(matching: .advanced).map(\.id).contains(StoryID("urashima-taro")))
    }

    // MARK: Schema version

    func testNewerSchemaVersionIsRefused() throws {
        let data = try SampleContent.json(try SampleContent.storyJSON(), replacing: "\"schemaVersion\": 1", with: "\"schemaVersion\": 2")
        XCTAssertThrowsError(try ContentDecoder.decodeStory(data, file: "story.json")) { error in
            guard case ContentError.unsupportedSchemaVersion(let file, let found, let supported) = error else {
                return XCTFail("wrong error: \(error)")
            }
            XCTAssertEqual(file, "story.json")
            XCTAssertEqual(found, 2)
            XCTAssertEqual(supported, ContentDecoder.supportedSchemaVersion)
            XCTAssertTrue((error.localizedDescription).contains("Update the app"))
        }
    }

    func testNewerSchemaIsRefusedEvenWhenTheRestIsUnreadable() {
        // A future file may have a shape this build cannot decode; the version is checked first.
        let data = Data("{\"schemaVersion\": 7, \"somethingNew\": true}".utf8)
        XCTAssertThrowsError(try ContentDecoder.decodeStory(data)) { error in
            guard case ContentError.unsupportedSchemaVersion(_, 7, _) = error else {
                return XCTFail("wrong error: \(error)")
            }
        }
    }

    func testZeroSchemaVersionIsRefused() {
        let data = Data("{\"schemaVersion\": 0}".utf8)
        XCTAssertThrowsError(try ContentDecoder.decodeCatalog(data)) { error in
            guard case ContentError.unsupportedSchemaVersion(_, 0, _) = error else {
                return XCTFail("wrong error: \(error)")
            }
        }
    }

    func testMissingSchemaVersionIsMalformed() {
        let data = Data("{\"catalogVersion\": 1, \"stories\": []}".utf8)
        XCTAssertThrowsError(try ContentDecoder.decodeCatalog(data)) { error in
            guard case ContentError.malformed(_, let detail) = error else {
                return XCTFail("wrong error: \(error)")
            }
            XCTAssertTrue(detail.contains("schemaVersion"), detail)
        }
    }

    func testCurrentSchemaVersionIsAccepted() throws {
        let data = Data("{\"schemaVersion\": 1, \"catalogVersion\": 3, \"stories\": [\"a\", \"b\"]}".utf8)
        let catalog = try ContentDecoder.decodeCatalog(data)
        XCTAssertEqual(catalog.catalogVersion, 3)
        XCTAssertEqual(catalog.stories, [StoryID("a"), StoryID("b")])
    }

    // MARK: Decoding errors

    private func assertMalformed(_ data: Data, mentions fragment: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertThrowsError(try ContentDecoder.decodeStory(data), file: file, line: line) { error in
            guard case ContentError.malformed(_, let detail) = error else {
                return XCTFail("wrong error: \(error)", file: file, line: line)
            }
            XCTAssertTrue(detail.contains(fragment), "\"\(detail)\" does not mention \(fragment)", file: file, line: line)
        }
    }

    func testUnknownTierIsRefused() throws {
        let data = try SampleContent.json(try SampleContent.storyJSON(), replacing: "\"tier\": \"low\"", with: "\"tier\": \"huge\"")
        assertMalformed(data, mentions: "tier")
    }

    func testUnknownRegionIDIsRefused() throws {
        let data = try SampleContent.json(try SampleContent.storyJSON(), replacing: "\"id\": \"indian\"", with: "\"id\": \"atlantean\"")
        assertMalformed(data, mentions: "region.id")
    }

    func testMissingEducationPillarIsRefused() throws {
        let data = try SampleContent.json(try SampleContent.storyJSON(), replacing: "\"moral\": {", with: "\"moralX\": {")
        assertMalformed(data, mentions: "education.moral")
    }

    func testMissingProvenanceIsRefused() throws {
        let data = try SampleContent.json(try SampleContent.storyJSON(), replacing: "\"provenance\": {", with: "\"provenanceX\": {")
        assertMalformed(data, mentions: "provenance")
    }

    func testMissingAltKeyIsRefused() throws {
        let data = try SampleContent.json(
            try SampleContent.storyJSON(),
            replacing: "\"alt\": \"A monkey riding on a crocodile's back across a river.\"",
            with: "\"altX\": \"\""
        )
        assertMalformed(data, mentions: "cover.alt")
    }

    func testBrokenJSONIsMalformed() {
        assertMalformed(Data("{ this is not json".utf8), mentions: "JSON")
    }

    func testMissingFileIsReported() throws {
        let repo = DirectoryContentRepository(root: URL(fileURLWithPath: "/nonexistent/omramo-content"))
        XCTAssertThrowsError(try repo.loadCatalog()) { error in
            guard case ContentError.fileNotFound = error else {
                return XCTFail("wrong error: \(error)")
            }
        }
        XCTAssertNil(try repo.loadManuscript(id: SampleContent.storyID))
    }

    func testCodingPathDescription() {
        struct Key: CodingKey {
            var stringValue: String
            var intValue: Int?
            init(_ string: String) { stringValue = string; intValue = nil }
            init(_ int: Int) { stringValue = String(int); intValue = int }
            init?(stringValue: String) { self.init(stringValue) }
            init?(intValue: Int) { self.init(intValue) }
        }
        let path: [CodingKey] = [Key("spreads"), Key(0), Key("blocks"), Key(1), Key("runs")]
        XCTAssertEqual(ContentDecoder.pathString(path), "spreads[0].blocks[1].runs")
    }
}
