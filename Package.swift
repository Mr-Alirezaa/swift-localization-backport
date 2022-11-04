// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-localization-backport",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "LocalizationBackport",
            targets: ["LocalizationBackport"]),
    ],
    targets: [
        .target(
            name: "LocalizationBackport",
            dependencies: []),
        .testTarget(
            name: "LocalizationBackportTests",
            dependencies: ["LocalizationBackport"]),
    ]
)
