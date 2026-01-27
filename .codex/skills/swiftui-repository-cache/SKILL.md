---
name: swiftui-repository-cache
description: SwiftUI(iOS 17+) 프로젝트에서 Repository + Cache(actor) 계층을 표준화한다. DTO↔Domain 매핑 위치, 캐시 정책(TTL/만료/강제갱신), 동시성 안전 규칙을 강제하며, Store/View에서 데이터 접근이 섞이지 않게 한다.
---

# 🎯 목표 (Goal)
이 프로젝트의 데이터 계층을 **Repository + Cache(actor)** 패턴으로 표준화한다.

- View/Store는 데이터 소스(API/DB/파일/캐시)를 몰라야 한다
- Repository는 Domain Model을 반환한다
- 캐시는 actor로 thread-safe 하게 관리한다
- 캐시 전략(우선순위, 만료, 강제 갱신)을 명확히 정의한다

---

# ❗ 절대 규칙 (Non-negotiable Rules)

1) ❌ View/Store에서 Repository 내부 구현(캐시/네트워크/DB) 접근 금지  
- Store는 UseCase 또는 Repository의 **공개 API**만 호출한다  
- Cache(actor)는 Repository 내부에서만 접근한다

2) ✅ Repository는 Domain Model만 반환  
- DTO(UserDTO 등)를 Store/View로 올리지 않는다  
- JSON/Decoder/Encoder는 네트워크 계층(APIClient) 또는 Repository 경계에서만 사용한다

3) ✅ DTO ↔ Domain 매핑 위치는 Repository  
- Repository가 DTO를 받아 Domain으로 매핑한다  
- Store는 매핑 로직을 가지지 않는다

4) ✅ 공유 캐시는 반드시 `actor`  
- Dictionary/Array 캐시는 동시성 안전을 위해 actor로 구현한다  
- Repository는 `await cache.get...()` 형태로만 접근한다

5) ✅ 캐시 정책은 Repository API에서 제어한다  
- `forceRefresh`(강제갱신) 또는 `CachePolicy`를 사용한다  
- 기본값은 “캐시 우선(cache-first)”을 권장한다(프로젝트 정책에 따름)

6) ✅ 만료(TTL) 정책(선택 사항이지만 권장)
- 데이터 성격상 신선도가 중요하면 TTL을 둔다  
- TTL이 있으면 캐시에 timestamp를 저장한다  
- TTL 초과 시 네트워크로 갱신한다

7) ✅ Stale-While-Revalidate(선택)
- UX가 중요하면 “낡은 캐시 즉시 반환 + 백그라운드 갱신”을 허용할 수 있다
- 이 경우에도 Store의 상태 변경은 MVI reduce 흐름을 따르게 설계한다

8) ✅ 에러/취소 규칙
- 네트워크 에러는 AppError(또는 프로젝트 에러 표준)로 throw
- Task cancel은 사용자 에러로 표시하지 않도록 상위(Store)에서 처리
- Repository는 cancel을 삼키지 않는다(그대로 throw/전파 가능)

9) ✅ 파일 구조 표준
Data/
  Repositories/
  Cache/
  Network/
Domain/
  Models/

10) ✅ 캐시 키/범위 정책
- 캐시 키는 id/slug 등 안정적인 식별자 사용
- user/session 스코프 분리를 명시한다(로그아웃 시 전량 초기화)

11) ✅ Invalidation 전략
- 수동 invalidation API 제공
- 로그아웃/계정 변경 등 이벤트에서 전체 무효화

12) ✅ Disk cache 기준(선택)
- in-memory vs disk 사용 기준 명시
- 저장 위치/용량 상한/정리 정책 정의

13) ✅ 병합/충돌 규칙
- 캐시와 네트워크 응답 충돌 시 우선순위/머지 규칙 정의

14) ✅ 테스트 표준화
- actor 캐시 단위 테스트
- Repository 단위 테스트에서 cache-first/network-first 시나리오 검증

---

# 📁 표준 파일 구성

예시(Users 도메인):
Data/
  Repositories/
    UserRepository.swift
    UserRepositoryImpl.swift
  Cache/
    UserCache.swift
Domain/
  Models/
    User.swift

---

# 🧠 권장 API 형태

## Repository Protocol
- 외부 노출은 최소한으로
- forceRefresh 또는 CachePolicy를 포함

예시:
- func fetchUsers(forceRefresh: Bool) async throws -> [User]
- func fetchUser(id: String, forceRefresh: Bool) async throws -> User

또는 CachePolicy:
- enum CachePolicy { case cacheFirst, networkFirst, cacheOnly, networkOnly }

---

# 🧱 템플릿(권장) - CachePolicy

프로젝트가 복잡해지면 Bool 대신 정책 enum을 권장한다.

```swift
enum CachePolicy: Equatable {
    case cacheFirst
    case networkFirst
    case cacheOnly
    case networkOnly
}
```

---

# 🧪 테스트 가이드(간단)

- Cache actor는 동시 접근/경합 시나리오를 포함해 테스트한다
- Repository는 아래 케이스를 포함한다
  - cache-first + cache hit
  - cache-first + cache miss
  - network-first + 실패 후 캐시 fallback(정책에 따라)
  - forceRefresh/CachePolicy 적용 여부
