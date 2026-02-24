# scripts/analyze.ps1 — Static analysis + formatting check only (no emulator)
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "── Static Analysis ────────────────────────────"
flutter analyze --fatal-infos

Write-Host ""
Write-Host "── Code Formatting ────────────────────────────"
dart format --set-exit-if-changed lib/ test/ integration_test/

Write-Host ""
Write-Host "✓ Analysis clean"
Write-Host ""
