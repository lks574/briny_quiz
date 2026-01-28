# 오프라인 팩 및 스테이지 진행 (설계)

## 범위
- 기본 팩은 앱 번들에 포함, 이후 업데이트는 설정 탭에서 수동 다운로드
- 팩 포맷 v1: JSON (추후 SQLite로 마이그레이션 예정)
- 최신 팩 자동 선택
- 카테고리 + 스테이지 구성
- 스테이지 규칙: 스테이지당 5문제, 4/5 이상 정답 시 다음 스테이지 해제, 순차형
- 빠른 시작: 현재 해제된 스테이지 중 랜덤

## 팩 위치 및 우선순위
1) 다운로드 팩: `Application Support/QuizPack/pack_v{version}.json`
2) 번들 팩: `Resources/QuizPack/pack_v{version}.json`
3) 네트워크 API (추후 선택)

추가 메타:
- `Application Support/QuizPack/current.json` : 현재 선택된 packVersion 저장

## 팩 JSON 스키마 (v1)
최상위 키:
- `meta`: 팩 메타데이터
- `categories`: 카테고리 목록
- `stages`: 스테이지 목록
- `questions`: 문제 목록

### meta
- `packId` (string, 필수)
- `version` (int, 필수)
- `language` (string, 필수, 예: "ko")
- `sizeMB` (int, 필수)
- `updatedAt` (string, ISO-8601, 필수)

### categories
- `id` (string, 필수, 고정 ID)
- `title` (string, 필수)

### stages
- `id` (string, 필수, 고정 ID)
- `title` (string, 필수, "Stage N" 고정 포맷)
- `categoryId` (string, 필수, categories.id 참조)
- `difficulty` (string, 필수: easy/medium/hard)
- `order` (int, 필수, 1부터)

### questions
- `id` (string, 필수, 고정 ID)
- `categoryId` (string, 필수)
- `stageId` (string, 필수)
- `difficulty` (string, 필수)
- `type` (string, 필수: mixed/multiple/boolean)
- `question` (string, 필수)
- `correctAnswer` (string, 필수)
- `incorrectAnswers` (string[], 필수)

### 예시 (축약)
```json
{
  "meta": {
    "packId": "base",
    "version": 1,
    "language": "ko",
    "sizeMB": 80,
    "updatedAt": "2026-01-28"
  },
  "categories": [
    { "id": "general", "title": "General" }
  ],
  "stages": [
    { "id": "general_easy_1", "title": "Stage 1", "categoryId": "general", "difficulty": "easy", "order": 1 }
  ],
  "questions": [
    {
      "id": "q1",
      "categoryId": "general",
      "stageId": "general_easy_1",
      "difficulty": "easy",
      "type": "multiple",
      "question": "Example?",
      "correctAnswer": "A",
      "incorrectAnswers": ["B", "C", "D"]
    }
  ]
}
```

## StageProgress 저장 스키마
로컬 저장, stageId 기준.

필드:
- `stageId` (string)
- `isUnlocked` (bool)
- `bestScore` (int, 0~5)
- `lastPlayedAt` (ISO-8601 string)

저장 위치:
- `Application Support/StageProgress/progress.json` (또는 동일 역할)

초기 상태:
- 각 카테고리+난이도 조합의 order=1 스테이지만 해제
- bestScore = 0

해제 규칙:
- stage N의 bestScore >= 4이면 stage N+1 해제 (같은 카테고리/난이도)

## 히스토리 저장 스키마
로컬 저장, 결과 단위.

필드:
- `id` (string)
- `date` (ISO-8601 string)
- `totalCount` (int)
- `correctCount` (int)
- `settings` (QuizSettings: categoryId, stageId, difficulty, type, amount)

저장 위치:
- `Application Support/History/history.json` (또는 동일 역할)

저장 정책:
- 로컬 우선 저장
- 추후 온라인 동기화가 필요하면 별도 동기화 큐 추가

## 빠른 시작
- 모든 카테고리+난이도에서 해제된 스테이지 풀 생성
- 랜덤 1개 선택
- settings: amount=5, categoryId, stageId, difficulty로 퀴즈 시작

## 비고
- JSON v1은 개발 속도 우선. 대규모 팩은 SQLite로 전환.
- 팩 업데이트는 설정 탭 수동. 다운로드 후 자동 최신 팩 선택.
