import Foundation

struct FetchHistoryUseCase {
    private let repository: TriviaRepository

    init(repository: TriviaRepository) {
        self.repository = repository
    }

    func execute() async -> [HistoryItem] {
        await repository.fetchHistory()
    }
}
