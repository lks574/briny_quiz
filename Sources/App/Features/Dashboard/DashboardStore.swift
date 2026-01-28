import Observation

@MainActor
@Observable
final class DashboardStore {
    struct State: Equatable {
        struct CategoryItem: Equatable, Identifiable {
            let id: String
            let title: String
        }

        var categories: [CategoryItem]
        var selectedCategoryId: String
        var selectedDifficulty: Difficulty
        var selectedType: QuestionType
        var questionCount: Int
        var timeLimitSeconds: Int
        var isStarting: Bool
        var errorMessage: String?
    }

    enum Action: Equatable {
        case categorySelected(String)
        case difficultySelected(Difficulty)
        case typeSelected(QuestionType)
        case questionCountChanged(Int)
        case timeLimitChanged(Int)
        case stageTapped
    }

    enum InternalAction: Equatable {
        case setCategory(String)
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
        let categories = [
            State.CategoryItem(id: "general", title: "일반 상식"),
            State.CategoryItem(id: "science", title: "과학"),
            State.CategoryItem(id: "history", title: "역사"),
            State.CategoryItem(id: "sports", title: "스포츠")
        ]
        self.state = State(
            categories: categories,
            selectedCategoryId: categories.first?.id ?? "general",
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
        case .categorySelected(let categoryId):
            reduce(.setCategory(categoryId))
        case .difficultySelected(let difficulty):
            reduce(.setDifficulty(difficulty))
        case .typeSelected(let type):
            reduce(.setType(type))
        case .questionCountChanged(let count):
            reduce(.setQuestionCount(count))
        case .timeLimitChanged(let seconds):
            reduce(.setTimeLimit(seconds))
        case .stageTapped:
            showStage()
        }
    }

    private func showStage() {
        let snapshot = state
        guard validate(snapshot) else { return }
        reduce(.setStarting(true))
        sideEffect.showStage(categoryId: snapshot.selectedCategoryId, difficulty: snapshot.selectedDifficulty)
        reduce(.setStarting(false))
    }

    private func validate(_ snapshot: State) -> Bool {
        guard !snapshot.selectedCategoryId.isEmpty else {
            reduce(.setError("카테고리를 선택해주세요."))
            return false
        }
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
        case .setCategory(let categoryId):
            state.selectedCategoryId = categoryId
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
