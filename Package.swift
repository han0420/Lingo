// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Lingo",
    defaultLocalization: "zh-Hans",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "Lingo", targets: ["Lingo"])],
    targets: [
        .executableTarget(
            name: "Lingo",
            path: "Sources/Lingo",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "LingoTests",
            dependencies: ["Lingo"],
            path: "Tests/LingoTests"
        )
    ]
)
