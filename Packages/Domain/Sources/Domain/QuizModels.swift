import Foundation

public enum Difficulty: String, Codable, CaseIterable, Hashable {
    case easy
    case medium
    case hard
}

public enum QuestionType: String, Codable, CaseIterable, Hashable {
    case mixed
    case multiple
    case boolean
}

public struct QuizSettings: Hashable, Codable {
    public var amount: Int
    public var difficulty: Difficulty
    public var type: QuestionType
    public var categoryId: String?
    public var stageId: String?
    public var timeLimitSeconds: Int

    public static let `default` = QuizSettings(
        amount: 10,
        difficulty: .easy,
        type: .mixed,
        categoryId: nil,
        stageId: nil,
        timeLimitSeconds: 10
    )

    public init(
        amount: Int,
        difficulty: Difficulty,
        type: QuestionType,
        categoryId: String?,
        stageId: String?,
        timeLimitSeconds: Int
    ) {
        self.amount = amount
        self.difficulty = difficulty
        self.type = type
        self.categoryId = categoryId
        self.stageId = stageId
        self.timeLimitSeconds = timeLimitSeconds
    }
}

public struct QuizQuestion: Identifiable, Hashable {
    public let id: String
    public let category: String
    public let difficulty: Difficulty
    public let type: QuestionType
    public let question: String
    public let correctAnswer: String
    public let incorrectAnswers: [String]

    public init(
        id: String,
        category: String,
        difficulty: Difficulty,
        type: QuestionType,
        question: String,
        correctAnswer: String,
        incorrectAnswers: [String]
    ) {
        self.id = id
        self.category = category
        self.difficulty = difficulty
        self.type = type
        self.question = question
        self.correctAnswer = correctAnswer
        self.incorrectAnswers = incorrectAnswers
    }
}

public struct QuizResult: Identifiable, Hashable, Codable {
    public let id: String
    public let date: Date
    public let totalCount: Int
    public let correctCount: Int
    public let settings: QuizSettings

    public init(id: String, date: Date, totalCount: Int, correctCount: Int, settings: QuizSettings) {
        self.id = id
        self.date = date
        self.totalCount = totalCount
        self.correctCount = correctCount
        self.settings = settings
    }
}

public struct HistoryItem: Identifiable, Hashable, Codable {
    public let id: String
    public let result: QuizResult

    public init(id: String, result: QuizResult) {
        self.id = id
        self.result = result
    }
}

public enum CachePolicy: Hashable {
    case cacheFirst
    case networkFirst
    case cacheOnly
    case networkOnly
}
