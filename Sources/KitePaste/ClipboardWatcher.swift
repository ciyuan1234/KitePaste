import Foundation
import AppKit

/// 与 macOS 系统剪贴板交互
enum Clipboard {
    private static var pasteboard: NSPasteboard { .general }

    static func readString() -> String? {
        guard let items = pasteboard.pasteboardItems?.first else { return nil }
        for type in [NSPasteboard.PasteboardType.string, NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")] {
            if let s = items.string(forType: type), !s.isEmpty {
                return s.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }

    static func writeString(_ text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

/// 剪贴板轮询监听器
final class ClipboardWatcher {
    private var timer: Timer?
    private let store: HistoryStore
    private var lastCount: Int

    init(store: HistoryStore) {
        self.store = store
        // 用 changeCount 判断剪贴板是否变化，比比对内容更可靠
        self.lastCount = NSPasteboard.general.changeCount
    }

    func start(interval: TimeInterval = 0.5) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            let count = NSPasteboard.general.changeCount
            guard count != self.lastCount else { return }
            self.lastCount = count
            if let text = Clipboard.readString() {
                self.store.append(text)
                print("已记录: \(text.prefix(40))")
            }
        }
        RunLoop.main.run()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
