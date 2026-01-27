import Foundation

@MainActor
final class AppContainer {
    let appRouter = AppRouter()

    private let quizRepository: QuizRepository
    private let fetchQuizUseCase: FetchQuizUseCase

    init() {
        let cache = QuizCache()
        let repository = QuizRepositoryImpl(cache: cache)
        self.quizRepository = repository
        self.fetchQuizUseCase = FetchQuizUseCase(repository: repository)
    }

    func makeHomeStore() -> HomeStore {
        HomeStore(fetchQuizUseCase: fetchQuizUseCase, router: appRouter)
    }
}
