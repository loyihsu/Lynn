// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lynn",
    products: [
        .library(name: "Lynn", targets: ["Lynn"]),
        .library(name: "LynnURLSession", targets: ["LynnURLSession"]),
        .library(name: "LynnUserDefaultsStorageManager", targets: ["LynnUserDefaultsStorageManager"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Lynn", dependencies: []),
        .target(name: "LynnURLSession", dependencies: ["Lynn"]),
        .target(name: "LynnUserDefaultsStorageManager", dependencies: ["Lynn"]),
    ]
)
