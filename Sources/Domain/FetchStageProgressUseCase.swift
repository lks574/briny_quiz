import Foundation

struct FetchStageProgressUseCase {
    private let repository: StageProgressRepository

    init(repository: StageProgressRepository) {
        self.repository = repository
    }

    func execute() async -> [StageProgress] {
        await repository.fetchProgress()
    }
}
