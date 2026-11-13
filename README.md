# KitePaste

轻量级 macOS 剪贴板历史工具，纯 Swift 编写，无第三方依赖。提供**菜单栏应用**与**命令行**两种形态。

## 功能

- **菜单栏常驻** —— 点击状态栏图标即弹出历史面板
- **一键复贴** —— 点击任意历史条目立即写回剪贴板
- **实时监听** —— 自动记录你复制的每一段文本（去重、上限 200 条）
- **搜索历史** —— 面板内关键词过滤
- **命令行模式** —— watch / list / copy / clear 全套 CLI

## 环境要求

- macOS 13+
- Swift 5.9+（来自 Xcode 或 Command Line Tools）

## 编译

```bash
git clone https://github.com/ciyuan1234/KitePaste.git
cd KitePaste
swift build -c release          # 命令行 + GUI 全部编译
```

## 打包 .app

```bash
./scripts/package.sh            # 产出 .build/release/KitePaste.app
```

## 使用

### 菜单栏应用

双击 `KitePaste.app` 启动，菜单栏出现 📋 图标，点击查看历史、点击条目复贴。

### 命令行

```bash
kitepaste watch        # 开始监听剪贴板（Ctrl+C 退出）
kitepaste list         # 查看历史
kitepaste copy 0       # 把序号 0 的记录写回剪贴板
kitepaste clear        # 清空历史
```

## 工作原理

通过 `NSPasteboard.changeCount` 轮询检测剪贴板变化，历史以 JSON 格式
存储在 `~/.kitepaste/history.json`。菜单栏应用基于 SwiftUI `MenuBarExtra`，
LSUIElement 模式不占用 Dock。

## License

MIT
