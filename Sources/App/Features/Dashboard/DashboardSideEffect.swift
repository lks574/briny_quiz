import Foundation

@MainActor
protocol DashboardSideEffect {
    func fetchCategories() async -> Result<[QuizCategory], AppError>
    func showStage(categoryId: String, difficulty: Difficulty)
}

@MainActor
final class DashboardSideEffectImpl: DashboardSideEffect {
    private let router: AppRouter
    private let fetchPackCategoriesUseCase: FetchPackCategoriesUseCase

    init(router: AppRouter, fetchPackCategoriesUseCase: FetchPackCategoriesUseCase) {
        self.router = router
        self.fetchPackCategoriesUseCase = fetchPackCategoriesUseCase
    }

    func fetchCategories() async -> Result<[QuizCategory], AppError> {
        do {
            let categories = try await fetchPackCategoriesUseCase.execute()
            return .success(categories)
        } catch {
            return .failure(AppError.map(error))
        }
    }

    func showStage(categoryId: String, difficulty: Difficulty) {
        router.push(.stage(categoryId: categoryId, difficulty: difficulty))
    }
}
