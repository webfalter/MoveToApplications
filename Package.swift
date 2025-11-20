// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MoveToApplications",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "MoveToApplications",
            targets: ["MoveToApplications"]
        )
    ],
    targets: [
        .target(
            name: "MoveToApplications",
            path: "Sources/MoveToApplications"
        ),
        .testTarget(
            name: "MoveToApplicationsTests",
            dependencies: ["MoveToApplications"],
            path: "Tests/MoveToApplicationsTests"
        )
    ]
)
