import Foundation

enum Command {
    case watch
    case list
    case copy(Int)
    case clear
    case help

    static func parse(_ args: [String]) -> Command {
        switch args.first {
        case "watch": return .watch
        case "list", nil: return .list
        case "copy":
            guard args.count > 1, let index = Int(args[1]) else {
                return .help
            }
            return .copy(index)
        case "clear": return .clear
        case "help", "-h", "--help": return .help
        default: return .help
        }
    }
}

let help = """
KitePaste —— 轻量剪贴板历史工具

用法:
  kitepaste watch          持续监听剪贴板并记录历史 (Ctrl+C 退出)
  kitepaste list           查看全部历史记录
  kitepaste copy <序号>    把第 N 条历史复制回剪贴板
  kitepaste clear          清空历史记录
  kitepaste help           显示帮助
"""

let args = Array(CommandLine.arguments.dropFirst())
let store = HistoryStore()

switch Command.parse(args) {
case .watch:
    print("KitePaste 正在监听剪贴板... (Ctrl+C 退出)")
    ClipboardWatcher(store: store).start()

case .list:
    let entries = store.load()
    if entries.isEmpty {
        print("暂无历史记录，试试 kitepaste watch")
    } else {
        for (i, entry) in entries.enumerated() {
            let preview = entry.content.replacingOccurrences(of: "\n", with: "\\n")
            let prefix = preview.count > 60 ? String(preview.prefix(60)) + "…" : preview
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd HH:mm"
            print("[\(i)] \(prefix)    (\(formatter.string(from: entry.timestamp)))")
        }
    }

case .copy(let index):
    let entries = store.load()
    guard entries.indices.contains(index) else {
        print("错误: 没有序号为 \(index) 的记录，运行 kitepaste list 查看")
        exit(1)
    }
    Clipboard.writeString(entries[index].content)
    print("已复制: \(entries[index].content.prefix(40))")

case .clear:
    store.clear()
    print("历史已清空")

case .help:
    print(help)
}
