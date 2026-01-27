---
name: swiftui-design-system
description: SwiftUI(iOS 17+) 프로젝트에서 디자인 시스템(토큰/타이포/간격/컬러/컴포넌트)을 표준화한다. 라이트/다크 테마를 포함하고, 공통 컴포넌트를 일관된 방식으로 구성한다.
---

# 🎯 목표 (Goal)
SwiftUI 앱의 디자인 시스템을 **토큰 + 컴포넌트**로 표준화한다.

- 라이트/다크 테마 지원
- 색상/타이포/간격 토큰 정의
- 공통 컴포넌트(Button, Card, Tag 등) 규칙 통일
- View는 토큰/컴포넌트만 사용하도록 유도

---

# ❗ 절대 규칙 (Non-negotiable Rules)

1) ❌ View에서 임의 색상/폰트 직접 지정 금지
- 반드시 DesignToken을 통해서만 사용한다.

2) ✅ 테마는 Light/Dark 모두 제공
- 색상 토큰은 라이트/다크 값 모두 정의한다.

3) ✅ 타이포 스케일 고정
- Title/Body/Caption 등 규격을 고정하고 임의 크기 금지

4) ✅ 간격/라운드/섀도우 토큰화
- spacing, radius, elevation을 토큰으로 관리

5) ✅ 공통 컴포넌트는 재사용 가능하게 설계
- Button/Card/Chip 등은 하나의 표준 스타일로 구현

6) ✅ UI 작업 전 디자인 시스템 확인 필수
- 새로운 View/화면을 그리기 전, 항상 DesignSystem 토큰/컴포넌트 정의를 확인한다.
- 토큰/컴포넌트가 없으면 먼저 추가한 뒤 UI에 적용한다.

7) ✅ 모든 UI 값은 디자인 시스템에서만 사용
- 색상/폰트/간격/라운드/섀도우 값은 DesignSystem 외부에서 직접 사용 금지

---

# 📁 표준 파일 구성

DesignSystem/
- DesignTokens.swift
- Typography.swift
- Spacing.swift
- Radius.swift
- Elevation.swift
- DSButton.swift
- DSCard.swift
- DSTag.swift

---

# 🧱 토큰 구조 (권장)

## Colors
- primary / secondary / background / surface / textPrimary / textSecondary / error
- 라이트/다크 값을 모두 지정

## Typography
- title / headline / body / caption
- 폰트/크기/굵기 고정

## Spacing
- xs/s/m/l/xl (예: 4/8/12/16/24)

## Radius
- s/m/l (예: 8/12/16)

## Elevation
- low/medium/high (shadow 규칙)

---

# 🧩 컴포넌트 규칙

## Button
- Primary / Secondary
- disabled/pressed 상태 포함

## Card
- 기본 surface 배경 + radius + elevation

## Tag
- 정보/상태 표시용 작은 컴포넌트

---

# 🔄 Codex가 이 스킬을 호출했을 때 해야 할 일

1) DesignSystem 폴더 생성 및 토큰 정의
2) 공통 컴포넌트 구현
3) 기존 View에서 직접 지정된 색/폰트를 토큰/컴포넌트로 교체
4) 라이트/다크 모드 확인

---

# 📌 결론
이 스킬은 SwiftUI 프로젝트에서 디자인 시스템을 통일하기 위해,
"Tokens + Components" 원칙을 강제한다.
