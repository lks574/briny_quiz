import XCTest
@testable import FeatureQuiz
import Domain
import Data

@MainActor
final class FeatureQuizTests: XCTestCase {
    func testOnAppearLoadsQuestions() async {
        let question = QuizQuestion(
            id: "q1",
            category: "general",
            difficulty: .easy,
            type: .multiple,
            question: "Q?",
            correctAnswer: "A",
            incorrectAnswers: ["B", "C", "D"]
        )
        let sideEffect = MockQuizSideEffect(loadResult: .success([question]))
        let store = QuizStore(settings: .default, sideEffect: sideEffect)

        store.send(.onAppear)
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertFalse(store.state.isLoading)
        XCTAssertNil(store.state.errorMessage)
        XCTAssertEqual(store.state.questions.count, 1)
        XCTAssertEqual(store.state.currentIndex, 0)
        XCTAssertEqual(store.state.currentQuestion?.id, "q1")
        XCTAssertEqual(Set(store.state.currentAnswers), Set(["A", "B", "C", "D"]))
        XCTAssertEqual(store.state.timeRemaining, store.state.settings.timeLimitSeconds)
        XCTAssertTrue(sideEffect.startTimerCalled)
    }

    func testOnAppearFailureSetsError() async {
        let sideEffect = MockQuizSideEffect(loadResult: .failure(.unknown("테스트 오류")))
        let store = QuizStore(settings: .default, sideEffect: sideEffect)

        store.send(.onAppear)
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertNotNil(store.state.errorMessage)
        XCTAssertEqual(store.state.errorMessage, AppError.unknown("테스트 오류").displayMessage)
        XCTAssertFalse(store.state.isLoading)
    }

    func testAnswerSelectionUpdatesCorrectCount() async {
        let question = QuizQuestion(
            id: "q1",
            category: "general",
            difficulty: .easy,
            type: .multiple,
            question: "Q?",
            correctAnswer: "A",
            incorrectAnswers: ["B"]
        )
        let sideEffect = MockQuizSideEffect(loadResult: .success([question]))
        let store = QuizStore(settings: .default, sideEffect: sideEffect)

        store.send(.onAppear)
        try? await Task.sleep(nanoseconds: 50_000_000)

        store.send(.answerSelected("A"))
        try? await Task.sleep(nanoseconds: 10_000_000)
        XCTAssertEqual(store.state.correctCount, 1)
        XCTAssertEqual(store.state.isCorrect, true)

        store.send(.answerSelected("B"))
        try? await Task.sleep(nanoseconds: 10_000_000)
        XCTAssertEqual(store.state.correctCount, 0)
        XCTAssertEqual(store.state.isCorrect, false)
    }

    func testNextTappedFinishesAndShowsResult() async {
        let question = QuizQuestion(
            id: "q1",
            category: "general",
            difficulty: .easy,
            type: .multiple,
            question: "Q?",
            correctAnswer: "A",
            incorrectAnswers: ["B"]
        )
        let sideEffect = MockQuizSideEffect(loadResult: .success([question]))
        let store = QuizStore(settings: .default, sideEffect: sideEffect)

        store.send(.onAppear)
        try? await Task.sleep(nanoseconds: 50_000_000)
        store.send(.nextTapped)
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(store.state.isFinished)
        XCTAssertNotNil(sideEffect.shownResult)
        XCTAssertTrue(sideEffect.stopTimerCalled)
    }

    func testTimerTickFinishesOnZero() async {
        var settings = QuizSettings.default
        settings.timeLimitSeconds = 1
        let question = QuizQuestion(
            id: "q1",
            category: "general",
            difficulty: .easy,
            type: .multiple,
            question: "Q?",
            correctAnswer: "A",
            incorrectAnswers: ["B"]
        )
        let sideEffect = MockQuizSideEffect(loadResult: .success([question]))
        let store = QuizStore(settings: settings, sideEffect: sideEffect)

        store.send(.onAppear)
        try? await Task.sleep(nanoseconds: 50_000_000)
        store.send(.timerTick)
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(store.state.isFinished)
        XCTAssertNotNil(sideEffect.shownResult)
    }
}

@MainActor
private final class MockQuizSideEffect: QuizSideEffect {
    let loadResult: Result<[QuizQuestion], AppError>
    private(set) var startTimerCalled = false
    private(set) var stopTimerCalled = false
    private(set) var shownResult: QuizResult?

    init(loadResult: Result<[QuizQuestion], AppError>) {
        self.loadResult = loadResult
    }

    func loadQuestions(settings: QuizSettings, policy: CachePolicy) async -> Result<[QuizQuestion], AppError> {
        loadResult
    }

    func startTimer(onTick: @escaping () -> Void, shouldStop: @escaping () -> Bool) async {
        startTimerCalled = true
        _ = onTick
        _ = shouldStop
    }

    func stopTimer() async {
        stopTimerCalled = true
    }

    func showResult(_ result: QuizResult) {
        shownResult = result
    }
}
