// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GliderNetWatcher",
    platforms: [
        .iOS(.v13), .macOS(.v11), .tvOS(.v13)
    ],
    products: [
        .library(name: "GliderNetWatcher", targets: ["GliderNetWatcher"])
    ],
    dependencies: [
        .package(url: "https://github.com/immobiliare/Glider.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .target(
            name: "GliderNetWatcher",
            dependencies: [
                "Glider"
            ],
            path:"GliderNetWatcher/Sources"
        ),
        .testTarget(
            name: "GliderNetWatcherTests",
            dependencies: [
                "Glider",
                "GliderNetWatcher"
            ],
            path: "Tests/GliderNetWatcherTests"
        )
    ]
)
