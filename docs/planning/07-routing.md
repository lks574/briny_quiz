# 라우팅/네비게이션 설계

## 탭 구조
- 탭 2개: Dashboard / History
- Quiz/Result는 Dashboard 탭의 NavigationStack에서 push

## AppRouter

### AppTab
- dashboard
- history

### Route
- quiz(QuizSettings)
- result(QuizResult)

### 보유 상태
- selectedTab: AppTab
- dashboardPath: [Route]
- historyPath: [Route] (현재는 비어있음, 확장 대비)

### API
- selectTab(_ tab: AppTab)
- push(_ route: Route)
- pop()
- popToRoot()
- handleDeepLink(_ url: URL)

## DeepLink

### DeepLink 타입
- quiz (설정 포함은 향후 확장)
- history

### 처리 규칙
- App 레벨에서 onOpenURL 수신
- DeepLink.parse → router.selectTab/push 수행

## 네비게이션 배치
- RootView에서 TabView 구성
- 각 탭 내부에 NavigationStack
- navigationDestination(for: Route.self)는 Dashboard 탭 루트에 집중

## 정책
- View는 router 직접 호출 금지
- Store에서 router 호출 허용
- DeepLink 실패 시 무시(또는 로깅)
