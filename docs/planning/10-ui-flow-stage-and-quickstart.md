# UI 흐름 (Stage / Quick Start)

## 목적
- 스테이지 기반 퀴즈와 빠른 시작 플로우를 명확히 정의
- Dashboard → StageView → Quiz 흐름을 표준화

---

## 1) Dashboard 화면
표시 요소:
- 카테고리 선택 (Picker)
- 난이도 선택 (Picker)
- 스테이지 선택 버튼
- 빠른 시작 버튼

동작:
- **스테이지 선택 버튼**: 카테고리+난이도 기준으로 StageView 이동
- **빠른 시작 버튼**: 전체 해제된 스테이지 풀에서 랜덤 1개 선택 후 Quiz 시작

검증:
- 카테고리/난이도 미선택 상태에서도 빠른 시작은 가능
- 스테이지 선택은 카테고리/난이도 필수

---

## 2) StageView 화면 (Grid)
입력:
- categoryId, difficulty

표시 요소:
- 스테이지 그리드 (Stage 1, Stage 2, ...)
- 잠금 상태 표시
- 최고 점수(bestScore) 표시

동작:
- 잠금된 스테이지는 비활성
- 해제된 스테이지 선택 시 Quiz 시작

---

## 3) Quiz 시작 규칙
- 스테이지 선택 시:
  - settings.amount = 5
  - settings.categoryId = 선택한 카테고리
  - settings.stageId = 선택한 스테이지
  - settings.difficulty = 선택한 난이도
- 빠른 시작 시:
  - unlocked 스테이지 풀에서 랜덤 선택
  - settings는 선택된 스테이지 기준 자동 설정

---

## 4) 라우팅
Route:
- `.stage(categoryId: String, difficulty: Difficulty)`
- `.quiz(settings: QuizSettings)`

---

## 5) 해제 조건
- 스테이지 종료 후 `correctCount >= 4`이면 다음 스테이지 해제
- 해제 갱신은 결과 저장과 동시에 처리
