import Foundation

struct QuizRepositoryImpl: QuizRepository {
    private let cache: QuizCache

    init(cache: QuizCache) {
        self.cache = cache
    }

    func fetchQuestions() async throws -> [QuizQuestion] {
        let cached = await cache.load()
        if !cached.isEmpty {
            return cached
        }

        try await Task.sleep(nanoseconds: 500_000_000)

        let questions = [
            QuizQuestion(id: "1", title: "SwiftUI", body: "Which modifier is used to style text?"),
            QuizQuestion(id: "2", title: "Concurrency", body: "What keyword marks async functions?"),
            QuizQuestion(id: "3", title: "Observation", body: "Which macro provides observable state in iOS 17?"),
            QuizQuestion(id: "4", title: "Tuist", body: "Which file defines a project configuration?"),
            QuizQuestion(id: "5", title: "Navigation", body: "Which view manages path-based navigation?"),
            QuizQuestion(id: "6", title: "MVI", body: "Where should state mutations happen?"),
            QuizQuestion(id: "7", title: "Routing", body: "Which object owns the navigation path?"),
            QuizQuestion(id: "8", title: "State", body: "Why keep UI state in a single struct?")
        ]

        await cache.save(questions)
        return questions
    }
}
