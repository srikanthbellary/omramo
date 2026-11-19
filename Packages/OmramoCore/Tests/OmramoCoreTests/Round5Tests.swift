import Foundation
import XCTest
@testable import OmramoCore

// Round 5 (the stories round): the catalog grows toward the 32 planned stories
// (docs/CONTENT_PLAN.md). These tests hold every catalog story to the same rules — it decodes,
// validates, has its manuscript, a one-sentence moral, tap words, a character card, art
// references for every spread and the landmarks the plan gives it — and check the flag
// "needs cultural review before release", the library's shelves, the crowded story map and
// the next-story choice across the bigger catalog.

/// The plan, as data (docs/CONTENT_PLAN.md §3, §6 and §7).
enum ContentPlan {
    /// All 32 planned stories in plan order: Low, then Medium, then Advanced.
    static let order: [String] = [
        // Low (11)
        "monkey-and-crocodile", "shipwrecked-sailor", "tongue-cut-sparrow", "old-man-who-moved-mountains",
        "why-possums-tail-is-bare", "the-snow-house", "peasant-and-bear", "bremen-town-musicians",
        "north-wind-and-sun", "why-sun-and-moon-live-in-sky", "lion-and-hare",
        // Medium (11)
        "tiger-brahman-jackal", "khufu-and-the-magician", "bamboo-cutter-and-moon-child",
        "herd-boy-and-weaving-maiden", "iktomi-and-the-muskrat", "long-day-at-fish-camp", "sadko",
        "androcles-and-the-lion", "horse-and-the-olive", "anansi-wisdom", "sindbad-second-voyage",
        // Advanced (10)
        "savitri-and-satyavan", "eloquent-peasant", "urashima-taro", "ballad-of-mulan", "the-two-sisters",
        "woman-who-raised-a-bear", "firebird-and-horse-of-power", "daedalus-and-icarus",
        "the-griots-apprentice", "zal-and-the-simurgh",
    ]

    /// Round 5, batch 1: the eleven Low stories and the two older prototypes.
    static let batchOne: [String] = [
        "monkey-and-crocodile", "shipwrecked-sailor", "tongue-cut-sparrow", "old-man-who-moved-mountains",
        "why-possums-tail-is-bare", "the-snow-house", "peasant-and-bear", "bremen-town-musicians",
        "north-wind-and-sun", "why-sun-and-moon-live-in-sky", "lion-and-hare",
        "anansi-wisdom", "urashima-taro",
    ]

    /// Round 5, batch 2: the ten new Medium stories (M1–M9 and M11; M10 is the Anansi prototype).
    static let batchTwo: [String] = [
        "tiger-brahman-jackal", "khufu-and-the-magician", "bamboo-cutter-and-moon-child",
        "herd-boy-and-weaving-maiden", "iktomi-and-the-muskrat", "long-day-at-fish-camp", "sadko",
        "androcles-and-the-lion", "horse-and-the-olive", "sindbad-second-voyage",
    ]

    /// Round 5, batch 3: the nine new Advanced stories (A1, A2, A4–A10; A3 is the Urashima prototype).
    static let batchThree: [String] = [
        "savitri-and-satyavan", "eloquent-peasant", "ballad-of-mulan", "the-two-sisters",
        "woman-who-raised-a-bear", "firebird-and-horse-of-power", "daedalus-and-icarus",
        "the-griots-apprentice", "zal-and-the-simurgh",
    ]

    /// §7: the twelve stories that must carry the flag "needs cultural review before release".
    static let requiredReview: Set<String> = [
        "monkey-and-crocodile", "savitri-and-satyavan", "lion-and-hare", "why-possums-tail-is-bare",
        "iktomi-and-the-muskrat", "the-two-sisters", "the-snow-house", "long-day-at-fish-camp",
        "woman-who-raised-a-bear", "why-sun-and-moon-live-in-sky", "anansi-wisdom", "the-griots-apprentice",
    ]

    /// The three originals written by us.
    static let originals: Set<String> = ["the-snow-house", "long-day-at-fish-camp", "the-griots-apprentice"]

    /// §6: the landmarks each story weaves in (an empty list: none, by design). Stories of
    /// later batches are added here with their stories.
    static let landmarks: [String: [String]] = [
        "monkey-and-crocodile": ["taj-mahal"],
        "shipwrecked-sailor": ["sydney-opera-house", "lighthouse-of-alexandria"],
        "tongue-cut-sparrow": ["himeji-castle"],
        "old-man-who-moved-mountains": ["great-wall-of-china", "machu-picchu"],
        "why-possums-tail-is-bare": [],
        "the-snow-house": ["hagia-sophia"],
        "peasant-and-bear": ["saint-basils-cathedral"],
        "bremen-town-musicians": ["bremen-town-hall-roland"],
        "north-wind-and-sun": ["colossus-of-rhodes", "statue-of-liberty"],
        "why-sun-and-moon-live-in-sky": [],
        "lion-and-hare": ["petra"],
        // Batch 2 (§6.2), in the order the story meets them.
        "tiger-brahman-jackal": [],
        "khufu-and-the-magician": ["great-pyramid-giza", "chichen-itza"],
        "bamboo-cutter-and-moon-child": ["mount-fuji"],
        "herd-boy-and-weaving-maiden": ["golden-gate-bridge"],
        "iktomi-and-the-muskrat": [],
        "long-day-at-fish-camp": [],
        "sadko": ["novgorod-kremlin", "christ-the-redeemer"],
        "androcles-and-the-lion": ["temple-of-artemis-ephesus", "colosseum"],
        "horse-and-the-olive": ["statue-of-zeus-olympia", "parthenon"],
        "sindbad-second-voyage": ["hanging-gardens-babylon", "burj-khalifa"],
        "anansi-wisdom": ["asante-traditional-buildings"],
        "urashima-taro": ["tokyo-skytree"],
        // Batch 3 (§6.3), in the order the story meets them.
        "savitri-and-satyavan": ["angkor-wat"],
        "eloquent-peasant": ["bibliotheca-alexandrina"],
        "ballad-of-mulan": ["great-wall-of-china", "forbidden-city"],
        "the-two-sisters": ["lions-gate-bridge"],
        "woman-who-raised-a-bear": ["ilulissat-icefjord"],
        "firebird-and-horse-of-power": ["kizhi-pogost"],
        "daedalus-and-icarus": ["palace-of-knossos", "eiffel-tower"],
        "the-griots-apprentice": ["great-mosque-of-djenne"],
        "zal-and-the-simurgh": ["persepolis", "mausoleum-halicarnassus"],
    ]

    /// §5.1: the 37 landmarks of the plan.
    static let landmarkIDs: Set<String> = [
        "great-pyramid-giza", "hanging-gardens-babylon", "statue-of-zeus-olympia", "temple-of-artemis-ephesus",
        "mausoleum-halicarnassus", "colossus-of-rhodes", "lighthouse-of-alexandria", "great-wall-of-china",
        "petra", "christ-the-redeemer", "machu-picchu", "chichen-itza", "colosseum", "taj-mahal",
        "palace-of-knossos", "persepolis", "parthenon", "hagia-sophia", "novgorod-kremlin", "angkor-wat",
        "bremen-town-hall-roland", "forbidden-city", "saint-basils-cathedral", "himeji-castle", "kizhi-pogost",
        "asante-traditional-buildings", "statue-of-liberty", "eiffel-tower", "great-mosque-of-djenne",
        "golden-gate-bridge", "lions-gate-bridge", "sydney-opera-house", "bibliotheca-alexandrina",
        "burj-khalifa", "tokyo-skytree", "mount-fuji", "ilulissat-icefjord",
    ]

    /// Most words a moral may have, by level (round 5: short, concrete, one sentence).
    static func moralWordLimit(_ tier: Tier) -> Int {
        tier == .low ? 14 : 18
    }

    static func bundledLibrary() throws -> Library {
        try SampleContent.repository().loadLibrary()
    }
}

// MARK: - The catalog

final class CatalogPlanTests: XCTestCase {
    func testThePlanListsThirtyTwoStories() {
        XCTAssertEqual(ContentPlan.order.count, 32)
        XCTAssertEqual(Set(ContentPlan.order).count, 32)
        XCTAssertEqual(ContentPlan.requiredReview.count, 12)
        XCTAssertTrue(ContentPlan.requiredReview.isSubset(of: Set(ContentPlan.order)))
        XCTAssertTrue(ContentPlan.originals.isSubset(of: Set(ContentPlan.order)))
        XCTAssertEqual(ContentPlan.landmarkIDs.count, 37)
    }

    func testTheCatalogIsInPlanOrderAndHoldsBatchOne() throws {
        let catalog = try SampleContent.repository().loadCatalog().stories.map(\.rawValue)
        XCTAssertEqual(Set(catalog).count, catalog.count)
        // Only planned stories, in the plan's order.
        XCTAssertEqual(catalog, ContentPlan.order.filter { catalog.contains($0) })
        // Batch 1 is all there (later batches only add).
        for id in ContentPlan.batchOne {
            XCTAssertTrue(catalog.contains(id), "\(id) is missing from the catalog")
        }
        XCTAssertGreaterThanOrEqual(catalog.count, 13)
        XCTAssertLessThanOrEqual(catalog.count, 32)
        // Batch 2 is all there too: 23 stories after it.
        for id in ContentPlan.batchTwo {
            XCTAssertTrue(catalog.contains(id), "\(id) is missing from the catalog")
        }
        XCTAssertGreaterThanOrEqual(catalog.count, 23)
    }

    func testEveryPlannedMediumStoryIsInTheCatalog() throws {
        let library = try ContentPlan.bundledLibrary()
        let medium = library.stories.filter { $0.tier == .medium }.map(\.id.rawValue)
        XCTAssertEqual(medium, Array(ContentPlan.order[11..<22]))
        XCTAssertEqual(Set(ContentPlan.batchTwo).union(["anansi-wisdom"]), Set(medium))
        // One Medium story from every region, and two from Europe (Roman and Greek).
        let regions = library.stories.filter { $0.tier == .medium }.map(\.region.id)
        XCTAssertEqual(Set(regions), Set(RegionID.allCases))
        XCTAssertEqual(regions.filter { $0 == .european }.count, 2)
    }

    func testTheNewMediumStoriesAreLevelledLikeTheAnansiStory() throws {
        let library = try ContentPlan.bundledLibrary()
        for story in library.stories where story.tier == .medium {
            let id = story.id.rawValue
            let isNew = ContentPlan.batchTwo.contains(id)
            // Anansi has 8 pages; the plan gives a Medium story 8 to 10.
            XCTAssertGreaterThanOrEqual(story.spreads.count, 8, id)
            XCTAssertLessThanOrEqual(story.spreads.count, 10, id)
            XCTAssertEqual(story.sample.freeSpreads, 2, id)
            XCTAssertEqual(Set(story.spreads.map(\.scene.unfolded.assetName)).count, 4, id)
            for spread in story.spreads {
                // About 90 words a page; never a wall of text.
                XCTAssertLessThanOrEqual(spread.wordCount, 118, "\(id) \(spread.id)")
                XCTAssertGreaterThanOrEqual(spread.wordCount, 40, "\(id) \(spread.id)")
                XCTAssertLessThanOrEqual(spread.blocks.count, 6, "\(id) \(spread.id)")
                XCTAssertTrue(spread.blocks.allSatisfy { $0.pane == .leading && $0.kind == .paragraph }, "\(id) \(spread.id)")
                let taps = spread.blocks.flatMap(\.runs).filter { $0.tapTarget != nil }
                XCTAssertLessThanOrEqual(taps.count, 1, "\(id) \(spread.id)")
            }
            XCTAssertTrue(story.spreads[0].blocks[0].runs.allSatisfy(\.isLead), id)
            // One ink a story: the three chrome styles agree (all light, or all dark like Anansi).
            XCTAssertEqual(story.theme.chrome.leading, story.theme.chrome.trailing, id)
            XCTAssertEqual(story.theme.chrome.leading, story.theme.chrome.folded, id)
            if isNew {
                XCTAssertEqual(story.parts.count, 2, id)
                // A place card and "how people live there" (CONTENT_PLAN §4.2): three or more.
                XCTAssertGreaterThanOrEqual(story.tapTargets.filter { $0.kind != .landmark }.count, 3, id)
                XCTAssertEqual(story.characters.filter { $0.card != nil }.count, 2, id)
                // The first page of Part II opens with a lead line too.
                let second = try XCTUnwrap(story.spreads.first { $0.part == story.parts[1].id }, id)
                XCTAssertTrue(second.blocks[0].runs.allSatisfy(\.isLead), id)
            }
        }
    }

    func testTheFishCampStoryTeachesAlaskaCorrectly() throws {
        // CONTENT_PLAN §1.4: a present-day Yup'ik summer story with no snow house in it; a card
        // says what the winter houses were built of.
        let story = try XCTUnwrap(try ContentPlan.bundledLibrary().story(id: StoryID("long-day-at-fish-camp")))
        XCTAssertEqual(story.region.id, .arctic)
        XCTAssertTrue(story.region.culture.contains("Yup"))
        XCTAssertTrue(story.region.place.contains("Alaska"))
        XCTAssertNil(story.setting.latestYear, "a present-day story")
        XCTAssertEqual(story.provenance.kind, .original)
        let text = story.spreads.flatMap(\.blocks).map(\.plainText).joined(separator: " ").lowercased()
        XCTAssertFalse(text.contains("snow house"))
        XCTAssertFalse(text.contains("midnight sun"), "at 61° N the June sun dips below the horizon")
        let sod = try XCTUnwrap(story.tapTargets.first { $0.id.rawValue == "sod-house" })
        XCTAssertTrue((sod.cultureNote?.text ?? "").lowercased().contains("sod"))
        XCTAssertTrue(story.landmarkIDs.isEmpty)
    }

    func testEveryPlannedLowStoryIsInTheCatalog() throws {
        let library = try ContentPlan.bundledLibrary()
        let low = library.stories.filter { $0.tier == .low }.map(\.id.rawValue)
        XCTAssertEqual(low, Array(ContentPlan.order.prefix(11)))
        // One Low story from every region, and two from Europe (German and Greek).
        let regions = library.stories.filter { $0.tier == .low }.map(\.region.id)
        XCTAssertEqual(Set(regions), Set(RegionID.allCases))
        XCTAssertEqual(regions.filter { $0 == .european }.count, 2)
    }

    func testEveryCatalogStoryDecodesAndValidatesWithItsManuscript() throws {
        let repository = try SampleContent.repository()
        let landmarks = try repository.loadLandmarks()
        for id in try repository.loadCatalog().stories {
            let story = try repository.loadStory(id: id)
            XCTAssertEqual(story.id, id)
            XCTAssertEqual(story.schemaVersion, 1, "\(id)")
            XCTAssertEqual(story.language, "en", "\(id)")
            let manuscript = try XCTUnwrap(try repository.loadManuscript(id: id), "\(id) has no manuscript")
            let report = StoryValidator().validate(story: story, landmarks: landmarks, manuscript: manuscript)
            XCTAssertEqual(report.errors, [], "\(id)")
            XCTAssertFalse(report.contains(.wordsPerSpread), "\(id): a page is too long for its level")
            XCTAssertFalse(report.contains(.unusedTapTarget), "\(id): a tap target is on no word")
            XCTAssertFalse(report.contains(.tooManyLandmarks), "\(id)")
            XCTAssertNil(TextFidelity.compare(story: story, manuscript: manuscript), "\(id)")
        }
    }

    func testEveryStoryHasAMoralOfOneShortSentence() throws {
        let library = try ContentPlan.bundledLibrary()
        for story in library.stories {
            let id = story.id.rawValue
            XCTAssertNil(MoralRule.problem(in: story.moral), id)
            let moral = try XCTUnwrap(story.moral, id)
            XCTAssertEqual(moral, moral.trimmingCharacters(in: .whitespacesAndNewlines), id)
            let words = moral.split(separator: " ").count
            XCTAssertLessThanOrEqual(words, ContentPlan.moralWordLimit(story.tier), "\(id): “\(moral)”")
            XCTAssertGreaterThanOrEqual(words, 4, id)
            XCTAssertFalse(moral.contains(";"), "\(id): one clear sentence, no semicolon")
            XCTAssertFalse(moral.contains("—"), id)
            XCTAssertTrue(moral.hasSuffix("."), "\(id): a moral is a plain statement")
            // The editor-facing lesson and a question to talk about are there too.
            XCTAssertFalse(story.education.moral.lesson.trimmingCharacters(in: .whitespaces).isEmpty, id)
            XCTAssertFalse((story.education.moral.reflectionQuestion ?? "").isEmpty, id)
        }
        // Every story leaves something of its own.
        XCTAssertEqual(Set(library.stories.compactMap(\.moral)).count, library.stories.count)
    }

    func testThePolishedMoralsOfTheThreePrototypes() throws {
        let library = try ContentPlan.bundledLibrary()
        XCTAssertEqual(library.story(id: StoryID("monkey-and-crocodile"))?.moral, "When you are in trouble, stay calm and think.")
        XCTAssertEqual(library.story(id: StoryID("anansi-wisdom"))?.moral, "Nobody has all the wisdom, so even a child can teach a grown-up.")
        XCTAssertEqual(library.story(id: StoryID("urashima-taro"))?.moral, "Be kind and keep your promises, for lost time never comes back.")
    }

    func testEveryStoryHasTapWordsACharacterCardAndItsPlannedLandmarks() throws {
        let library = try ContentPlan.bundledLibrary()
        for story in library.stories {
            let id = story.id.rawValue
            // Every tap word opens a card; a name opens one when its character has a card (a
            // name with no card is not tappable).
            let marked = Set(story.spreads.flatMap(\.blocks).flatMap(\.cardRefs)).filter { ref in
                if case .character(let characterID) = ref {
                    return story.character(id: characterID)?.card != nil
                }
                return true
            }
            let cards = marked.compactMap { story.cardContent(for: $0, landmarks: library.landmarks) }
            XCTAssertEqual(cards.count, marked.count, "\(id): a marked word opens no card")

            // Ordinary tap-to-see words: at least as many as the Monkey story has (two).
            let ordinary = story.tapTargets.filter { $0.kind != .landmark }
            XCTAssertGreaterThanOrEqual(ordinary.count, 2, id)
            XCTAssertTrue(ordinary.contains { $0.kind == .place }, "\(id): no place card (geography)")
            for target in ordinary {
                XCTAssertFalse((target.cultureNote?.text ?? "").isEmpty, "\(id) \(target.id): no culture note")
            }

            // At least one character card, opened by a name in the text.
            XCTAssertTrue(cards.contains { content in
                if case .character = content { return true }
                return false
            }, "\(id): no character name opens a card")
            XCTAssertTrue(story.characters.contains { $0.card != nil }, id)

            // Landmarks exactly as the plan's story → landmark map says.
            let planned = try XCTUnwrap(ContentPlan.landmarks[id], "\(id) is not in the test's landmark map")
            XCTAssertEqual(story.landmarkIDs.map(\.rawValue), planned, id)
            for landmarkID in story.landmarkIDs {
                XCTAssertNotNil(library.landmarks.landmark(id: landmarkID), "\(id): \(landmarkID) is not in the catalog")
            }
        }
    }

    func testEverySpreadNamesArtForBothShapes() throws {
        let library = try ContentPlan.bundledLibrary()
        for story in library.stories {
            let id = story.id.rawValue
            XCTAssertEqual(story.cover.assetName, "cover", id)
            XCTAssertFalse(story.cover.alt.isEmpty, id)
            for spread in story.spreads {
                let scene = spread.scene
                XCTAssertTrue(scene.unfolded.assetName.hasPrefix("scene-"), "\(id) \(spread.id)")
                // One picture name, drawn for the wide shape and for the phone's band.
                XCTAssertEqual(scene.unfolded.assetName, scene.folded.assetName, "\(id) \(spread.id)")
                XCTAssertFalse(scene.unfolded.alt.isEmpty, "\(id) \(spread.id)")
                XCTAssertFalse(scene.folded.alt.isEmpty, "\(id) \(spread.id)")
                XCTAssertEqual(scene.fallbackColors.count, 3, "\(id) \(spread.id)")
            }
            for character in story.characters {
                // The Anansi prototype names Kweku Tsin's art by his short name ("face-kweku").
                let exactNames = !(id == "anansi-wisdom" && character.id.rawValue == "kweku-tsin")
                XCTAssertTrue(character.face.assetName.hasPrefix("face-"), id)
                if exactNames {
                    XCTAssertEqual(character.face.assetName, "face-" + character.id.rawValue, id)
                }
                if let card = character.card {
                    XCTAssertTrue(card.portrait.assetName.hasPrefix("char-"), id)
                    if exactNames {
                        XCTAssertEqual(card.portrait.assetName, "char-" + character.id.rawValue, id)
                    }
                    XCTAssertEqual(card.traits.count, 3, "\(id) \(character.id)")
                    XCTAssertEqual(card.background.count, 3, "\(id) \(character.id)")
                }
            }
            for target in story.tapTargets {
                if let picture = target.picture {
                    XCTAssertEqual(picture.assetName, "see-" + target.id.rawValue, id)
                }
            }
            // A tap target and a character never share an id: both become `word.<id>` and
            // `card.<id>` for the UI tests and for `-OmramoOpenCard`.
            let characterIDs = Set(story.characters.map(\.id.rawValue))
            for target in story.tapTargets {
                XCTAssertFalse(characterIDs.contains(target.id.rawValue), "\(id): “\(target.id)” names a card twice")
            }
        }
    }

    func testTheNewLowStoriesAreLevelledLikeTheMonkeyStory() throws {
        let library = try ContentPlan.bundledLibrary()
        let monkey = try XCTUnwrap(library.story(id: StoryID("monkey-and-crocodile")))
        for story in library.stories where story.tier == .low {
            let id = story.id.rawValue
            XCTAssertGreaterThanOrEqual(story.spreads.count, 12, id)
            XCTAssertLessThanOrEqual(story.spreads.count, monkey.spreads.count, id)
            XCTAssertEqual(story.parts.count, 2, id)
            XCTAssertEqual(story.sample.freeSpreads, 2, id)
            // Four scenes, as the Monkey story has.
            XCTAssertEqual(Set(story.spreads.map(\.scene.unfolded.assetName)).count, 4, id)
            for spread in story.spreads {
                XCTAssertLessThanOrEqual(spread.wordCount, 75, "\(id) \(spread.id)")
                XCTAssertGreaterThanOrEqual(spread.wordCount, 20, "\(id) \(spread.id)")
                XCTAssertLessThanOrEqual(spread.blocks.count, 5, "\(id) \(spread.id)")
                // A Low page keeps its words on the leading pane; the picture has the other.
                XCTAssertTrue(spread.blocks.allSatisfy { $0.pane == .leading && $0.kind == .paragraph }, "\(id) \(spread.id)")
                // At most one tap-to-see word a page.
                let taps = spread.blocks.flatMap(\.runs).filter { $0.tapTarget != nil }
                XCTAssertLessThanOrEqual(taps.count, 1, "\(id) \(spread.id)")
            }
            // The first page opens with a lead line.
            XCTAssertTrue(story.spreads[0].blocks[0].runs.allSatisfy(\.isLead), id)
            // Dark ink on a pale sky, on every page (one text colour a story).
            XCTAssertEqual(story.theme.chrome.leading, .light, id)
            XCTAssertEqual(story.theme.chrome.folded, .light, id)
        }
    }

    func testTheOriginalsAreLabelledAsOurs() throws {
        let library = try ContentPlan.bundledLibrary()
        for story in library.stories {
            let id = story.id.rawValue
            if ContentPlan.originals.contains(id) {
                XCTAssertEqual(story.provenance.kind, .original, id)
                XCTAssertEqual(story.provenance.credit, Brand.originalStoryCredit, id)
                XCTAssertFalse((story.provenance.premise ?? "").isEmpty, id)
            } else {
                XCTAssertEqual(story.provenance.kind, .publicDomainRetelling, id)
                XCTAssertEqual(story.provenance.textBasis, .omramoRetelling, id)
                XCTAssertFalse((story.provenance.sources ?? []).isEmpty, id)
            }
            XCTAssertEqual(story.review.text.status, .pending, id)
            XCTAssertEqual(story.review.art.status, .pending, id)
        }
        let snowHouse = try XCTUnwrap(library.story(id: StoryID("the-snow-house")))
        XCTAssertEqual(snowHouse.provenance.kind, .original)
        XCTAssertNil(snowHouse.setting.latestYear, "a present-day story")
    }

    func testNoWordTheAppShowsUsesTheOldNameForArcticPeoples() throws {
        // CONTENT_PLAN §1.3: never "Eskimo" in app text (old source titles in the provenance
        // record are the one place the word may stand).
        let library = try ContentPlan.bundledLibrary()
        var shown: [String] = []
        for story in library.stories {
            shown.append(story.title)
            shown.append(story.region.label)
            shown.append(story.moral ?? "")
            shown.append(contentsOf: story.spreads.flatMap(\.blocks).map(\.plainText))
            for character in story.characters {
                shown.append(character.name)
                shown.append(character.card?.body ?? "")
                shown.append(contentsOf: character.card?.traits.map(\.text) ?? [])
            }
            for target in story.tapTargets {
                shown.append(target.title ?? "")
                shown.append(target.line ?? "")
                shown.append(target.cultureNote?.label ?? "")
                shown.append(target.cultureNote?.text ?? "")
                shown.append(target.landmark?.framingDevice?.line ?? "")
            }
        }
        for landmark in library.landmarks.landmarks {
            shown.append(landmark.name)
            for tier in Tier.allCases {
                shown.append(landmark.factCards[tier].line)
                shown.append(landmark.factCards[tier].note ?? "")
            }
        }
        for text in shown {
            XCTAssertFalse(text.lowercased().contains("eskimo"), text)
            XCTAssertFalse(text.lowercased().contains("igloo"), "write “iglu” or “snow house”: \(text)")
        }
    }

    func testTheSnowHouseTeachesTheArcticCorrectly() throws {
        // CONTENT_PLAN §1.4: a Canadian Inuit snow house, in Nunavut, in the present day.
        let story = try XCTUnwrap(try ContentPlan.bundledLibrary().story(id: StoryID("the-snow-house")))
        XCTAssertEqual(story.region.id, .arctic)
        XCTAssertTrue(story.region.culture.contains("Inuit"))
        XCTAssertTrue(story.region.place.contains("Nunavut"))
        let text = story.spreads.flatMap(\.blocks).map(\.plainText).joined(separator: " ")
        XCTAssertFalse(text.contains("Alaska"))
        XCTAssertTrue(text.contains("snow house"))
    }
}

// MARK: - The landmark catalog

final class LandmarkPlanTests: XCTestCase {
    func testEveryLandmarkIsOneOfThePlansThirtySeven() throws {
        let catalog = try SampleContent.landmarks()
        let ids = catalog.landmarks.map(\.id.rawValue)
        XCTAssertEqual(Set(ids).count, ids.count)
        for id in ids {
            XCTAssertTrue(ContentPlan.landmarkIDs.contains(id), "\(id) is not a landmark of CONTENT_PLAN §5.1")
        }
        // Every landmark a batch-1 story weaves in is there.
        for (story, planned) in ContentPlan.landmarks {
            for id in planned {
                XCTAssertNotNil(catalog.landmark(id: LandmarkID(id)), "\(story): \(id)")
            }
        }
    }

    func testEveryLandmarkHasAFactCardForEachLevelAndItsOwnPicture() throws {
        let catalog = try SampleContent.landmarks()
        for landmark in catalog.landmarks {
            let id = landmark.id.rawValue
            for tier in Tier.allCases {
                let line = landmark.factCards[tier].line
                XCTAssertFalse(line.trimmingCharacters(in: .whitespaces).isEmpty, "\(id) \(tier)")
            }
            // The Low card is one short thing to picture.
            XCTAssertLessThanOrEqual(landmark.factCards.low.line.split(separator: " ").count, 22, id)
            XCTAssertEqual(landmark.art.assetName, id)
            XCTAssertFalse(landmark.art.alt.isEmpty, id)
            XCTAssertFalse((landmark.rights ?? "").isEmpty, id)
            if landmark.status == .lost || landmark.status == .unproven {
                XCTAssertEqual(landmark.depiction, .reconstruction, id)
            }
        }
        XCTAssertEqual(StoryValidator().validate(landmarks: catalog).errors, [])
    }

    func testLostWondersOfThisBatchAreReconstructions() throws {
        let catalog = try SampleContent.landmarks()
        for id in ["colossus-of-rhodes", "lighthouse-of-alexandria"] {
            let landmark = try XCTUnwrap(catalog.landmark(id: LandmarkID(id)), id)
            XCTAssertEqual(landmark.status, .lost, id)
            XCTAssertEqual(landmark.depiction, .reconstruction, id)
            XCTAssertTrue(landmark.lists.contains(.ancientSeven), id)
        }
    }

    func testTheWondersOfBatchTwoAreShownHonestly() throws {
        let catalog = try SampleContent.landmarks()
        for id in ["temple-of-artemis-ephesus", "statue-of-zeus-olympia"] {
            let landmark = try XCTUnwrap(catalog.landmark(id: LandmarkID(id)), id)
            XCTAssertEqual(landmark.status, .lost, id)
            XCTAssertEqual(landmark.depiction, .reconstruction, id)
            XCTAssertTrue(landmark.lists.contains(.ancientSeven), id)
        }
        // No trace of the gardens has been found: unproven, and drawn as an idea.
        let gardens = try XCTUnwrap(catalog.landmark(id: LandmarkID("hanging-gardens-babylon")))
        XCTAssertEqual(gardens.status, .unproven)
        XCTAssertEqual(gardens.depiction, .reconstruction)
        // The one Ancient Wonder still standing.
        let pyramid = try XCTUnwrap(catalog.landmark(id: LandmarkID("great-pyramid-giza")))
        XCTAssertEqual(pyramid.status, .standing)
        XCTAssertEqual(pyramid.depiction, .asIs)
        XCTAssertTrue(pyramid.lists.contains(.ancientSeven))
        // A mountain was not built.
        let fuji = try XCTUnwrap(catalog.landmark(id: LandmarkID("mount-fuji")))
        XCTAssertEqual(fuji.era, .natural)
        XCTAssertEqual(fuji.status, .natural)
        XCTAssertNil(fuji.built)
        XCTAssertGreaterThanOrEqual(catalog.landmarks.count, 26)
    }

    func testTheNaturalLandmarksOfBatchTwoBelongToTheirStories() throws {
        // §6.2: Khufu's own pyramid, the mountain the tale ends on, Sadko's own city, and the
        // temple on the hill of the contest (told as "built later" by the narrator).
        let library = try ContentPlan.bundledLibrary()
        let natural: [(story: String, landmark: String)] = [
            ("khufu-and-the-magician", "great-pyramid-giza"),
            ("bamboo-cutter-and-moon-child", "mount-fuji"),
            ("sadko", "novgorod-kremlin"),
            ("horse-and-the-olive", "parthenon"),
        ]
        for pair in natural {
            let story = try XCTUnwrap(library.story(id: StoryID(pair.story)), pair.story)
            let target = try XCTUnwrap(story.tapTargets.first { $0.landmark?.id.rawValue == pair.landmark }, pair.landmark)
            XCTAssertEqual(target.landmark?.appearance, .natural, pair.landmark)
        }
        // Every other landmark of the batch stands outside its story and says how.
        for id in ContentPlan.batchTwo {
            let story = try XCTUnwrap(library.story(id: StoryID(id)), id)
            for target in story.tapTargets where target.kind == .landmark {
                let ref = try XCTUnwrap(target.landmark, id)
                if !natural.contains(where: { $0.story == id && $0.landmark == ref.id.rawValue }) {
                    XCTAssertEqual(ref.appearance, .framed, "\(id) \(ref.id)")
                    XCTAssertNotNil(ref.framingDevice, "\(id) \(ref.id)")
                }
            }
        }
    }

    func testFramedLandmarksNameTheirDevice() throws {
        let library = try ContentPlan.bundledLibrary()
        for story in library.stories {
            for target in story.tapTargets where target.kind == .landmark {
                let ref = try XCTUnwrap(target.landmark, "\(story.id) \(target.id)")
                if ref.appearance == .framed {
                    let device = try XCTUnwrap(ref.framingDevice, "\(story.id) \(target.id)")
                    XCTAssertFalse(device.label.isEmpty, "\(story.id) \(target.id)")
                    XCTAssertFalse(device.line.isEmpty, "\(story.id) \(target.id)")
                }
            }
        }
        // The one natural landmark of the batch: the city the animals are walking to.
        let bremen = try XCTUnwrap(library.story(id: StoryID("bremen-town-musicians")))
        XCTAssertEqual(bremen.tapTargets.first { $0.kind == .landmark }?.landmark?.appearance, .natural)
    }
}

// MARK: - Needs cultural review before release

final class CulturalReviewFlagTests: XCTestCase {
    func testEverySectionSevenStoryInTheCatalogIsFlagged() throws {
        let library = try ContentPlan.bundledLibrary()
        for story in library.stories {
            let id = story.id.rawValue
            let review = story.culturalReview
            if ContentPlan.requiredReview.contains(id) {
                XCTAssertEqual(review.level, .required, id)
                XCTAssertEqual(review.status, .pending, id)
                XCTAssertTrue(review.needsReviewBeforeRelease, id)
                XCTAssertFalse((review.reason ?? "").trimmingCharacters(in: .whitespaces).isEmpty, "\(id): no reason")
                XCTAssertFalse((review.community ?? "").trimmingCharacters(in: .whitespaces).isEmpty, "\(id): no reviewer named")
                let line = try XCTUnwrap(review.releaseFlagLine, id)
                XCTAssertTrue(line.hasPrefix(CulturalReview.releaseFlag), id)
            } else {
                XCTAssertEqual(review.level, .standard, id)
                XCTAssertFalse(review.needsReviewBeforeRelease, id)
                XCTAssertNil(review.releaseFlagLine, id)
            }
        }
        let flagged = library.storiesNeedingCulturalReview.map(\.id.rawValue)
        XCTAssertEqual(flagged, library.stories.map(\.id.rawValue).filter { ContentPlan.requiredReview.contains($0) })
        // Batch 1 holds six of the twelve.
        for id in ["monkey-and-crocodile", "why-possums-tail-is-bare", "the-snow-house",
                   "why-sun-and-moon-live-in-sky", "lion-and-hare", "anansi-wisdom"] {
            XCTAssertTrue(flagged.contains(id), id)
        }
        // Batch 2 adds the Dakota story and the Yup'ik original: eight of the twelve.
        for id in ["iktomi-and-the-muskrat", "long-day-at-fish-camp"] {
            XCTAssertTrue(flagged.contains(id), id)
        }
        XCTAssertGreaterThanOrEqual(flagged.count, 8)
    }

    func testAFlaggedStoryCannotShip() throws {
        let repository = try SampleContent.repository()
        let landmarks = try repository.loadLandmarks()
        for id in ["why-possums-tail-is-bare", "the-snow-house", "why-sun-and-moon-live-in-sky", "lion-and-hare",
                   "iktomi-and-the-muskrat", "long-day-at-fish-camp"] {
            let story = try repository.loadStory(id: StoryID(id))
            let manuscript = try XCTUnwrap(try repository.loadManuscript(id: story.id))
            let report = StoryValidator(mode: .release).validate(story: story, landmarks: landmarks, manuscript: manuscript)
            XCTAssertTrue(report.contains(.culturalReviewNotApproved, severity: .error), id)
        }
    }

    func testTheFlagClearsOnlyWhenTheReviewIsApproved() throws {
        var review = try SampleContent.story().culturalReview
        XCTAssertTrue(review.needsReviewBeforeRelease)
        for status in [CulturalReview.Status.pending, .inReview, .changesRequested] {
            review.status = status
            XCTAssertTrue(review.needsReviewBeforeRelease, status.rawValue)
        }
        review.status = .approved
        XCTAssertFalse(review.needsReviewBeforeRelease)
        XCTAssertNil(review.releaseFlagLine)
        // A standard review never raises the flag.
        review.status = .pending
        review.level = .standard
        XCTAssertFalse(review.needsReviewBeforeRelease)
    }

    func testTheFlagLineNamesTheReviewerAndTheReason() {
        let review = CulturalReview(
            level: .required,
            status: .pending,
            reason: "Indigenous story.",
            community: "Cherokee consultant",
            by: nil,
            date: nil,
            notes: nil
        )
        XCTAssertEqual(review.releaseFlagLine, "Needs cultural review before release — Cherokee consultant: Indigenous story.")
        XCTAssertEqual(CulturalReview.releaseFlag, "Needs cultural review before release")
    }

    func testARequiredReviewMustNameItsReviewer() throws {
        var story = try SampleContent.story()
        XCTAssertFalse(try SampleContent.report(for: story).contains(.culturalReviewNoCommunity))
        story.culturalReview.community = nil
        assertError(try SampleContent.report(for: story), .culturalReviewNoCommunity)
        story.culturalReview.community = "  "
        assertError(try SampleContent.report(for: story), .culturalReviewNoCommunity)
        // A standard review may leave it out.
        story.culturalReview.level = .standard
        story.culturalReview.community = nil
        XCTAssertFalse(try SampleContent.report(for: story).contains(.culturalReviewNoCommunity))
        XCTAssertEqual(ValidationCode.culturalReviewNoCommunity.rawValue, "cultural-review-no-community")
    }
}

// MARK: - The library's shelves

final class LibraryShelfTests: XCTestCase {
    func testShelvesGroupTheCatalogByLevelInCatalogOrder() throws {
        let library = try ContentPlan.bundledLibrary()
        let shelves = library.shelves()
        XCTAssertEqual(shelves.map(\.tier), [.low, .medium, .advanced])
        XCTAssertEqual(shelves.flatMap(\.stories).count, library.stories.count)
        for shelf in shelves {
            XCTAssertTrue(shelf.stories.allSatisfy { $0.tier == shelf.tier })
            XCTAssertEqual(shelf.stories.map(\.id), library.stories.filter { $0.tier == shelf.tier }.map(\.id))
            XCTAssertEqual(shelf.id, shelf.tier)
        }
        XCTAssertEqual(shelves[0].stories.count, 11)
        XCTAssertEqual(shelves[0].countText, "11 stories")
        XCTAssertEqual(shelves[0].stories.first?.id, StoryID("monkey-and-crocodile"))
        // Batch 2: the Medium shelf is full as well.
        XCTAssertEqual(shelves[1].stories.count, 11)
        XCTAssertEqual(shelves[1].countText, "11 stories")
        XCTAssertEqual(shelves[1].stories.first?.id, StoryID("tiger-brahman-jackal"))
        XCTAssertEqual(shelves[1].stories.last?.id, StoryID("sindbad-second-voyage"))
    }

    func testAChosenLevelIsOneShelf() throws {
        let library = try ContentPlan.bundledLibrary()
        for tier in Tier.allCases {
            let filter = try XCTUnwrap(LibraryFilter.allCases.first { $0.tier == tier })
            let shelves = library.shelves(matching: filter)
            XCTAssertEqual(shelves.map(\.tier), [tier])
            XCTAssertEqual(shelves[0].stories.map(\.id), library.entries(matching: filter).map(\.id))
        }
        XCTAssertEqual(library.shelves(matching: .all), library.shelves())
    }

    func testALevelWithNoStoryHasNoShelf() throws {
        let library = try ContentPlan.bundledLibrary()
        let onlyLow = Library(
            catalogVersion: 1,
            stories: library.stories.filter { $0.tier == .low },
            landmarks: library.landmarks
        )
        XCTAssertEqual(onlyLow.shelves().map(\.tier), [.low])
        XCTAssertTrue(onlyLow.shelves(matching: .advanced).isEmpty)
        let empty = Library(catalogVersion: 1, stories: [], landmarks: library.landmarks)
        XCTAssertTrue(empty.shelves().isEmpty)
        let one = LibraryShelf(tier: .medium, stories: [try SampleContent.story()])
        XCTAssertEqual(one.countText, "1 story")
    }
}

// MARK: - The story map with a pin for every story

final class StoryMapRulesTests: XCTestCase {
    func testOnlyTheStoryBeingReadIsNamedOnACrowdedMap() {
        XCTAssertTrue(StoryMapRules.showsLabel(isReadingNow: false, pinCount: 3))
        XCTAssertTrue(StoryMapRules.showsLabel(isReadingNow: false, pinCount: StoryMapRules.labelledPinLimit))
        XCTAssertFalse(StoryMapRules.showsLabel(isReadingNow: false, pinCount: StoryMapRules.labelledPinLimit + 1))
        XCTAssertFalse(StoryMapRules.showsLabel(isReadingNow: false, pinCount: 32))
        XCTAssertTrue(StoryMapRules.showsLabel(isReadingNow: true, pinCount: 32))
    }

    func testARingForLaterIsOnlyDrawnWhereNoStoryHasArrived() {
        let egypt = GeoPoint(lat: 27, lon: 31)
        let maya = GeoPoint(lat: 17, lon: -90)
        let pins = [GeoPoint(lat: 26, lon: 33), GeoPoint(lat: 36, lon: 138)]
        XCTAssertFalse(StoryMapRules.isClear(egypt, of: pins))
        XCTAssertTrue(StoryMapRules.isClear(maya, of: pins))
        XCTAssertTrue(StoryMapRules.isClear(egypt, of: []))
        XCTAssertTrue(StoryMapRules.isClear(egypt, of: pins, within: 1))
    }

    func testEveryStoryHasAPinOnTheMap() throws {
        let library = try ContentPlan.bundledLibrary()
        for story in library.stories {
            let pin = try XCTUnwrap(story.region.pin, story.id.rawValue)
            XCTAssertTrue(pin.isInRange, story.id.rawValue)
            // The origin chip and the label under a cover stay short.
            XCTAssertLessThanOrEqual(story.region.label.count, 24, story.id.rawValue)
        }
    }
}

// MARK: - The next story across the bigger catalog

final class NextStoryCatalogTests: XCTestCase {
    func testAReaderIsLedThroughTheirOwnLevelFirst() throws {
        let stories = try ContentPlan.bundledLibrary().stories
        let low = stories.filter { $0.tier == .low }
        var finished: Set<StoryID> = []
        var current = try XCTUnwrap(low.first)
        var walked = [current.id]
        // Finishing one Low story after another offers every other Low story before any other level.
        for _ in 1..<low.count {
            finished.insert(current.id)
            let next = try XCTUnwrap(NextStory.suggestion(after: current.id, in: stories, finished: finished))
            XCTAssertEqual(next.tier, .low, "after \(current.id)")
            XCTAssertFalse(finished.contains(next.id))
            walked.append(next.id)
            current = next
        }
        XCTAssertEqual(walked, low.map(\.id), "catalog order within the level")
        // With every Low story read, the next is one level up.
        finished.insert(current.id)
        let up = try XCTUnwrap(NextStory.suggestion(after: current.id, in: stories, finished: finished))
        XCTAssertEqual(up.tier, .medium)
    }

    func testTheSuggestionIsNeverTheStoryJustFinishedAnywhereInTheCatalog() throws {
        let stories = try ContentPlan.bundledLibrary().stories
        let all = Set(stories.map(\.id))
        for story in stories {
            for finished in [Set<StoryID>(), all] {
                let next = try XCTUnwrap(NextStory.suggestion(after: story.id, in: stories, finished: finished))
                XCTAssertNotEqual(next.id, story.id)
            }
            // Nothing read: the next story is never further than one level away.
            let fresh = try XCTUnwrap(NextStory.suggestion(after: story.id, in: stories, finished: []))
            XCTAssertLessThanOrEqual(abs(fresh.tier.level - story.tier.level), 1, story.id.rawValue)
        }
    }

    func testFromTheMiddleOfALevelTheNextIsTheFollowingStoryOfThatLevel() throws {
        let stories = try ContentPlan.bundledLibrary().stories
        let sparrow = StoryID("tongue-cut-sparrow")
        let next = NextStory.suggestion(after: sparrow, in: stories, finished: [sparrow])
        XCTAssertEqual(next?.id, StoryID("old-man-who-moved-mountains"))
        // The last Low story wraps round to the first unread Low story.
        let last = StoryID("lion-and-hare")
        XCTAssertEqual(NextStory.suggestion(after: last, in: stories, finished: [last])?.id, StoryID("monkey-and-crocodile"))
    }

    func testAMediumReaderIsLedAlongTheMediumShelf() throws {
        let stories = try ContentPlan.bundledLibrary().stories
        let medium = stories.filter { $0.tier == .medium }
        XCTAssertEqual(medium.count, 11)
        var finished: Set<StoryID> = []
        var current = try XCTUnwrap(medium.first)
        var walked = [current.id]
        for _ in 1..<medium.count {
            finished.insert(current.id)
            let next = try XCTUnwrap(NextStory.suggestion(after: current.id, in: stories, finished: finished))
            XCTAssertEqual(next.tier, .medium, "after \(current.id)")
            walked.append(next.id)
            current = next
        }
        XCTAssertEqual(walked, medium.map(\.id), "catalog order within the level")
        // With the whole Medium shelf read, the next story is one level up, not down.
        finished.insert(current.id)
        let up = try XCTUnwrap(NextStory.suggestion(after: current.id, in: stories, finished: finished))
        XCTAssertEqual(up.tier, .advanced)
        // From the middle of the shelf: the following Medium story.
        let sadko = StoryID("sadko")
        XCTAssertEqual(NextStory.suggestion(after: sadko, in: stories, finished: [sadko])?.id, StoryID("androcles-and-the-lion"))
    }
}

// MARK: - Batch 3: the Advanced stories and the whole catalog

final class AdvancedBatchTests: XCTestCase {
    func testTheCatalogHoldsAllThirtyTwoStoriesInPlanOrder() throws {
        let catalog = try SampleContent.repository().loadCatalog().stories.map(\.rawValue)
        XCTAssertEqual(catalog, ContentPlan.order)
        XCTAssertEqual(ContentPlan.batchThree.count, 9)
        for id in ContentPlan.batchThree {
            XCTAssertTrue(catalog.contains(id), "\(id) is missing from the catalog")
        }
        // Every planned story has its landmark list in the test's map.
        XCTAssertEqual(Set(ContentPlan.landmarks.keys), Set(ContentPlan.order))
    }

    func testEveryPlannedAdvancedStoryIsInTheCatalog() throws {
        let library = try ContentPlan.bundledLibrary()
        let advanced = library.stories.filter { $0.tier == .advanced }.map(\.id.rawValue)
        XCTAssertEqual(advanced, Array(ContentPlan.order[22..<32]))
        XCTAssertEqual(Set(ContentPlan.batchThree).union(["urashima-taro"]), Set(advanced))
        // One Advanced story from every region.
        let regions = library.stories.filter { $0.tier == .advanced }.map(\.region.id)
        XCTAssertEqual(Set(regions), Set(RegionID.allCases))
        XCTAssertEqual(regions.count, RegionID.allCases.count)
        // The whole catalog: a story in every region × level cell (CONTENT_PLAN §1.1).
        for tier in Tier.allCases {
            let cell = Set(library.stories.filter { $0.tier == tier }.map(\.region.id))
            XCTAssertEqual(cell, Set(RegionID.allCases), "\(tier)")
        }
        XCTAssertEqual(library.stories.count, 32)
    }

    func testTheNewAdvancedStoriesAreLevelledLikeUrashima() throws {
        let library = try ContentPlan.bundledLibrary()
        for id in ContentPlan.batchThree {
            let story = try XCTUnwrap(library.story(id: StoryID(id)), id)
            XCTAssertEqual(story.tier, .advanced, id)
            // Urashima has 16 pages in three parts; the new stories have 14 in three.
            XCTAssertEqual(story.spreads.count, 14, id)
            XCTAssertEqual(story.parts.count, 3, id)
            XCTAssertEqual(story.sample.freeSpreads, 2, id)
            XCTAssertEqual(Set(story.spreads.map(\.scene.unfolded.assetName)).count, 4, id)
            XCTAssertGreaterThanOrEqual(story.tapTargets.filter { $0.kind != .landmark }.count, 4, id)
            XCTAssertTrue(story.tapTargets.contains { $0.kind == .place }, id)
            XCTAssertGreaterThanOrEqual(story.characters.filter { $0.card != nil }.count, 2, id)
            XCTAssertEqual(story.theme.chrome.leading, story.theme.chrome.trailing, id)
            XCTAssertEqual(story.theme.chrome.leading, story.theme.chrome.folded, id)
            var total = 0
            for spread in story.spreads {
                let place = "\(id) \(spread.id)"
                total += spread.wordCount
                // About 190 words a page, never a wall of text.
                XCTAssertGreaterThanOrEqual(spread.wordCount, 120, place)
                XCTAssertLessThanOrEqual(spread.wordCount, 240, place)
                // Text on both panes, like Urashima: leading paragraphs first, then the trailing pane.
                XCTAssertEqual(spread.blocks.first?.pane, .leading, place)
                XCTAssertEqual(spread.blocks.last?.pane, .trailing, place)
                let panes = spread.blocks.map(\.pane)
                let firstTrailing = panes.firstIndex(of: .trailing) ?? panes.count
                XCTAssertTrue(panes[firstTrailing...].allSatisfy { $0 == .trailing }, place)
                for block in spread.blocks where block.kind == .pathText {
                    XCTAssertFalse((block.path ?? "").isEmpty, place)
                }
                // The words sit above the picture on both panes.
                let area = try XCTUnwrap(spread.scene.textArea, place)
                XCTAssertNotNil(area.leadingBottom, place)
                XCTAssertNotNil(area.trailingBottom, place)
                let taps = spread.blocks.flatMap(\.runs).filter { $0.tapTarget != nil }
                XCTAssertLessThanOrEqual(taps.count, 1, place)
            }
            XCTAssertGreaterThanOrEqual(total, 2_000, id)
            XCTAssertLessThanOrEqual(total, 3_000, id)
            // Lead lines open the story and each part.
            for part in story.parts {
                let first = try XCTUnwrap(story.spreads.first { $0.part == part.id }, "\(id) \(part.id)")
                XCTAssertTrue(first.blocks[0].runs.allSatisfy(\.isLead), "\(id) \(part.id)")
            }
            // Every character with a card is named (tappable) in the text.
            let named = Set(story.spreads.flatMap(\.blocks).flatMap(\.runs).compactMap(\.characterName))
            for character in story.characters where character.card != nil {
                XCTAssertTrue(named.contains(character.id), "\(id): \(character.id) is never named")
            }
        }
    }

    func testAllTwelveSectionSevenStoriesAreFlagged() throws {
        let library = try ContentPlan.bundledLibrary()
        let flagged = Set(library.storiesNeedingCulturalReview.map(\.id.rawValue))
        XCTAssertEqual(flagged, ContentPlan.requiredReview)
        XCTAssertEqual(flagged.count, 12)
        let repository = try SampleContent.repository()
        let landmarks = try repository.loadLandmarks()
        for id in ["savitri-and-satyavan", "the-two-sisters", "woman-who-raised-a-bear", "the-griots-apprentice"] {
            let story = try repository.loadStory(id: StoryID(id))
            XCTAssertEqual(story.culturalReview.notes, "Needs cultural review before release.", id)
            let manuscript = try XCTUnwrap(try repository.loadManuscript(id: story.id))
            let report = StoryValidator(mode: .release).validate(story: story, landmarks: landmarks, manuscript: manuscript)
            XCTAssertTrue(report.contains(.culturalReviewNotApproved, severity: .error), id)
        }
    }

    func testAllThirtySevenLandmarksAreInTheCatalogAndShownHonestly() throws {
        let catalog = try SampleContent.landmarks()
        XCTAssertEqual(Set(catalog.landmarks.map(\.id.rawValue)), ContentPlan.landmarkIDs)
        // A lost wonder is drawn as an idea.
        let mausoleum = try XCTUnwrap(catalog.landmark(id: LandmarkID("mausoleum-halicarnassus")))
        XCTAssertEqual(mausoleum.status, .lost)
        XCTAssertEqual(mausoleum.depiction, .reconstruction)
        XCTAssertTrue(mausoleum.lists.contains(.ancientSeven))
        // A fjord was not built.
        let fjord = try XCTUnwrap(catalog.landmark(id: LandmarkID("ilulissat-icefjord")))
        XCTAssertEqual(fjord.era, .natural)
        XCTAssertNil(fjord.built)
        // All seven Ancient Wonders are there now.
        XCTAssertEqual(catalog.landmarks.filter { $0.lists.contains(.ancientSeven) }.count, 7)
    }

    func testOnlyKnossosBelongsToItsAdvancedStory() throws {
        // §6.3: the palace on the Labyrinth's island is natural; every other Advanced landmark
        // stands outside its story and says how.
        let library = try ContentPlan.bundledLibrary()
        for id in ContentPlan.batchThree {
            let story = try XCTUnwrap(library.story(id: StoryID(id)), id)
            for target in story.tapTargets where target.kind == .landmark {
                let ref = try XCTUnwrap(target.landmark, id)
                if ref.id.rawValue == "palace-of-knossos" {
                    XCTAssertEqual(ref.appearance, .natural, id)
                } else {
                    XCTAssertEqual(ref.appearance, .framed, "\(id) \(ref.id)")
                    XCTAssertNotNil(ref.framingDevice, "\(id) \(ref.id)")
                }
            }
        }
        // The Squamish story opens today, on the bridge.
        let sisters = try XCTUnwrap(library.story(id: StoryID("the-two-sisters")))
        let bridge = try XCTUnwrap(sisters.tapTargets.first { $0.landmark?.id.rawValue == "lions-gate-bridge" })
        XCTAssertEqual(bridge.landmark?.framingDevice?.kind, .presentDayNarrator)
    }

    func testTheGreenlandStoryTeachesTheArcticCorrectly() throws {
        // CONTENT_PLAN §1.4: Kalaallit houses of stone and turf; no snow house, nothing of Alaska.
        let story = try XCTUnwrap(try ContentPlan.bundledLibrary().story(id: StoryID("woman-who-raised-a-bear")))
        XCTAssertEqual(story.region.id, .arctic)
        XCTAssertTrue(story.region.culture.contains("Kalaallit"))
        let text = story.spreads.flatMap(\.blocks).map(\.plainText).joined(separator: " ").lowercased()
        XCTAssertFalse(text.contains("snow house"))
        XCTAssertFalse(text.contains("alaska"))
    }

    func testTheAdvancedShelfIsFullAndTheNextStoryWalksIt() throws {
        let library = try ContentPlan.bundledLibrary()
        let shelves = library.shelves()
        XCTAssertEqual(shelves.map(\.stories.count), [11, 11, 10])
        XCTAssertEqual(shelves[2].countText, "10 stories")
        XCTAssertEqual(shelves[2].stories.first?.id, StoryID("savitri-and-satyavan"))
        XCTAssertEqual(shelves[2].stories.last?.id, StoryID("zal-and-the-simurgh"))

        let stories = library.stories
        let advanced = stories.filter { $0.tier == .advanced }
        var finished: Set<StoryID> = []
        var current = try XCTUnwrap(advanced.first)
        var walked = [current.id]
        for _ in 1..<advanced.count {
            finished.insert(current.id)
            let next = try XCTUnwrap(NextStory.suggestion(after: current.id, in: stories, finished: finished))
            XCTAssertEqual(next.tier, .advanced, "after \(current.id)")
            walked.append(next.id)
            current = next
        }
        XCTAssertEqual(walked, advanced.map(\.id), "catalog order within the level")
        // With the top shelf read, the reader is offered an unread Medium story, never nothing.
        finished.insert(current.id)
        let down = try XCTUnwrap(NextStory.suggestion(after: current.id, in: stories, finished: finished))
        XCTAssertEqual(down.tier, .medium)
        XCTAssertFalse(finished.contains(down.id))
        // Urashima, in the middle of the shelf, leads on to Mulan.
        let urashima = StoryID("urashima-taro")
        XCTAssertEqual(NextStory.suggestion(after: urashima, in: stories, finished: [urashima])?.id, StoryID("ballad-of-mulan"))
    }
}
