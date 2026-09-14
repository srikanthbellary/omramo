// swift-tools-version: 6.0
import PackageDescription

// OmramoCore holds everything that does not need UIKit, SwiftUI or StoreKit:
// the content model, the bundled prototype catalog, the entitlement state
// machine and the pane layout policy. Keeping it platform neutral means it
// builds and tests on Linux CI as well as inside Xcode.
let package = Package(
    name: "OmramoCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "OmramoCore", targets: ["OmramoCore"])
    ],
    targets: [
        .target(
            name: "OmramoCore",
            resources: [
                .copy("Resources/Content")
            ]
        ),
        .testTarget(
            name: "OmramoCoreTests",
            dependencies: ["OmramoCore"]
        )
    ],
    swiftLanguageModes: [.v6]
)
