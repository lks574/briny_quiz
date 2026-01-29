import Foundation

final class StageProgressRepositoryImpl: StageProgressRepository {
    private let store: StageProgressStore
    private let packRepository: PackRepository

    init(store: StageProgressStore = StageProgressStore(), packRepository: PackRepository) {
        self.store = store
        self.packRepository = packRepository
    }

    func fetchProgress() async -> [StageProgress] {
        await store.load()
    }

    func updateProgress(stageId: String, score: Int) async {
        let stages = (try? await packRepository.fetchAllStages()) ?? []
        let unlockNext = nextStageId(for: stageId, stages: stages, score: score)
        await store.update(stageId: stageId, score: score, unlockNextStageId: unlockNext)
    }

    private func nextStageId(for stageId: String, stages: [QuizStage], score: Int) -> String? {
        guard score >= 4 else { return nil }
        guard let current = stages.first(where: { $0.id == stageId }) else { return nil }
        let nextOrder = current.order + 1
        return stages.first(where: {
            $0.categoryId == current.categoryId &&
            $0.difficulty == current.difficulty &&
            $0.order == nextOrder
        })?.id
    }
}
