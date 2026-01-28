import Foundation

struct FetchPackQuestionsUseCase {
    private let repository: PackRepository

    init(repository: PackRepository) {
        self.repository = repository
    }

    func execute(stageId: String) async throws -> [QuizQuestion] {
        try await repository.fetchQuestions(stageId: stageId)
    }
}
