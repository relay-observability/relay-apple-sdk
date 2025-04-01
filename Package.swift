// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Relay",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(name: "Relay", targets: ["Relay"]),
        .library(name: "RelayCommon", targets: ["RelayCommon"]),
        .library(name: "RelayCore", targets: ["RelayCore"])
    ],
    dependencies: [
        // Add external dependencies here
    ],
    targets: [
        .target(
            name: "RelayCommon",
            dependencies: []
        ),
        .target(
            name: "RelayCore",
            dependencies: ["RelayCommon"]
        ),
        .target(
            name: "Relay",
            dependencies: ["RelayCore", "RelayCommon"]
        ),
        .target(
            name: "RelayMocks",
            dependencies: ["RelayCommon", "RelayCore"],
            path: "Tests/RelayMocks"
        ),
        .testTarget(
            name: "RelayCoreTests",
            dependencies: ["RelayCore", "RelayCommon", "RelayMocks"]
        ),
        .testTarget(
            name: "RelayTests",
            dependencies: ["Relay"]
        )
    ]
)
