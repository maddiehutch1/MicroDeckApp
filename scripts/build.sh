#!/usr/bin/env bash
# scripts/build.sh — Verify the app compiles to a release APK (no device needed)
set -e

echo ""
echo "── flutter pub get ─────────────────────────────"
flutter pub get

echo ""
echo "── flutter analyze ─────────────────────────────"
flutter analyze --fatal-warnings

echo ""
echo "── flutter build apk ───────────────────────────"
flutter build apk --release --split-per-abi

echo ""
echo "── Build artifacts ─────────────────────────────"
ls -lh build/app/outputs/flutter-apk/*.apk 2>/dev/null || ls -lh build/app/outputs/apk/release/*.apk

echo ""
echo "✓ Build complete"
echo ""
