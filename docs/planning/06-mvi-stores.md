# MVI Store 설계

## 공통 원칙
- View는 `store.state` 읽기 + `store.send(Action)`만 수행
- 비동기 작업은 Store 내부 Task로 처리
- 상태 변경은 InternalAction → reduce로만 수행

---

## 1) SplashStore

### State
- isLoading: Bool
- initialSettings: QuizSettings?
- errorMessage: String?

### Action
- onAppear
- retryTapped

### InternalAction
- setLoading(Bool)
- setSettings(QuizSettings)
- setError(String?)

### Side Effects
- 초기 설정값 로드(기본값, 저장된 마지막 설정 등)

---

## 2) DashboardStore

### State
- selectedDifficulty: Difficulty
- selectedType: QuestionType
- questionCount: Int (10 고정)
- category: Category (전체)
- isStarting: Bool
- errorMessage: String?

### Action
- difficultySelected(Difficulty)
- typeSelected(QuestionType)
- startTapped

### InternalAction
- setDifficulty(Difficulty)
- setType(QuestionType)
- setStarting(Bool)
- setError(String?)

### Side Effects
- startTapped → Quiz 라우팅

---

## 3) QuizStore

### State
- questions: [QuizQuestion]
- currentIndex: Int
- currentQuestion: QuizQuestion?
- selectedAnswer: String?
- isCorrect: Bool?
- timeRemaining: Int
- isLoading: Bool
- errorMessage: String?
- isFinished: Bool

### Action
- onAppear
- answerSelected(String)
- nextTapped
- skipTapped
- timerTick
- finish

### InternalAction
- setLoading(Bool)
- setQuestions([QuizQuestion])
- setAnswer(String?)
- setCorrect(Bool?)
- setTimeRemaining(Int)
- setIndex(Int)
- setFinished(Bool)
- setError(String?)

### Side Effects
- 문제 로드(Repository)
- 타이머 Task
- 문제당 10초
- 즉시 피드백 처리

---

## 4) ResultStore

### State
- result: QuizResult

### Action
- restartTapped
- historyTapped (선택)

### InternalAction
- (없음)

### Side Effects
- 결과 저장(History)
- restartTapped → Dashboard 라우팅

---

## 5) HistoryStore

### State
- items: [HistoryItem]
- isLoading: Bool
- errorMessage: String?

### Action
- onAppear
- refreshTapped

### InternalAction
- setLoading(Bool)
- setItems([HistoryItem])
- setError(String?)

### Side Effects
- 로컬 히스토리 로드

---

## 라우팅 이벤트
- Splash → Dashboard 전환은 AppRouter가 담당
- Dashboard에서 Quiz 시작 시 router.push(.quiz(settings))
- Quiz 완료 시 router.push(.result(result))
- History는 탭 전환
