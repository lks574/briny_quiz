import Foundation

public struct FetchPackStagesUseCase {
    private let repository: PackRepository

    public init(repository: PackRepository) {
        self.repository = repository
    }

    public func execute(categoryId: String, difficulty: Difficulty) async throws -> [QuizStage] {
        try await repository.fetchStages(categoryId: categoryId, difficulty: difficulty)
    }
}
