---
name: git-add-commit-approve
description: Git에서 변경된 파일을 전부 add하고 커밋 메시지를 받아 커밋하는 작업을 수행한다. 사용자가 "add/commit", "커밋", "git add", "git commit" 또는 "승인(approve)받고 커밋"을 요청할 때 사용한다. 환경에 따라 approval 없이도 실행할 수 있도록 기본은 일반 실행으로 둔다.
---

# Git Add + Commit

## 목표
변경된 파일을 안전하게 add하고, 사용자 메시지로 커밋한다. 기본은 일반 실행이며, 필요 시에만 approval 모드로 전환한다.

## 워크플로
1) `git status --porcelain`으로 변경 사항을 확인한다.
2) 변경이 없으면 사용자에게 알려 종료한다.
3) 변경이 있으면 커밋 메시지를 받아 `git add -A` 후 커밋한다.

## 실행 규칙
- 기본은 일반 실행(`sandbox_permissions` 미지정)으로 수행한다.
- 승인 모드가 필요한 환경에서만 `sandbox_permissions: require_escalated`를 사용한다.
- 커밋 메시지가 비어 있으면 반드시 다시 질문한다.
- 스테이징/커밋 전에 `git status --short` 요약을 출력한다.

## 스크립트 사용
`scripts/commit_all.sh`를 사용한다. 인자로 커밋 메시지를 전달한다.

예:
`scripts/commit_all.sh "feat: add quiz timer"`
