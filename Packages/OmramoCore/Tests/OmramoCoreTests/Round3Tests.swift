import Foundation
import XCTest
@testable import OmramoCore

// Round 3: tall-pane page fit, touch areas of marked words, and the M4 subset behind the
// library's side column (reading log, streak, shelf, friends met).

// MARK: - Page fit

final class PageFitTests: XCTestCase {
    private let resolver = PaneLayoutResolver()

    private func layout(_ width: Double, _ height: Double) -> PaneLayout {
        resolver.resolve(PaneLayoutInput(canvasWidth: width, canvasHeight: height))
    }

    private func extra(_ layout: PaneLayout) -> Double {
        PageFit.extraHeight(paneHeight: layout.leading.height, scale: layout.referenceScale)
    }

    /// The column the reader gives a tier on a two-pane layout (the rule of `ReaderMetrics`).
    private func column(_ tier: Tier, _ layout: PaneLayout) -> Double {
        let s = layout.referenceScale
        let width = layout.leading.width
        let inset = max(0, (width - layout.contentWidth) / 2)
        let hinge = max(inset, Tokens.Spacing.hingeClearance * s)
        return min(tier.readingScale().column * s, width - inset - Tokens.Spacing.insetText * s - hinge)
    }

    private func boost(_ tier: Tier, _ layout: PaneLayout) -> Double {
        PageFit.typeBoost(
            tier: tier,
            posture: layout.posture,
            baseFontSize: tier.readingScale(posture: layout.posture).body.size,
            paneScale: layout.referenceScale,
            columnWidth: column(tier, layout),
            extraHeight: extra(layout),
            maximumScale: layout.maximumReferenceScale
        )
    }

    func testTheReferencePaneHasNoExtraHeight() {
        XCTAssertEqual(extra(layout(892, 720)), 0, accuracy: 0.0001)
        XCTAssertEqual(extra(layout(432, 720)), 0, accuracy: 0.0001)
        // 11-inch landscape is limited by its height: the pane has the design's proportions or squatter.
        XCTAssertEqual(extra(layout(1210, 834)), 0, accuracy: 0.0001)
        XCTAssertEqual(PageFit.extraHeight(paneHeight: 0, scale: 1), 0)
        XCTAssertEqual(PageFit.extraHeight(paneHeight: 720, scale: 0), 0)
    }

    func testTallPanesHaveExtraHeight() {
        // 13-inch portrait: two panes 502 wide, the design at 1.162 ×, 836 pt of 1376 used.
        let portrait = layout(1032, 1376)
        XCTAssertEqual(portrait.posture, .unfolded)
        XCTAssertEqual(extra(portrait), 1376 - 720 * portrait.referenceScale, accuracy: 0.001)
        XCTAssertGreaterThan(extra(portrait), 500)
        // 13-inch landscape: capped at 1.3 ×, 936 of 1032 used.
        XCTAssertEqual(extra(layout(1376, 1032)), 1032 - 936, accuracy: 0.001)
        // A tall phone.
        XCTAssertGreaterThan(extra(layout(440, 956)), 200)
    }

    func testTypeDoesNotGrowOnTheDesignedLayouts() {
        for tier in Tier.allCases {
            // The reference canvas, derived.
            XCTAssertEqual(boost(tier, layout(892, 720)), 1, "\(tier)")
            // The simulated Duo and a system-reported Duo carry no limit: the locked design.
            let simulated = resolver.resolve(PaneLayoutInput(canvasWidth: 1032, canvasHeight: 1376, simulation: .unfolded))
            XCTAssertEqual(boost(tier, simulated), 1, "\(tier)")
            let duo = resolver.resolve(PaneLayoutInput(canvasWidth: 900, canvasHeight: 1400, reportedPosture: .unfolded))
            XCTAssertEqual(boost(tier, duo), 1, "\(tier)")
            // One pane: the picture takes the extra height, not the type.
            XCTAssertEqual(boost(tier, layout(834, 1210)), 1, "\(tier)")
            XCTAssertEqual(boost(tier, layout(440, 956)), 1, "\(tier)")
            // Already at the 1.3 × cap.
            XCTAssertEqual(boost(tier, layout(1376, 1032)), 1, "\(tier)")
        }
    }

    func testTypeGrowsOnAThirteenInchPortraitWithinTheTiersBounds() {
        let portrait = layout(1032, 1376)
        let s = portrait.referenceScale
        for tier in Tier.allCases {
            let factor = boost(tier, portrait)
            let label = "\(tier)"
            XCTAssertGreaterThanOrEqual(factor, 1, label)
            // Never past the layout's own limit…
            XCTAssertLessThanOrEqual(factor * s, 1.3 + 0.0001, label)
            // …and never so large that a line falls under the tier's shortest measure.
            let font = tier.readingScale().body.size * s * factor
            let perLine = PageFit.charactersPerLine(columnWidth: column(tier, portrait), fontSize: font)
            XCTAssertGreaterThanOrEqual(perLine, PageFit.measure(for: tier).lowerBound - 0.5, label)
            XCTAssertLessThanOrEqual(perLine, PageFit.measure(for: tier).upperBound, label)
        }
        // The younger tiers have room to grow; the oldest keeps its 45-character line instead.
        XCTAssertGreaterThan(boost(.low, portrait), 1.05)
        XCTAssertGreaterThan(boost(.medium, portrait), 1.05)
        XCTAssertLessThan(boost(.advanced, portrait), 1.03)
        // The tiers keep their order of size.
        let low = Tier.low.readingScale().body.size * boost(.low, portrait)
        let medium = Tier.medium.readingScale().body.size * boost(.medium, portrait)
        let advanced = Tier.advanced.readingScale().body.size * boost(.advanced, portrait)
        XCTAssertGreaterThan(low, medium)
        XCTAssertGreaterThan(medium, advanced)
    }

    func testTypeBoostMovesInHundredths() {
        let factor = boost(.low, layout(1032, 1376))
        XCTAssertEqual((factor * 100).rounded(), factor * 100, accuracy: 0.000001)
        // Degenerate inputs give 1, never a crash or a shrink.
        XCTAssertEqual(PageFit.typeBoost(tier: .low, posture: .unfolded, baseFontSize: 0, paneScale: 1, columnWidth: 300, extraHeight: 100, maximumScale: 1.3), 1)
        XCTAssertEqual(PageFit.typeBoost(tier: .low, posture: .unfolded, baseFontSize: 23.5, paneScale: 1, columnWidth: 100, extraHeight: 400, maximumScale: 1.3), 1)
    }

    func testMeasuresAreOrderedByTier() {
        XCTAssertLessThan(PageFit.measure(for: .low).lowerBound, PageFit.measure(for: .medium).lowerBound)
        XCTAssertLessThan(PageFit.measure(for: .medium).lowerBound, PageFit.measure(for: .advanced).lowerBound)
        XCTAssertEqual(PageFit.measure(for: .advanced), 45...65)
        // The designed columns sit inside their tier's measure.
        for tier in Tier.allCases {
            let scale = tier.readingScale()
            let perLine = PageFit.charactersPerLine(columnWidth: scale.column, fontSize: scale.body.size)
            XCTAssertTrue(PageFit.measure(for: tier).contains(perLine), "\(tier): \(perLine)")
        }
        XCTAssertEqual(PageFit.charactersPerLine(columnWidth: 0, fontSize: 20), 0)
        XCTAssertEqual(PageFit.charactersPerLine(columnWidth: 300, fontSize: 0), 0)
    }

    func testShortTextIsSetLowerOnATallPaneOnly() {
        // No extra height (the reference pane): the designed top, however short the text.
        XCTAssertEqual(PageFit.balancedOffset(free: 400, extra: 0), 0)
        // The text fills its column: nothing to balance.
        XCTAssertEqual(PageFit.balancedOffset(free: 0, extra: 500), 0)
        XCTAssertEqual(PageFit.balancedOffset(free: -20, extra: 500), 0)
        // A little under half of the free space…
        XCTAssertEqual(PageFit.balancedOffset(free: 200, extra: 540), 84)
        // …and never more than half of the extra height.
        XCTAssertEqual(PageFit.balancedOffset(free: 900, extra: 540), 270)
        XCTAssertEqual(PageFit.balancedOffset(free: 900, extra: 96), 48)
    }

    func testBalancedTextAlwaysStaysInsideItsColumn() {
        for free in stride(from: 0.0, through: 1200.0, by: 37.0) {
            for extra in stride(from: 0.0, through: 700.0, by: 53.0) {
                let offset = PageFit.balancedOffset(free: free, extra: extra)
                XCTAssertGreaterThanOrEqual(offset, 0)
                // Rounded to a whole point, so allow half a point.
                XCTAssertLessThanOrEqual(offset, free * 0.5 + 0.5, "free \(free) extra \(extra)")
                XCTAssertLessThanOrEqual(offset, extra * 0.5 + 0.5)
            }
        }
    }

    func testFoldedPictureKeepsTheDesignedHeightOnTheReferencePane() {
        XCTAssertEqual(PageFit.foldedPictureHeight(designed: 340, paneWidth: 432, paneHeight: 720, extra: 0), 340, accuracy: 0.0001)
    }

    func testFoldedPictureTakesAShareOfATallPhone() {
        // iPhone 17 Pro Max: 440 × 956.
        let phone = layout(440, 956)
        let s = phone.referenceScale
        let band = PageFit.foldedPictureHeight(designed: 340 * s, paneWidth: 440, paneHeight: 956, extra: extra(phone))
        XCTAssertEqual(band, 340 * s + extra(phone) * 0.4, accuracy: 0.001)
        XCTAssertGreaterThan(band, 340 * s + 60)
        // The words keep the larger part of the screen.
        XCTAssertLessThan(band, 956 * 0.5)
    }

    func testFoldedPictureIsBoundedOnEveryWindow() {
        let windows: [(Double, Double)] = [
            (375, 667), (393, 852), (440, 956), (320, 1000), (678, 1024), (834, 1210), (820, 1180), (760, 620), (432, 720),
        ]
        for (width, height) in windows {
            let window = layout(width, height)
            guard window.posture == .folded else { continue }
            let s = window.referenceScale
            let band = PageFit.foldedPictureHeight(designed: 340 * s, paneWidth: width, paneHeight: height, extra: extra(window))
            XCTAssertGreaterThanOrEqual(band, 340 * s - 0.001, "\(width) × \(height)")
            XCTAssertLessThanOrEqual(band, max(340 * s, height * 0.56) + 0.001, "\(width) × \(height)")
            XCTAssertLessThan(band, height * 0.62, "\(width) × \(height)")
        }
        // An 11-inch iPad in portrait gets a generous picture, wider than it is tall.
        let pad = layout(834, 1210)
        let band = PageFit.foldedPictureHeight(designed: 340 * 1.3, paneWidth: 834, paneHeight: 1210, extra: extra(pad))
        XCTAssertGreaterThan(band, 500)
        XCTAssertLessThan(band, 834)
    }
}

// MARK: - Touch areas of marked words

final class HitTargetTests: XCTestCase {
    func testAShortWordGetsAFullSizeTarget() {
        // "pot" at 16.5 pt: about 24 × 27.
        let word = LayoutRect(x: 100, y: 200, width: 24, height: 27)
        let area = HitTargets.expanded(word)
        XCTAssertEqual(area.width, 44)
        XCTAssertEqual(area.height, 44)
        // Centred on the word.
        XCTAssertEqual(area.x + area.width / 2, 112, accuracy: 0.0001)
        XCTAssertEqual(area.y + area.height / 2, 213.5, accuracy: 0.0001)
    }

    func testALongWordKeepsItsWidthPlusPadding() {
        let word = LayoutRect(x: 10, y: 0, width: 180, height: 38)
        let area = HitTargets.expanded(word)
        XCTAssertEqual(area.width, 188)
        XCTAssertEqual(area.x, 6)
        XCTAssertEqual(area.height, 44)
        XCTAssertEqual(area.y, -3)
        // A tall line keeps its own height.
        XCTAssertEqual(HitTargets.expanded(LayoutRect(x: 0, y: 0, width: 80, height: 60)).height, 60)
    }

    func testTheMinimumCanBeRaisedForPrimaryControls() {
        let area = HitTargets.expanded(LayoutRect(x: 0, y: 0, width: 10, height: 10), minimum: 56, padding: 0)
        XCTAssertEqual(area.width, 56)
        XCTAssertEqual(area.height, 56)
    }

    func testAWordAloneIsUntouchedByResolve() {
        let word = LayoutRect(x: 50, y: 50, width: 30, height: 30)
        XCTAssertEqual(HitTargets.resolve([word]), [HitTargets.expanded(word)])
        XCTAssertEqual(HitTargets.resolve([]), [])
    }

    func testTwoWordsSideBySideShareTheGapBetweenThem() {
        // Two short marked words 10 pt apart on one line.
        let first = LayoutRect(x: 100, y: 0, width: 20, height: 30)
        let second = LayoutRect(x: 130, y: 0, width: 20, height: 30)
        let areas = HitTargets.resolve([first, second])
        XCTAssertEqual(areas.count, 2)
        // They meet at the middle of the gap and do not overlap.
        XCTAssertEqual(areas[0].maxX, 125, accuracy: 0.0001)
        XCTAssertEqual(areas[1].x, 125, accuracy: 0.0001)
        // Each still holds its whole word and reaches outward as far as before.
        XCTAssertLessThanOrEqual(areas[0].x, first.x)
        XCTAssertGreaterThanOrEqual(areas[1].maxX, second.maxX)
        XCTAssertEqual(areas[0].x, 88, accuracy: 0.0001)
        XCTAssertEqual(areas[1].maxX, 162, accuracy: 0.0001)
        // A tap just left of the gap's middle opens the first word; just right, the second.
        XCTAssertEqual(HitTargets.index(at: 124, 15, in: areas), 0)
        XCTAssertEqual(HitTargets.index(at: 126, 15, in: areas), 1)
    }

    func testOrderOfTheWordsDoesNotMatter() {
        let left = LayoutRect(x: 100, y: 0, width: 20, height: 30)
        let right = LayoutRect(x: 130, y: 0, width: 20, height: 30)
        let areas = HitTargets.resolve([right, left])
        XCTAssertEqual(areas[1].maxX, 125, accuracy: 0.0001)
        XCTAssertEqual(areas[0].x, 125, accuracy: 0.0001)
    }

    func testWordsOnNeighbouringLinesShareTheLeading() {
        // Advanced tier: 27-pt lines, a marked word on each of two lines, one above the other.
        let upper = LayoutRect(x: 40, y: 0, width: 90, height: 27)
        let lower = LayoutRect(x: 60, y: 27, width: 70, height: 27)
        let areas = HitTargets.resolve([upper, lower])
        XCTAssertEqual(areas[0].maxY, 27, accuracy: 0.0001)
        XCTAssertEqual(areas[1].y, 27, accuracy: 0.0001)
        // Outward they keep the room that makes them 44 pt targets.
        XCTAssertEqual(areas[0].y, -8.5, accuracy: 0.0001)
        XCTAssertEqual(areas[1].maxY, 62.5, accuracy: 0.0001)
        XCTAssertEqual(HitTargets.index(at: 80, 20, in: areas), 0)
        XCTAssertEqual(HitTargets.index(at: 80, 30, in: areas), 1)
    }

    func testFarApartWordsKeepTheirFullTargets() {
        let a = LayoutRect(x: 0, y: 0, width: 20, height: 30)
        let b = LayoutRect(x: 300, y: 120, width: 20, height: 30)
        let areas = HitTargets.resolve([a, b])
        XCTAssertEqual(areas[0], HitTargets.expanded(a))
        XCTAssertEqual(areas[1], HitTargets.expanded(b))
    }

    func testEveryResolvedAreaContainsItsWord() {
        // A dense line of three marked words and one on the next line.
        let words = [
            LayoutRect(x: 0, y: 0, width: 26, height: 32),
            LayoutRect(x: 34, y: 0, width: 18, height: 32),
            LayoutRect(x: 60, y: 0, width: 40, height: 32),
            LayoutRect(x: 30, y: 32, width: 30, height: 32),
        ]
        let areas = HitTargets.resolve(words)
        for (word, area) in zip(words, areas) {
            XCTAssertLessThanOrEqual(area.x, word.x + 0.0001)
            XCTAssertGreaterThanOrEqual(area.maxX, word.maxX - 0.0001)
            XCTAssertLessThanOrEqual(area.y, word.y + 0.0001)
            XCTAssertGreaterThanOrEqual(area.maxY, word.maxY - 0.0001)
        }
        // The middle of every word hits that word.
        for (index, word) in words.enumerated() {
            XCTAssertEqual(HitTargets.index(at: word.x + word.width / 2, word.y + word.height / 2, in: areas), index)
        }
    }

    func testATapOutsideEveryAreaOpensNothing() {
        let areas = HitTargets.resolve([LayoutRect(x: 100, y: 100, width: 60, height: 30)])
        XCTAssertNil(HitTargets.index(at: 10, 10, in: areas))
        XCTAssertNil(HitTargets.index(at: 400, 115, in: areas))
        XCTAssertEqual(HitTargets.index(at: 130, 115, in: areas), 0)
    }

    func testIdentifiersOfWordsAndCards() {
        let tap = StoryCardRef.tapTarget(TapTargetID("river-bank"))
        XCTAssertEqual(tap.cardID, "river-bank")
        XCTAssertEqual(tap.wordIdentifier, "word.river-bank")
        XCTAssertEqual(tap.cardIdentifier, "card.river-bank")
        let name = StoryCardRef.character(CharacterID("urashima"))
        XCTAssertEqual(name.wordIdentifier, "word.urashima")
        XCTAssertEqual(name.cardIdentifier, "card.urashima")
    }

    func testMarkedWordsOfTheBundledStories() throws {
        let library = try BundledContent.repository().loadLibrary()
        // The words the UI tests tap are where the tests expect them: on page 1 of each story.
        let expected: [String: String] = [
            "monkey-and-crocodile": "word.river-bank",
            "anansi-wisdom": "word.village-houses",
            "urashima-taro": "word.urashima",
        ]
        for (storyID, identifier) in expected {
            let story = try XCTUnwrap(library.story(id: StoryID(storyID)))
            let first = try XCTUnwrap(story.spreads.first)
            let words = first.blocks.flatMap { $0.markedWords }
            XCTAssertTrue(words.contains { $0.ref.wordIdentifier == identifier }, "\(storyID) page 1 has no \(identifier)")
            let ref = try XCTUnwrap(words.first { $0.ref.wordIdentifier == identifier }?.ref)
            XCTAssertNotNil(story.cardContent(for: ref, landmarks: library.landmarks), "\(identifier) opens no card")
        }
        // Every marked word of every story has a non-empty text and resolves to its own id;
        // an unmarked run is never listed.
        for story in library.stories {
            for spread in story.spreads {
                for block in spread.blocks {
                    let marked = block.markedWords
                    XCTAssertEqual(marked.count, block.runs.filter { $0.tapTarget != nil || $0.characterName != nil }.count)
                    for word in marked {
                        XCTAssertFalse(word.text.trimmingCharacters(in: .whitespaces).isEmpty, "\(story.id) \(block.id)")
                        XCTAssertTrue(word.ref.wordIdentifier.hasPrefix("word."))
                        XCTAssertTrue(block.cardRefs.contains(word.ref))
                    }
                }
            }
        }
    }
}

// MARK: - Reading days

final class ReadingDayTests: XCTestCase {
    private func calendar(_ zone: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: zone) ?? TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, zone: String) -> Date {
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        parts.hour = hour
        parts.minute = minute
        return calendar(zone).date(from: parts) ?? Date(timeIntervalSince1970: 0)
    }

    func testOrdinalRoundTrip() {
        XCTAssertEqual(ReadingDay(year: 1970, month: 1, day: 1).ordinal, 0)
        XCTAssertEqual(ReadingDay(year: 1970, month: 1, day: 2).ordinal, 1)
        XCTAssertEqual(ReadingDay(year: 1969, month: 12, day: 31).ordinal, -1)
        XCTAssertEqual(ReadingDay(year: 2000, month: 3, day: 1).ordinal, 11017)
        for ordinal in stride(from: -800, through: 30000, by: 13) {
            XCTAssertEqual(ReadingDay(ordinal: ordinal).ordinal, ordinal)
        }
    }

    func testTheDayAfterAcrossMonthsYearsAndLeapDays() {
        XCTAssertEqual(ReadingDay(year: 2026, month: 11, day: 30).adding(days: 1), ReadingDay(year: 2026, month: 12, day: 1))
        XCTAssertEqual(ReadingDay(year: 2026, month: 12, day: 31).adding(days: 1), ReadingDay(year: 2027, month: 1, day: 1))
        XCTAssertEqual(ReadingDay(year: 2028, month: 2, day: 28).adding(days: 1), ReadingDay(year: 2028, month: 2, day: 29))
        XCTAssertEqual(ReadingDay(year: 2028, month: 2, day: 29).adding(days: 1), ReadingDay(year: 2028, month: 3, day: 1))
        XCTAssertEqual(ReadingDay(year: 2027, month: 2, day: 28).adding(days: 1), ReadingDay(year: 2027, month: 3, day: 1))
        XCTAssertEqual(ReadingDay(year: 2027, month: 1, day: 1).adding(days: -1), ReadingDay(year: 2026, month: 12, day: 31))
    }

    func testWeekdays() {
        // 14 November 2026 is a Saturday; 9 November 2026 a Monday.
        XCTAssertEqual(ReadingDay(year: 2026, month: 11, day: 14).weekdayFromMonday, 5)
        XCTAssertEqual(ReadingDay(year: 2026, month: 11, day: 9).weekdayFromMonday, 0)
        XCTAssertEqual(ReadingDay(year: 2026, month: 11, day: 15).weekdayFromMonday, 6)
        XCTAssertEqual(ReadingDay(year: 1970, month: 1, day: 1).weekdayFromMonday, 3)
        XCTAssertEqual(ReadingDay(year: 1969, month: 12, day: 29).weekdayFromMonday, 0)
    }

    func testOrderAndDescription() {
        XCTAssertLessThan(ReadingDay(year: 2026, month: 11, day: 9), ReadingDay(year: 2026, month: 11, day: 10))
        XCTAssertLessThan(ReadingDay(year: 2026, month: 9, day: 30), ReadingDay(year: 2026, month: 10, day: 1))
        XCTAssertLessThan(ReadingDay(year: 2025, month: 12, day: 31), ReadingDay(year: 2026, month: 1, day: 1))
        XCTAssertEqual(ReadingDay(year: 2026, month: 3, day: 7).description, "2026-03-07")
    }

    func testADayIsTheDeviceCalendarDayWithNoTimeInIt() throws {
        let zone = "America/New_York"
        let lateEvening = date(2026, 11, 13, 23, 59, zone: zone)
        let justAfterMidnight = date(2026, 11, 14, 0, 1, zone: zone)
        let evening = ReadingDay(date: lateEvening, calendar: calendar(zone))
        let morning = ReadingDay(date: justAfterMidnight, calendar: calendar(zone))
        XCTAssertEqual(evening, ReadingDay(year: 2026, month: 11, day: 13))
        XCTAssertEqual(morning, ReadingDay(year: 2026, month: 11, day: 14))
        XCTAssertEqual(morning.ordinal - evening.ordinal, 1)

        // What is stored is three numbers: no hour, no minute, no time-zone, no timestamp.
        let data = try JSONEncoder().encode(evening)
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(Set(object.keys), ["year", "month", "day"])
    }

    func testTheSameInstantIsADifferentDayInAnotherTimeZone() {
        // 23:30 on the 13th in New York is already the 14th in Tokyo.
        let instant = date(2026, 11, 13, 23, 30, zone: "America/New_York")
        XCTAssertEqual(ReadingDay(date: instant, calendar: calendar("America/New_York")), ReadingDay(year: 2026, month: 11, day: 13))
        XCTAssertEqual(ReadingDay(date: instant, calendar: calendar("Asia/Tokyo")), ReadingDay(year: 2026, month: 11, day: 14))
    }
}

// MARK: - Reading log and streak

final class ReadingLogTests: XCTestCase {
    private let monkey = StoryID("monkey-and-crocodile")
    private let anansi = StoryID("anansi-wisdom")

    private func day(_ month: Int, _ day: Int) -> ReadingDay {
        ReadingDay(year: 2026, month: month, day: day)
    }

    private func makeLog(readingOn days: [ReadingDay]) -> ReadingLogFile {
        var log = ReadingLogFile()
        for (index, day) in days.enumerated() {
            log.recordPageRead(storyID: monkey, spreadID: SpreadID("s\(index)"), on: day)
        }
        return log
    }

    func testAnEmptyLog() {
        let log = ReadingLogFile()
        XCTAssertEqual(log.totalPagesRead, 0)
        XCTAssertTrue(log.readingDays.isEmpty)
        XCTAssertEqual(StreakCalculator.currentStreak(days: log.readingDays, today: day(11, 14)), 0)
        XCTAssertEqual(StreakCalculator.longestStreak(days: log.readingDays), 0)
        XCTAssertFalse(log.isFinished(monkey))
    }

    func testADayCountsWhenAtLeastOnePageIsRead() {
        // One page is enough…
        let one = makeLog(readingOn: [day(11, 14)])
        XCTAssertEqual(StreakCalculator.currentStreak(days: one.readingDays, today: day(11, 14)), 1)
        // …and twenty pages on the same day are still one day.
        let many = makeLog(readingOn: Array(repeating: day(11, 14), count: 20))
        XCTAssertEqual(many.pagesRead(on: day(11, 14)), 20)
        XCTAssertEqual(many.readingDays.count, 1)
        XCTAssertEqual(StreakCalculator.currentStreak(days: many.readingDays, today: day(11, 14)), 1)
    }

    func testAPageIsCountedOncePerForwardTurn() {
        var log = ReadingLogFile()
        log.recordPageRead(storyID: monkey, spreadID: SpreadID("s01"), on: day(11, 14))
        XCTAssertEqual(log.totalPagesRead, 1)
        XCTAssertEqual(log.entries, [PageRead(day: day(11, 14), storyID: monkey, spreadID: SpreadID("s01"))])
        // The next turn records the next page: one entry per turn.
        log.recordPageRead(storyID: monkey, spreadID: SpreadID("s02"), on: day(11, 14))
        XCTAssertEqual(log.totalPagesRead, 2)
        // Turning the same page forward again (after going back) is another turn (PRD Q14 default).
        log.recordPageRead(storyID: monkey, spreadID: SpreadID("s02"), on: day(11, 14))
        XCTAssertEqual(log.totalPagesRead, 3)
        XCTAssertEqual(log.pagesRead(on: day(11, 14)), 3)
        XCTAssertEqual(log.pagesRead(on: day(11, 13)), 0)
    }

    func testStreakAcrossMidnight() {
        // A page at 23:59 and a page at 00:01 are two days in a row.
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/London") ?? TimeZone(secondsFromGMT: 0)!
        var parts = DateComponents()
        parts.year = 2026
        parts.month = 11
        parts.day = 13
        parts.hour = 23
        parts.minute = 59
        let before = calendar.date(from: parts) ?? Date(timeIntervalSince1970: 0)
        let after = before.addingTimeInterval(120)
        var log = ReadingLogFile()
        log.recordPageRead(storyID: monkey, spreadID: SpreadID("s01"), on: ReadingDay(date: before, calendar: calendar))
        let today = ReadingDay(date: after, calendar: calendar)
        // Not yet read today: yesterday's day still stands.
        XCTAssertEqual(StreakCalculator.currentStreak(days: log.readingDays, today: today), 1)
        log.recordPageRead(storyID: monkey, spreadID: SpreadID("s02"), on: today)
        XCTAssertEqual(log.readingDays.count, 2)
        XCTAssertEqual(StreakCalculator.currentStreak(days: log.readingDays, today: today), 2)
    }

    func testAStreakIsStillAliveBeforeTodaysPage() {
        let three = makeLog(readingOn: [day(11, 11), day(11, 12), day(11, 13)])
        // On the 14th, before reading: three days, not zero.
        XCTAssertEqual(StreakCalculator.currentStreak(days: three.readingDays, today: day(11, 14)), 3)
        // After reading on the 14th: four.
        var four = three
        four.recordPageRead(storyID: monkey, spreadID: SpreadID("s9"), on: day(11, 14))
        XCTAssertEqual(StreakCalculator.currentStreak(days: four.readingDays, today: day(11, 14)), 4)
    }

    func testAMissedDayStartsAgainQuietly() {
        // Read on the 10th and 11th, nothing on the 12th, then the 13th and 14th.
        let gap = makeLog(readingOn: [day(11, 10), day(11, 11), day(11, 13), day(11, 14)])
        XCTAssertEqual(StreakCalculator.currentStreak(days: gap.readingDays, today: day(11, 14)), 2)
        XCTAssertEqual(StreakCalculator.longestStreak(days: gap.readingDays), 2)
        // Two days with nothing: the run is over; the count is simply 0, with no "lost" state.
        let old = makeLog(readingOn: [day(11, 10), day(11, 11)])
        XCTAssertEqual(StreakCalculator.currentStreak(days: old.readingDays, today: day(11, 14)), 0)
        XCTAssertEqual(StreakCalculator.longestStreak(days: old.readingDays), 2)
        let summary = StreakSummary(log: old, today: day(11, 14))
        XCTAssertEqual(summary.title, "Your reading days")
        XCTAssertNil(summary.chipText)
    }

    func testATimeZoneChangeNeverBreaksOrInventsADay() {
        // The child reads in New York on the evening of the 12th and 13th, then flies to Tokyo.
        var newYork = Calendar(identifier: .gregorian)
        newYork.timeZone = TimeZone(identifier: "America/New_York") ?? TimeZone(secondsFromGMT: 0)!
        var tokyo = Calendar(identifier: .gregorian)
        tokyo.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? TimeZone(secondsFromGMT: 0)!

        func evening(_ day: Int) -> Date {
            var parts = DateComponents()
            parts.year = 2026
            parts.month = 11
            parts.day = day
            parts.hour = 20
            return newYork.date(from: parts) ?? Date(timeIntervalSince1970: 0)
        }

        var log = ReadingLogFile()
        log.recordPageRead(storyID: monkey, spreadID: SpreadID("s01"), on: ReadingDay(date: evening(12), calendar: newYork))
        log.recordPageRead(storyID: monkey, spreadID: SpreadID("s02"), on: ReadingDay(date: evening(13), calendar: newYork))
        // The stored days are the days the child saw: the 12th and the 13th, whatever zone
        // the device is in when the log is read again.
        XCTAssertEqual(log.readingDays, [day(11, 12), day(11, 13)])

        // Ten hours later the device is on Tokyo time: it is the evening of the 14th there
        // (and early morning on the 14th in New York).
        let later = evening(13).addingTimeInterval(10 * 3600)
        let todayInTokyo = ReadingDay(date: later, calendar: tokyo)
        XCTAssertEqual(todayInTokyo, day(11, 14))
        XCTAssertEqual(StreakCalculator.currentStreak(days: log.readingDays, today: todayInTokyo), 2)
        log.recordPageRead(storyID: monkey, spreadID: SpreadID("s03"), on: todayInTokyo)
        XCTAssertEqual(StreakCalculator.currentStreak(days: log.readingDays, today: todayInTokyo), 3)

        // Flying the other way can make "today" repeat a date already read: still one day, once.
        let backInNewYork = ReadingDay(date: later, calendar: newYork)
        XCTAssertEqual(backInNewYork, day(11, 14))
        log.recordPageRead(storyID: monkey, spreadID: SpreadID("s04"), on: backInNewYork)
        XCTAssertEqual(log.readingDays.count, 3)
    }

    func testAStreakRunsAcrossAWeekBoundary() {
        // Friday 13 to Tuesday 17 November 2026: Sunday → Monday is crossed.
        let days = [day(11, 13), day(11, 14), day(11, 15), day(11, 16), day(11, 17)]
        let log = makeLog(readingOn: days)
        XCTAssertEqual(StreakCalculator.currentStreak(days: log.readingDays, today: day(11, 17)), 5)
        // The week row shows only the new week: Monday and Tuesday ticked, the rest still to come.
        let summary = StreakSummary(log: log, today: day(11, 17))
        XCTAssertEqual(summary.title, "5 days in a row")
        XCTAssertEqual(summary.chipText, "5 days")
        XCTAssertEqual(summary.week.map(\.day), (16...22).map { day(11, $0) })
        XCTAssertEqual(summary.week.map(\.letter), ["M", "T", "W", "T", "F", "S", "S"])
        XCTAssertEqual(summary.week.map(\.isRead), [true, true, false, false, false, false, false])
        XCTAssertEqual(summary.week.map(\.isToday), [false, true, false, false, false, false, false])
        XCTAssertEqual(summary.week.map(\.isFuture), [false, false, true, true, true, true, true])
        XCTAssertTrue(summary.readToday)
    }

    func testAStreakRunsAcrossAMonthAndAYear() {
        var days: [ReadingDay] = []
        var cursor = ReadingDay(year: 2026, month: 12, day: 29)
        for _ in 0..<6 {
            days.append(cursor)
            cursor = cursor.adding(days: 1)
        }
        let log = makeLog(readingOn: days)
        XCTAssertEqual(StreakCalculator.currentStreak(days: log.readingDays, today: ReadingDay(year: 2027, month: 1, day: 3)), 6)
    }

    func testWeekContainingADay() {
        // Saturday 14 November 2026 → Monday 9 to Sunday 15.
        XCTAssertEqual(StreakCalculator.week(containing: day(11, 14)), (9...15).map { day(11, $0) })
        // A Monday starts its own week; a Sunday ends it.
        XCTAssertEqual(StreakCalculator.week(containing: day(11, 9)).first, day(11, 9))
        XCTAssertEqual(StreakCalculator.week(containing: day(11, 15)).last, day(11, 15))
        // Across a month.
        XCTAssertEqual(StreakCalculator.week(containing: day(12, 1)).first, day(11, 30))
    }

    func testStreakWordsAreGentle() {
        let none = StreakSummary(log: ReadingLogFile(), today: day(11, 14))
        XCTAssertEqual(none.count, 0)
        XCTAssertEqual(none.title, "Your reading days")
        XCTAssertNil(none.chipText)
        XCTAssertFalse(none.readToday)
        let one = StreakSummary(log: makeLog(readingOn: [day(11, 14)]), today: day(11, 14))
        XCTAssertEqual(one.title, "1 day of reading")
        XCTAssertEqual(one.chipText, "1 day")
        let three = StreakSummary(log: makeLog(readingOn: [day(11, 12), day(11, 13), day(11, 14)]), today: day(11, 14))
        XCTAssertEqual(three.title, "3 days in a row")

        // No pressure and no loss-shaming in any state.
        let unkind = ["lost", "lose", "broke", "missed", "hurry", "don't", "only", "left", "fail"]
        for summary in [none, one, three] {
            let words = (summary.title + " " + (summary.chipText ?? "") + " " + StreakSummary.caption).lowercased()
            for word in unkind {
                XCTAssertFalse(words.contains(word), "\"\(words)\" contains \"\(word)\"")
            }
        }
    }

    func testFinishedStories() {
        var log = ReadingLogFile()
        XCTAssertTrue(log.markFinished(monkey))
        XCTAssertFalse(log.markFinished(monkey), "finishing again is not a second finish")
        XCTAssertTrue(log.markFinished(anansi))
        XCTAssertEqual(log.finished, [monkey, anansi])
        XCTAssertTrue(log.isFinished(monkey))
        XCTAssertFalse(log.isFinished(StoryID("urashima-taro")))
    }

    func testTheLogStoresDatesStoriesAndPagesAndNothingElse() throws {
        var log = ReadingLogFile()
        log.recordPageRead(storyID: monkey, spreadID: SpreadID("s01"), on: day(11, 14))
        log.markFinished(monkey)
        let data = try JSONEncoder().encode(log)
        let text = try XCTUnwrap(String(data: data, encoding: .utf8)).lowercased()
        for banned in ["time", "hour", "minute", "second", "duration", "timer", "elapsed", "stamp"] {
            XCTAssertFalse(text.contains(banned), "the stored log mentions \"\(banned)\"")
        }
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(Set(object.keys), ["schemaVersion", "entries", "finished", "earlierPages"])
        let entry = try XCTUnwrap((object["entries"] as? [[String: Any]])?.first)
        XCTAssertEqual(Set(entry.keys), ["day", "storyID", "spreadID"])
        XCTAssertEqual(try JSONDecoder().decode(ReadingLogFile.self, from: data), log)
    }

    func testOldEntriesAreDroppedButStillCounted() {
        var log = ReadingLogFile()
        let start = ReadingDay(year: 2025, month: 1, day: 1)
        log.recordPageRead(storyID: monkey, spreadID: SpreadID("s01"), on: start)
        log.recordPageRead(storyID: monkey, spreadID: SpreadID("s02"), on: start.adding(days: 1))
        // More than 400 days later.
        log.recordPageRead(storyID: monkey, spreadID: SpreadID("s03"), on: start.adding(days: 500))
        XCTAssertEqual(log.entries.count, 1)
        XCTAssertEqual(log.earlierPages, 2)
        XCTAssertEqual(log.totalPagesRead, 3)
    }
}

// MARK: - Shelf and friends

final class ShelfAndFriendsTests: XCTestCase {
    private func library() throws -> Library {
        try BundledContent.repository().loadLibrary()
    }

    func testEmptyStoresGiveAnEmptyShelf() throws {
        let shelf = ShelfState(stories: try library().stories, progress: ReadingProgressFile(), log: ReadingLogFile())
        XCTAssertTrue(shelf.isEmpty)
        XCTAssertNil(shelf.keepReading)
        XCTAssertTrue(shelf.alsoReading.isEmpty)
        XCTAssertTrue(shelf.finished.isEmpty)
        XCTAssertNil(shelf.summary)
    }

    func testKeepReadingIsTheStoryReadLastAtItsSavedPage() throws {
        let stories = try library().stories
        let monkey = try XCTUnwrap(stories.first { $0.id == StoryID("monkey-and-crocodile") })
        let urashima = try XCTUnwrap(stories.first { $0.id == StoryID("urashima-taro") })
        var progress = ReadingProgressFile()
        progress.record(ReadingPosition(storyID: monkey.id, spreadID: monkey.spreads[2].id))
        progress.record(ReadingPosition(storyID: urashima.id, spreadID: urashima.spreads[4].id))

        let shelf = ShelfState(stories: stories, progress: progress, log: ReadingLogFile())
        XCTAssertFalse(shelf.isEmpty)
        XCTAssertEqual(shelf.keepReading?.storyID, urashima.id)
        XCTAssertEqual(shelf.keepReading?.page, 5)
        XCTAssertEqual(shelf.keepReading?.pageCount, urashima.spreads.count)
        XCTAssertEqual(shelf.keepReading?.fraction ?? 0, 5.0 / Double(urashima.spreads.count), accuracy: 0.0001)
        XCTAssertEqual(shelf.alsoReading.map(\.storyID), [monkey.id])
        XCTAssertEqual(shelf.alsoReading.first?.page, 3)
    }

    func testASavedPlaceOnAPageThatNoLongerExistsIsLeftOut() throws {
        let stories = try library().stories
        var progress = ReadingProgressFile()
        progress.record(ReadingPosition(storyID: stories[0].id, spreadID: SpreadID("no-such-page")))
        progress.record(ReadingPosition(storyID: StoryID("no-such-story"), spreadID: SpreadID("s01")))
        let shelf = ShelfState(stories: stories, progress: progress, log: ReadingLogFile())
        XCTAssertNil(shelf.keepReading)
        XCTAssertTrue(shelf.alsoReading.isEmpty)
    }

    func testFinishedStoriesAndPagesRead() throws {
        let stories = try library().stories
        var log = ReadingLogFile()
        let today = ReadingDay(year: 2026, month: 11, day: 14)
        log.recordPageRead(storyID: stories[0].id, spreadID: stories[0].spreads[0].id, on: today)
        XCTAssertEqual(ShelfState(stories: stories, progress: ReadingProgressFile(), log: log).summary, "1 page read")
        log.recordPageRead(storyID: stories[0].id, spreadID: stories[0].spreads[1].id, on: today)
        log.markFinished(stories[0].id)
        // A finished story that has left the catalog is not shown.
        log.markFinished(StoryID("retired-story"))
        let shelf = ShelfState(stories: stories, progress: ReadingProgressFile(), log: log)
        XCTAssertEqual(shelf.finished, [stories[0].id])
        XCTAssertEqual(shelf.pagesRead, 2)
        XCTAssertEqual(shelf.summary, "1 story finished · 2 pages read")
        log.markFinished(stories[1].id)
        XCTAssertEqual(ShelfState(stories: stories, progress: ReadingProgressFile(), log: log).summary, "2 stories finished · 2 pages read")
    }

    func testFriendsMetComeFromTheReaderMemoryInCatalogOrder() throws {
        let stories = try library().stories
        var memory = ReaderMemoryFile()
        XCTAssertTrue(FriendMet.all(stories: stories, memory: memory).isEmpty)

        memory.recordMet([CharacterID("urashima"), CharacterID("tortoise")], in: StoryID("urashima-taro"))
        memory.recordMet([CharacterID("mother-crocodile"), CharacterID("monkey")], in: StoryID("monkey-and-crocodile"))
        // An id the story no longer has is skipped.
        memory.recordMet([CharacterID("nobody")], in: StoryID("anansi-wisdom"))

        let friends = FriendMet.all(stories: stories, memory: memory)
        XCTAssertEqual(friends.map(\.character.id.rawValue), ["mother-crocodile", "monkey", "urashima", "tortoise"])
        XCTAssertEqual(friends.map(\.shortName), ["Mother Crocodile", "Monkey", "Urashima", "Tortoise"])
        XCTAssertEqual(Set(friends.map(\.id)).count, friends.count)
    }

    func testShortNames() {
        XCTAssertEqual(FriendMet.shortName(for: "Monkey"), "Monkey")
        XCTAssertEqual(FriendMet.shortName(for: "the tortoise"), "Tortoise")
        XCTAssertEqual(FriendMet.shortName(for: "Father Anansi"), "Anansi")
        XCTAssertEqual(FriendMet.shortName(for: "Kweku Tsin"), "Kweku Tsin")
        XCTAssertEqual(FriendMet.shortName(for: "Princess Otohime"), "Otohime")
        XCTAssertEqual(FriendMet.shortName(for: "Urashima Taro"), "Urashima")
        XCTAssertEqual(FriendMet.shortName(for: "Mother Crocodile"), "Mother Crocodile")
        XCTAssertEqual(FriendMet.shortName(for: ""), "")
    }

    func testEveryBundledCharacterHasAShortNameThatFits() throws {
        for story in try library().stories {
            for character in story.characters {
                let name = FriendMet.shortName(for: character.name)
                XCTAssertFalse(name.isEmpty, "\(story.id) \(character.id)")
                XCTAssertLessThanOrEqual(name.count, 16, "\(story.id) \(character.id): \(name)")
            }
        }
    }
}
