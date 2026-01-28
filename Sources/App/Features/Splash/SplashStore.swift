import Observation

@MainActor
@Observable
final class SplashStore {
    struct State: Equatable {
        var isLoading: Bool
        var settings: QuizSettings?
        var errorMessage: String?
    }

    enum Action: Equatable {
        case onAppear
        case retryTapped
    }

    enum InternalAction: Equatable {
        case setLoading(Bool)
        case setSettings(QuizSettings)
        case setError(String?)
    }

    private let sideEffect: SplashSideEffect
    var state: State

    init(sideEffect: SplashSideEffect) {
        self.sideEffect = sideEffect
        state = State(isLoading: false, settings: nil, errorMessage: nil)
    }

    func send(_ action: Action) async {
        switch action {
        case .onAppear:
            await load()
        case .retryTapped:
            await load()
        }
    }

    func send(_ action: Action) {
        Task { await send(action) }
    }

    private func load() async {
        reduce(.setLoading(true))
        reduce(.setError(nil))
        let packResult = await sideEffect.ensurePackReady()
        switch packResult {
        case .success:
            let settings = QuizSettings.default
            reduce(.setSettings(settings))
        case .failure(let error):
            reduce(.setError(error.displayMessage))
        }
        reduce(.setLoading(false))
    }

    private func reduce(_ action: InternalAction) {
        switch action {
        case .setLoading(let isLoading):
            state.isLoading = isLoading
        case .setSettings(let settings):
            state.settings = settings
        case .setError(let message):
            state.errorMessage = message
        }
    }
}
