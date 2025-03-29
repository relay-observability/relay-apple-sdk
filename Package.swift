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
        .library(name: "RelayCore", targets: ["RelayCore"])
    ],
    dependencies: [
        // Add external dependencies here
    ],
    targets: [
        .target(
            name: "RelayCore",
            dependencies: []
        ),
        .target(
            name: "Relay",
            dependencies: ["RelayCore"]
        ),
        .testTarget(
            name: "RelayCoreTests",
            dependencies: ["RelayCore"]
        ),
        .testTarget(
            name: "RelayTests",
            dependencies: ["Relay"]
        )
    ]
)
