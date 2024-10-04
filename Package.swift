// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IgniteStarter",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/twostraws/Ignite.git", revision: "a4bade4363ad6525b671ad49e23089970780b47b"),
        .package(url: "https://github.com/satoshi-takano/OpenGraph", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "IgniteStarter",
            dependencies: ["Ignite", "OpenGraph"]),
    ]
)
