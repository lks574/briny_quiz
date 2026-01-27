import Observation

@MainActor
@Observable
final class HistoryStore {
    struct State: Equatable {
        var items: [HistoryItem]
        var isLoading: Bool
        var errorMessage: String?
    }

    enum Action: Equatable {
        case onAppear
        case refreshTapped
    }

    enum InternalAction: Equatable {
        case setLoading(Bool)
        case setItems([HistoryItem])
        case setError(String?)
    }

    private let fetchHistoryUseCase: FetchHistoryUseCase

    var state: State

    init(fetchHistoryUseCase: FetchHistoryUseCase) {
        self.fetchHistoryUseCase = fetchHistoryUseCase
        self.state = State(items: [], isLoading: false, errorMessage: nil)
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            load()
        case .refreshTapped:
            load()
        }
    }

    private func load() {
        Task { [weak self] in
            guard let self else { return }
            reduce(.setLoading(true))
            let items = await fetchHistoryUseCase.execute()
            reduce(.setItems(items))
            reduce(.setLoading(false))
        }
    }

    private func reduce(_ action: InternalAction) {
        switch action {
        case .setLoading(let isLoading):
            state.isLoading = isLoading
        case .setItems(let items):
            state.items = items
        case .setError(let message):
            state.errorMessage = message
        }
    }
}
