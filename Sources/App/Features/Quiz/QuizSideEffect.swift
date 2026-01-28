import Foundation

@MainActor
protocol QuizSideEffect {
    func loadQuestions(settings: QuizSettings, policy: CachePolicy) async -> Result<[QuizQuestion], AppError>
    func startTimer(onTick: @escaping () -> Void, shouldStop: @escaping () -> Bool)
    func stopTimer()
    func showResult(_ result: QuizResult)
}

@MainActor
final class QuizSideEffectImpl: QuizSideEffect {
    private let fetchQuestionsUseCase: FetchQuestionsUseCase
    private let router: AppRouter
    private var loadTask: Task<[QuizQuestion], Error>?
    private var timerTask: Task<Void, Never>?

    init(fetchQuestionsUseCase: FetchQuestionsUseCase, router: AppRouter) {
        self.fetchQuestionsUseCase = fetchQuestionsUseCase
        self.router = router
    }

    func loadQuestions(settings: QuizSettings, policy: CachePolicy) async -> Result<[QuizQuestion], AppError> {
        loadTask?.cancel()
        do {
            let task = Task {
                try await fetchQuestionsUseCase.execute(settings: settings, policy: policy)
            }
            loadTask = task
            let questions = try await task.value
            return .success(questions)
        } catch {
            let appError = AppError.map(error)
            return .failure(appError)
        }
    }

    func startTimer(onTick: @escaping () -> Void, shouldStop: @escaping () -> Bool) {
        stopTimer()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    onTick()
                }
                let isFinished = await MainActor.run {
                    shouldStop()
                }
                if isFinished {
                    break
                }
            }
        }
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    func showResult(_ result: QuizResult) {
        router.push(.result(result))
    }
}
