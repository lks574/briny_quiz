import Foundation

actor QuestionCache {
    struct Entry {
        let questions: [QuizQuestion]
        let timestamp: Date
    }

    private var storage: [QuizSettings: Entry] = [:]

    func load(for settings: QuizSettings) -> Entry? {
        storage[settings]
    }

    func save(_ questions: [QuizQuestion], for settings: QuizSettings, now: Date = Date()) {
        storage[settings] = Entry(questions: questions, timestamp: now)
    }

    func clear() {
        storage.removeAll()
    }
}
