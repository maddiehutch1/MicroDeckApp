# Micro-Deck — CLI Test Plan

*Last updated: February 2026*

---

## 1. MVP Summary

Micro-Deck is a minimalist habit initiation app: one card, two minutes, no judgment. Six screens prove the core loop: Welcome → Onboarding (goal + action) → Confirm → Timer → Deck. MVP is done when a user can go from cold launch to haptic completion in under 90 seconds on a real device without crashes.

---

## 2. MVP Feature Inventory (Testable)

| # | Feature | Testable assertion |
|---|---------|--------------------|
| F1 | Welcome screen | First launch shows "begin" button; tapping navigates to goal screen |
| F2 | Onboarding goal | Goal screen has TextField; valid input enables Next |
| F3 | Onboarding action | Action screen shows goal as context; valid input enables Let's go |
| F4 | Confirm screen | Action label displayed; "Save for later" lands on deck; "Start now" opens timer |
| F5 | Timer screen | Countdown displays MM:SS; haptic fires on completion |
| F6 | Deck view | Card list shows action + goal; tap card opens timer; FAB opens add flow |
| F7 | Add card | Template browser or add sheet; saving adds card to deck |
| F8 | Persistence | Cards survive app restart |
| F9 | Settings | Deck header icon opens settings screen |

---

## 3. Test Matrix

| Feature | Test Type | Command | Inputs/flags | Expected Output | Pass/Fail Rule | Notes |
|---------|-----------|---------|--------------|-----------------|----------------|-------|
| F1–F4, F6 (partial) | Integration | `flutter test integration_test/app_test.dart` | (none) | All tests pass; "completes full onboarding flow and reaches deck" | Exit 0 = pass | Uses "Save for later" path |
| F6 (FAB) | Integration | Same | (none) | "opens template browser when FAB is tapped" | Exit 0 = pass | Verifies sheet opens, not full add flow |
| F6 (swipe) | Integration | Same | (none) | Swipe test passes if cards exist | Exit 0 = pass | Conditional on deck having cards |
| F5 (timer open) | Integration | Same | (none) | "tapping a card opens the timer screen" | Exit 0 = pass | Conditional; verifies countdown visible |
| F9 | Integration | Same | (none) | "opens from deck header settings icon" | Exit 0 = pass | Verifies "Resting" heading |
| All unit/widget | Unit | `flutter test` | (none) | All unit + widget tests pass | Exit 0 = pass | No emulator needed |
| Analysis | Static | `flutter analyze --fatal-infos` | (none) | No issues | Exit 0 = pass | Fast first-pass |
| Format | Static | `dart format --set-exit-if-changed lib/ test/ integration_test/` | (none) | No changes needed | Exit 0 = pass | |

**Primary CLI integration test:** `flutter test integration_test/app_test.dart`

---

## 4. Gaps (MVP features not covered by app_test.dart)

| Gap | Proposed integration test | Command |
|-----|---------------------------|---------|
| F4 "Start now" path | Add test in `app_test.dart` or `integration_test/timer_completion_test.dart` | `flutter test integration_test/timer_completion_test.dart` |
| F5 haptic on completion | Same as above; haptic may require real device | — |
| F7 full add-card flow | `integration_test/add_card_test.dart` — select template, save, verify card in deck | `flutter test integration_test/add_card_test.dart` |
| F8 persistence | `integration_test/persistence_test.dart` — add card, restart app, verify card present | `flutter test integration_test/persistence_test.dart` |

---

## 5. Quickstart: Validate MVP in 10 Minutes

```powershell
# 1. Analysis (fast)
flutter analyze --fatal-infos

# 2. Format check
dart format --set-exit-if-changed lib/ test/ integration_test/

# 3. Unit + widget tests (no emulator)
flutter test

# 4. Start Android emulator (one-time per session)
flutter emulators
flutter emulators --launch <name_from_list>

# 5. Integration tests (emulator required)
flutter test integration_test/app_test.dart --reporter=compact
```

**Pass criteria:** All commands exit with code 0.

---

## 6. Android Emulator Setup

```powershell
# List available emulators
flutter emulators

# Create one if none exist
flutter create --platforms=android .

# Launch (replace with your emulator name)
flutter emulators --launch Pixel_7_API_34

# Verify device is connected
flutter devices
```

---

## 7. State Reset Strategy

| What | How |
|------|-----|
| SharedPreferences | `SharedPreferencesAsync().clear()` — clears onboarding flag and other prefs |
| App database (SQLite) | Not reset by `app_test.dart`; persists between tests. First-launch test clears prefs only; subsequent tests rely on card created by first test. |
| Full reset (manual) | Uninstall app from emulator, or clear app data in device settings |

**In `app_test.dart`:**
- `_clearState()` — clears SharedPreferences for first-launch test
- `_setOnboardingComplete()` — sets `hasCompletedOnboarding: true` only; DB unchanged

---

## 8. CI Note

For headless CI (e.g. GitHub Actions):

1. Use `flutter emulators --launch <name>` with a pre-created AVD.
2. Or use `android-emulator-runner` / `ReactiveCircus/android-emulator-runner` action to start an emulator before `flutter test integration_test/app_test.dart`.
3. Ensure `ANDROID_HOME` is set and SDK components are installed.
4. Integration tests require `integration_test` (sdk: flutter) — already in pubspec.yaml.

Example (conceptual):

```yaml
- uses: reactivecircus/android-emulator-runner@v2
  with:
    api-level: 34
    script: flutter test integration_test/app_test.dart
```
