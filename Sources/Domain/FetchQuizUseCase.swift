import Foundation

struct FetchQuizUseCase {
    private let repository: QuizRepository

    init(repository: QuizRepository) {
        self.repository = repository
    }

    func execute() async throws -> [QuizQuestion] {
        try await repository.fetchQuestions()
    }
}
