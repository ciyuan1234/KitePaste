// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KitePaste",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "KitePaste",
            path: "Sources/KitePaste"
        )
    ]
)
