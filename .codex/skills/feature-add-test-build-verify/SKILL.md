---
name: feature-add-test-build-verify
description: "새 기능 추가 후 변경된 피처만 테스트하고 앱 빌드/검증까지 자동 수행한다. '테스트하고 빌드' 요청 시 사용."
---

# Feature Add → Test → Build → Verify

## 목적
새 기능을 추가한 뒤 **변경된 피처만 테스트**하고, **앱 빌드/검증**까지 수행한다.

## 기본 설정 (고정)
- 시뮬레이터: iPhone 17 Pro 26.1 (iOS 26.1)
- 테스트 대상: 변경된 Feature만
- 빌드: `BrinyQuiz` 스킴, code signing 비활성화

## 워크플로
1) 기능 추가 작업을 완료한다.
2) 변경된 Feature를 판단한다.
   - 우선순위: staged 변경 > working tree 변경
   - 매핑 기준:
     - `Sources/Features/Quiz/**` 또는 `Tests/FeatureQuizTests/**` → FeatureQuizTests
     - `Sources/Features/History/**` 또는 `Tests/FeatureHistoryTests/**` → FeatureHistoryTests
     - `Sources/Features/Settings/**` 또는 `Tests/FeatureSettingsTests/**` → FeatureSettingsTests
3) 해당 Feature 테스트 실행
4) 앱 빌드/검증 실행

## 실행 규칙
- 테스트는 아래 스크립트를 사용한다.
  - `scripts/run_feature_tests.sh`
- 빌드는 다음 명령으로 실행한다.
  - `xcodebuild -project BrinyQuiz.xcodeproj -scheme BrinyQuiz -destination 'generic/platform=iOS' -derivedDataPath Derived/DerivedData CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGNING_IDENTITY="" build`
- 테스트/빌드 로그 요약과 결과(성공/실패)를 보고한다.

## 스크립트
- 테스트 실행: `scripts/run_feature_tests.sh`
