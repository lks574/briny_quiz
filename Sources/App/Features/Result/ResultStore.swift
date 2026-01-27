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
    private let router: AppRouter

    var state: State

    init(result: QuizResult, saveResultUseCase: SaveResultUseCase, router: AppRouter) {
        self.saveResultUseCase = saveResultUseCase
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
