import Foundation
import Domain
import Data

@MainActor
protocol DashboardSideEffect {
    func fetchCategories() async -> Result<[QuizCategory], AppError>
    func fetchAllStages() async -> Result<[QuizStage], AppError>
    func fetchProgress() async -> Result<[StageProgress], AppError>
    func showStage(categoryId: String, difficulty: Difficulty)
    func startQuiz(settings: QuizSettings)
}

@MainActor
final class DashboardSideEffectImpl: DashboardSideEffect {
    private let router: AppRouter
    private let fetchPackCategoriesUseCase: FetchPackCategoriesUseCase
    private let fetchAllPackStagesUseCase: FetchAllPackStagesUseCase
    private let fetchStageProgressUseCase: FetchStageProgressUseCase

    init(
        router: AppRouter,
        fetchPackCategoriesUseCase: FetchPackCategoriesUseCase,
        fetchAllPackStagesUseCase: FetchAllPackStagesUseCase,
        fetchStageProgressUseCase: FetchStageProgressUseCase
    ) {
        self.router = router
        self.fetchPackCategoriesUseCase = fetchPackCategoriesUseCase
        self.fetchAllPackStagesUseCase = fetchAllPackStagesUseCase
        self.fetchStageProgressUseCase = fetchStageProgressUseCase
    }

    func fetchCategories() async -> Result<[QuizCategory], AppError> {
        do {
            let categories = try await fetchPackCategoriesUseCase.execute()
            return .success(categories)
        } catch {
            return .failure(AppError.map(error))
        }
    }

    func fetchAllStages() async -> Result<[QuizStage], AppError> {
        do {
            let stages = try await fetchAllPackStagesUseCase.execute()
            return .success(stages)
        } catch {
            return .failure(AppError.map(error))
        }
    }

    func fetchProgress() async -> Result<[StageProgress], AppError> {
        let progress = await fetchStageProgressUseCase.execute()
        return .success(progress)
    }

    func showStage(categoryId: String, difficulty: Difficulty) {
        router.push(.stage(categoryId: categoryId, difficulty: difficulty))
    }

    func startQuiz(settings: QuizSettings) {
        router.push(.quiz(settings))
    }
}
