import Foundation

public struct UpdateStageProgressUseCase {
    private let repository: StageProgressRepository

    public init(repository: StageProgressRepository) {
        self.repository = repository
    }

    public func execute(stageId: String, score: Int) async {
        await repository.updateProgress(stageId: stageId, score: score)
    }
}
