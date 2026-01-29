import Foundation
import Domain

actor StageProgressStore {
    private let fileManager = FileManager.default
    private let fileName = "progress.json"

    func load() -> [StageProgress] {
        guard let url = fileURL(),
              let data = try? Data(contentsOf: url),
              let progress = try? JSONDecoder().decode([StageProgress].self, from: data) else {
            return []
        }
        return progress
    }

    func save(_ progress: [StageProgress]) {
        guard let url = fileURL() else { return }
        let data = (try? JSONEncoder().encode(progress)) ?? Data()
        try? data.write(to: url, options: .atomic)
    }

    func update(stageId: String, score: Int, unlockNextStageId: String?) {
        var progress = load()
        if let index = progress.firstIndex(where: { $0.stageId == stageId }) {
            let existing = progress[index]
            let best = max(existing.bestScore, score)
            progress[index] = StageProgress(
                stageId: stageId,
                isUnlocked: true,
                bestScore: best,
                lastPlayedAt: Date()
            )
        } else {
            progress.append(StageProgress(stageId: stageId, isUnlocked: true, bestScore: score, lastPlayedAt: Date()))
        }
        if let nextId = unlockNextStageId {
            if let nextIndex = progress.firstIndex(where: { $0.stageId == nextId }) {
                let next = progress[nextIndex]
                progress[nextIndex] = StageProgress(
                    stageId: nextId,
                    isUnlocked: true,
                    bestScore: next.bestScore,
                    lastPlayedAt: next.lastPlayedAt
                )
            } else {
                progress.append(StageProgress(stageId: nextId, isUnlocked: true, bestScore: 0, lastPlayedAt: nil))
            }
        }
        save(progress)
    }

    private func fileURL() -> URL? {
        guard let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let dir = support.appendingPathComponent("StageProgress", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(fileName)
    }
}
