#!/usr/bin/env bash
set -euo pipefail

msg="${1:-}"
if [[ -z "$msg" ]]; then
  echo "error: commit message is required" >&2
  exit 2
fi

status="$(git status --porcelain)"
if [[ -z "$status" ]]; then
  echo "no changes to commit"
  exit 0
fi

echo "staging/commit summary:"
git status --short

git add -A
git commit -m "$msg"
