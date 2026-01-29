import Foundation
import Domain

public actor HistoryCache {
    private let fileURL: URL

    public init(fileManager: FileManager = .default) {
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = directory.appendingPathComponent("quiz_history.json")
    }

    func load() async -> [HistoryItem] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return []
        }
        return (try? JSONDecoder().decode([HistoryItem].self, from: data)) ?? []
    }

    func save(_ items: [HistoryItem]) async {
        guard let data = try? JSONEncoder().encode(items) else {
            return
        }
        try? data.write(to: fileURL, options: [.atomic])
    }

    func append(_ item: HistoryItem) async {
        var current = await load()
        current.insert(item, at: 0)
        await save(current)
    }

    func clear() async {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
