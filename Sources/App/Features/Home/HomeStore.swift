import Observation

@MainActor
@Observable
final class HomeStore {
    struct State: Equatable {
        var isLoading: Bool
        var questions: [QuizQuestion]
        var errorMessage: String?
    }

    enum Action: Equatable {
        case onAppear
        case reloadTapped
        case questionSelected(QuizQuestion)
    }

    enum InternalAction: Equatable {
        case setLoading(Bool)
        case setQuestions([QuizQuestion])
        case setError(String?)
    }

    private let fetchQuizUseCase: FetchQuizUseCase
    private let router: AppRouter
    private var loadTask: Task<Void, Never>?

    var state: State

    init(fetchQuizUseCase: FetchQuizUseCase, router: AppRouter) {
        self.fetchQuizUseCase = fetchQuizUseCase
        self.router = router
        self.state = State(isLoading: false, questions: [], errorMessage: nil)
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            loadQuestions()
        case .reloadTapped:
            loadQuestions()
        case .questionSelected(let question):
            router.push(.questionDetail(question))
        }
    }

    private func loadQuestions() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            reduce(.setLoading(true))
            reduce(.setError(nil))
            do {
                let questions = try await fetchQuizUseCase.execute()
                reduce(.setQuestions(questions))
            } catch {
                reduce(.setError(error.localizedDescription))
            }
            reduce(.setLoading(false))
        }
    }

    private func reduce(_ action: InternalAction) {
        switch action {
        case .setLoading(let isLoading):
            state.isLoading = isLoading
        case .setQuestions(let questions):
            state.questions = questions
        case .setError(let message):
            state.errorMessage = message
        }
    }
}
