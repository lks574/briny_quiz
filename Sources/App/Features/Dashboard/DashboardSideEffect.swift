import Foundation

@MainActor
protocol DashboardSideEffect {
    func showStage(categoryId: String, difficulty: Difficulty)
}

@MainActor
final class DashboardSideEffectImpl: DashboardSideEffect {
    private let router: AppRouter

    init(router: AppRouter) {
        self.router = router
    }

    func showStage(categoryId: String, difficulty: Difficulty) {
        router.push(.stage(categoryId: categoryId, difficulty: difficulty))
    }
}
