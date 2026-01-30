SHELL := /bin/bash

.PHONY: ios-setup ios-generate ios-pods ios-run

ios-generate:
	tuist generate

# Pods install (includes Xcode 26 objectVersion workaround in Podfile)
ios-pods:
	pod install --project-directory="$(PWD)"

# One-shot setup for iOS workspace (Tuist + CocoaPods)
ios-setup: ios-generate ios-pods

# Optional helper: start Metro in RN/ (use separate terminal)
ios-run:
	cd RN && npm run start
