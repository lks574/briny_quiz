import Foundation

protocol PackRepository {
    func fetchCategories() async throws -> [QuizCategory]
    func fetchStages(categoryId: String, difficulty: Difficulty) async throws -> [QuizStage]
    func fetchQuestions(stageId: String) async throws -> [QuizQuestion]
    func fetchAllStages() async throws -> [QuizStage]
}
