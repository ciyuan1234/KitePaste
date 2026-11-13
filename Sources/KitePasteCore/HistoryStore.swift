import Foundation

/// 剪贴板历史记录条目
public struct ClipEntry: Codable, Equatable, Identifiable {
    public var id: UUID { uuid }
    public let uuid: UUID
    public let content: String
    public let timestamp: Date

    public init(content: String, timestamp: Date = Date()) {
        self.uuid = UUID()
        self.content = content
        self.timestamp = timestamp
    }

    private enum CodingKeys: String, CodingKey {
        case uuid, content, timestamp
    }
}

/// 负责历史的存储与读取（JSON 文件持久化）
public final class HistoryStore {
    let storageURL: URL

    public init() {
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".kitepaste")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        storageURL = dir.appendingPathComponent("history.json")
    }

    public func load() -> [ClipEntry] {
        guard let data = try? Data(contentsOf: storageURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([ClipEntry].self, from: data)) ?? []
    }

    public func save(_ entries: [ClipEntry]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(entries) else { return }
        try? data.write(to: storageURL, options: .atomic)
    }

    /// 追加一条记录（去重：与最近一条相同则跳过）
    public func append(_ content: String) -> Bool {
        var entries = load()
        if entries.first?.content == content { return false }
        entries.insert(ClipEntry(content: content), at: 0)
        if entries.count > 200 { entries.removeLast(entries.count - 200) }
        save(entries)
        return true
    }

    /// 删除指定序号的记录
    public func remove(at index: Int) {
        var entries = load()
        guard entries.indices.contains(index) else { return }
        entries.remove(at: index)
        save(entries)
    }

    public func clear() {
        save([])
    }
}
