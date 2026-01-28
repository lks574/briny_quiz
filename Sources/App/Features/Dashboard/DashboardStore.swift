import Observation

@MainActor
@Observable
final class DashboardStore {
    struct State: Equatable {
        var selectedDifficulty: Difficulty
        var selectedType: QuestionType
        var questionCount: Int
        var timeLimitSeconds: Int
        var isStarting: Bool
        var errorMessage: String?
    }

    enum Action: Equatable {
        case difficultySelected(Difficulty)
        case typeSelected(QuestionType)
        case questionCountChanged(Int)
        case timeLimitChanged(Int)
        case startTapped
    }

    enum InternalAction: Equatable {
        case setDifficulty(Difficulty)
        case setType(QuestionType)
        case setQuestionCount(Int)
        case setTimeLimit(Int)
        case setStarting(Bool)
        case setError(String?)
    }

    private let sideEffect: DashboardSideEffect

    var state: State

    init(sideEffect: DashboardSideEffect, initialSettings: QuizSettings) {
        self.sideEffect = sideEffect
        self.state = State(
            selectedDifficulty: initialSettings.difficulty,
            selectedType: initialSettings.type,
            questionCount: initialSettings.amount,
            timeLimitSeconds: initialSettings.timeLimitSeconds,
            isStarting: false,
            errorMessage: nil
        )
    }

    func send(_ action: Action) {
        switch action {
        case .difficultySelected(let difficulty):
            reduce(.setDifficulty(difficulty))
        case .typeSelected(let type):
            reduce(.setType(type))
        case .questionCountChanged(let count):
            reduce(.setQuestionCount(count))
        case .timeLimitChanged(let seconds):
            reduce(.setTimeLimit(seconds))
        case .startTapped:
            startQuiz()
        }
    }

    private func startQuiz() {
        let snapshot = state
        guard validate(snapshot) else { return }
        reduce(.setStarting(true))
        let settings = QuizSettings(
            amount: snapshot.questionCount,
            difficulty: snapshot.selectedDifficulty,
            type: snapshot.selectedType,
            categoryId: nil,
            timeLimitSeconds: snapshot.timeLimitSeconds
        )
        sideEffect.startQuiz(settings: settings)
        reduce(.setStarting(false))
    }

    private func validate(_ snapshot: State) -> Bool {
        guard snapshot.questionCount > 0 else {
            reduce(.setError("문제 수는 1개 이상이어야 합니다."))
            return false
        }
        guard snapshot.timeLimitSeconds > 0 else {
            reduce(.setError("제한 시간은 1초 이상이어야 합니다."))
            return false
        }
        reduce(.setError(nil))
        return true
    }

    private func reduce(_ action: InternalAction) {
        switch action {
        case .setDifficulty(let difficulty):
            state.selectedDifficulty = difficulty
        case .setType(let type):
            state.selectedType = type
        case .setQuestionCount(let count):
            state.questionCount = count
        case .setTimeLimit(let seconds):
            state.timeLimitSeconds = seconds
        case .setStarting(let isStarting):
            state.isStarting = isStarting
        case .setError(let message):
            state.errorMessage = message
        }
    }
}
