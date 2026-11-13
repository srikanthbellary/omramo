import Foundation
import XCTest
@testable import OmramoCore

final class ValidationTests: XCTestCase {

    // MARK: The bundled sample is valid

    func testBundledStoryValidates() throws {
        let report = try SampleContent.report(for: try SampleContent.story())
        XCTAssertTrue(report.isValid, "\(report.errors.map(\.description))")
    }

    func testBundledStoryIsNotReleasableWhileReviewsArePending() throws {
        let report = try SampleContent.report(for: try SampleContent.story(), mode: .release)
        XCTAssertFalse(report.isValid)
        assertError(report, .culturalReviewNotApproved)
        assertError(report, .reviewPending)
    }

    func testPendingReviewsAreWarningsInDevelopment() throws {
        let report = try SampleContent.report(for: try SampleContent.story())
        XCTAssertTrue(report.contains(.reviewPending, severity: .warning))
        XCTAssertTrue(report.contains(.culturalReviewNotApproved, severity: .warning))
    }

    func testApprovedStoryIsReleasable() throws {
        var story = try SampleContent.story()
        story.review.text.status = .approved
        story.review.art.status = .approved
        story.culturalReview.status = .approved
        let report = try SampleContent.report(for: story, mode: .release)
        XCTAssertTrue(report.isValid, "\(report.errors.map(\.description))")
    }

    // MARK: Identity and references

    func testDuplicateSpreadID() throws {
        var story = try SampleContent.story()
        story.spreads[1].id = story.spreads[0].id
        assertError(try SampleContent.report(for: story), .duplicateID)
    }

    func testDuplicateBlockIDAcrossSpreads() throws {
        var story = try SampleContent.story()
        story.spreads[1].blocks[0].id = story.spreads[0].blocks[0].id
        assertError(try SampleContent.report(for: story), .duplicateID)
    }

    func testDuplicateCharacterAndTapTargetIDs() throws {
        var story = try SampleContent.story()
        story.characters.append(story.characters[0])
        assertError(try SampleContent.report(for: story), .duplicateID)

        var second = try SampleContent.story()
        second.tapTargets.append(second.tapTargets[0])
        assertError(try SampleContent.report(for: second), .duplicateID)
    }

    func testDanglingPart() throws {
        var story = try SampleContent.story()
        story.spreads[0].part = PartID("part-9")
        assertError(try SampleContent.report(for: story), .danglingPart)
    }

    func testDanglingTap() throws {
        var story = try SampleContent.story()
        story.spreads[0].blocks[0].runs[1].tapTarget = TapTargetID("nowhere")
        assertError(try SampleContent.report(for: story), .danglingTap)
    }

    func testDanglingName() throws {
        var story = try SampleContent.story()
        story.spreads[0].blocks[1].runs[0].characterName = CharacterID("nobody")
        assertError(try SampleContent.report(for: story), .danglingName)
    }

    func testDanglingSay() throws {
        var story = try SampleContent.story()
        story.spreads[0].blocks[1].runs[0].speaker = CharacterID("nobody")
        assertError(try SampleContent.report(for: story), .danglingSay)
    }

    func testRunWithBothTapAndName() throws {
        var story = try SampleContent.story()
        XCTAssertNotNil(story.spreads[0].blocks[0].runs[1].tapTarget)
        story.spreads[0].blocks[0].runs[1].characterName = CharacterID("monkey")
        assertError(try SampleContent.report(for: story), .tapAndName)
    }

    func testUnusedTapTargetIsAWarning() throws {
        var story = try SampleContent.story()
        story.spreads[0].blocks[0].runs[1].tapTarget = nil
        let report = try SampleContent.report(for: story)
        XCTAssertTrue(report.contains(.unusedTapTarget, severity: .warning))
    }

    // MARK: Art, colours, sample

    func testMissingAltText() throws {
        var story = try SampleContent.story()
        story.spreads[0].scene.unfolded.alt = "   "
        assertError(try SampleContent.report(for: story), .missingAlt)

        var second = try SampleContent.story()
        second.characters[0].face.alt = ""
        assertError(try SampleContent.report(for: second), .missingAlt)
    }

    func testBadColour() throws {
        var story = try SampleContent.story()
        story.theme.textColor = "navy"
        assertError(try SampleContent.report(for: story), .badColor)
    }

    func testFreeSpreadsOutOfRange() throws {
        var story = try SampleContent.story()
        story.sample.freeSpreads = story.spreads.count + 1
        assertError(try SampleContent.report(for: story), .freeSpreadsRange)
    }

    func testMissingArtFilesArePlaceholderWarningsThenReleaseErrors() throws {
        let story = try SampleContent.story()
        let landmarks = try SampleContent.landmarks()
        let manuscript = try SampleContent.manuscript()

        let development = StoryValidator(mode: .development)
            .validate(story: story, landmarks: landmarks, manuscript: manuscript, artFileExists: { _ in false })
        XCTAssertTrue(development.isValid)
        XCTAssertTrue(development.contains(.artFileMissing, severity: .warning))

        let release = StoryValidator(mode: .release)
            .validate(story: story, landmarks: landmarks, manuscript: manuscript, artFileExists: { _ in false })
        assertError(release, .artFileMissing)

        let present = StoryValidator(mode: .development)
            .validate(story: story, landmarks: landmarks, manuscript: manuscript, artFileExists: { _ in true })
        XCTAssertFalse(present.contains(.artFileMissing))
    }

    func testVeryLongSpreadIsAWarning() throws {
        var story = try SampleContent.story()
        let filler = String(repeating: "word ", count: 120)
        story.spreads[0].blocks[0].runs[0].text += " " + filler
        let report = try SampleContent.report(for: story)
        XCTAssertTrue(report.contains(.wordsPerSpread, severity: .warning))
    }

    // MARK: Text fidelity

    func testFidelityPassesForTheBundledStory() throws {
        XCTAssertNil(TextFidelity.compare(story: try SampleContent.story(), manuscript: try SampleContent.manuscript()))
    }

    func testChangedWordFailsFidelity() throws {
        var story = try SampleContent.story()
        let original = story.spreads[0].blocks[1].runs[0].text
        XCTAssertTrue(original.contains("sweet"))
        story.spreads[0].blocks[1].runs[0].text = original.replacingOccurrences(of: "sweet", with: "sour")
        assertError(try SampleContent.report(for: story), .textFidelity)

        let mismatch = try XCTUnwrap(TextFidelity.compare(story: story, manuscript: try SampleContent.manuscript()))
        XCTAssertTrue(mismatch.expected.contains("sweet"))
        XCTAssertTrue(mismatch.found.contains("sour"))
    }

    func testDroppedParagraphFailsFidelity() throws {
        var story = try SampleContent.story()
        story.spreads[13].blocks.removeLast()
        assertError(try SampleContent.report(for: story), .textFidelity)
    }

    func testNormalisationIgnoresQuotesDashesAndSpacing() {
        XCTAssertEqual(
            TextFidelity.normalize("\u{201C}No\u{2014}but   I do,\u{201D}\n said the  Crocodile\u{2019}s son\u{2026}"),
            TextFidelity.normalize("\"No--but I do,\" said the Crocodile's son...")
        )
        XCTAssertEqual(TextFidelity.normalize("  a \u{00A0} b\t"), "a b")
        XCTAssertNotEqual(TextFidelity.normalize("sweet"), TextFidelity.normalize("sour"))
    }

    func testManuscriptNotesAreNotStoryText() {
        let manuscript = "# A note\n# Part I\nOne line.\n\n  # an indented note\nTwo lines.\n"
        XCTAssertEqual(TextFidelity.normalize(TextFidelity.manuscriptBody(manuscript)), "One line. Two lines.")
    }

    func testMissingManuscriptIsReported() throws {
        let story = try SampleContent.story()
        let landmarks = try SampleContent.landmarks()
        let development = StoryValidator(mode: .development).validate(story: story, landmarks: landmarks, manuscript: nil)
        XCTAssertTrue(development.contains(.manuscriptMissing, severity: .warning))
        let release = StoryValidator(mode: .release).validate(story: story, landmarks: landmarks, manuscript: nil)
        assertError(release, .manuscriptMissing)
    }

    // MARK: Region, provenance, cultural review, education

    func testEmptyRegionCulture() throws {
        var story = try SampleContent.story()
        story.region.culture = ""
        assertError(try SampleContent.report(for: story), .regionIncomplete)
    }

    func testEmptyRegionPlace() throws {
        var story = try SampleContent.story()
        story.region.place = " "
        assertError(try SampleContent.report(for: story), .regionIncomplete)
    }

    func testPinOutOfRange() throws {
        var story = try SampleContent.story()
        story.region.pin = GeoPoint(lat: 123, lon: 79)
        assertError(try SampleContent.report(for: story), .pinOutOfRange)
    }

    func testRetellingWithNoSource() throws {
        var story = try SampleContent.story()
        story.provenance.sources = []
        assertError(try SampleContent.report(for: story), .provenanceNoSource)

        story.provenance.sources = nil
        assertError(try SampleContent.report(for: story), .provenanceNoSource)
    }

    func testSourceNeedsAuthorTitleAndYear() throws {
        var story = try SampleContent.story()
        story.provenance.sources?[0].author = ""
        assertError(try SampleContent.report(for: story), .provenanceSourceIncomplete)
    }

    func testOriginalWithNoPremise() throws {
        var story = try SampleContent.story()
        story.provenance = Provenance(
            kind: .original,
            tradition: nil,
            sources: nil,
            textBasis: nil,
            credit: Brand.originalStoryCredit,
            premise: nil,
            authors: nil,
            rights: "Written for Omramo."
        )
        assertError(try SampleContent.report(for: story), .originalIncomplete)

        story.provenance.premise = "A monkey outwits a crocodile."
        let report = try SampleContent.report(for: story)
        XCTAssertTrue(report.isValid, "\(report.errors.map(\.description))")
    }

    func testOriginalWithNoCredit() throws {
        var story = try SampleContent.story()
        story.provenance.kind = .original
        story.provenance.premise = "A monkey outwits a crocodile."
        story.provenance.credit = nil
        assertError(try SampleContent.report(for: story), .originalIncomplete)
    }

    func testRequiredCulturalReviewWithNoReason() throws {
        var story = try SampleContent.story()
        story.culturalReview.reason = nil
        assertError(try SampleContent.report(for: story), .culturalReviewNoReason)
    }

    func testStandardReviewNeedsNoReason() throws {
        var story = try SampleContent.story()
        story.culturalReview.level = .standard
        story.culturalReview.reason = nil
        let report = try SampleContent.report(for: story, mode: .development)
        XCTAssertFalse(report.contains(.culturalReviewNoReason))
        XCTAssertTrue(report.isValid)
    }

    func testEmptyEducationLesson() throws {
        for pillar in 0..<3 {
            var story = try SampleContent.story()
            switch pillar {
            case 0: story.education.geography.lesson = ""
            case 1: story.education.culture.lesson = " "
            default: story.education.moral.lesson = "\n"
            }
            assertError(try SampleContent.report(for: story), .educationIncomplete)
        }
    }

    func testEducationFactCardMustBeATapTargetOfTheStory() throws {
        var story = try SampleContent.story()
        story.education.geography.factCards = [TapTargetID("no-such-card")]
        assertError(try SampleContent.report(for: story), .educationFactCardDangling)
    }

    func testRuleCodesAreUnique() {
        let codes = ValidationCode.allCases.map(\.rawValue)
        XCTAssertEqual(Set(codes).count, codes.count)
    }
}
