import Foundation

struct UpdateStageProgressUseCase {
    private let repository: StageProgressRepository

    init(repository: StageProgressRepository) {
        self.repository = repository
    }

    func execute(stageId: String, score: Int) async {
        await repository.updateProgress(stageId: stageId, score: score)
    }
}
