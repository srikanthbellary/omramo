import XCTest
import UIKit
import OmramoCore
@testable import Omramo

/// App-level checks that need the app bundle. Core logic is tested in
/// Packages/OmramoCore/Tests (run with `swift test`).
@MainActor
final class OmramoAppTests: XCTestCase {

    func testFontFilesAreInTheBundleAndListedInInfoPlist() throws {
        let listed = try XCTUnwrap(Bundle.main.object(forInfoDictionaryKey: "UIAppFonts") as? [String])
        for fileName in Tokens.FontFamily.allFileNames {
            XCTAssertTrue(listed.contains(fileName), "\(fileName) is not listed under UIAppFonts")
            let name = (fileName as NSString).deletingPathExtension
            let ext = (fileName as NSString).pathExtension
            XCTAssertNotNil(Bundle.main.url(forResource: name, withExtension: ext), "\(fileName) is not in the bundle")
        }
    }

    func testFontsRegisterWithNoProblems() {
        XCTAssertEqual(FontRegistrar.registerBundledFonts(), [])
    }

    /// No runtime font fallback: each family resolves to its own font, not to the system font.
    func testEveryFamilyResolvesToItsOwnFont() {
        let expectedFamilies: [Tokens.FontFamily: String] = [
            .display: "Bricolage Grotesque",
            .reading: "Atkinson Hyperlegible Next",
            .system: "Inter",
        ]
        for (family, expected) in expectedFamilies {
            let font = OmramoFont.uiFont(Tokens.TypeRole(family, size: 20, weight: 500))
            XCTAssertTrue(
                font.familyName.hasPrefix(expected),
                "\(family) resolved to \(font.familyName) (\(font.fontName)); expected \(expected)"
            )
        }
        let italic = OmramoFont.uiFont(Tokens.TypeRole(.reading, size: 20, weight: 560, italic: true))
        XCTAssertTrue(italic.fontDescriptor.symbolicTraits.contains(.traitItalic), "italic resolved to \(italic.fontName)")
    }

    func testDisplayNameMatchesBrand() {
        XCTAssertEqual(Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String, Brand.displayName)
    }

    func testBundledLibraryLoadsInsideTheApp() throws {
        let library = try BundledContent.repository().loadLibrary()
        XCTAssertFalse(library.stories.isEmpty)
        XCTAssertEqual(library.stories.first?.tier, .low)
    }

    func testPostureLaunchArgument() {
        XCTAssertEqual(PaneLayoutProviders.simulation(from: ["Omramo", "-OmramoPosture", "unfolded"]), .unfolded)
        XCTAssertEqual(PaneLayoutProviders.simulation(from: ["Omramo", "-OmramoPosture", "folded"]), .folded)
        XCTAssertNil(PaneLayoutProviders.simulation(from: ["Omramo", "-OmramoPosture", "sideways"]))
        XCTAssertNil(PaneLayoutProviders.simulation(from: ["Omramo", "-OmramoPosture"]))
        XCTAssertNil(PaneLayoutProviders.simulation(from: ["Omramo"]))
    }

    func testOpenStoryLaunchArgument() {
        XCTAssertEqual(DebugLaunch.storyID(from: ["Omramo", "-OmramoOpenStory", "monkey-and-crocodile"]), StoryID("monkey-and-crocodile"))
        XCTAssertNil(DebugLaunch.storyID(from: ["Omramo", "-OmramoOpenStory"]))
        XCTAssertNil(DebugLaunch.storyID(from: ["Omramo", "-OmramoOpenStory", "-OmramoPosture"]))
        XCTAssertNil(DebugLaunch.storyID(from: ["Omramo"]))
    }

    func testReaderModelTurnsPagesAndSavesThePosition() throws {
        let library = try BundledContent.repository().loadLibrary()
        let story = try XCTUnwrap(library.stories.first)
        let progress = ReadingProgressStore(fileURL: nil)
        let model = ReaderModel(story: story, progress: progress)

        XCTAssertEqual(model.pageNumber, 1)
        XCTAssertNil(progress.lastPosition, "opening the model must not save anything by itself")

        model.didOpen()
        XCTAssertEqual(progress.lastPosition?.spreadID, story.spreads[0].id)

        model.turnPage()
        XCTAssertEqual(model.pageNumber, 2)
        XCTAssertEqual(progress.position(for: story.id)?.spreadID, story.spreads[1].id)

        // A new reader resumes at the saved page.
        XCTAssertEqual(ReaderModel(story: story, progress: progress).pageNumber, 2)

        for _ in 0..<(story.spreads.count + 3) {
            model.turnPage()
        }
        XCTAssertTrue(model.isLastPage)
        XCTAssertEqual(model.pageNumber, story.spreads.count)

        model.finish()
        XCTAssertNil(progress.lastPosition)
    }
}
