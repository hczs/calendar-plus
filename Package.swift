// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CalendarPlus",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CalendarPlus", targets: ["CalendarPlus"]),
        .executable(name: "CalendarPlusApp", targets: ["CalendarPlusApp"])
    ],
    targets: [
        .target(
            name: "CalendarPlus",
            path: "CalendarPlus"
        ),
        .executableTarget(
            name: "CalendarPlusApp",
            dependencies: ["CalendarPlus"],
            path: "CalendarPlusApp"
        ),
        .testTarget(
            name: "CalendarPlusTests",
            dependencies: ["CalendarPlus"],
            path: "CalendarPlusTests"
        )
    ]
)
