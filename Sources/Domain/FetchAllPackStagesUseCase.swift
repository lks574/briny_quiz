import Foundation

struct FetchAllPackStagesUseCase {
    private let repository: PackRepository

    init(repository: PackRepository) {
        self.repository = repository
    }

    func execute() async throws -> [QuizStage] {
        let stages = try await repository.fetchAllStages()
        return stages.sorted { lhs, rhs in
            if lhs.categoryId == rhs.categoryId {
                if lhs.difficulty == rhs.difficulty {
                    return lhs.order < rhs.order
                }
                return lhs.difficulty.rawValue < rhs.difficulty.rawValue
            }
            return lhs.categoryId < rhs.categoryId
        }
    }
}
