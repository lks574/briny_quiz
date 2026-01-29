import Observation

@MainActor
@Observable
final class DashboardStore {
    struct State: Equatable {
        struct CategoryItem: Equatable, Identifiable {
            let id: String
            let title: String
        }

        struct StageCandidate: Equatable {
            let stageId: String
            let categoryId: String
            let difficulty: Difficulty
        }

        var categories: [CategoryItem]
        var selectedCategoryId: String
        var selectedDifficulty: Difficulty
        var questionCount: Int
        var timeLimitSeconds: Int
        var isStarting: Bool
        var errorMessage: String?
        var quickStartCandidates: [StageCandidate]
    }

    enum Action: Equatable {
        case onAppear
        case categorySelected(String)
        case difficultySelected(Difficulty)
        case questionCountChanged(Int)
        case timeLimitChanged(Int)
        case stageTapped
        case quickStartTapped
    }

    enum InternalAction: Equatable {
        case setCategories([State.CategoryItem])
        case setSelectedCategoryId(String)
        case setCategory(String)
        case setDifficulty(Difficulty)
        case setQuestionCount(Int)
        case setTimeLimit(Int)
        case setStarting(Bool)
        case setError(String?)
        case setQuickStartCandidates([State.StageCandidate])
    }

    private let sideEffect: DashboardSideEffect

    var state: State

    init(sideEffect: DashboardSideEffect, initialSettings: QuizSettings) {
        self.sideEffect = sideEffect
        self.state = State(
            categories: [],
            selectedCategoryId: "",
            selectedDifficulty: initialSettings.difficulty,
            questionCount: initialSettings.amount,
            timeLimitSeconds: initialSettings.timeLimitSeconds,
            isStarting: false,
            errorMessage: nil,
            quickStartCandidates: []
        )
    }

    func send(_ action: Action) async {
        switch action {
        case .onAppear:
            await loadCategories()
            await loadQuickStartCandidates()
        case .categorySelected(let categoryId):
            reduce(.setCategory(categoryId))
        case .difficultySelected(let difficulty):
            reduce(.setDifficulty(difficulty))
        case .questionCountChanged(let count):
            reduce(.setQuestionCount(count))
        case .timeLimitChanged(let seconds):
            reduce(.setTimeLimit(seconds))
        case .stageTapped:
            showStage()
        case .quickStartTapped:
            quickStart()
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

    private func quickStart() {
        let snapshot = state
        guard !snapshot.quickStartCandidates.isEmpty else {
            reduce(.setError("빠른 시작을 위한 스테이지가 없습니다."))
            return
        }
        let pick = snapshot.quickStartCandidates.randomElement()
        guard let candidate = pick else { return }
        let settings = QuizSettings(
            amount: 5,
            difficulty: candidate.difficulty,
            type: .mixed,
            categoryId: candidate.categoryId,
            stageId: candidate.stageId,
            timeLimitSeconds: 10
        )
        sideEffect.startQuiz(settings: settings)
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
        case .setQuestionCount(let count):
            state.questionCount = count
        case .setTimeLimit(let seconds):
            state.timeLimitSeconds = seconds
        case .setStarting(let isStarting):
            state.isStarting = isStarting
        case .setError(let message):
            state.errorMessage = message
        case .setQuickStartCandidates(let candidates):
            state.quickStartCandidates = candidates
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

    func loadQuickStartCandidates() async {
        let stagesResult = await sideEffect.fetchAllStages()
        switch stagesResult {
        case .success(let stages):
            let progressResult = await sideEffect.fetchProgress()
            let unlocked = applyUnlockRules(stages: stages, progress: progressResult)
            let candidates = unlocked.map { stage in
                State.StageCandidate(
                    stageId: stage.id,
                    categoryId: stage.categoryId,
                    difficulty: stage.difficulty
                )
            }
            reduce(.setQuickStartCandidates(candidates))
        case .failure(let error):
            reduce(.setError(error.displayMessage))
        }
    }

    func applyUnlockRules(stages: [QuizStage], progress: Result<[StageProgress], AppError>) -> [QuizStage] {
        let progressMap: [String: StageProgress]
        switch progress {
        case .success(let items):
            progressMap = Dictionary(uniqueKeysWithValues: items.map { ($0.stageId, $0) })
        case .failure:
            progressMap = [:]
        }

        var result: [QuizStage] = []
        struct StageGroup: Hashable {
            let categoryId: String
            let difficulty: Difficulty
        }
        let grouped = Dictionary(grouping: stages) { StageGroup(categoryId: $0.categoryId, difficulty: $0.difficulty) }
        for (_, groupStages) in grouped {
            let sorted = groupStages.sorted { $0.order < $1.order }
            var unlocked = true
            for stage in sorted {
                let progress = progressMap[stage.id]
                if stage.order == 1 {
                    unlocked = true
                } else {
                    let prev = sorted[stage.order - 2]
                    let prevProgress = progressMap[prev.id]
                    unlocked = (prevProgress?.bestScore ?? 0) >= 4
                }
                if unlocked {
                    if progress == nil || progress?.isUnlocked == true {
                        result.append(stage)
                    }
                }
            }
        }
        return result
    }
}
