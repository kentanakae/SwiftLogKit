// swift-tools-version: 6.1

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
    settings.append(.enableUpcomingFeature("ExistentialAny", .when(configuration: .debug)))
    target.swiftSettings = settings
}
