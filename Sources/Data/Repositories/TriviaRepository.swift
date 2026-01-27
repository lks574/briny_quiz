import Foundation

protocol TriviaRepository {
    func fetchQuestions(settings: QuizSettings, policy: CachePolicy) async throws -> [QuizQuestion]
    func saveResult(_ result: QuizResult) async
    func fetchHistory() async -> [HistoryItem]
}
