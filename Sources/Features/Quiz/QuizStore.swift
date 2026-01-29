import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class QuizStore {
    public struct State: Equatable {
        var settings: QuizSettings
        var questions: [QuizQuestion]
        var currentIndex: Int
        var selectedAnswer: String?
        var isCorrect: Bool?
        var currentAnswers: [String]
        var timeRemaining: Int
        var isLoading: Bool
        var errorMessage: String?
        var isFinished: Bool
        var correctCount: Int

        var currentQuestion: QuizQuestion? {
            guard currentIndex < questions.count else { return nil }
            return questions[currentIndex]
        }

        static func initial(settings: QuizSettings) -> State {
            State(
                settings: settings,
                questions: [],
                currentIndex: 0,
                selectedAnswer: nil,
                isCorrect: nil,
                currentAnswers: [],
                timeRemaining: settings.timeLimitSeconds,
                isLoading: false,
                errorMessage: nil,
                isFinished: false,
                correctCount: 0
            )
        }
    }

    public enum Action: Equatable {
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
        case setAnswers([String])
        case setTimeRemaining(Int)
        case setFinished(Bool)
        case setError(String?)
        case setCorrectCount(Int)
    }

    private let sideEffect: QuizSideEffect

    public var state: State

    public init(settings: QuizSettings, sideEffect: QuizSideEffect) {
        self.sideEffect = sideEffect
        self.state = State.initial(settings: settings)
    }

    public func send(_ action: Action) {
        Task { await send(action) }
    }
}

private extension QuizStore {
    static let emptyQuestionsErrorMessage = "문제를 불러오지 못했습니다. 잠시 후 다시 시도해주세요."

    func loadQuestions() async {
        reduce(.setLoading(true))
        reduce(.setError(nil))
        let result = await sideEffect.loadQuestions(settings: state.settings, policy: .cacheFirst)
        switch result {
        case .success(let questions):
            if questions.isEmpty {
                reduce(.setError(Self.emptyQuestionsErrorMessage))
                break
            }
            reduce(.setQuestions(questions))
            reduce(.setIndex(0))
            resetQuestionState()
            await startTimer()
        case .failure(let appError):
            reduce(.setError(appError.displayMessage))
        }
        reduce(.setLoading(false))
    }

    func selectAnswer(_ answer: String) {
        if state.selectedAnswer == answer {
            return
        }
        let wasCorrect = state.isCorrect == true
        reduce(.setSelectedAnswer(answer))
        let isCorrect = answer == state.currentQuestion?.correctAnswer
        reduce(.setCorrect(isCorrect))
        switch (wasCorrect, isCorrect) {
        case (true, false):
            reduce(.setCorrectCount(max(0, state.correctCount - 1)))
        case (false, true):
            reduce(.setCorrectCount(state.correctCount + 1))
        default:
            break
        }
    }

    func startTimer() async {
        await sideEffect.startTimer(onTick: { [weak self] in
            self?.send(.timerTick)
        }, shouldStop: { [weak self] in
            self?.state.isFinished == true
        })
    }

    func advanceToNext() async {
        await sideEffect.stopTimer()
        if state.currentIndex + 1 >= state.questions.count {
            await finish()
        } else {
            reduce(.setIndex(state.currentIndex + 1))
            resetQuestionState()
            await startTimer()
        }
    }

    func finish() async {
        await sideEffect.stopTimer()
        reduce(.setFinished(true))
        let result = QuizResult(
            id: UUID().uuidString,
            date: Date(),
            totalCount: state.questions.count,
            correctCount: state.correctCount,
            settings: state.settings
        )
        sideEffect.showResult(result)
    }

    func resetQuestionState() {
        reduce(.setSelectedAnswer(nil))
        reduce(.setCorrect(nil))
        reduce(.setTimeRemaining(state.settings.timeLimitSeconds))
        reduce(.setAnswers(makeAnswers()))
    }

    func makeAnswers() -> [String] {
        guard let question = state.currentQuestion else { return [] }
        var answers = question.incorrectAnswers + [question.correctAnswer]
        answers.shuffle()
        return answers
    }

    func send(_ action: Action) async {
        switch action {
        case .onAppear:
            await loadQuestions()
        case .answerSelected(let answer):
            selectAnswer(answer)
        case .nextTapped:
            await advanceToNext()
        case .skipTapped:
            await advanceToNext()
        case .timerTick:
            guard state.timeRemaining > 0 else { return }
            reduce(.setTimeRemaining(state.timeRemaining - 1))
            if state.timeRemaining == 0 {
                await advanceToNext()
            }
        case .finish:
            await finish()
        }
    }

    func reduce(_ action: InternalAction) {
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
        case .setAnswers(let answers):
            state.currentAnswers = answers
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
