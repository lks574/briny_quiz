import Foundation

@MainActor
protocol DashboardSideEffect {
    func startQuiz(settings: QuizSettings)
}

@MainActor
final class DashboardSideEffectImpl: DashboardSideEffect {
    private let router: AppRouter

    init(router: AppRouter) {
        self.router = router
    }

    func startQuiz(settings: QuizSettings) {
        router.push(.quiz(settings))
    }
}
