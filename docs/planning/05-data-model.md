# 데이터 계층 설계

## Open Trivia DB DTO

### TriviaResponseDTO
- responseCode: Int
- results: [TriviaQuestionDTO]

### TriviaQuestionDTO
- category: String
- type: String ("multiple" | "boolean")
- difficulty: String ("easy" | "medium" | "hard")
- question: String (base64 인코딩)
- correctAnswer: String (base64 인코딩)
- incorrectAnswers: [String] (base64 인코딩)

## Domain 모델

### QuizQuestion
- id: String (UUID or hash)
- category: String
- difficulty: Difficulty
- type: QuestionType
- question: String
- correctAnswer: String
- incorrectAnswers: [String]
- allAnswersShuffled: [String]

### QuizSettings
- amount: Int (기본 10)
- difficulty: Difficulty
- type: QuestionType
- category: Category (기본 전체)
- timeLimitSeconds: Int (10)

### QuizResult
- id: String
- date: Date
- totalCount: Int
- correctCount: Int
- settings: QuizSettings

### HistoryItem
- result: QuizResult

## 공통 Enum

### Difficulty
- easy | medium | hard

### QuestionType
- mixed | multiple | boolean

### CachePolicy
- cacheFirst | networkFirst | cacheOnly | networkOnly

## 매핑 규칙
- DTO → Domain 매핑은 Repository에서 수행
- base64 디코딩은 APIClient 또는 Repository 경계에서 수행

## 캐시 구조

### QuestionCache(actor)
- key: QuizSettings(난이도/타입/카테고리/amount)
- value: questions + timestamp

### HistoryCache(actor)
- 로컬 저장(JSON 파일 또는 UserDefaults)
- append/list API 제공

## Repository API (초안)

### TriviaRepository
- func fetchQuestions(settings: QuizSettings, policy: CachePolicy) async throws -> [QuizQuestion]
- func saveResult(_ result: QuizResult) async
- func fetchHistory() async -> [HistoryItem]

