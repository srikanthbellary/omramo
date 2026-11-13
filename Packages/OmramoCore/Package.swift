// swift-tools-version: 5.9
// OmramoCore: everything that needs no UI framework. Foundation only.
// Builds and tests with `swift test` on macOS or Linux; no third-party dependencies.
//
// Language mode: the tools version is 5.9 so older toolchains can run the tests. Strict
// concurrency checking is switched on, and the code is written to pass in Swift 6 language
// mode too. To build in Swift 6 mode, raise the tools version to 6.0 (see docs/BUILD.md).

import PackageDescription

let package = Package(
    name: "OmramoCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
    ],
    products: [
        .library(name: "OmramoCore", targets: ["OmramoCore"]),
    ],
    targets: [
        .target(
            name: "OmramoCore",
            resources: [
                // The bundled story content. Copied as a folder so the directory layout of
                // docs/ARCHITECTURE.md §6.2 is preserved inside the resource bundle.
                .copy("Resources/Content"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "OmramoCoreTests",
            dependencies: ["OmramoCore"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
    ]
)
