// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VendureSwiftSDK",
    platforms: [
        .macOS(.v13),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "VendureSwiftSDK",
            targets: ["VendureSwiftSDK"]),
    ],
    dependencies: [
        // For SKIP.tools compatibility (Android cross-platform)
        .package(url: "https://source.skip.tools/skip.git", from: "1.2.0"),
        .package(url: "https://source.skip.tools/skip-foundation.git", from: "1.0.0"),
        .package(url: "https://source.skip.tools/skip-model.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        .target(
            name: "VendureSwiftSDK",
            dependencies: [
                .product(name: "SkipFoundation", package: "skip-foundation", condition: .when(platforms: [.iOS, .macOS, .tvOS, .watchOS, .visionOS])),
                .product(name: "SkipModel", package: "skip-model", condition: .when(platforms: [.iOS, .macOS, .tvOS, .watchOS, .visionOS]))
            ],
            path: "Sources",
            plugins: [
                .plugin(name: "skipstone", package: "skip")
            ]
        ),
        .testTarget(
            name: "VendureSwiftSDKTests",
            dependencies: [
                "VendureSwiftSDK"
            ],
            path: "Tests",
            plugins: [
                .plugin(name: "skipstone", package: "skip")
            ]
        ),
    ]
)
