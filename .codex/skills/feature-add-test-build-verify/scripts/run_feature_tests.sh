#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT_DIR"

SIM_NAME="iPhone 17 Pro 26.1"
SIM_OS="26.1"
DERIVED_DATA="Derived/DerivedData"

get_changed_files() {
  if git diff --name-only --cached | grep -q .; then
    git diff --name-only --cached
  else
    git diff --name-only
  fi
}

changed_files="$(get_changed_files)"

features=()
if echo "$changed_files" | rg -q "^Sources/Features/Quiz/|^Tests/FeatureQuizTests/"; then
  features+=("FeatureQuiz")
fi
if echo "$changed_files" | rg -q "^Sources/Features/History/|^Tests/FeatureHistoryTests/"; then
  features+=("FeatureHistory")
fi
if echo "$changed_files" | rg -q "^Sources/Features/Settings/|^Tests/FeatureSettingsTests/"; then
  features+=("FeatureSettings")
fi

if [ ${#features[@]} -eq 0 ]; then
  echo "No feature changes detected."
  exit 0
fi

for feature in "${features[@]}"; do
  echo "Running ${feature} tests..."
  xcodebuild \
    -project BrinyQuiz.xcodeproj \
    -scheme "${feature}" \
    -destination "platform=iOS Simulator,name=${SIM_NAME},OS=${SIM_OS}" \
    -derivedDataPath "${DERIVED_DATA}" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_IDENTITY="" \
    test \
    -only-testing:"${feature}Tests"
  echo "${feature} tests done."
  echo ""
done
