// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MoviesCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
    ],
    products: [
        .library(
            name: "MoviesCore",
            targets: ["MoviesCore"]
        ),
        .library(
            name: "MoviesCoreFramework",
            type: .dynamic,
            targets: ["MoviesCore"]
        ),
    ],
    targets: [
        .target(
            name: "MoviesCore",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "MoviesCoreTests",
            dependencies: ["MoviesCore"],
            resources: [.process("Resources")],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ]
)
