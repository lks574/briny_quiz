#!/bin/sh
set -e

if [ "$CONFIGURATION" != "Release" ]; then
  echo "Skipping RN bundle for configuration: $CONFIGURATION"
  exit 0
fi

if [ ! -d "$PROJECT_DIR/RN" ]; then
  echo "RN workspace not found at $PROJECT_DIR/RN"
  exit 1
fi

export NODE_BINARY=${NODE_BINARY:-node}
export RCT_METRO_PORT=${RCT_METRO_PORT:-8081}
export ENTRY_FILE=${ENTRY_FILE:-index.tsx}

RN_DIR="$PROJECT_DIR/RN"
RN_SCRIPTS="$RN_DIR/node_modules/react-native/scripts/react-native-xcode.sh"

if [ ! -f "$RN_SCRIPTS" ]; then
  echo "react-native-xcode.sh not found. Did you run npm install in RN/?"
  exit 1
fi

BUNDLE_OUTPUT="$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/main.jsbundle"
ASSETS_DEST="$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH"

export BUNDLE_FILE="$BUNDLE_OUTPUT"
export ASSETS_DEST="$ASSETS_DEST"

"$RN_SCRIPTS"
