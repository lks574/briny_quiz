# Codex 프롬프트: Tuist + SwiftUI 기존 iOS 앱에 React Native 0.83(New Architecture) 임베드 (Expo/OTA 제외)

아래 프롬프트를 **그대로 복사**해서 Codex에 넣고, `<...>` 부분만 본인 레포에 맞게 채우세요.  
목표는 **기존 SwiftUI 앱을 유지**하면서 **React Native 0.83.x**를 **브라운필드(기존 앱 통합)** 형태로 임베드하고, **New Architecture(Fabric/TurboModules/Codegen)를 ON**으로 운영하는 것입니다.

---

## Codex 프롬프트 (복사-붙여넣기)

```text
너는 iOS(SwiftUI) + Tuist 기반 “기존 앱(브라운필드)”에 React Native를 임베드하는 iOS/빌드 전문가다.
내 목표는 “기존 SwiftUI 앱을 유지”하면서, 특정 화면/플로우를 React Native 0.83로 점진적으로 추가하는 것이다.
Expo는 사용하지 않고, OTA도 하지 않는다.

기준 버전/조건:
- React Native: 0.83.x (패치 최신, 릴리스 노트 기준으로 최신 패치 재확인)
- New Architecture(Fabric/TurboModules/Codegen): ON 전제 (0.83에서도 New Architecture 흐름을 따른다)
- iOS 프로젝트 관리: Tuist 사용 (tuist generate로 Workspace/Project 생성)
- 의존성: React Native iOS는 CocoaPods 기반으로 연결(필수). 기타 iOS SDK는 SPM 혼용 가능.
- 결과물: SwiftUI에서 RCTRootView(또는 RN New Arch 기반 Root View)를 통해 RN 화면을 띄운다.
- Debug: Metro로 JS 번들 로딩
- Release: 앱에 포함된 main.jsbundle 로딩(빌드 단계에서 번들 생성)

리포 구조(내가 채워 넣을 값):
- Repository root: <REPO_ROOT>
- Tuist manifest 위치: <TUIST_MANIFEST_PATH> (예: <REPO_ROOT>/Tuist 또는 <REPO_ROOT>)
- iOS App Target name: <APP_TARGET_NAME>
- iOS bundle id: <BUNDLE_ID>
- Tuist가 생성할 workspace 이름: <WORKSPACE_NAME>
- Tuist가 생성하는 workspace/프로젝트 위치: <WORKSPACE_PATH> (예: <REPO_ROOT>/Tuist/Derived 또는 <REPO_ROOT> 하위)
- RN 워크스페이스 위치(신규): <REPO_ROOT>/RN
  - 여기에 package.json, node_modules, index.js(or tsx), src/ 등을 둔다.
- Podfile 위치: Tuist 생성 산출물과 충돌 없이 가장 안정적인 위치를 제안해라.
  - (Tuist generate 후 pod install이 workspace에 정상 결합되는 방향으로)

요청사항(반드시 “파일별 변경(diff)” 형태로, 바로 적용 가능하게 제공):
1) RN 워크스페이스(RN/) 초기 구성
   - package.json(스크립트 포함), index.js(or index.tsx)
   - AppRegistry.registerComponent 등록 이름(moduleName)을 확정(예: "MyRNEntry")
   - Metro 실행 커맨드 및 Debug에서 iOS가 번들을 받아오는 엔트리/경로 정리

2) Tuist + CocoaPods 결합 설계 (재현 가능한 워크플로우)
   - tuist generate → pod install 순서를 기준으로, 실행 스크립트/Makefile 제안
   - CI에서도 동일하게 재현되도록 ruby/bundler 사용 여부까지 포함해도 좋다
   - Tuist generate 산출물(workspace/Pods 연결 대상) 경로를 명확히 적어라
   - Podfile 템플릿을 “내 폴더 구조에 맞는 상대경로”로 정확히 작성:
     - react-native 경로는 <REPO_ROOT>/RN/node_modules 기준
     - use_react_native!, react_native_post_install 포함
     - Hermes 사용 여부 기본값 제안
     - New Architecture가 실제로 ON으로 빌드되도록 필요한 플래그/환경변수/설정 위치 제시
       (예: RCT_NEW_ARCH_ENABLED 등. 어디에 두면 팀/CI에서 일관되는지)

3) SwiftUI 호스트 앱에서 RN 화면 임베드
   - ReactBridgeManager(브리지/호스트 싱글톤) 구현: 앱 생명주기 동안 Bridge 1개 공유
   - SwiftUI용 UIViewRepresentable 래퍼(ReactNativeView) 구현
   - SwiftUI에서 RN 화면을:
     A) 화면 내 embed(일부 영역)
     B) sheet(모달)
     두 가지 예시로 제공
   - SwiftUI lifecycle(@main App) 기반, UIApplicationDelegate 기반, SceneDelegate(레거시) 각각
     “어디에 초기화/부트스트랩 코드를 두는지”를 명확히 제시

4) Debug/Release 번들 로딩 전략
   - Debug: RCTBundleURLProvider(or 동등)로 Metro 번들 URL을 얻어 로딩
   - Release: main.jsbundle을 빌드 시 생성/포함하고 Bundle.main에서 로딩
   - Tuist 기반에서 “번들 생성 스크립트를 어디에 넣는지”를 구체적으로 제안:
     - Tuist Project.swift의 build phase/script 단계로 넣는 방식 또는
     - Xcode 빌드 페이즈로 들어가는 방식 중 하나를 골라, 재현 가능한 답을 제시

5) New Architecture(0.83) 체크리스트 + 트러블슈팅
   - Codegen 산출물(생성 위치/빌드 포함 여부), Fabric/TurboModules 빌드 확인 포인트를 체크리스트로 정리
   - 흔한 에러 5개와 해결:
     - Tuist+Pods 경로 꼬임, workspace 중복 생성, 헤더/모듈맵, codegen 실행 누락,
       hermes/folly 관련, C++/clang 설정, 번들 스크립트 중복(Build Phases) 등
   - “특정 라이브러리가 아직 레거시 아키텍처에 의존”하는 경우의 대응 옵션도 간단히 제시
     (예: 임시로 new arch off 전략을 쓸지, 해당 모듈만 대체할지)

산출물 형식(필수):
A) 새로 추가/수정될 파일 목록
B) 각 파일의 내용 또는 diff
C) 실행 커맨드: 초기 세팅 → Debug 실행 → Release 아카이브까지
D) 오류/해결 표(최소 5개)

제약:
- 기존 SwiftUI 앱(네이티브 구조)은 최대한 유지. RN은 “붙이는” 형태로만.
- Expo/OTA는 절대 포함하지 말 것.
- RN 버전은 0.83 계열 기준으로 템플릿/Podfile 문법을 맞출 것.
```

---

## 참고 링크(근거/레퍼런스) — 문서 최신성은 실행 시점에 재확인

- React Native 0.83 릴리스 노트: https://reactnative.dev/blog/2025/12/10/react-native-0.83  
- 기존 앱에 RN 통합(브라운필드) 문서: https://reactnative.dev/docs/integration-with-existing-apps  
- New Architecture 개요(0.76 기본 활성화 흐름):  
  - https://reactnative.dev/blog/2024/10/23/the-new-architecture-is-here  
  - https://reactnative.dev/blog/2024/10/23/release-0.76-new-architecture  
- Tuist + CocoaPods 워크플로우(Generate 후 pod install 패턴 사례):  
  - https://blogs.halodoc.io/streamlining-dependencies-how-tuist-enables-cocoapods-and-swift-package-manager-integration/

---

## 메모(선택)
- 위 프롬프트에서 가장 자주 실패하는 지점은 **Podfile 위치/상대경로**, **Tuist generate ↔ pod install 순서**, **Codegen 실행/산출물 포함**입니다.
- Codex 산출물이 나오면, 실제 레포 트리(2~3레벨)와 Podfile 경로를 기준으로 한 번 더 정합성 점검을 권장합니다.
- New Architecture 플래그/환경변수는 **RN 0.83 최신 패치 기준**으로 다시 확인하도록 한 줄 추가하면 안전합니다.
