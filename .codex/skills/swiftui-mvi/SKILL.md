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

7. ✅ Task 취소 처리 권장
- 중복 로딩 방지를 위해 취소 가능한 Task 사용
```swift
private var loadTask: Task<Void, Never>?
loadTask?.cancel()

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
- (선택) Action → Route 이벤트로 분리 가능
