import Foundation

public struct SaveResultUseCase {
    private let repository: TriviaRepository

    public init(repository: TriviaRepository) {
        self.repository = repository
    }

    public func execute(_ result: QuizResult) async {
        await repository.saveResult(result)
    }
}
