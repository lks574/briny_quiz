import Foundation

@MainActor
protocol QuizSideEffect {
    func loadQuestions(settings: QuizSettings, policy: CachePolicy) async -> Result<[QuizQuestion], AppError>
    func startTimer(onTick: @escaping () -> Void, shouldStop: @escaping () -> Bool) async
    func stopTimer() async
    func showResult(_ result: QuizResult)
}

@MainActor
final class QuizSideEffectImpl: QuizSideEffect {
    private enum TaskID: Hashable {
        case loadQuestions
        case timer
    }

    private let fetchQuestionsUseCase: FetchQuestionsUseCase
    private let router: AppRouter
    private let taskStore = TaskStore<TaskID>()

    init(fetchQuestionsUseCase: FetchQuestionsUseCase, router: AppRouter) {
        self.fetchQuestionsUseCase = fetchQuestionsUseCase
        self.router = router
    }

    func loadQuestions(settings: QuizSettings, policy: CachePolicy) async -> Result<[QuizQuestion], AppError> {
        await taskStore.cancel(.loadQuestions)
        do {
            let task = Task {
                try await fetchQuestionsUseCase.execute(settings: settings, policy: policy)
            }
            await taskStore.set(.loadQuestions, cancel: { task.cancel() })
            let questions = try await task.value
            await taskStore.remove(.loadQuestions)
            return .success(questions)
        } catch {
            await taskStore.remove(.loadQuestions)
            let appError = AppError.map(error)
            return .failure(appError)
        }
    }

    func startTimer(onTick: @escaping () -> Void, shouldStop: @escaping () -> Bool) async {
        let task = Task {
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
        await taskStore.setTask(.timer, task: task)
    }

    func stopTimer() async {
        await taskStore.cancel(.timer)
    }

    func showResult(_ result: QuizResult) {
        router.push(.result(result))
    }
}
