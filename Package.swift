// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PhotoManager",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "PhotoManager",
            targets: ["PhotoManager"]
        )
    ],
    targets: [
        .target(
            name: "PhotoManager",
            path: "PhotoManager"
        )
    ]
)