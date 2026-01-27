---
name: swiftui-routing
description: SwiftUI(iOS 17+)에서 NavigationStack/TabView 기반 라우팅을 표준화한다. AppRouter/Route/DeepLink 규칙과 딥링크 처리, 탭별 스택 분리, Route payload 규칙을 강제하고, Feature가 라우팅을 일관된 방식으로 사용하게 한다.
---

# 🎯 목표 (Goal)
이 프로젝트의 네비게이션/딥링크를 **일관된 표준**으로 고정한다.

- SwiftUI iOS 17+ 기준
- NavigationStack + NavigationPath 사용
- TabView(탭) 환경에서 **탭별 스택 분리**를 기본으로 한다
- 딥링크 URL → Route 변환 규칙을 강제한다

---

# ❗ 절대 규칙 (Non-negotiable Rules)

1) ❌ View에서 직접 NavigationPath 조작 금지  
- View는 router/state를 통해서만 이동한다.

2) ✅ 라우팅의 단일 진실 원천(Single Source of Truth)은 AppRouter  
- push/pop/popToRoot/selectTab/handleDeepLink는 AppRouter에만 둔다.

3) ✅ Route는 Hashable enum으로 정의  
- 화면 이동 단위는 반드시 Route로 표현한다.
- Route payload는 가능한 작게: id/slug 등 기본 타입 위주.
- Domain 모델/큰 객체 직접 전달 금지

4) ✅ 탭별 NavigationPath 분리(기본)
- users 탭 → usersPath
- settings 탭 → settingsPath
- (추가 탭도 동일 패턴)
 - 탭 재선택 시 popToRoot 여부 기본 정책을 명시한다

5) ✅ 딥링크는 DeepLink.parse(URL)로만 해석
- URL 파싱 로직은 View/Store에 두지 않는다.
- onOpenURL 등 딥링크 entry는 App 레벨에서만 처리한다.
- 파싱 실패 시 무시 또는 로깅 정책을 명시한다.

6) ✅ Store에서 router를 직접 호출하는 것은 허용(기본 정책)
- Store(Action 처리)에서 router.push(...) 호출 허용
- 단, View에서 router 직접 호출은 금지

7) ✅ navigationDestination(for:)은 App 레벨(또는 탭 루트)에서 집중 처리
- destination 분기 로직을 Feature 내부 여기저기 흩뿌리지 않는다.

---

# 📁 표준 파일 구성

App/
- AppRouter.swift
- DeepLink.swift
- (선택) Route.swift (Route가 커지면 분리)

---

# 🧭 표준 구현 템플릿

## AppRouter.swift (템플릿)
- 반드시 @MainActor + @Observable
- selectedTab, 탭별 path 보유
- push/pop/popToRoot 제공
- 딥링크 처리용 API 제공(또는 App에서 parse 후 router 호출)

필수 형태:
- enum AppTab: Hashable
- enum Route: Hashable
- final class AppRouter

## DeepLink.swift (템플릿)
- enum DeepLink
- static func parse(_ url: URL) -> DeepLink?

---

# ✅ 딥링크 표준 규격

기본 규격 예시:
- myapp://user/<id>        → Route.userDetail(id: "<id>")
- myapp://settings         → settings 탭 루트

규칙:
- scheme 고정(예: myapp)
- host/pathComponents 기반 파싱
- 파싱 실패 시 nil 반환(조용히 무시) 또는 로깅

---

# 🔄 Codex가 이 스킬을 호출했을 때 해야 할 일

1) 프로젝트 내 라우팅 방식 확인
- NavigationLink 남발/임의 path 조작/Feature별 라우팅 분산이 있다면 표준으로 정리

2) AppRouter/Route/DeepLink가 없으면 생성
- 있으면 본 스킬 규칙에 맞게 수정

3) 탭별 스택 분리 구조로 맞추기
- selectedTab
- usersPath/settingsPath 등

4) navigationDestination(for: Route.self) 를 루트에 배치
- Route 케이스별 화면 매핑을 한 곳으로 모으기

5) View에서 navigation 관련 로직 제거
- View는 store.send(Action)만 호출하도록 정리
- Store에서 router.push(...) 호출로 통일

6) 딥링크 entry 위치 통일
- App에서 `.onOpenURL` 처리 → DeepLink.parse → router 호출 흐름으로 정리

7) 탭 재선택 정책 반영
- 탭 재선택 시 popToRoot 여부를 AppRouter에 명시

8) 멀티 윈도우/Scene 필요 시 정책 명시
- Scene별 router 분리 또는 공유 정책을 문서화

---

# 📌 결론
이 스킬은 SwiftUI 앱에서 네비게이션이 산발적으로 구현되는 문제를 막기 위해,
"Router + Route + DeepLink" 3요소를 표준으로 강제한다.
