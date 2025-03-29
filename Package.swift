// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Relay",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(name: "RelayCore", targets: ["RelayCore"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "RelayCore", dependencies: []),
        .testTarget(name: "RelayCoreTests", dependencies: ["RelayCore"]),
    ]
)