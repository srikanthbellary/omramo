import Foundation

/// The content rules. The raw values are the rule codes printed by both validators:
/// `StoryValidator` here (the authority) and `tools/validate_content.py`. Keep the two lists
/// the same (docs/IMPLEMENTATION_PLAN.md criterion 1.20).
public enum ValidationCode: String, CaseIterable, Hashable, Sendable {
    // Identity and references
    case duplicateID = "duplicate-id"
    case danglingPart = "dangling-part"
    case danglingTap = "dangling-tap"
    case danglingName = "dangling-name"
    case danglingSay = "dangling-say"
    case tapAndName = "tap-and-name"
    case emptyText = "empty-text"
    case unusedTapTarget = "unused-tap-target"
    case pathTextIncomplete = "path-text-incomplete"

    // Art, colours, sample
    case missingAlt = "missing-alt"
    case badArtSize = "bad-art-size"
    case artFileMissing = "art-file-missing"
    case badColor = "bad-color"
    case freeSpreadsRange = "free-spreads-range"
    case wordsPerSpread = "words-per-spread"
    case textAreaRange = "text-area-range"

    // Text fidelity
    case manuscriptMissing = "manuscript-missing"
    case textFidelity = "text-fidelity"

    // Region, provenance, review, education
    case regionIncomplete = "region-incomplete"
    case pinOutOfRange = "pin-out-of-range"
    case provenanceNoSource = "provenance-no-source"
    case provenanceSourceIncomplete = "provenance-source-incomplete"
    case provenanceIncomplete = "provenance-incomplete"
    case originalIncomplete = "original-incomplete"
    case culturalReviewNoReason = "cultural-review-no-reason"
    case culturalReviewNotApproved = "cultural-review-not-approved"
    case reviewPending = "review-pending"
    case educationIncomplete = "education-incomplete"
    case educationFactCardDangling = "education-fact-card-dangling"

    // Tap targets and landmarks in a story
    case tapTargetIncomplete = "tap-target-incomplete"
    case landmarkTargetShape = "landmark-target-shape"
    case danglingLandmark = "dangling-landmark"
    case framedWithoutDevice = "framed-without-device"
    case landmarkAnachronism = "landmark-anachronism"
    case landmarkOutOfRegion = "landmark-out-of-region"
    case tooManyLandmarks = "too-many-landmarks"

    // The landmark catalog itself
    case landmarkIncomplete = "landmark-incomplete"
    case landmarkBuilt = "landmark-built"
    case landmarkCoordinates = "landmark-coordinates"
    case landmarkNoList = "landmark-no-list"
    case landmarkFactCard = "landmark-fact-card"
    case landmarkNotReconstruction = "landmark-not-reconstruction"

    // The catalog
    case catalogDuplicate = "catalog-duplicate"
    case catalogStoryMismatch = "catalog-story-mismatch"
}

public struct ValidationIssue: Hashable, Sendable, CustomStringConvertible {
    public enum Severity: String, Hashable, Sendable {
        case error
        case warning
    }

    public var severity: Severity
    public var code: ValidationCode
    /// Where in the file, e.g. "spreads[2].blocks[0].runs[1]".
    public var location: String
    public var message: String

    public init(_ severity: Severity, _ code: ValidationCode, at location: String, _ message: String) {
        self.severity = severity
        self.code = code
        self.location = location
        self.message = message
    }

    public var description: String {
        "\(severity.rawValue) [\(code.rawValue)] \(location): \(message)"
    }
}

public struct ValidationReport: Hashable, Sendable {
    public var issues: [ValidationIssue]

    public init(issues: [ValidationIssue] = []) {
        self.issues = issues
    }

    public var errors: [ValidationIssue] {
        issues.filter { $0.severity == .error }
    }

    public var warnings: [ValidationIssue] {
        issues.filter { $0.severity == .warning }
    }

    /// True when there are no errors. Warnings do not make content invalid.
    public var isValid: Bool {
        errors.isEmpty
    }

    public func contains(_ code: ValidationCode, severity: ValidationIssue.Severity? = nil) -> Bool {
        issues.contains { $0.code == code && (severity == nil || $0.severity == severity) }
    }
}

/// How strict to be.
public enum ValidationMode: String, Hashable, Sendable {
    /// Day-to-day work: pending reviews and missing placeholder art are warnings.
    case development
    /// A build that ships: pending reviews, an unapproved required cultural review and
    /// missing art are errors.
    case release
}
