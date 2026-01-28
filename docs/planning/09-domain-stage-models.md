# 도메인 모델 확장 설계 (Stage/Pack)

## 목적
- 오프라인 팩 기반 퀴즈와 스테이지 진행을 지원하기 위한 도메인 확장
- MVI/Repository 구조에서 재사용 가능하도록 모델 분리

---

## 1) QuizSettings 확장
Stage/Category를 포함하는 실행 설정.

필드:
- `amount` (Int) : 스테이지 기반일 경우 5 고정
- `difficulty` (Difficulty)
- `type` (QuestionType)
- `categoryId` (String?)
- `stageId` (String?)
- `timeLimitSeconds` (Int)

규칙:
- 스테이지 기반 퀴즈는 `amount = 5`
- 빠른 시작은 `categoryId`/`stageId`를 랜덤 선택해 채움

---

## 2) QuizPackMeta
팩 버전과 관리용 메타데이터.

필드:
- `packId` (String)
- `version` (Int)
- `language` (String)
- `sizeMB` (Int)
- `updatedAt` (Date/ISO-8601 string)

---

## 3) QuizCategory
카테고리 정의.

필드:
- `id` (String)
- `title` (String)

---

## 4) QuizStage
스테이지 정의.

필드:
- `id` (String)
- `title` (String) : "Stage N"
- `categoryId` (String)
- `difficulty` (Difficulty)
- `order` (Int) : 1부터 증가

---

## 5) QuizPack
팩 구성 전체.

필드:
- `meta` (QuizPackMeta)
- `categories` ([QuizCategory])
- `stages` ([QuizStage])
- `questions` ([QuizQuestion])

규칙:
- `questions`는 `categoryId`, `stageId`, `difficulty`와 일관성을 유지
- `stages`는 카테고리+난이도 조합 내에서 `order` 순차

---

## 6) StageProgress
스테이지 진행 상태.

필드:
- `stageId` (String)
- `isUnlocked` (Bool)
- `bestScore` (Int, 0~5)
- `lastPlayedAt` (Date/ISO-8601 string)

규칙:
- `bestScore >= 4` 시 다음 스테이지 해제
- 초기 상태는 각 카테고리+난이도 조합의 `order = 1`만 해제

---

## 7) 추가 고려사항
- StageProgress는 로컬 저장이 기본
- Pack 업데이트 시 `stageId`가 유지되어야 진행 데이터 연속성 확보
- 추후 SQLite 전환 시에도 모델 구조는 유지
