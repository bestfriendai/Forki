// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CalorieCameraKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CalorieCameraKit",
            targets: ["CalorieCameraKit"]),
    ],
    dependencies: [
        // No external dependencies - keeping it lean and controllable
        // Cloud APIs called via URLSession
        // Remote config via JSON endpoints
    ],
    targets: [
        // Main library target
        .target(
            name: "CalorieCameraKit",
            dependencies: [],
            path: "Sources/CalorieCameraKit",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        // Test target
        .testTarget(
            name: "CalorieCameraKitTests",
            dependencies: ["CalorieCameraKit"],
            path: "Tests/CalorieCameraKitTests"
        ),
    ]
)

