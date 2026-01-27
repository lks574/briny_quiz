import Foundation

enum Difficulty: String, Codable, CaseIterable, Hashable {
    case easy
    case medium
    case hard
}

enum QuestionType: String, Codable, CaseIterable, Hashable {
    case mixed
    case multiple
    case boolean
}

struct QuizSettings: Hashable, Codable {
    var amount: Int
    var difficulty: Difficulty
    var type: QuestionType
    var categoryId: Int?
    var timeLimitSeconds: Int

    static let `default` = QuizSettings(
        amount: 10,
        difficulty: .easy,
        type: .mixed,
        categoryId: nil,
        timeLimitSeconds: 10
    )
}

struct QuizQuestion: Identifiable, Hashable {
    let id: String
    let category: String
    let difficulty: Difficulty
    let type: QuestionType
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    var allAnswersShuffled: [String] {
        var answers = incorrectAnswers + [correctAnswer]
        answers.shuffle()
        return answers
    }
}

struct QuizResult: Identifiable, Hashable, Codable {
    let id: String
    let date: Date
    let totalCount: Int
    let correctCount: Int
    let settings: QuizSettings
}

struct HistoryItem: Identifiable, Hashable, Codable {
    let id: String
    let result: QuizResult
}

enum CachePolicy: Hashable {
    case cacheFirst
    case networkFirst
    case cacheOnly
    case networkOnly
}
