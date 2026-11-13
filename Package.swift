// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KitePaste",
    platforms: [.macOS(.v13)],
    targets: [
        // 公共核心库：剪贴板监听 + 历史存储
        .target(
            name: "KitePasteCore",
            path: "Sources/KitePasteCore"
        ),
        // 命令行工具
        .executableTarget(
            name: "KitePaste",
            dependencies: ["KitePasteCore"],
            path: "Sources/KitePaste"
        ),
        // 菜单栏 GUI 应用
        .executableTarget(
            name: "KitePasteApp",
            dependencies: ["KitePasteCore"],
            path: "Sources/KitePasteApp"
        ),
    ]
)
