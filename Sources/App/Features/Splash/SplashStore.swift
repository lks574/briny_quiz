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

    var state: State

    init() {
        state = State(isLoading: false, settings: nil, errorMessage: nil)
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            load()
        case .retryTapped:
            load()
        }
    }

    private func load() {
        Task { [weak self] in
            guard let self else { return }
            reduce(.setLoading(true))
            reduce(.setError(nil))
            // Placeholder for persisted settings
            let settings = QuizSettings.default
            reduce(.setSettings(settings))
            reduce(.setLoading(false))
        }
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
