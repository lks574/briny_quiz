import Foundation

protocol QuizRepository {
    func fetchQuestions() async throws -> [QuizQuestion]
}
