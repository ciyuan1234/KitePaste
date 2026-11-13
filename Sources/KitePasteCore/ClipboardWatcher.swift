import Foundation
import AppKit

/// 与 macOS 系统剪贴板交互
public enum Clipboard {
    private static var pasteboard: NSPasteboard { .general }

    public static func readString() -> String? {
        guard let items = pasteboard.pasteboardItems?.first else { return nil }
        for type in [NSPasteboard.PasteboardType.string,
                     NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")] {
            if let s = items.string(forType: type), !s.isEmpty {
                return s.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }

    public static func writeString(_ text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    public static var changeCount: Int { pasteboard.changeCount }
}

/// 剪贴板轮询监听器（供 GUI 应用作为 ObservableObject 使用）
public final class ClipboardWatcher: ObservableObject {
    private var timer: Timer?
    private let store: HistoryStore
    private var lastCount: Int
    private var ignoreNext: Bool = false

    /// GUI 绑定用：当前历史列表
    @Published public private(set) var entries: [ClipEntry] = []

    public init(store: HistoryStore) {
        self.store = store
        self.lastCount = Clipboard.changeCount
        self.entries = store.load()
    }

    /// 轮询模式（命令行 watch 用）
    public func startPolling(interval: TimeInterval = 0.5) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.poll()
        }
        RunLoop.main.run()
    }

    /// GUI 用：启动但不阻塞 RunLoop
    public func startBackground(interval: TimeInterval = 0.5) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.poll()
        }
    }

    /// 手动 poll 一次（也可供测试调用）
    public func poll() {
        let count = Clipboard.changeCount
        guard count != lastCount else { return }
        lastCount = count
        if ignoreNext {
            ignoreNext = false
            return
        }
        if let text = Clipboard.readString() {
            if store.append(text) {
                entries = store.load()
            }
        }
    }

    /// 用户主动复制回剪贴板时，忽略由此产生的 changeCount
    public func suppressNextChange() {
        ignoreNext = true
    }

    public func reload() {
        entries = store.load()
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }
}
