// swift-tools-version:5.9
import PackageDescription

// Swift Package Manager distribution manifest for SRG Login SDK (iOS/tvOS)
//
// This file is updated automatically by the CI pipeline in
// https://github.com/swisstxt/srg-login-mobile-sdk on each release.
// The url and checksum below always reflect the latest published version.
//
// Consumers: see README.md for integration instructions.

let package = Package(
    name: "SRGLoginSDK",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "SRGLoginSDK",
            targets: ["SRGLoginCore"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "SRGLoginCore",
            url: "https://github.com/swisstxt/srg-login-sdk-distribution-apple/releases/download/v1.0.0-beta.12/SRGLoginCore.xcframework.zip",
            checksum: "7214dbbba20f3d20ada3d714f9da3681e5558dbff1a7533a096b83e9dbe9e90a"
        )
    ]
)