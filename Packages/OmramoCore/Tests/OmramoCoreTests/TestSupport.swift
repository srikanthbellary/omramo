import Foundation
import XCTest
@testable import OmramoCore

/// The bundled sample content, loaded fresh for each test so a test can change its own copy.
/// Invalid "fixtures" are made by breaking one thing in a valid copy: either a field of the
/// decoded model (rule tests) or a piece of the raw JSON text (decoding tests).
enum SampleContent {
    static let storyID = StoryID("monkey-and-crocodile")

    static func repository() throws -> DirectoryContentRepository {
        try BundledContent.repository()
    }

    static func story() throws -> Story {
        try repository().loadStory(id: storyID)
    }

    static func landmarks() throws -> LandmarkCatalog {
        try repository().loadLandmarks()
    }

    static func manuscript() throws -> String {
        try XCTUnwrap(try repository().loadManuscript(id: storyID), "the sample manuscript is missing")
    }

    static func storyJSON() throws -> String {
        let repo = try repository()
        return try XCTUnwrap(String(data: try repo.read(repo.storyURL(id: storyID)), encoding: .utf8))
    }

    static func landmarksJSON() throws -> String {
        let repo = try repository()
        return try XCTUnwrap(String(data: try repo.read(repo.landmarksURL), encoding: .utf8))
    }

    /// Replaces `target` (which must be present) in a JSON text and returns the bytes.
    static func json(_ text: String, replacing target: String, with replacement: String) throws -> Data {
        guard text.contains(target) else {
            XCTFail("fixture text not found: \(target)")
            throw ContentError.malformed(file: "fixture", detail: "text not found: \(target)")
        }
        return Data(text.replacingOccurrences(of: target, with: replacement).utf8)
    }

    /// Validates a (possibly changed) story against the bundled landmarks and manuscript.
    static func report(
        for story: Story,
        landmarks: LandmarkCatalog? = nil,
        mode: ValidationMode = .development
    ) throws -> ValidationReport {
        let catalog = try landmarks ?? SampleContent.landmarks()
        return StoryValidator(mode: mode).validate(
            story: story,
            landmarks: catalog,
            manuscript: try manuscript()
        )
    }

    /// Index of the sample's landmark tap target.
    static func landmarkTargetIndex(in story: Story) throws -> Int {
        try XCTUnwrap(story.tapTargets.firstIndex { $0.kind == .landmark }, "the sample has no landmark target")
    }
}

func assertError(
    _ report: ValidationReport,
    _ code: ValidationCode,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertTrue(
        report.contains(code, severity: .error),
        "expected error \(code.rawValue); got \(report.issues.map(\.description))",
        file: file,
        line: line
    )
}
