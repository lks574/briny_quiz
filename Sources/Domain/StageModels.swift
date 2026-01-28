import Foundation

struct QuizStage: Hashable, Codable, Identifiable {
    let id: String
    let title: String
    let categoryId: String
    let difficulty: Difficulty
    let order: Int
}

struct StageProgress: Hashable, Codable {
    let stageId: String
    let isUnlocked: Bool
    let bestScore: Int
    let lastPlayedAt: Date?
}
