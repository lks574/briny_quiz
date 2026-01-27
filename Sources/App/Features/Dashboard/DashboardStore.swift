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
        case startTapped
    }

    enum InternalAction: Equatable {
        case setDifficulty(Difficulty)
        case setType(QuestionType)
        case setStarting(Bool)
        case setError(String?)
    }

    private let router: AppRouter

    var state: State

    init(router: AppRouter, initialSettings: QuizSettings) {
        self.router = router
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
        case .startTapped:
            startQuiz()
        }
    }

    private func startQuiz() {
        reduce(.setStarting(true))
        let settings = QuizSettings(
            amount: state.questionCount,
            difficulty: state.selectedDifficulty,
            type: state.selectedType,
            categoryId: nil,
            timeLimitSeconds: state.timeLimitSeconds
        )
        router.push(.quiz(settings))
        reduce(.setStarting(false))
    }

    private func reduce(_ action: InternalAction) {
        switch action {
        case .setDifficulty(let difficulty):
            state.selectedDifficulty = difficulty
        case .setType(let type):
            state.selectedType = type
        case .setStarting(let isStarting):
            state.isStarting = isStarting
        case .setError(let message):
            state.errorMessage = message
        }
    }
}
