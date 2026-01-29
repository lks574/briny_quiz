import Foundation
import SQLite3
import Domain

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

actor PackDatabase {
    private let dbURL: URL
    private var db: OpaquePointer?

    init(dbURL: URL) {
        self.dbURL = dbURL
    }

    deinit {
        if let db {
            sqlite3_close(db)
        }
    }

    func fetchCategories() throws -> [QuizCategory] {
        try openIfNeeded()
        let query = "SELECT id, title FROM categories ORDER BY title;"
        return try runQuery(query) { stmt in
            let id = columnText(stmt, 0)
            let title = columnText(stmt, 1)
            return QuizCategory(id: id, title: title)
        }
    }

    func fetchStages(categoryId: String, difficulty: Difficulty) throws -> [QuizStage] {
        try openIfNeeded()
        let query = "SELECT id, title, categoryId, difficulty, \"order\" FROM stages WHERE categoryId = ? AND difficulty = ? ORDER BY \"order\";"
        return try runQuery(query, bind: { stmt in
            sqlite3_bind_text(stmt, 1, (categoryId as NSString).utf8String, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 2, (difficulty.rawValue as NSString).utf8String, -1, SQLITE_TRANSIENT)
        }) { stmt in
            QuizStage(
                id: columnText(stmt, 0),
                title: columnText(stmt, 1),
                categoryId: columnText(stmt, 2),
                difficulty: Difficulty(rawValue: columnText(stmt, 3)) ?? .easy,
                order: Int(sqlite3_column_int(stmt, 4))
            )
        }
    }

    func fetchQuestions(stageId: String) throws -> [QuizQuestion] {
        try openIfNeeded()
        let query = """
        SELECT id, categoryId, stageId, difficulty, type, question, correctAnswer, incorrectAnswers
        FROM questions WHERE stageId = ? ORDER BY id;
        """
        return try runQuery(query, bind: { stmt in
            sqlite3_bind_text(stmt, 1, (stageId as NSString).utf8String, -1, SQLITE_TRANSIENT)
        }) { stmt in
            let incorrectJSON = columnText(stmt, 7)
            let incorrectAnswers = (try? JSONDecoder().decode([String].self, from: Data(incorrectJSON.utf8))) ?? []
            return QuizQuestion(
                id: columnText(stmt, 0),
                category: columnText(stmt, 1),
                difficulty: Difficulty(rawValue: columnText(stmt, 3)) ?? .easy,
                type: QuestionType(rawValue: columnText(stmt, 4)) ?? .mixed,
                question: columnText(stmt, 5),
                correctAnswer: columnText(stmt, 6),
                incorrectAnswers: incorrectAnswers
            )
        }
    }

    func fetchAllStages() throws -> [QuizStage] {
        try openIfNeeded()
        let query = "SELECT id, title, categoryId, difficulty, \"order\" FROM stages ORDER BY categoryId, difficulty, \"order\";"
        return try runQuery(query) { stmt in
            QuizStage(
                id: columnText(stmt, 0),
                title: columnText(stmt, 1),
                categoryId: columnText(stmt, 2),
                difficulty: Difficulty(rawValue: columnText(stmt, 3)) ?? .easy,
                order: Int(sqlite3_column_int(stmt, 4))
            )
        }
    }

    private func openIfNeeded() throws {
        if db != nil { return }
        let result = sqlite3_open(dbURL.path, &db)
        guard result == SQLITE_OK else {
            throw AppError.pack("팩 DB를 열 수 없습니다.")
        }
    }

    private func runQuery<T>(_ query: String, bind: ((OpaquePointer?) -> Void)? = nil, map: (OpaquePointer?) -> T) throws -> [T] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
            throw AppError.pack("팩 DB 쿼리 준비 실패")
        }
        bind?(stmt)
        var results: [T] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(map(stmt))
        }
        return results
    }

    private func columnText(_ stmt: OpaquePointer?, _ index: Int32) -> String {
        guard let cString = sqlite3_column_text(stmt, index) else { return "" }
        return String(cString: cString)
    }
}
