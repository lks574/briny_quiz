import Foundation
import Domain
import Data

@MainActor
public protocol QuizSideEffect {
    func loadQuestions(settings: QuizSettings, policy: CachePolicy) async -> Result<[QuizQuestion], AppError>
    func startTimer(onTick: @escaping () -> Void, shouldStop: @escaping () -> Bool) async
    func stopTimer() async
    func showResult(_ result: QuizResult)
}

@MainActor
public protocol QuizRouting: AnyObject {
    func showResult(_ result: QuizResult)
}

@MainActor
public final class QuizSideEffectImpl: QuizSideEffect {
    private enum TaskID: Hashable {
        case loadQuestions
        case timer
    }

    private let fetchQuestionsUseCase: FetchQuestionsUseCase
    private let fetchPackQuestionsUseCase: FetchPackQuestionsUseCase
    private let router: QuizRouting
    private let taskStore = TaskStore<TaskID>()

    public init(fetchQuestionsUseCase: FetchQuestionsUseCase, fetchPackQuestionsUseCase: FetchPackQuestionsUseCase, router: QuizRouting) {
        self.fetchQuestionsUseCase = fetchQuestionsUseCase
        self.fetchPackQuestionsUseCase = fetchPackQuestionsUseCase
        self.router = router
    }

    public func loadQuestions(settings: QuizSettings, policy: CachePolicy) async -> Result<[QuizQuestion], AppError> {
        await taskStore.cancel(.loadQuestions)
        do {
            let task = Task {
                if let stageId = settings.stageId, !stageId.isEmpty {
                    return try await fetchPackQuestionsUseCase.execute(stageId: stageId)
                }
                return try await fetchQuestionsUseCase.execute(settings: settings, policy: policy)
            }
            await taskStore.setTask(.loadQuestions, task: task)
            let questions = try await task.value
            await taskStore.remove(.loadQuestions)
            return .success(questions)
        } catch {
            await taskStore.remove(.loadQuestions)
            let appError = AppError.map(error)
            return .failure(appError)
        }
    }

    public func startTimer(onTick: @escaping () -> Void, shouldStop: @escaping () -> Bool) async {
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

    public func stopTimer() async {
        await taskStore.cancel(.timer)
    }

    public func showResult(_ result: QuizResult) {
        router.showResult(result)
    }
}
