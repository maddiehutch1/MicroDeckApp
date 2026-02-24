#!/usr/bin/env bash
# scripts/analyze.sh — Static analysis + formatting check only (no emulator)
# Fast first-pass for AI agents after code changes.
set -e

echo ""
echo "── Static Analysis ────────────────────────────"
flutter analyze --fatal-infos

echo ""
echo "── Code Formatting ────────────────────────────"
dart format --set-exit-if-changed lib/ test/ integration_test/

echo ""
echo "✓ Analysis clean"
echo ""
