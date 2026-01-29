import Foundation

public struct FetchQuestionsUseCase {
    private let repository: TriviaRepository

    public init(repository: TriviaRepository) {
        self.repository = repository
    }

    public func execute(settings: QuizSettings, policy: CachePolicy) async throws -> [QuizQuestion] {
        try await repository.fetchQuestions(settings: settings, policy: policy)
    }
}
