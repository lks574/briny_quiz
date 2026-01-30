#!/bin/sh
set -e

tuist generate
pod install --project-directory="$PWD"
