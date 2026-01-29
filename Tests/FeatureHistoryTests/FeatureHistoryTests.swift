import XCTest
@testable import FeatureHistory
import Domain

@MainActor
final class FeatureHistoryTests: XCTestCase {
    func testOnAppearLoadsItems() async {
        let now = Date()
        let items = [
            HistoryItem(id: "1", result: QuizResult(id: "r1", date: now, totalCount: 5, correctCount: 4, settings: .default)),
            HistoryItem(id: "2", result: QuizResult(id: "r2", date: now, totalCount: 10, correctCount: 7, settings: .default))
        ]
        let store = HistoryStore(fetchHistoryUseCase: FetchHistoryUseCase(repository: MockTriviaRepository(items: items)))

        store.send(.onAppear)
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(store.state.displayItems.count, 2)
        XCTAssertEqual(store.state.displayItems.first?.correctCount, 4)
        XCTAssertEqual(store.state.displayItems.first?.totalCount, 5)
        XCTAssertEqual(store.state.displayItems.first?.isSuccess, true)
    }

    func testDateFilterLast7Days() {
        let now = Date()
        let recent = HistoryItem(id: "1", result: QuizResult(id: "r1", date: now, totalCount: 10, correctCount: 9, settings: .default))
        let oldDate = Calendar.current.date(byAdding: .day, value: -10, to: now)!
        let old = HistoryItem(id: "2", result: QuizResult(id: "r2", date: oldDate, totalCount: 10, correctCount: 9, settings: .default))
        let store = HistoryStore(fetchHistoryUseCase: FetchHistoryUseCase(repository: MockTriviaRepository(items: [])))
        store.state.items = [recent, old]

        store.send(.dateFilterChanged(.last7Days))

        XCTAssertEqual(store.state.displayItems.count, 1)
        XCTAssertEqual(store.state.displayItems.first?.id, "1")
    }
}

private struct MockTriviaRepository: TriviaRepository {
    let items: [HistoryItem]

    func fetchQuestions(settings: QuizSettings, policy: CachePolicy) async throws -> [QuizQuestion] {
        []
    }

    func saveResult(_ result: QuizResult) async {}

    func fetchHistory() async -> [HistoryItem] {
        items
    }
}
