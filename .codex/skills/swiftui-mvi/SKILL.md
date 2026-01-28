---
name: swiftui-mvi
description: SwiftUI(iOS 17+) 프로젝트에 MVI(Model-View-Intent) 아키텍처를 적용한다. Observation(@Observable)과 Swift Concurrency(async/await)만 사용하며, TCA/Rx/VIPER는 사용하지 않는다.
metadata:
  short-description: SwiftUI MVI(Store 기반) 아키텍처 표준
---

# 🎯 목표 (Goal)

이 프로젝트에 **MVI(Model–View–Intent)** 아키텍처를 표준으로 도입한다.

- SwiftUI(iOS 17+) + Observation(@Observable) + async/await 기반
- 단방향 데이터 흐름(UDF)을 강제한다
- ViewModel(MVVM) 대신 **Store 중심 구조**를 사용한다

---

# ❗ 절대 규칙 (Non-negotiable Rules)

1. ❌ 외부 상태관리/반응형 프레임워크 사용 금지  
   - TCA, RxSwift, VIPER, ReactorKit 등 금지

2. ✅ 단방향 데이터 흐름만 허용  

3. ✅ View의 역할 제한
- View는 `store.state` **읽기만** 한다
- View는 **반드시** `store.send(Action)`만 호출한다
- 네트워크, UseCase, Repository 직접 호출 ❌

4. ✅ 화면 상태는 반드시 단일 State로 관리
- `Store.State` 하나의 struct에 모든 UI 상태 포함
- isLoading / data / error 등을 흩어두지 말 것

5. ✅ Store 구조 강제
- `@MainActor @Observable final class`
- `State / Action / InternalAction` 반드시 분리
- State 변경은 **reduce(InternalAction)** 에서만 수행

6. ✅ Side Effect 규칙
- 비동기 작업은 Store 내부에서 `Task {}`로 실행
- 결과는 반드시 `InternalAction` → `reduce`를 통해 반영
- Task 결과에서 State 직접 수정 ❌
- SideEffect 레이어는 Store 타입에 결합되지 않도록 `Result`/DTO를 반환하고, Store가 `reduce`로 반영한다
 - SideEffect 책임 범위: **라우팅/네트워크/타이머/Task 관리** (Task 취소/교체 포함)

7. ✅ Task 취소 처리 권장
- 중복 로딩 방지를 위해 취소 가능한 Task 사용
```swift
private var loadTask: Task<Void, Never>?
loadTask?.cancel()
```
- 다수 Task는 ID 기반 관리(`TaskStore`)로 정리 가능

8.  ✅ 데이터 계층 규칙
- Repository 패턴 사용
- Repository는 Domain Model만 반환
- 공유 캐시는 반드시 actor로 구현

9.  ✅ DI(조립)는 AppContainer에서만 수행
- Store 생성 시 필요한 UseCase / Router 주입
- View에서 의존성 생성 ❌

10.  ✅ 네비게이션 규칙
- NavigationStack + AppRouter 사용
- Store가 router.push(Route)를 직접 호출하는 것은 허용
- (선택) Action → InternalAction → Route 이벤트로 분리 가능

---

# ✅ 추가 가이드 (권장)

## 1) 초기 로딩/중복 로딩 규칙
- `onAppear`는 **idempotent** 해야 한다 (중복 호출 안전)
- 새 요청 전 **이전 Task 취소** + 로딩 플래그 초기화
- 로딩 중 재요청은 무시하거나 기존 Task 재사용
- View는 `.task(id:)`를 사용해 설정 변경 시에만 재호출되게 한다

## 2) 에러 표준화 및 UI 매핑
- Domain 에러는 `enum`으로 표준화 (네트워크/파싱/권한 등)
- Store는 Domain 에러를 **UI 메시지로 변환**해서 `State`에 저장
- View는 메시지 렌더링만 수행

## 3) State 설계 원칙
- 파생 상태(derived state)는 View가 아니라 **Store 내부 계산**으로 둔다
- `empty/loading/loaded/error`를 단일 `State`로 표현
- 상태 전이 흐름을 명확히 유지
- `State.initial(...)` 같은 팩토리로 기본값을 분리한다

## 6) Store API 설계 (프로젝트 합의)
- `send(_:)`는 `async`를 기본으로 사용하고, View 편의를 위해 동기 `send(_:)` 오버로드를 둔다
- Store 내부 함수는 최대 3단계 깊이까지만 분해하고, 그 이상은 인라인 처리
- `private` 헬퍼는 `private extension`으로 분리해 읽기 흐름을 단순화한다

## 7) Task 관리 가이드
- `TaskStore<ID>`를 사용해 로딩/타이머 등 Task를 ID로 관리한다
- 타이머는 `SideEffect.startTimer(...) async` 형태로 노출하고 Store가 `await` 호출한다

## 8) SideEffect 설계 규칙 (프로젝트 합의)
- 역할: 라우팅/네트워크/타이머/Task 관리만 담당하고, 상태 변경은 절대 하지 않는다
- 호출 패턴: Store에서 **검증 → SideEffect 호출 → 결과를 `reduce`로 반영** 흐름을 유지한다
- 네이밍/위치: `FeatureSideEffect` / `FeatureSideEffectImpl`로 구성하고 Feature 폴더 내에 둔다

## 4) Store 테스트 가이드
- `reduce(InternalAction)`는 **동기 테스트** 가능하도록 설계
- 비동기 Task는 **UseCase/Repository mock**으로 제어
- `Task` 취소/중복 호출 시나리오 테스트 포함

## 5) Preview/DI 규칙
- Preview에서는 **Mock Repository/Fixture 데이터**만 사용
- 실제 네트워크/캐시는 Preview에서 금지
