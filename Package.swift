// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MMWormhole",
    platforms: [
        .iOS(.v11),
        .watchOS(.v2),
    ],
    products: [
        .library(
            name: "MMWormhole",
            targets: ["MMWormhole"]),
    ],
    targets: [
        .target(
            name: "MMWormhole",
            path: "Source",
            publicHeadersPath: ".",
            linkerSettings: [
                .linkedFramework("WatchConnectivity", .when(platforms: [.iOS])),
            ]),
    ])
