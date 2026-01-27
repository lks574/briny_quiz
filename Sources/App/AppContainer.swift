import Foundation

@MainActor
final class AppContainer {
    let appRouter = AppRouter()

    private let repository: TriviaRepository
    private let fetchQuestionsUseCase: FetchQuestionsUseCase
    private let saveResultUseCase: SaveResultUseCase
    private let fetchHistoryUseCase: FetchHistoryUseCase

    init() {
        let apiClient = APIClient()
        let cache = QuestionCache()
        let historyCache = HistoryCache()
        let tokenStore = TriviaTokenStore()
        let repository = TriviaRepositoryImpl(
            apiClient: apiClient,
            cache: cache,
            historyStore: historyCache,
            tokenStore: tokenStore
        )
        self.repository = repository
        self.fetchQuestionsUseCase = FetchQuestionsUseCase(repository: repository)
        self.saveResultUseCase = SaveResultUseCase(repository: repository)
        self.fetchHistoryUseCase = FetchHistoryUseCase(repository: repository)
    }

    func makeSplashStore() -> SplashStore {
        SplashStore()
    }

    func makeDashboardStore(initialSettings: QuizSettings) -> DashboardStore {
        DashboardStore(router: appRouter, initialSettings: initialSettings)
    }

    func makeQuizStore(settings: QuizSettings) -> QuizStore {
        QuizStore(settings: settings, fetchQuestionsUseCase: fetchQuestionsUseCase, router: appRouter)
    }

    func makeResultStore(result: QuizResult) -> ResultStore {
        ResultStore(result: result, saveResultUseCase: saveResultUseCase, router: appRouter)
    }

    func makeHistoryStore() -> HistoryStore {
        HistoryStore(fetchHistoryUseCase: fetchHistoryUseCase)
    }
}
