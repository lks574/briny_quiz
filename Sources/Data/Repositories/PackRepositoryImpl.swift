import Foundation

final class PackRepositoryImpl: PackRepository {
    private let fileStore: PackFileStore

    init(fileStore: PackFileStore = PackFileStore()) {
        self.fileStore = fileStore
    }

    func fetchCategories() async throws -> [QuizCategory] {
        let db = try await openDatabase()
        return try await db.fetchCategories()
    }

    func fetchStages(categoryId: String, difficulty: Difficulty) async throws -> [QuizStage] {
        let db = try await openDatabase()
        return try await db.fetchStages(categoryId: categoryId, difficulty: difficulty)
    }

    func fetchQuestions(stageId: String) async throws -> [QuizQuestion] {
        let db = try await openDatabase()
        return try await db.fetchQuestions(stageId: stageId)
    }

    func fetchAllStages() async throws -> [QuizStage] {
        let db = try await openDatabase()
        return try await db.fetchAllStages()
    }

    private func openDatabase() async throws -> PackDatabase {
        guard let url = fileStore.currentPackURL() else {
            throw AppError.pack("팩 파일을 찾을 수 없습니다.")
        }
        return PackDatabase(dbURL: url)
    }
}
