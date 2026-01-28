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
        case onAppear
        case categorySelected(String)
        case difficultySelected(Difficulty)
        case typeSelected(QuestionType)
        case questionCountChanged(Int)
        case timeLimitChanged(Int)
        case stageTapped
    }

    enum InternalAction: Equatable {
        case setCategories([State.CategoryItem])
        case setSelectedCategoryId(String)
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
        self.state = State(
            categories: [],
            selectedCategoryId: "",
            selectedDifficulty: initialSettings.difficulty,
            selectedType: initialSettings.type,
            questionCount: initialSettings.amount,
            timeLimitSeconds: initialSettings.timeLimitSeconds,
            isStarting: false,
            errorMessage: nil
        )
    }

    func send(_ action: Action) async {
        switch action {
        case .onAppear:
            await loadCategories()
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

    func send(_ action: Action) {
        Task { await send(action) }
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
        case .setCategories(let categories):
            state.categories = categories
        case .setSelectedCategoryId(let categoryId):
            state.selectedCategoryId = categoryId
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

private extension DashboardStore {
    func loadCategories() async {
        let result = await sideEffect.fetchCategories()
        switch result {
        case .success(let categories):
            let items = categories.map { State.CategoryItem(id: $0.id, title: $0.title) }
            reduce(.setCategories(items))
            if state.selectedCategoryId.isEmpty, let first = items.first?.id {
                reduce(.setSelectedCategoryId(first))
            }
        case .failure(let error):
            reduce(.setError(error.displayMessage))
        }
    }
}
