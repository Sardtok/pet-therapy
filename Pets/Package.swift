// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Pets",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "Pets",
            targets: ["Pets"]
        )
    ],
    dependencies: [
        .package(path: "../Biosphere"),
        .package(path: "../Squanch")
    ],
    targets: [
        .target(
            name: "Pets",
            dependencies: [
                .product(name: "Biosphere", package: "Biosphere"),
                .product(name: "Squanch", package: "Squanch")
            ]
        )
    ]
)
