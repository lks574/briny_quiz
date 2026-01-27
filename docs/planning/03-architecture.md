# 아키텍처

## 원칙
- MVI(Store) 기반 단방향 데이터 흐름
- View는 state 읽기 + Action 전송만 수행
- 네트워크/캐시/라우팅은 표준 계층에서만 처리

## 계층
- App
  - AppRouter
  - RootView
- Features
  - Store / View
- Domain
  - Models / UseCases
- Data
  - Network(APIClient/Endpoint/AppError)
  - Repository + Cache(actor)

## 데이터 흐름
View -> Store(Action)
Store -> UseCase/Repository -> APIClient/Cache
APIClient/Repository 결과 -> Store(InternalAction) -> State 업데이트

## 네트워크 정책(Open Trivia DB)
- 질문 요청은 `api.php` 사용
- 중복 방지를 위해 세션 토큰(token) 사용을 기본으로 고려
- 인코딩은 encode 파라미터 사용 (HTML entity 디코딩 or url/base64 정책 확정)
- response_code를 AppError로 매핑(0 성공, 1/2/3/4/5 에러)

## 데이터 계층 설계 문서
- 상세 모델/DTO/캐시 구조는 `docs/planning/05-data-model.md` 참고

## 캐시 정책
- 기본: cache-first (정책 확정 전)
- TTL: 24시간
- 강제 갱신: 사용자가 명시적으로 요청할 때
- 오프라인 범위: 질문 데이터(디스크) + 히스토리(로컬 저장)

## 라우팅/화면 구조(초안)
- Splash (초기 설정/기본값 로딩)
- Tab: Dashboard / History
  - Dashboard Stack: Quiz -> Result
  - History: 내부 데이터 기반 기록

## 라우팅 문서
- AppRouter/DeepLink 규칙은 `docs/planning/07-routing.md` 참고
