import Foundation

@MainActor
protocol StageSideEffect {
    func fetchStages(categoryId: String, difficulty: Difficulty) async -> Result<[QuizStage], AppError>
    func fetchProgress(categoryId: String, difficulty: Difficulty) async -> Result<[StageProgress], AppError>
    func startQuiz(settings: QuizSettings)
}

@MainActor
final class StageSideEffectImpl: StageSideEffect {
    private let router: AppRouter
    private let fetchPackStagesUseCase: FetchPackStagesUseCase
    private let fetchStageProgressUseCase: FetchStageProgressUseCase

    init(
        router: AppRouter,
        fetchPackStagesUseCase: FetchPackStagesUseCase,
        fetchStageProgressUseCase: FetchStageProgressUseCase
    ) {
        self.router = router
        self.fetchPackStagesUseCase = fetchPackStagesUseCase
        self.fetchStageProgressUseCase = fetchStageProgressUseCase
    }

    func fetchStages(categoryId: String, difficulty: Difficulty) async -> Result<[QuizStage], AppError> {
        do {
            let stages = try await fetchPackStagesUseCase.execute(categoryId: categoryId, difficulty: difficulty)
            return .success(stages)
        } catch {
            return .failure(AppError.map(error))
        }
    }

    func fetchProgress(categoryId: String, difficulty: Difficulty) async -> Result<[StageProgress], AppError> {
        let progress = await fetchStageProgressUseCase.execute()
        return .success(progress)
    }

    func startQuiz(settings: QuizSettings) {
        router.push(.quiz(settings))
    }
}
