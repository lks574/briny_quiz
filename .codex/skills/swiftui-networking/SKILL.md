---
name: swiftui-networking
description: SwiftUI(iOS 17+) 프로젝트의 네트워크 계층을 표준화한다. APIClient/Endpoint/AppError 규칙을 정의하고 URLSession + async/await 기반으로 구현한다.
---

# 🎯 목표 (Goal)
이 프로젝트의 네트워크 계층을 **일관된 형태**로 고정한다.

- URLSession + async/await 기반
- 요청/응답/에러 처리 표준화
- Repository는 Domain Model을 반환하도록 돕는 기반 제공

---

# ❗ 절대 규칙 (Non-negotiable Rules)

1) ❌ View/Store에서 URLSession 직접 호출 금지  
- 네트워크 요청은 반드시 APIClient를 통해서만 수행한다.

2) ✅ Endpoint(라우트) 정의를 분리
- baseURL, path, method, headers, query, body 등을 Endpoint에서 정의한다.
- APIClient는 Endpoint를 받아 URLRequest를 만들어 실행한다.

3) ✅ 에러는 AppError로 통일
- 네트워크/HTTP/디코딩/타임아웃/취소 등 케이스를 구분한다.
- 사용자 표시 메시지(localizedDescription)와 로깅용 정보를 분리한다.

4) ✅ HTTP 상태코드 처리 표준
- 200~299: 성공
- 그 외: AppError.httpStatus(code, body?)로 변환
- 401/403은 인증/권한 에러로 별도 분기 가능

5) ✅ 디코딩은 APIClient에서 수행
- Repository에서 JSONDecoder를 직접 돌리지 않는다(원칙)
- Repository는 DTO → Domain 매핑에 집중한다

6) ✅ Task 취소는 정상 흐름으로 처리
- 취소(Task.isCancelled)는 사용자 에러로 표시하지 않는다

7) ✅ 기본 타임아웃/로깅 훅 제공
- timeoutInterval 설정 가능(기본값 제공)
- (선택) 요청/응답 로깅은 APIClient 한 곳에서
 - debug/dev/prod 환경별 로깅 수준을 구분한다

8) ✅ 재시도/백오프 정책 명시
- 5xx/네트워크 오류에서만 재시도 허용
- 재시도 횟수/지연(backoff) 규칙을 고정한다

9) ✅ 인증 토큰 갱신 규칙
- 401 처리 시 refresh → 재시도 흐름을 APIClient에서 수행
- 갱신 실패 시 unauthorized로 변환

10) ✅ 디코딩 전략 표준화
- keyDecodingStrategy/dateDecodingStrategy 기본값을 고정

11) ✅ 업로드/다운로드 타입 규칙
- Multipart/파일 업로드/다운로드용 Endpoint 규칙을 정의한다

---

# 📁 표준 폴더 구조

Data/
  Network/
    APIClient.swift
    Endpoint.swift
    HTTPMethod.swift
    AppError.swift
    (선택) RequestBuilder.swift
    (선택) NetworkLogger.swift

---

# 🧱 표준 타입 정의

## HTTPMethod
- GET, POST, PUT, PATCH, DELETE

## Endpoint
필수 구성:
- var path: String
- var method: HTTPMethod
- var headers: [String: String]
- var queryItems: [URLQueryItem]
- var body: Data? (또는 Encodable 기반)
- var timeout: TimeInterval? (선택)
- var requiresAuth: Bool (선택)
 - var retryPolicy: RetryPolicy? (선택)

## AppError
필수 케이스 예시:
- invalidURL
- transport(URLError)
- httpStatus(Int, Data?)
- decoding(Error)
- encoding(Error)
- unauthorized
- forbidden
- cancelled
- unknown(Error)

그리고:
- 사용자 표시용 메시지 제공 프로퍼티(예: displayMessage)

---

# 🧪 APIClient 표준 동작

1) Endpoint → URLRequest 생성
2) URLSession.data(for:) 호출
3) 취소 처리
4) HTTP 상태코드 검사(2xx만 성공)
5) 성공 시 Decodable 타입으로 decode
6) 실패 시 AppError로 변환해서 throw
7) 401은 refresh 정책에 따라 재시도
8) RetryPolicy에 따라 재시도/백오프

---

# 🔄 Codex가 이 스킬을 호출했을 때 해야 할 일

1) Network 폴더에 표준 타입들이 없으면 생성
- HTTPMethod, Endpoint, AppError, APIClient

2) 기존 네트워크 코드가 있다면 마이그레이션
- View/Store/Repository에서 URLSession 직접 호출 제거
- APIClient로 일원화

3) Repository 코드 정리
- Repository는 APIClient로 DTO를 받아오고 Domain으로 매핑
- 캐시가 있으면 Cache(actor) → Repository 내부에서만 접근

4) 에러 처리 일관화
- throw AppError
- UI(Store)는 AppError.displayMessage 또는 localizedDescription 사용(프로젝트 정책에 따라)

5) 테스트 표준화
- URLProtocol 기반 스텁/모킹으로 네트워크 테스트 구성

---

# 📌 결론
이 스킬은 네트워크 계층을 APIClient/Endpoint/AppError 3요소로 표준화하여,
- 호출 위치 혼란 방지
- 에러 처리 통일
- 테스트/확장 용이
를 확보한다.
