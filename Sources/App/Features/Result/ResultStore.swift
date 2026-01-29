import Observation

@MainActor
@Observable
final class ResultStore {
    struct State: Equatable {
        let result: QuizResult
        var isSaved: Bool
    }

    enum Action: Equatable {
        case onAppear
        case restartTapped
    }

    enum InternalAction: Equatable {
        case setSaved(Bool)
    }

    private let saveResultUseCase: SaveResultUseCase
    private let updateStageProgressUseCase: UpdateStageProgressUseCase
    private let router: AppRouter

    var state: State

    init(
        result: QuizResult,
        saveResultUseCase: SaveResultUseCase,
        updateStageProgressUseCase: UpdateStageProgressUseCase,
        router: AppRouter
    ) {
        self.saveResultUseCase = saveResultUseCase
        self.updateStageProgressUseCase = updateStageProgressUseCase
        self.router = router
        self.state = State(result: result, isSaved: false)
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            save()
        case .restartTapped:
            router.popToRoot()
        }
    }

    private func save() {
        guard !state.isSaved else { return }
        Task { [weak self] in
            guard let self else { return }
            await saveResultUseCase.execute(state.result)
            if let stageId = state.result.settings.stageId {
                await updateStageProgressUseCase.execute(stageId: stageId, score: state.result.correctCount)
            }
            reduce(.setSaved(true))
        }
    }

    private func reduce(_ action: InternalAction) {
        switch action {
        case .setSaved(let isSaved):
            state.isSaved = isSaved
        }
    }
}
