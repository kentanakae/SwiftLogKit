// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftLogKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SwiftLogKit",
            targets: ["SwiftLogKit"]),
    ],
    targets: [
        .target(
            name: "SwiftLogKit"),
        .testTarget(
            name: "SwiftLogKitTests",
            dependencies: ["SwiftLogKit"]
        ),
    ]
)

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(.enableExperimentalFeature("StrictConcurrency", .when(configuration: .debug)))
    settings.append(.enableUpcomingFeature("ConciseMagicFile", .when(configuration: .debug)))
    settings.append(.enableUpcomingFeature("ExistentialAny", .when(configuration: .debug)))
    target.swiftSettings = settings
}
