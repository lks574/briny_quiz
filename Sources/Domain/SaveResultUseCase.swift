import Foundation

struct SaveResultUseCase {
    private let repository: TriviaRepository

    init(repository: TriviaRepository) {
        self.repository = repository
    }

    func execute(_ result: QuizResult) async {
        await repository.saveResult(result)
    }
}
