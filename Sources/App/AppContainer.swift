import Foundation

@MainActor
final class AppContainer {
    let appRouter = AppRouter()

    private let repository: TriviaRepository
    private let packRepository: PackRepository
    private let fetchQuestionsUseCase: FetchQuestionsUseCase
    private let fetchPackCategoriesUseCase: FetchPackCategoriesUseCase
    private let fetchPackStagesUseCase: FetchPackStagesUseCase
    private let fetchPackQuestionsUseCase: FetchPackQuestionsUseCase

    private struct StageKey: Hashable {
        let categoryId: String
        let difficulty: Difficulty
    }

    private var stageStoreCache: [StageKey: StageStore] = [:]
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
        self.packRepository = PackRepositoryImpl()
        self.fetchQuestionsUseCase = FetchQuestionsUseCase(repository: repository)
        self.fetchPackCategoriesUseCase = FetchPackCategoriesUseCase(repository: packRepository)
        self.fetchPackStagesUseCase = FetchPackStagesUseCase(repository: packRepository)
        self.fetchPackQuestionsUseCase = FetchPackQuestionsUseCase(repository: packRepository)
        self.saveResultUseCase = SaveResultUseCase(repository: repository)
        self.fetchHistoryUseCase = FetchHistoryUseCase(repository: repository)
    }

    func makeSplashStore() -> SplashStore {
        SplashStore(sideEffect: SplashSideEffectImpl())
    }

    func makeDashboardStore(initialSettings: QuizSettings) -> DashboardStore {
        DashboardStore(
            sideEffect: DashboardSideEffectImpl(
                router: appRouter,
                fetchPackCategoriesUseCase: fetchPackCategoriesUseCase
            ),
            initialSettings: initialSettings
        )
    }

    func makeQuizStore(settings: QuizSettings) -> QuizStore {
        QuizStore(
            settings: settings,
            sideEffect: QuizSideEffectImpl(
                fetchQuestionsUseCase: fetchQuestionsUseCase,
                fetchPackQuestionsUseCase: fetchPackQuestionsUseCase,
                router: appRouter
            )
        )
    }

    func makeResultStore(result: QuizResult) -> ResultStore {
        ResultStore(result: result, saveResultUseCase: saveResultUseCase, router: appRouter)
    }

    func makeHistoryStore() -> HistoryStore {
        HistoryStore(fetchHistoryUseCase: fetchHistoryUseCase)
    }

    func makeSettingsStore() -> SettingsStore {
        SettingsStore(sideEffect: SettingsSideEffectImpl())
    }

    func makeStageStore(categoryId: String, difficulty: Difficulty) -> StageStore {
        let key = StageKey(categoryId: categoryId, difficulty: difficulty)
        if let cached = stageStoreCache[key] {
            return cached
        }
        let store = StageStore(
            categoryId: categoryId,
            difficulty: difficulty,
            sideEffect: StageSideEffectImpl(
                router: appRouter,
                fetchPackStagesUseCase: fetchPackStagesUseCase
            )
        )
        stageStoreCache[key] = store
        return store
    }
}
