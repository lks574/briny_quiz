import Foundation

public struct QuizStage: Hashable, Codable, Identifiable {
    public let id: String
    public let title: String
    public let categoryId: String
    public let difficulty: Difficulty
    public let order: Int

    public init(id: String, title: String, categoryId: String, difficulty: Difficulty, order: Int) {
        self.id = id
        self.title = title
        self.categoryId = categoryId
        self.difficulty = difficulty
        self.order = order
    }
}

public struct StageProgress: Hashable, Codable {
    public let stageId: String
    public let isUnlocked: Bool
    public let bestScore: Int
    public let lastPlayedAt: Date?

    public init(stageId: String, isUnlocked: Bool, bestScore: Int, lastPlayedAt: Date?) {
        self.stageId = stageId
        self.isUnlocked = isUnlocked
        self.bestScore = bestScore
        self.lastPlayedAt = lastPlayedAt
    }
}
