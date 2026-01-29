# BrinyQuiz

SwiftUI 기반 iOS 퀴즈 앱입니다. 온라인(Open Trivia DB) 문제와 오프라인 팩(로컬 DB)을 함께 사용해
카테고리/난이도별 퀴즈를 풀고 기록을 확인할 수 있습니다.

## 주요 기능
- 대시보드: 카테고리 선택, 난이도 선택, 문제 수/제한 시간 확인, 빠른 시작
- 스테이지: 카테고리/난이도별 스테이지 목록, 잠금/최고 점수 표시
- 퀴즈: 타이머, 선택지 응답, 스킵/다음, 정답 수 집계
- 결과: 점수 표시 및 재시작
- 히스토리: 기간 필터로 기록 조회(성공/실패, 점수)
- 설정: 오프라인 팩 버전 확인/다운로드(서버 설정 필요)

## 기술/구조
- iOS 17+ / SwiftUI / Observation(@Observable)
- Tuist + Swift Package Manager(SPM) 기반 모듈화로 의존성과 빌드 구성을 일관되게 관리합니다.
- 모듈 구조
  - `Packages/Domain`: 모델, 유스케이스, 프로토콜
  - `Packages/Data`: 네트워크(Open Trivia DB), 캐시/로컬 DB, 리포지토리 구현
  - `Packages/DesignSystem`: 색상/타이포/컴포넌트
  - `Sources/App`, `Sources/Features`: 화면/스토어/사이드이펙트

## 실행 방법
1) (선택) Tuist 사용 시
   - `tuist generate`
2) Xcode에서 `BrinyQuiz.xcworkspace` 또는 `BrinyQuiz.xcodeproj` 열기
3) 스킴 `BrinyQuiz` 선택 후 iOS 17+ 시뮬레이터에서 실행

## 테스트
- 테스트 코드가 포함되어 있습니다.
- Xcode Test 메뉴에서 실행
- 테스트 타깃: `FeatureQuizTests`, `FeatureHistoryTests`, `FeatureSettingsTests`

## 개발 방식
- vibe coding으로 Codex를 사용하며, Skill을 적극 활용하고 있습니다.

## 폴더 구조
- `Sources/App`: 앱 진입, 라우팅, 공용 플로우(스플래시/대시보드/스테이지/결과)
- `Sources/Features`: 기능별 화면(Quiz/History/Settings)
- `Packages`: Domain/Data/DesignSystem 모듈
