import Foundation

struct FetchQuestionsUseCase {
    private let repository: TriviaRepository

    init(repository: TriviaRepository) {
        self.repository = repository
    }

    func execute(settings: QuizSettings, policy: CachePolicy) async throws -> [QuizQuestion] {
        try await repository.fetchQuestions(settings: settings, policy: policy)
    }
}
