import Foundation
import Observation

@MainActor
@Observable
final class QuizStore {
    struct State: Equatable {
        var settings: QuizSettings
        var questions: [QuizQuestion]
        var currentIndex: Int
        var selectedAnswer: String?
        var isCorrect: Bool?
        var timeRemaining: Int
        var isLoading: Bool
        var errorMessage: String?
        var isFinished: Bool
        var correctCount: Int

        var currentQuestion: QuizQuestion? {
            guard currentIndex < questions.count else { return nil }
            return questions[currentIndex]
        }
    }

    enum Action: Equatable {
        case onAppear
        case answerSelected(String)
        case nextTapped
        case skipTapped
        case timerTick
        case finish
    }

    enum InternalAction: Equatable {
        case setLoading(Bool)
        case setQuestions([QuizQuestion])
        case setIndex(Int)
        case setSelectedAnswer(String?)
        case setCorrect(Bool?)
        case setTimeRemaining(Int)
        case setFinished(Bool)
        case setError(String?)
        case setCorrectCount(Int)
    }

    private let fetchQuestionsUseCase: FetchQuestionsUseCase
    private let router: AppRouter
    private var loadTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?

    var state: State

    init(settings: QuizSettings, fetchQuestionsUseCase: FetchQuestionsUseCase, router: AppRouter) {
        self.fetchQuestionsUseCase = fetchQuestionsUseCase
        self.router = router
        self.state = State(
            settings: settings,
            questions: [],
            currentIndex: 0,
            selectedAnswer: nil,
            isCorrect: nil,
            timeRemaining: settings.timeLimitSeconds,
            isLoading: false,
            errorMessage: nil,
            isFinished: false,
            correctCount: 0
        )
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            loadQuestions()
        case .answerSelected(let answer):
            selectAnswer(answer)
        case .nextTapped:
            goNext()
        case .skipTapped:
            skip()
        case .timerTick:
            tick()
        case .finish:
            finish()
        }
    }

    private func loadQuestions() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            reduce(.setLoading(true))
            reduce(.setError(nil))
            do {
                let questions = try await fetchQuestionsUseCase.execute(settings: state.settings, policy: .cacheFirst)
                reduce(.setQuestions(questions))
                reduce(.setIndex(0))
                resetQuestionState()
                startTimer()
            } catch {
                let appError = AppError.map(error)
                reduce(.setError(appError.displayMessage))
            }
            reduce(.setLoading(false))
        }
    }

    private func selectAnswer(_ answer: String) {
        guard state.selectedAnswer == nil else { return }
        reduce(.setSelectedAnswer(answer))
        let isCorrect = answer == state.currentQuestion?.correctAnswer
        reduce(.setCorrect(isCorrect))
        if isCorrect {
            reduce(.setCorrectCount(state.correctCount + 1))
        }
    }

    private func goNext() {
        advanceToNext()
    }

    private func skip() {
        advanceToNext()
    }

    private func tick() {
        guard state.timeRemaining > 0 else { return }
        reduce(.setTimeRemaining(state.timeRemaining - 1))
        if state.timeRemaining == 0 {
            advanceToNext()
        }
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    self.send(.timerTick)
                }
                if self.state.isFinished {
                    break
                }
            }
        }
    }

    private func advanceToNext() {
        timerTask?.cancel()
        if state.currentIndex + 1 >= state.questions.count {
            finish()
        } else {
            reduce(.setIndex(state.currentIndex + 1))
            resetQuestionState()
            startTimer()
        }
    }

    private func finish() {
        timerTask?.cancel()
        reduce(.setFinished(true))
        let result = QuizResult(
            id: UUID().uuidString,
            date: Date(),
            totalCount: state.questions.count,
            correctCount: state.correctCount,
            settings: state.settings
        )
        router.push(.result(result))
    }

    private func resetQuestionState() {
        reduce(.setSelectedAnswer(nil))
        reduce(.setCorrect(nil))
        reduce(.setTimeRemaining(state.settings.timeLimitSeconds))
    }

    private func reduce(_ action: InternalAction) {
        switch action {
        case .setLoading(let isLoading):
            state.isLoading = isLoading
        case .setQuestions(let questions):
            state.questions = questions
        case .setIndex(let index):
            state.currentIndex = index
        case .setSelectedAnswer(let answer):
            state.selectedAnswer = answer
        case .setCorrect(let isCorrect):
            state.isCorrect = isCorrect
        case .setTimeRemaining(let timeRemaining):
            state.timeRemaining = timeRemaining
        case .setFinished(let isFinished):
            state.isFinished = isFinished
        case .setError(let message):
            state.errorMessage = message
        case .setCorrectCount(let count):
            state.correctCount = count
        }
    }
}
