import Foundation

actor QuizCache {
    private var questions: [QuizQuestion] = []

    func load() -> [QuizQuestion] {
        questions
    }

    func save(_ questions: [QuizQuestion]) {
        self.questions = questions
    }
}
