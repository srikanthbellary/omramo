import Foundation
import XCTest
@testable import OmramoCore

final class TierAndTokenTests: XCTestCase {

    // MARK: Tier metrics (docs/DESIGN.md §4.2)

    func testTierReadingSizes() {
        let low = Tier.low.readingScale()
        XCTAssertEqual(low.body.size, 23.5)
        XCTAssertEqual(low.body.lineHeight, 37)
        XCTAssertEqual(low.body.weight, 460)
        XCTAssertEqual(low.paragraphGap, 17)
        XCTAssertEqual(low.column, 374)
        XCTAssertEqual(low.textTop, 106)

        let medium = Tier.medium.readingScale()
        XCTAssertEqual(medium.body.size, 19.5)
        XCTAssertEqual(medium.body.lineHeight, 32)
        XCTAssertEqual(medium.body.weight, 430)
        XCTAssertEqual(medium.paragraphGap, 16)
        XCTAssertEqual(medium.column, 372)

        let advanced = Tier.advanced.readingScale()
        XCTAssertEqual(advanced.body.size, 16.5)
        XCTAssertEqual(advanced.body.lineHeight, 27)
        XCTAssertEqual(advanced.body.weight, 420)
        XCTAssertEqual(advanced.paragraphGap, 12)
    }

    func testLeadSentenceMetrics() {
        let low = Tier.low.readingScale().lead
        XCTAssertEqual(low.family, .display)
        XCTAssertEqual(low.size, 32)
        XCTAssertEqual(low.lineHeight, 38)
        XCTAssertEqual(low.weight, 720)
        XCTAssertEqual(low.tracking, -0.6)
        XCTAssertEqual(low.opticalSize, 48)
        XCTAssertEqual(low.width, 92)

        XCTAssertEqual(Tier.medium.readingScale().lead.size, 27)
        XCTAssertEqual(Tier.advanced.readingScale().lead.size, 21)
    }

    func testFoldedLowMetrics() {
        let folded = Tier.low.readingScale(posture: .folded)
        XCTAssertEqual(folded.body.size, 22.5)
        XCTAssertEqual(folded.body.lineHeight, 35)
        XCTAssertEqual(folded.paragraphGap, 12)
        XCTAssertEqual(folded.column, 376)
        XCTAssertEqual(folded.textTop, 366)
        XCTAssertTrue(folded.isDesigned)
        // Folded Medium and Advanced are not drawn (design gap G8).
        XCTAssertFalse(Tier.medium.readingScale(posture: .folded).isDesigned)
        XCTAssertFalse(Tier.advanced.readingScale(posture: .folded).isDesigned)
    }

    func testTierOrderIsPreserved() {
        XCTAssertEqual(Tier.allCases, [.low, .medium, .advanced])
        XCTAssertTrue(Tier.low < Tier.medium && Tier.medium < Tier.advanced)
        XCTAssertEqual(Tier.allCases.map(\.level), [1, 2, 3])
        XCTAssertEqual(Tier.allCases.map(\.displayName), ["Low", "Medium", "Advanced"])
        for posture in [DisplayPosture.unfolded, .folded] {
            let sizes = Tier.allCases.map { $0.readingScale(posture: posture).body.size }
            XCTAssertEqual(sizes, sizes.sorted(by: >), "Low is always larger than Medium, Medium larger than Advanced")
            let targets = Tier.allCases.map { $0.readingScale(posture: posture).targetWordsPerSpread }
            XCTAssertEqual(targets, targets.sorted())
        }
    }

    func testTierDecodesFromJSON() throws {
        XCTAssertEqual(try JSONDecoder().decode([Tier].self, from: Data("[\"low\",\"medium\",\"advanced\"]".utf8)), Tier.allCases)
        XCTAssertThrowsError(try JSONDecoder().decode([Tier].self, from: Data("[\"huge\"]".utf8)))
    }

    // MARK: Colours (docs/DESIGN.md §3)

    func testTierColours() {
        let low = Tokens.TierColors.colors(for: .low)
        XCTAssertEqual(low.base.hexString, "#12B58F")
        XCTAssertEqual(low.pillText.hexString, "#0B8A6C")
        XCTAssertEqual(low.pillBackground.hexString, "#D6F7EC")
        XCTAssertEqual(low.chipTextOnGlass.hexString, "#0B7A62")

        let medium = Tokens.TierColors.colors(for: .medium)
        XCTAssertEqual(medium.base.hexString, "#FF9F1A")
        XCTAssertEqual(medium.pillText.hexString, "#B36200")
        XCTAssertEqual(medium.pillBackground.hexString, "#FFEFC9")

        let advanced = Tokens.TierColors.colors(for: .advanced)
        XCTAssertEqual(advanced.base.hexString, "#6E56FF")
        XCTAssertEqual(advanced.pillText.hexString, "#5A3FE0")
        XCTAssertEqual(advanced.pillBackground.hexString, "#E6E0FF")
    }

    func testBrandColours() {
        XCTAssertEqual(Tokens.Palette.night.hexString, "#130F36")
        XCTAssertEqual(Tokens.Palette.ink.hexString, "#16123D")
        XCTAssertEqual(Tokens.Palette.coral.hexString, "#FF6A4D")
        XCTAssertEqual(Tokens.Palette.sun.hexString, "#FFC43D")
        XCTAssertEqual(Tokens.Palette.mint.hexString, "#19C7A2")
        XCTAssertEqual(Tokens.Palette.wordmarkAccent.hexString, "#FF5B3D")
        XCTAssertEqual(Tokens.Palette.textSecondary.alpha, 0.62, accuracy: 0.0001)
    }

    func testPageTurnGradients() {
        XCTAssertEqual(Tokens.Gradients.pageTurn(.coral).map(\.color.hexString), ["#FF9A66", "#FF5B3D", "#E8432B"])
        XCTAssertEqual(Tokens.Gradients.pageTurn(.amber).map(\.color.hexString), ["#FFD76B", "#FFB020", "#F08A12"])
        XCTAssertEqual(Tokens.Gradients.pageTurn(.red).map(\.color.hexString), ["#FF8A70", "#F4503F", "#D8342B"])
        XCTAssertEqual(Tokens.Gradients.pageTurnArrow(.amber).hexString, "#3A1B08")
        XCTAssertEqual(Tokens.Gradients.pageTurnArrow(.coral).hexString, "#FFFFFF")
    }

    func testAuroraHasFiveBlobs() {
        XCTAssertEqual(Tokens.Aurora.light.blobs.count, 5)
        XCTAssertEqual(Tokens.Aurora.dark.blobs.count, 5)
        XCTAssertEqual(Tokens.Aurora.light.base.hexString, "#F4F2FF")
        XCTAssertEqual(Tokens.Aurora.dark.base.hexString, "#110C33")
    }

    func testRadiiAndSizes() {
        XCTAssertEqual(Tokens.Radius.card, 26)
        XCTAssertEqual(Tokens.Radius.chip, 14)
        XCTAssertEqual(Tokens.Radius.pageTurn, Tokens.Size.pageTurn / 2)
        XCTAssertEqual(Tokens.Radius.roundGlassButton, Tokens.Size.roundGlassButton / 2)
        XCTAssertEqual(Tokens.Spacing.insetText, 30)
        XCTAssertGreaterThanOrEqual(Tokens.Size.minimumHitTarget, 44)
    }

    func testReferenceCanvas() {
        XCTAssertEqual(ReferenceCanvas.paneWidth, 432)
        XCTAssertEqual(ReferenceCanvas.paneHeight, 720)
        XCTAssertEqual(ReferenceCanvas.hingeWidth, 28)
        XCTAssertEqual(ReferenceCanvas.unfoldedWidth, 892)
    }

    // MARK: RGBA

    func testRGBAParsing() throws {
        let opaque = try XCTUnwrap(RGBA(string: "#10283A"))
        XCTAssertEqual(opaque.hexString, "#10283A")
        XCTAssertEqual(opaque.alpha, 1)

        let translucent = try XCTUnwrap(RGBA(string: "#FFC43D80"))
        XCTAssertEqual(translucent.hexString, "#FFC43D")
        XCTAssertEqual(translucent.alpha, 128.0 / 255.0, accuracy: 0.0001)

        XCTAssertEqual(RGBA(string: "#ffc43d")?.hexString, "#FFC43D")
        XCTAssertNil(RGBA(string: "FFC43D"))
        XCTAssertNil(RGBA(string: "#FFF"))
        XCTAssertNil(RGBA(string: "#GGGGGG"))
        XCTAssertNil(RGBA(string: "navy"))
        XCTAssertNil(RGBA(string: ""))
    }

    func testEveryColourInTheSampleStoryParses() throws {
        let story = try SampleContent.story()
        var colours = [story.theme.textColor, story.theme.chipGlass, story.region.pinColor,
                       story.theme.tap.fill, story.theme.tap.fill2, story.theme.tap.line, story.theme.tap.spark]
        colours += story.characters.map(\.color)
        colours += story.spreads.flatMap(\.scene.fallbackColors)
        for colour in colours {
            XCTAssertNotNil(RGBA(string: colour), colour)
        }
    }

    // MARK: Fonts

    func testFontFiles() {
        XCTAssertEqual(Set(Tokens.FontFamily.allFileNames).count, 4)
        for family in Tokens.FontFamily.allCases {
            XCTAssertTrue(Tokens.FontFamily.allFileNames.contains(family.fileName))
            if let italic = family.italicFileName {
                XCTAssertTrue(Tokens.FontFamily.allFileNames.contains(italic))
            }
        }
        // Every reading weight is inside the variable font's range.
        for tier in Tier.allCases {
            let scale = tier.readingScale()
            XCTAssertTrue(scale.body.family.weightRange.contains(scale.body.weight))
            XCTAssertTrue(scale.lead.family.weightRange.contains(scale.lead.weight))
            XCTAssertTrue(Tokens.DisplayAxes.opticalSize.contains(scale.lead.opticalSize ?? 0))
            XCTAssertTrue(Tokens.DisplayAxes.width.contains(scale.lead.width ?? 0))
        }
    }
}

final class BrandTests: XCTestCase {
    func testFoldMarkDerivesOMRAMO() {
        let mark = FoldMark()
        XCTAssertEqual(mark.leading, "OM")
        XCTAssertEqual(mark.middle, "RA")
        XCTAssertEqual(mark.trailing, "MO")
        XCTAssertEqual(mark.leading + mark.middle + mark.trailing, Brand.wordmark)
        // The hinge runs through the middle of "RA".
        XCTAssertEqual(mark.leftOfHinge, "OMR")
        XCTAssertEqual(mark.rightOfHinge, "AMO")
    }

    func testFoldMarkWithOtherLengths() {
        let seven = FoldMark(wordmark: "ABCDEFG")
        XCTAssertEqual([seven.leading, seven.middle, seven.trailing], ["AB", "CDE", "FG"])
        let empty = FoldMark(wordmark: "")
        XCTAssertEqual(empty.leftOfHinge + empty.rightOfHinge, "")
    }

    func testWordmarkIsTheDisplayNameInCapitals() {
        XCTAssertEqual(Brand.wordmark, Brand.displayName.uppercased())
        XCTAssertTrue(Brand.privacyURLString.contains(Brand.domain))
        XCTAssertTrue(Brand.termsURLString.contains(Brand.domain))
    }

    /// `Configuration/Brand.xcconfig` must name the product the same way `Brand` does.
    func testBrandXcconfigAgreesWithBrand() throws {
        var url = URL(fileURLWithPath: #filePath)
        // …/repo/Packages/OmramoCore/Tests/OmramoCoreTests/TokenAndBrandTests.swift → …/repo
        for _ in 0..<5 {
            url.deleteLastPathComponent()
        }
        url.appendPathComponent("Configuration")
        url.appendPathComponent("Brand.xcconfig")
        guard let text = try? String(contentsOf: url, encoding: .utf8) else {
            throw XCTSkip("Configuration/Brand.xcconfig not found (package checked out on its own)")
        }
        var value: String?
        for line in text.split(whereSeparator: { $0.isNewline }) {
            let parts = line.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            if parts.count == 2, parts[0] == "OMRAMO_DISPLAY_NAME" {
                value = parts[1]
            }
        }
        XCTAssertEqual(value, Brand.displayName)
    }
}
