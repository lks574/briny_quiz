# API (Open Trivia DB)

## 목적
- 문제 목록을 받아 퀴즈 화면에 제공한다.

## 확정 정책
- 문제 수: 10
- 카테고리: 전체
- 난이도: 사용자가 선택한 값만 요청
- 질문 유형: 사용자가 선택 (혼합/객관식/주관식)
- 문제당 제한시간: 10초
- 캐시 TTL: 24시간
- 인코딩: encode=base64 사용
- 세션 토큰: 사용(중복 방지), 만료/소진 시 리셋

## 기본 엔드포인트
- 문제 조회: Trivia API(api.php)
- 카테고리 목록: `https://opentdb.com/api_category.php`
- 글로벌 질문 수: `https://opentdb.com/api_count_global.php`

## 요청 파라미터(api.php)
- amount: 1~50 (기본 10)
- category: 카테고리 ID (전체는 미지정)
- difficulty: easy | medium | hard (선택값)
- type: multiple | boolean (혼합은 미지정)
- encode: urlLegacy | url3986 | base64 (미지정 시 HTML entity)
- token: 세션 토큰(중복 방지용, 선택)

## 응답 포맷
```json
{
  "response_code": 0,
  "results": [
    {
      "category": "General Knowledge",
      "type": "multiple",
      "difficulty": "easy",
      "question": "Question text",
      "correct_answer": "Answer",
      "incorrect_answers": ["A", "B", "C"]
    }
  ]
}
```

## Response Code
- 0: 성공
- 1: 결과 없음(조건이 너무 빡빡함)
- 2: 파라미터 오류
- 3: 토큰 없음/잘못됨
- 4: 토큰 소진(리셋 필요)
- 5: 레이트 리밋(동일 IP 5초 1회)

## 인코딩
- 기본값은 HTML entity
- encode 파라미터로 urlLegacy/url3986/base64 선택 가능

## 세션 토큰(선택)
- 신규 토큰 발급/리셋 API 제공
- 토큰은 6시간 미사용 시 만료

## 제한 사항
- 카테고리는 요청당 1개만 지정 가능
- 요청당 최대 50문항
