import SwiftUI
import KitePasteCore

@main
struct KitePasteMenuBarApp: App {
    @StateObject private var watcher = ClipboardWatcher(store: HistoryStore())

    init() {
        // 防止运行结束就退出：菜单栏应用需要常驻
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarPanel(watcher: watcher)
        } label: {
            Image(systemName: "doc.on.clipboard")
        }
        .menuBarExtraStyle(.window)
    }
}

/// 菜单栏弹窗内容
struct MenuBarPanel: View {
    @ObservedObject var watcher: ClipboardWatcher
    @State private var searchText = ""
    private let store = HistoryStore()

    var filtered: [ClipEntry] {
        guard !searchText.isEmpty else { return watcher.entries }
        return watcher.entries.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 顶部搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("搜索历史…", text: $searchText)
                    .textFieldStyle(.plain)
                    .padding(.vertical, 4)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)

            Divider()

            if filtered.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clipboard")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "暂无剪贴板历史\n复制点什么试试" : "没有匹配的记录")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                // 历史列表
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(filtered.enumerated()), id: \.element.id) { _, entry in
                            HistoryRow(entry: entry) {
                                watcher.suppressNextChange()
                                Clipboard.writeString(entry.content)
                            }
                        }
                    }
                }
                .frame(maxHeight: 320)
            }

            Divider()

            // 底部操作
            HStack {
                Text("\(watcher.entries.count) 条记录")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("清空") {
                    store.clear()
                    watcher.reload()
                }
                Divider().frame(height: 14)
                Button("退出") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .frame(width: 320)
        .onAppear {
            // 面板打开时刷新一次列表并开始后台监听
            watcher.reload()
            watcher.startBackground()
        }
    }
}

/// 单条历史记录行
struct HistoryRow: View {
    let entry: ClipEntry
    let onTap: () -> Void
    @State private var copied = false

    var body: some View {
        Button(action: {
            onTap()
            copied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { copied = false }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.content.replacingOccurrences(of: "\n", with: " ⏎ "))
                        .font(.system(size: 12))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundColor(.primary)
                    Text(entry.timestamp.formatted(.dateTime.month().day().hour().minute()))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                Spacer()
                if copied {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        Divider().padding(.leading, 10)
    }
}
