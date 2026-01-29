import Observation

@MainActor
@Observable
final class StageStore {
    struct StageItem: Identifiable, Equatable {
        let id: String
        let title: String
        let order: Int
        let isUnlocked: Bool
        let bestScore: Int
    }

    struct State: Equatable {
        var categoryId: String
        var difficulty: Difficulty
        var stages: [StageItem]
        var isLoading: Bool
        var errorMessage: String?

        static func initial(categoryId: String, difficulty: Difficulty) -> State {
            State(
                categoryId: categoryId,
                difficulty: difficulty,
                stages: [],
                isLoading: false,
                errorMessage: nil
            )
        }
    }

    enum Action: Equatable {
        case onAppear
        case stageTapped(String)
    }

    enum InternalAction: Equatable {
        case setLoading(Bool)
        case setStages([StageItem])
        case setError(String?)
    }

    private let sideEffect: StageSideEffect
    var state: State

    init(categoryId: String, difficulty: Difficulty, sideEffect: StageSideEffect) {
        self.sideEffect = sideEffect
        self.state = State.initial(categoryId: categoryId, difficulty: difficulty)
    }

    func send(_ action: Action) async {
        switch action {
        case .onAppear:
            await loadStages()
        case .stageTapped(let stageId):
            guard let item = state.stages.first(where: { $0.id == stageId }),
                  item.isUnlocked else { return }
            let settings = QuizSettings(
                amount: 5,
                difficulty: state.difficulty,
                type: .mixed,
                categoryId: state.categoryId,
                stageId: stageId,
                timeLimitSeconds: 10
            )
            sideEffect.startQuiz(settings: settings)
        }
    }

    func send(_ action: Action) {
        Task { await send(action) }
    }
}

private extension StageStore {
    func loadStages() async {
        reduce(.setLoading(true))
        reduce(.setError(nil))
        async let stagesResult = sideEffect.fetchStages(categoryId: state.categoryId, difficulty: state.difficulty)
        async let progressResult = sideEffect.fetchProgress(categoryId: state.categoryId, difficulty: state.difficulty)
        let (stagesResponse, progressResponse) = await (stagesResult, progressResult)

        switch stagesResponse {
        case .success(let stages):
            let progressMap = makeProgressMap(from: progressResponse, stages: stages)
            let items = stages
                .sorted { $0.order < $1.order }
                .map { stage in
                    let progress = progressMap[stage.id]
                    return StageItem(
                        id: stage.id,
                        title: stage.title,
                        order: stage.order,
                        isUnlocked: progress?.isUnlocked ?? (stage.order == 1),
                        bestScore: progress?.bestScore ?? 0
                    )
                }
            reduce(.setStages(items))
        case .failure(let error):
            reduce(.setError(error.displayMessage))
        }
        reduce(.setLoading(false))
    }

    func makeProgressMap(
        from result: Result<[StageProgress], AppError>,
        stages: [QuizStage]
    ) -> [String: StageProgress] {
        switch result {
        case .success(let progress):
            if progress.isEmpty {
                return Dictionary(uniqueKeysWithValues: stages.map { stage in
                    (stage.id, StageProgress(stageId: stage.id, isUnlocked: stage.order == 1, bestScore: 0, lastPlayedAt: nil))
                })
            }
            return Dictionary(uniqueKeysWithValues: progress.map { ($0.stageId, $0) })
        case .failure:
            return Dictionary(uniqueKeysWithValues: stages.map { stage in
                (stage.id, StageProgress(stageId: stage.id, isUnlocked: stage.order == 1, bestScore: 0, lastPlayedAt: nil))
            })
        }
    }

    func reduce(_ action: InternalAction) {
        switch action {
        case .setLoading(let isLoading):
            state.isLoading = isLoading
        case .setStages(let stages):
            state.stages = stages
        case .setError(let message):
            state.errorMessage = message
        }
    }
}
