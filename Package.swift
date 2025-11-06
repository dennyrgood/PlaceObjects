// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PlaceObjects",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "PlaceObjects",
            targets: ["PlaceObjects"]),
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .target(
            name: "PlaceObjects",
            dependencies: []),
        .testTarget(
            name: "PlaceObjectsTests",
            dependencies: ["PlaceObjects"]),
    ]
)
