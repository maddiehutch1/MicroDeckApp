#!/usr/bin/env bash
# scripts/test.sh — Run all Micro-Deck test suites
# Usage: bash scripts/test.sh [--integration]
# Exit code: 0 = all passed, 1 = any failure
set -e

INTEGRATION=false
for arg in "$@"; do
  [[ "$arg" == "--integration" ]] && INTEGRATION=true
done

echo ""
echo "══════════════════════════════════════════════"
echo "  Micro-Deck Test Runner"
echo "══════════════════════════════════════════════"

echo ""
echo "── [1/4] Static Analysis ──────────────────────"
flutter analyze --fatal-infos
echo "    ✓ No issues"

echo ""
echo "── [2/4] Code Formatting ──────────────────────"
dart format --set-exit-if-changed lib/ test/ integration_test/ || {
  echo "    ✗ Formatting issues found. Run: dart format lib/ test/ integration_test/"
  exit 1
}
echo "    ✓ Formatting OK"

echo ""
echo "── [3/4] Unit + Widget Tests ──────────────────"
flutter test --coverage --reporter=compact
echo "    ✓ Unit and widget tests passed"

if $INTEGRATION; then
  echo ""
  echo "── [4/4] Integration Tests ────────────────────"
  echo "    (Requires a running emulator)"
  flutter test integration_test/app_test.dart --reporter=compact
  echo "    ✓ Integration tests passed"
else
  echo ""
  echo "── [4/4] Integration Tests — SKIPPED ─────────"
  echo "    Re-run with --integration flag and a running emulator"
fi

echo ""
echo "══════════════════════════════════════════════"
echo "  All checks passed ✓"
echo "══════════════════════════════════════════════"
echo ""
