# KitePaste

轻量级 macOS 剪贴板历史工具，纯 Swift 编写，无第三方依赖。

## 功能

- **监听剪贴板** —— 后台持续记录你复制的每一段文本
- **查看历史** —— 按时间倒序列出最近 200 条记录
- **重新复制** —— 一键把任意历史条目写回剪贴板
- **自动去重** —— 连续复制相同内容不会重复记录

## 环境要求

- macOS 13+
- Swift 5.9+（来自 Xcode 或 Command Line Tools）

## 编译

```bash
git clone https://github.com/ciyuan1234/KitePaste.git
cd KitePaste
swift build -c release
```

## 使用

```bash
# 编译产物路径
alias kitepaste="$(pwd)/.build/release/KitePaste"

kitepaste watch        # 开始监听剪贴板（Ctrl+C 退出）
kitepaste list         # 查看历史
kitepaste copy 0       # 把序号 0 的记录写回剪贴板
kitepaste clear        # 清空历史
```

## 工作原理

通过 `NSPasteboard.changeCount` 轮询检测剪贴板变化，历史以 JSON 格式
存储在 `~/.kitepaste/history.json`。

## License

MIT
