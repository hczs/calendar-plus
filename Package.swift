// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CalendarPlus",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CalendarPlus", targets: ["CalendarPlus"])
    ],
    targets: [
        .target(
            name: "CalendarPlus",
            path: "CalendarPlus"
        ),
        .testTarget(
            name: "CalendarPlusTests",
            dependencies: ["CalendarPlus"],
            path: "CalendarPlusTests"
        )
    ]
)
