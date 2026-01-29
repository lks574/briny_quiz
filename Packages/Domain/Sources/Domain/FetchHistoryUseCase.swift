import Foundation

public struct FetchHistoryUseCase {
    private let repository: TriviaRepository

    public init(repository: TriviaRepository) {
        self.repository = repository
    }

    public func execute() async -> [HistoryItem] {
        await repository.fetchHistory()
    }
}
