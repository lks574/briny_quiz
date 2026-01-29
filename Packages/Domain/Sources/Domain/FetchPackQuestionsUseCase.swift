import Foundation

public struct FetchPackQuestionsUseCase {
    private let repository: PackRepository

    public init(repository: PackRepository) {
        self.repository = repository
    }

    public func execute(stageId: String) async throws -> [QuizQuestion] {
        try await repository.fetchQuestions(stageId: stageId)
    }
}
