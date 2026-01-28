import Foundation

struct FetchPackStagesUseCase {
    private let repository: PackRepository

    init(repository: PackRepository) {
        self.repository = repository
    }

    func execute(categoryId: String, difficulty: Difficulty) async throws -> [QuizStage] {
        try await repository.fetchStages(categoryId: categoryId, difficulty: difficulty)
    }
}
