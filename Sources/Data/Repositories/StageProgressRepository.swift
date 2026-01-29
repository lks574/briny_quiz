import Foundation

protocol StageProgressRepository {
    func fetchProgress() async -> [StageProgress]
    func updateProgress(stageId: String, score: Int) async
}
