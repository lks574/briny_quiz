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

    init(router: AppRouter) {
        self.router = router
    }

    func fetchStages(categoryId: String, difficulty: Difficulty) async -> Result<[QuizStage], AppError> {
        let stages = (1...10).map { index in
            QuizStage(
                id: "\(categoryId)_\(difficulty.rawValue)_\(index)",
                title: "Stage \(index)",
                categoryId: categoryId,
                difficulty: difficulty,
                order: index
            )
        }
        return .success(stages)
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
