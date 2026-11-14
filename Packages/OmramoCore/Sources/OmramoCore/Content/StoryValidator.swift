import Foundation

/// Checks content against the rules of docs/ARCHITECTURE.md §6.3, §6.5 and §7.3.
/// This validator is the authority; `tools/validate_content.py` mirrors it rule for rule.
///
/// Not checked here (M1): the pixel size of image files. Art is placeholder in M1, so an image
/// file that does not exist is reported as `art-file-missing` (a warning in development, an
/// error in release) and only when the caller supplies `artFileExists`.
public struct StoryValidator: Sendable {
    public var mode: ValidationMode
    /// A spread may hold up to this multiple of the tier's target word count before a warning.
    public var wordAllowance: Double = 1.5
    /// More landmark targets than this in one story is a warning.
    public var maximumLandmarksPerStory: Int = 2

    public init(mode: ValidationMode = .development) {
        self.mode = mode
    }

    // MARK: Story

    /// - Parameters:
    ///   - landmarks: the shared catalog; landmark references must resolve in it.
    ///   - manuscript: the text of `sources/<story-id>.txt`. Pass nil when there is none:
    ///     that is itself reported.
    ///   - artFileExists: given an `ArtRef.file`, says whether the image exists. Pass nil to
    ///     skip the file check.
    public func validate(
        story: Story,
        landmarks: LandmarkCatalog,
        manuscript: String?,
        artFileExists: ((String) -> Bool)? = nil
    ) -> ValidationReport {
        var issues: [ValidationIssue] = []

        checkIdentity(story, &issues)
        checkRuns(story, &issues)
        checkArtAndColors(story, artFileExists, &issues)
        checkSample(story, &issues)
        checkRegion(story, &issues)
        checkProvenance(story, &issues)
        checkReviews(story, &issues)
        checkEducation(story, &issues)
        checkTapTargets(story, landmarks, artFileExists, &issues)
        checkFidelity(story, manuscript, &issues)

        return ValidationReport(issues: issues)
    }

    private var pendingSeverity: ValidationIssue.Severity {
        mode == .release ? .error : .warning
    }

    private func isBlank(_ text: String?) -> Bool {
        guard let text else { return true }
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func duplicates<ID: Hashable>(_ ids: [ID]) -> [ID] {
        var seen = Set<ID>()
        var repeated: [ID] = []
        for id in ids where !seen.insert(id).inserted {
            if !repeated.contains(id) { repeated.append(id) }
        }
        return repeated
    }

    private func checkIdentity(_ story: Story, _ issues: inout [ValidationIssue]) {
        for id in duplicates(story.parts.map(\.id)) {
            issues.append(.init(.error, .duplicateID, at: "parts", "part id \"\(id)\" is used more than once"))
        }
        for id in duplicates(story.characters.map(\.id)) {
            issues.append(.init(.error, .duplicateID, at: "characters", "character id \"\(id)\" is used more than once"))
        }
        for id in duplicates(story.tapTargets.map(\.id)) {
            issues.append(.init(.error, .duplicateID, at: "tapTargets", "tap-target id \"\(id)\" is used more than once"))
        }
        for id in duplicates(story.spreads.map(\.id)) {
            issues.append(.init(.error, .duplicateID, at: "spreads", "spread id \"\(id)\" is used more than once"))
        }
        // Block ids are unique across the whole story: reading position refers to them.
        for id in duplicates(story.spreads.flatMap { $0.blocks.map(\.id) }) {
            issues.append(.init(.error, .duplicateID, at: "spreads", "block id \"\(id)\" is used more than once"))
        }
        if isBlank(story.title) {
            issues.append(.init(.error, .emptyText, at: "title", "the story has no title"))
        }
        if story.spreads.isEmpty {
            issues.append(.init(.error, .emptyText, at: "spreads", "the story has no spreads"))
        }
    }

    private func checkRuns(_ story: Story, _ issues: inout [ValidationIssue]) {
        let partIDs = Set(story.parts.map(\.id))
        let characterIDs = Set(story.characters.map(\.id))
        let targetIDs = Set(story.tapTargets.map(\.id))
        var usedTargets = Set<TapTargetID>()
        let targetWords = story.tier.readingScale().targetWordsPerSpread
        let wordLimit = Int((Double(targetWords) * wordAllowance).rounded())

        for (spreadIndex, spread) in story.spreads.enumerated() {
            let spreadPath = "spreads[\(spreadIndex)]"
            if !partIDs.contains(spread.part) {
                issues.append(.init(.error, .danglingPart, at: spreadPath + ".part",
                                    "part \"\(spread.part)\" is not in parts[]"))
            }
            if spread.blocks.isEmpty {
                issues.append(.init(.error, .emptyText, at: spreadPath + ".blocks", "the spread has no text blocks"))
            }
            if spread.wordCount > wordLimit {
                issues.append(.init(.warning, .wordsPerSpread, at: spreadPath,
                                    "\(spread.wordCount) words; the \(story.tier.rawValue) tier aims for about \(targetWords) a page"))
            }
            for (blockIndex, block) in spread.blocks.enumerated() {
                let blockPath = spreadPath + ".blocks[\(blockIndex)]"
                if block.runs.isEmpty {
                    issues.append(.init(.error, .emptyText, at: blockPath + ".runs", "the block has no runs"))
                }
                if block.kind == .pathText {
                    if block.path.flatMap({ SVGPath(string: $0) }) == nil {
                        issues.append(.init(.error, .pathTextIncomplete, at: blockPath + ".path",
                                            "a pathText block needs a path of absolute M, L, Q and C commands"))
                    }
                } else if block.path != nil {
                    issues.append(.init(.error, .pathTextIncomplete, at: blockPath + ".path",
                                        "only a pathText block may have a path"))
                }
                for (runIndex, run) in block.runs.enumerated() {
                    let runPath = blockPath + ".runs[\(runIndex)]"
                    if run.text.isEmpty {
                        issues.append(.init(.error, .emptyText, at: runPath + ".t", "a run has empty text"))
                    }
                    if run.tapTarget != nil && run.characterName != nil {
                        issues.append(.init(.error, .tapAndName, at: runPath,
                                            "a run may have \"tap\" or \"name\", not both"))
                    }
                    if let tap = run.tapTarget {
                        usedTargets.insert(tap)
                        if !targetIDs.contains(tap) {
                            issues.append(.init(.error, .danglingTap, at: runPath + ".tap",
                                                "tap target \"\(tap)\" is not in tapTargets[]"))
                        }
                    }
                    if let name = run.characterName, !characterIDs.contains(name) {
                        issues.append(.init(.error, .danglingName, at: runPath + ".name",
                                            "character \"\(name)\" is not in characters[]"))
                    }
                    if let speaker = run.speaker, !characterIDs.contains(speaker) {
                        issues.append(.init(.error, .danglingSay, at: runPath + ".say",
                                            "character \"\(speaker)\" is not in characters[]"))
                    }
                }
            }
        }

        for (index, target) in story.tapTargets.enumerated() where !usedTargets.contains(target.id) {
            issues.append(.init(.warning, .unusedTapTarget, at: "tapTargets[\(index)]",
                                "tap target \"\(target.id)\" is not marked on any word"))
        }
    }

    private func checkArt(
        _ art: ArtRef,
        at path: String,
        _ artFileExists: ((String) -> Bool)?,
        _ issues: inout [ValidationIssue]
    ) {
        if isBlank(art.alt) {
            issues.append(.init(.error, .missingAlt, at: path + ".alt", "every picture needs alt text"))
        }
        if isBlank(art.file) || art.width <= 0 || art.height <= 0 {
            issues.append(.init(.error, .badArtSize, at: path,
                                "a picture needs a file name and a pixel width and height above zero"))
        }
        if let artFileExists, !isBlank(art.file), !artFileExists(art.file) {
            issues.append(.init(pendingSeverity, .artFileMissing, at: path + ".file",
                                "image file \"\(art.file)\" does not exist (placeholder art)"))
        }
    }

    private func checkColor(_ value: String, at path: String, _ issues: inout [ValidationIssue]) {
        if RGBA(string: value) == nil {
            issues.append(.init(.error, .badColor, at: path,
                                "\"\(value)\" is not a colour; use #RRGGBB or #RRGGBBAA"))
        }
    }

    private func checkArtAndColors(
        _ story: Story,
        _ artFileExists: ((String) -> Bool)?,
        _ issues: inout [ValidationIssue]
    ) {
        checkArt(story.cover, at: "cover", artFileExists, &issues)
        checkColor(story.region.pinColor, at: "region.pinColor", &issues)
        checkColor(story.theme.textColor, at: "theme.textColor", &issues)
        checkColor(story.theme.tap.fill, at: "theme.tap.fill", &issues)
        checkColor(story.theme.tap.fill2, at: "theme.tap.fill2", &issues)
        checkColor(story.theme.tap.line, at: "theme.tap.line", &issues)
        checkColor(story.theme.tap.spark, at: "theme.tap.spark", &issues)
        checkColor(story.theme.chipGlass, at: "theme.chipGlass", &issues)

        for (index, character) in story.characters.enumerated() {
            let path = "characters[\(index)]"
            if isBlank(character.name) {
                issues.append(.init(.error, .emptyText, at: path + ".name", "a character needs a name"))
            }
            checkColor(character.color, at: path + ".color", &issues)
            if let chipBackground = character.chipBackground {
                checkColor(chipBackground, at: path + ".chipBackground", &issues)
            }
            checkArt(character.face, at: path + ".face", artFileExists, &issues)
            if let card = character.card {
                checkArt(card.portrait, at: path + ".card.portrait", artFileExists, &issues)
                for (colorIndex, color) in card.background.enumerated() {
                    checkColor(color, at: path + ".card.background[\(colorIndex)]", &issues)
                }
                for (traitIndex, trait) in card.traits.enumerated() {
                    checkColor(trait.fill, at: path + ".card.traits[\(traitIndex)].fill", &issues)
                    checkColor(trait.ink, at: path + ".card.traits[\(traitIndex)].ink", &issues)
                }
            }
        }

        for (index, spread) in story.spreads.enumerated() {
            let path = "spreads[\(index)].scene"
            checkArt(spread.scene.unfolded, at: path + ".unfolded", artFileExists, &issues)
            checkArt(spread.scene.folded, at: path + ".folded", artFileExists, &issues)
            for (colorIndex, color) in spread.scene.fallbackColors.enumerated() {
                checkColor(color, at: path + ".fallbackColors[\(colorIndex)]", &issues)
            }
            let areaEdges: [(String, Double?)] = [
                ("leadingBottom", spread.scene.textArea?.leadingBottom),
                ("trailingBottom", spread.scene.textArea?.trailingBottom),
            ]
            for (name, value) in areaEdges {
                if let value, !Spread.Scene.TextArea.range.contains(value) {
                    issues.append(.init(.error, .textAreaRange, at: path + ".textArea.\(name)",
                                        "the text area must end between 200 and 720 points down the 720-point reference pane"))
                }
            }
        }
    }

    private func checkSample(_ story: Story, _ issues: inout [ValidationIssue]) {
        if story.sample.freeSpreads < 0 || story.sample.freeSpreads > story.spreads.count {
            issues.append(.init(.error, .freeSpreadsRange, at: "sample.freeSpreads",
                                "freeSpreads is \(story.sample.freeSpreads); the story has \(story.spreads.count) spreads"))
        }
    }

    private func checkRegion(_ story: Story, _ issues: inout [ValidationIssue]) {
        if isBlank(story.region.culture) {
            issues.append(.init(.error, .regionIncomplete, at: "region.culture",
                                "name the specific people or tradition (never a continent)"))
        }
        if isBlank(story.region.place) {
            issues.append(.init(.error, .regionIncomplete, at: "region.place", "name the place"))
        }
        if isBlank(story.region.label) {
            issues.append(.init(.error, .regionIncomplete, at: "region.label", "the origin chip needs a label"))
        }
        if let pin = story.region.pin, !pin.isInRange {
            issues.append(.init(.error, .pinOutOfRange, at: "region.pin",
                                "latitude must be -90...90 and longitude -180...180"))
        }
        if isBlank(story.setting.period) {
            issues.append(.init(.error, .regionIncomplete, at: "setting.period", "say when the story is set"))
        }
    }

    private func checkProvenance(_ story: Story, _ issues: inout [ValidationIssue]) {
        let provenance = story.provenance
        if isBlank(provenance.rights) {
            issues.append(.init(.error, .provenanceIncomplete, at: "provenance.rights",
                                "state the rights basis"))
        }
        switch provenance.kind {
        case .publicDomainRetelling:
            let sources = provenance.sources ?? []
            if sources.isEmpty {
                issues.append(.init(.error, .provenanceNoSource, at: "provenance.sources",
                                    "a public-domain retelling must cite at least one source"))
            }
            for (index, source) in sources.enumerated() {
                if isBlank(source.author) || isBlank(source.title) || source.year <= 0 {
                    issues.append(.init(.error, .provenanceSourceIncomplete, at: "provenance.sources[\(index)]",
                                        "a source needs an author, a title and a year"))
                }
            }
            if isBlank(provenance.tradition) {
                issues.append(.init(.error, .provenanceIncomplete, at: "provenance.tradition",
                                    "name the tradition the tale comes from"))
            }
            if provenance.textBasis == nil {
                issues.append(.init(.error, .provenanceIncomplete, at: "provenance.textBasis",
                                    "say whether the text is sourceVerbatim or omramoRetelling"))
            }
        case .original:
            if isBlank(provenance.credit) {
                issues.append(.init(.error, .originalIncomplete, at: "provenance.credit",
                                    "an original story needs its credit line"))
            }
            if isBlank(provenance.premise) {
                issues.append(.init(.error, .originalIncomplete, at: "provenance.premise",
                                    "an original story needs its premise"))
            }
        }
    }

    private func checkReviews(_ story: Story, _ issues: inout [ValidationIssue]) {
        if story.review.text.status == .pending {
            issues.append(.init(pendingSeverity, .reviewPending, at: "review.text", "text review is pending"))
        }
        if story.review.art.status == .pending {
            issues.append(.init(pendingSeverity, .reviewPending, at: "review.art", "art review is pending"))
        }
        let cultural = story.culturalReview
        switch cultural.level {
        case .required:
            if isBlank(cultural.reason) {
                issues.append(.init(.error, .culturalReviewNoReason, at: "culturalReview.reason",
                                    "a required cultural review must say why it is required"))
            }
            if cultural.status != .approved {
                issues.append(.init(pendingSeverity, .culturalReviewNotApproved, at: "culturalReview.status",
                                    "required cultural review is \(cultural.status.rawValue); the story cannot ship until it is approved"))
            }
        case .standard:
            if cultural.status != .approved {
                issues.append(.init(.warning, .culturalReviewNotApproved, at: "culturalReview.status",
                                    "standard cultural review is \(cultural.status.rawValue)"))
            }
        }
    }

    private func checkEducation(_ story: Story, _ issues: inout [ValidationIssue]) {
        let targetIDs = Set(story.tapTargets.map(\.id))
        let pillars: [(String, EducationPillar)] = [
            ("geography", story.education.geography),
            ("culture", story.education.culture),
            ("moral", story.education.moral),
        ]
        for (name, pillar) in pillars {
            if isBlank(pillar.lesson) {
                issues.append(.init(.error, .educationIncomplete, at: "education.\(name).lesson",
                                    "the \(name) lesson is empty"))
            }
            for (index, id) in (pillar.factCards ?? []).enumerated() where !targetIDs.contains(id) {
                issues.append(.init(.error, .educationFactCardDangling, at: "education.\(name).factCards[\(index)]",
                                    "\"\(id)\" is not a tap target of this story"))
            }
        }
        // The line shown to the child when the story is finished.
        if let problem = MoralRule.problem(in: story.moral) {
            issues.append(.init(.error, .moralIncomplete, at: "moral", problem))
        }
    }

    private func checkTapTargets(
        _ story: Story,
        _ landmarks: LandmarkCatalog,
        _ artFileExists: ((String) -> Bool)?,
        _ issues: inout [ValidationIssue]
    ) {
        var landmarkTargetCount = 0
        for (index, target) in story.tapTargets.enumerated() {
            let path = "tapTargets[\(index)]"
            checkColor(target.background, at: path + ".background", &issues)

            guard target.kind == .landmark else {
                if target.landmark != nil {
                    issues.append(.init(.error, .landmarkTargetShape, at: path + ".landmark",
                                        "only a target of kind \"landmark\" may have a landmark reference"))
                }
                if isBlank(target.title) || isBlank(target.line) || target.picture == nil {
                    issues.append(.init(.error, .tapTargetIncomplete, at: path,
                                        "a tap target needs a title, a line to read and a picture"))
                }
                if let picture = target.picture {
                    checkArt(picture, at: path + ".picture", artFileExists, &issues)
                }
                continue
            }

            landmarkTargetCount += 1
            if target.title != nil || target.line != nil || target.cultureNote != nil || target.picture != nil {
                issues.append(.init(.error, .landmarkTargetShape, at: path,
                                    "a landmark target takes its title, line, note and picture from the landmark catalog; omit them here"))
            }
            guard let ref = target.landmark else {
                issues.append(.init(.error, .landmarkTargetShape, at: path + ".landmark",
                                    "a target of kind \"landmark\" needs a landmark reference"))
                continue
            }
            if ref.appearance == .framed {
                if let device = ref.framingDevice {
                    if isBlank(device.label) || isBlank(device.line) {
                        issues.append(.init(.error, .framedWithoutDevice, at: path + ".landmark.framingDevice",
                                            "a framing device needs a label and a line"))
                    }
                } else {
                    issues.append(.init(.error, .framedWithoutDevice, at: path + ".landmark",
                                        "appearance \"framed\" needs a framingDevice"))
                }
            }
            guard let landmark = landmarks.landmark(id: ref.id) else {
                issues.append(.init(.error, .danglingLandmark, at: path + ".landmark.id",
                                    "landmark \"\(ref.id)\" is not in the landmark catalog"))
                continue
            }
            // Anachronism rule: a landmark built after the story's world must be framed.
            if let latestYear = story.setting.latestYear, let built = landmark.built,
               built.from > latestYear, ref.appearance != .framed {
                issues.append(.init(.error, .landmarkAnachronism, at: path + ".landmark.appearance",
                                    "\(landmark.name) was built in \(built.from), after this story's world (\(latestYear)); it must be \"framed\""))
            }
            // Out-of-region rule: needs a worldLink or mapMoment device.
            if landmark.region != story.region.id {
                let kind = ref.framingDevice?.kind
                let framedForPlace = ref.appearance == .framed && (kind == .worldLink || kind == .mapMoment)
                if !framedForPlace {
                    issues.append(.init(.error, .landmarkOutOfRegion, at: path + ".landmark",
                                        "\(landmark.name) is outside this story's region; it must be \"framed\" with a worldLink or mapMoment device"))
                }
            }
        }
        if landmarkTargetCount > maximumLandmarksPerStory {
            issues.append(.init(.warning, .tooManyLandmarks, at: "tapTargets",
                                "\(landmarkTargetCount) landmark targets; the plan allows at most \(maximumLandmarksPerStory) a story"))
        }
    }

    private func checkFidelity(_ story: Story, _ manuscript: String?, _ issues: inout [ValidationIssue]) {
        guard let manuscript else {
            issues.append(.init(pendingSeverity, .manuscriptMissing, at: "sources/\(story.id).txt",
                                "there is no manuscript to check the story text against"))
            return
        }
        if let mismatch = TextFidelity.compare(story: story, manuscript: manuscript) {
            issues.append(.init(.error, .textFidelity, at: "spreads",
                                "story text differs from the manuscript at character \(mismatch.offset): manuscript has \"\(mismatch.expected)\", story has \"\(mismatch.found)\""))
        }
    }

    // MARK: Landmark catalog

    public func validate(landmarks: LandmarkCatalog, artFileExists: ((String) -> Bool)? = nil) -> ValidationReport {
        var issues: [ValidationIssue] = []
        for id in duplicates(landmarks.landmarks.map(\.id)) {
            issues.append(.init(.error, .duplicateID, at: "landmarks", "landmark id \"\(id)\" is used more than once"))
        }
        for (index, landmark) in landmarks.landmarks.enumerated() {
            let path = "landmarks[\(index)]"
            if isBlank(landmark.name) || isBlank(landmark.country) {
                issues.append(.init(.error, .landmarkIncomplete, at: path, "a landmark needs a name and a country"))
            }
            if landmark.era == .natural {
                if landmark.status != .natural {
                    issues.append(.init(.error, .landmarkBuilt, at: path + ".status",
                                        "a landmark of era \"natural\" must have status \"natural\""))
                }
            } else {
                if landmark.status == .natural {
                    issues.append(.init(.error, .landmarkBuilt, at: path + ".status",
                                        "status \"natural\" is only for landmarks of era \"natural\""))
                }
                if let built = landmark.built {
                    if let to = built.to, to < built.from {
                        issues.append(.init(.error, .landmarkBuilt, at: path + ".built",
                                            "built.to is earlier than built.from"))
                    }
                } else {
                    issues.append(.init(.error, .landmarkBuilt, at: path + ".built",
                                        "a built landmark needs its built year"))
                }
            }
            if !landmark.coordinates.isInRange {
                issues.append(.init(.error, .landmarkCoordinates, at: path + ".coordinates",
                                    "latitude must be -90...90 and longitude -180...180"))
            }
            if landmark.lists.isEmpty {
                issues.append(.init(.error, .landmarkNoList, at: path + ".lists",
                                    "a landmark belongs to at least one list"))
            }
            for tier in Tier.allCases where isBlank(landmark.factCards[tier].line) {
                issues.append(.init(.error, .landmarkFactCard, at: path + ".factCards.\(tier.rawValue).line",
                                    "the \(tier.rawValue) fact card has no line"))
            }
            if (landmark.status == .lost || landmark.status == .unproven) && landmark.depiction != .reconstruction {
                issues.append(.init(.error, .landmarkNotReconstruction, at: path + ".depiction",
                                    "a lost or unproven landmark must be shown as a reconstruction"))
            }
            checkArt(landmark.art, at: path + ".art", artFileExists, &issues)
            checkColor(landmark.background, at: path + ".background", &issues)
            if landmark.review.facts == .pending {
                issues.append(.init(pendingSeverity, .reviewPending, at: path + ".review.facts", "fact check is pending"))
            }
            if landmark.review.art == .pending {
                issues.append(.init(pendingSeverity, .reviewPending, at: path + ".review.art", "art review is pending"))
            }
        }
        return ValidationReport(issues: issues)
    }

    // MARK: Catalog

    /// `loadedStoryIDs`: the id inside each story file, keyed by the id the catalog used to find it.
    public func validate(catalog: Catalog, loadedStoryIDs: [StoryID: StoryID]) -> ValidationReport {
        var issues: [ValidationIssue] = []
        for id in duplicates(catalog.stories) {
            issues.append(.init(.error, .catalogDuplicate, at: "stories", "story \"\(id)\" is listed more than once"))
        }
        for (index, id) in catalog.stories.enumerated() {
            if let actual = loadedStoryIDs[id], actual != id {
                issues.append(.init(.error, .catalogStoryMismatch, at: "stories[\(index)]",
                                    "folder \"\(id)\" holds a story whose id is \"\(actual)\""))
            }
        }
        return ValidationReport(issues: issues)
    }
}
