# scripts/test.ps1 — Run all Micro-Deck test suites (Windows PowerShell)
# Usage: .\scripts\test.ps1 [-Integration]
# Exit code: 0 = all passed, 1 = any failure
param(
  [switch]$Integration
)
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================"
Write-Host "  Micro-Deck Test Runner"
Write-Host "========================================"

Write-Host ""
Write-Host "-- [1/4] Static Analysis ----------------"
flutter analyze --fatal-infos
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host "    OK: No issues"

Write-Host ""
Write-Host "-- [2/4] Code Formatting ---------------"
dart format --set-exit-if-changed lib/ test/ integration_test/
if ($LASTEXITCODE -ne 0) {
  Write-Host "    ERROR: Formatting issues found. Run:"
  Write-Host "    dart format lib/ test/ integration_test/"
  exit 1
}
Write-Host "    OK: Formatting OK"

Write-Host ""
Write-Host "-- [3/4] Unit + Widget Tests -----------"
flutter test --coverage --reporter=compact
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host "    OK: Unit and widget tests passed"

if ($Integration) {
  Write-Host ""
  Write-Host "-- [4/4] Integration Tests -------------"
  Write-Host "    (Requires a running emulator)"
  flutter test integration_test/app_test.dart --reporter=compact
  if ($LASTEXITCODE -ne 0) { exit 1 }
  Write-Host "    OK: Integration tests passed"
} else {
  Write-Host ""
  Write-Host "-- [4/4] Integration Tests SKIPPED -----"
  Write-Host "    Re-run with -Integration flag and a running emulator"
}

Write-Host ""
Write-Host "========================================"
Write-Host "  All checks passed"
Write-Host "========================================"
Write-Host ""