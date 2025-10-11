// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WeightedList",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        // Build an executable that can be run via `swift run weighted-list`
        .executable(name: "weighted-list", targets: ["WeightedList"])
    ],
    targets: [
        .executableTarget(
            name: "WeightedList",
            path: "Sources/WeightedList"
        )
    ]
)
