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

    init(router: AppRouter, fetchPackStagesUseCase: FetchPackStagesUseCase) {
        self.router = router
        self.fetchPackStagesUseCase = fetchPackStagesUseCase
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
        let firstStageId = "\(categoryId)_\(difficulty.rawValue)_1"
        let progress = StageProgress(stageId: firstStageId, isUnlocked: true, bestScore: 0, lastPlayedAt: nil)
        return .success([progress])
    }

    func startQuiz(settings: QuizSettings) {
        router.push(.quiz(settings))
    }
}
