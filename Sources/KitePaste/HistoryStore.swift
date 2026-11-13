import Foundation

/// 剪贴板历史记录条目
struct ClipEntry: Codable, Equatable {
    let content: String
    let timestamp: Date
}

/// 负责历史的存储与读取（JSON 文件持久化）
final class HistoryStore {
    let storageURL: URL

    init() {
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".kitepaste")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        storageURL = dir.appendingPathComponent("history.json")
    }

    func load() -> [ClipEntry] {
        guard let data = try? Data(contentsOf: storageURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([ClipEntry].self, from: data)) ?? []
    }

    func save(_ entries: [ClipEntry]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(entries) else { return }
        try? data.write(to: storageURL, options: .atomic)
    }

    /// 追加一条记录（去重：与最近一条相同则跳过）
    func append(_ content: String) {
        var entries = load()
        if entries.first?.content == content { return }
        entries.insert(ClipEntry(content: content, timestamp: Date()), at: 0)
        if entries.count > 200 { entries.removeLast(entries.count - 200) }
        save(entries)
    }

    func clear() {
        save([])
    }
}
