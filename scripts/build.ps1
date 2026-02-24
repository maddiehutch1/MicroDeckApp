# scripts/build.ps1 — Verify the app compiles to a release APK (no device needed)
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "── flutter pub get ─────────────────────────────"
flutter pub get

Write-Host ""
Write-Host "── flutter analyze ─────────────────────────────"
flutter analyze --fatal-warnings

Write-Host ""
Write-Host "── flutter build apk ───────────────────────────"
flutter build apk --release --split-per-abi

Write-Host ""
Write-Host "── Build artifacts ─────────────────────────────"
Get-ChildItem "build\app\outputs\flutter-apk\*.apk" -ErrorAction SilentlyContinue |
  Format-Table Name, Length

Write-Host ""
Write-Host "✓ Build complete"
Write-Host ""
