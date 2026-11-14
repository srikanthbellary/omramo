import XCTest

/// Simulator screenshot helpers. Not part of the regular unit-test suite (see the OmramoShots
/// scheme). Used to rotate the simulated iPad and capture landscape frames from the command line.
final class ShotTests: XCTestCase {
    private var shotDir: String {
        ProcessInfo.processInfo.environment["OMRAMO_SHOT_DIR"] ?? "/tmp/omramo-shots"
    }

    override func setUp() {
        continueAfterFailure = false
    }

    func testIPadLandscapeLibrary() throws {
        try capture(
            arguments: [],
            orientation: .landscapeLeft,
            name: "r2-ipad-library-landscape.png"
        )
    }

    func testIPadLandscapeReaderMonkey() throws {
        try capture(
            arguments: ["-OmramoOpenStory", "monkey-and-crocodile"],
            orientation: .landscapeLeft,
            name: "r2-ipad-reader-monkey-landscape.png"
        )
    }

    func testIPadLandscapeTapToSee() throws {
        try capture(
            arguments: ["-OmramoOpenStory", "monkey-and-crocodile", "-OmramoOpenCard", "river-bank"],
            orientation: .landscapeLeft,
            name: "r2-ipad-tap-to-see-landscape.png"
        )
    }

    func testIPadLandscapeReaderAnansi() throws {
        try capture(
            arguments: ["-OmramoOpenStory", "anansi-wisdom"],
            orientation: .landscapeLeft,
            name: "r2-ipad-reader-anansi-landscape.png"
        )
    }

    private func capture(arguments: [String], orientation: UIDeviceOrientation, name: String) throws {
        XCUIDevice.shared.orientation = orientation
        let app = XCUIApplication()
        app.launchArguments = arguments
        app.launch()
        // Art and orientation need a moment to settle.
        sleep(5)
        try FileManager.default.createDirectory(atPath: shotDir, withIntermediateDirectories: true)
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let url = URL(fileURLWithPath: shotDir).appendingPathComponent(name)
        try data.write(to: url)
        app.terminate()
    }
}
