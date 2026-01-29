import Foundation

public struct FetchStageProgressUseCase {
    private let repository: StageProgressRepository

    public init(repository: StageProgressRepository) {
        self.repository = repository
    }

    public func execute() async -> [StageProgress] {
        await repository.fetchProgress()
    }
}
