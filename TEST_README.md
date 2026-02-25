# Micro-Deck — Test Harness Guide

This document explains how an AI agent (or a human) can exercise every core feature of the app from the command line, with zero manual UI interaction.

---

## Quick Reference

| What to run | Command (Windows) | Command (Mac/Linux) | Emulator? |
|---|---|---|:---:|
| Analysis only (fastest) | `.\scripts\analyze.ps1` | `bash scripts/analyze.sh` | No |
| Unit + widget tests | `flutter test` | `flutter test` | No |
| Unit + widget + analysis | `.\scripts\test.ps1` | `bash scripts/test.sh` | No |
| Integration tests | `.\scripts\test.ps1 -Integration` | `bash scripts/test.sh --integration` | **Yes** |
| Build APK (compile check) | `.\scripts\build.ps1` | `bash scripts/build.sh` | No |
| Machine-readable output | `flutter test --reporter=json` | same | No |

All commands return **exit code 0** on success and **exit code 1** on any failure — exactly what an AI agent needs to decide whether to proceed or fix.

---

## Test Structure

```
test/
  unit/
    card_model_test.dart         CardModel toMap/fromMap, durationLabel
    schedule_model_test.dart     ScheduleModel toMap/fromMap, hour/minute getters
    templates_test.dart          starterTemplates count, areas, content integrity
    card_repository_test.dart    Full CRUD via in-memory SQLite (no emulator)
  widgets/
    onboarding_test.dart         Goal + action screens: field validation, button states
    deck_screen_test.dart        Empty state, card rendering, FAB, header icons
    timer_screen_test.dart       Countdown display, initial time, tick decrement
integration_test/
  app_test.dart                  Full onboarding → deck → add → defer → settings flow
scripts/
  analyze.sh / analyze.ps1       Analysis + formatting (fastest, no tests)
  test.sh / test.ps1             Full test suite (unit + widget, optionally integration)
  build.sh / build.ps1           Release APK compile check
```

---

## Recommended AI Agent Loop

This is the autonomous test-fix cycle an AI agent should follow after making code changes:

```
1.  flutter analyze --fatal-infos          ← Fast first-pass (~5s). Fix any issues before running tests.
2.  flutter test                           ← Unit + widget tests, no emulator (~15-30s).
3.  Read exit code. If 1 → fix and repeat from step 1.
4.  flutter test integration_test/ ← Full app on emulator. Only run when unit tests pass.
5.  Read exit code + output. If 1 → fix and repeat from step 1.
```

For machine-readable output at step 2:

```bash
flutter test --reporter=json > build/test-results.json
```

The JSON output contains each test's name, result (`success`/`failure`), and error message. An AI agent can parse this to identify exactly which assertions failed.

---

## Running Tests

### Unit + Widget Tests (no emulator required)

```powershell
# Windows
flutter test

# With coverage report
flutter test --coverage

# Fast compact output
flutter test --reporter=compact

# JSON output for AI parsing
flutter test --reporter=json > build/test-results.json
```

```bash
# Mac/Linux — same commands
flutter test --reporter=compact
```

### Run a Single Test File

```bash
flutter test test/unit/card_model_test.dart
flutter test test/unit/card_repository_test.dart
flutter test test/widgets/deck_screen_test.dart
```

### Integration Tests (emulator required)

```powershell
# 1. Start an emulator first (one-time setup per session)
flutter emulators --launch <your_emulator_name>

# 2. Run integration tests
flutter test integration_test/app_test.dart
```

```bash
# List available emulators
flutter emulators
```

Integration tests require a running Android emulator or connected device. They install the debug APK, run all interactions programmatically, and report results with an exit code — no human needed.

---

## What Each Test File Covers

### `test/unit/card_model_test.dart`
Verifies `CardModel` serialization and computed properties.

| Test | Feature covered |
|---|---|
| `toMap serialises all fields` | DB write correctness |
| `isArchived encodes as 0/1` | SQLite bool encoding |
| `fromMap round-trips correctly` | DB read correctness |
| `fromMap handles null goalLabel` | Optional field handling |
| `fromMap handles missing isArchived` | Schema migration safety |
| `durationLabel returns minutes` | UI badge display |

### `test/unit/schedule_model_test.dart`
Verifies `ScheduleModel` serialization (weekdays as JSON array, time getters).

| Test | Feature covered |
|---|---|
| `weekdays serialises as JSON string` | Correct SQLite encoding |
| `fromMap round-trips correctly` | DB read correctness |
| `hour/minute getters` | Correct time decomposition |
| `empty weekdays list` | Edge case handling |

### `test/unit/templates_test.dart`
Verifies the static starter template list.

| Test | Feature covered |
|---|---|
| `contains exactly 20 templates` | Template count contract |
| `every template has non-empty fields` | Content integrity |
| `all areas from known set` | Area categorisation |
| `each area has at least one template` | Template completeness |
| `no duplicate actionLabels` | Template uniqueness |

### `test/unit/card_repository_test.dart`
Exercises every repository method against an in-memory SQLite database. No emulator needed — uses `sqflite_common_ffi`.

| Test group | Feature covered |
|---|---|
| Insert & read | `insertCard`, `getAllCards`, sort order, archive filter |
| Delete | `deleteCard`, cascading deferral/schedule cleanup |
| Archive & restore | `archiveCard`, `restoreCard`, sort order on restore |
| Defer | `deferCard`, sort order update, deferral record insert |
| Deferral count | `getDeferralCount` within time window |
| Archive prompt | `getCardsNeedingArchivePrompt` (3+ deferrals in 7 days) |
| Active count | `getActiveCardCount` |

### `test/widgets/onboarding_test.dart`
Verifies onboarding screen field validation without a database or emulator.

| Test | Feature covered |
|---|---|
| Goal prompt renders | Screen content |
| Next button disabled when empty | Input validation |
| Next button enabled after typing | Correct enable logic |
| Action screen shows goal as context | Cross-screen data passing |

### `test/widgets/deck_screen_test.dart`
Verifies deck screen rendering using a fake Riverpod provider (no DB).

| Test | Feature covered |
|---|---|
| Empty state message | Empty deck UX |
| FAB present | Add card entry point |
| Card action + goal + duration rendered | Card tile content |
| Multiple cards render | List rendering |
| Settings icon present | Navigation entry point |
| Just One mode icon present | Mode toggle presence |

### `test/widgets/timer_screen_test.dart`
Verifies timer display and tick behaviour.

| Test | Feature covered |
|---|---|
| Initial time renders as MM:SS | Countdown display |
| Action label displayed | Card context on timer |
| Timer decrements after 1 second | Tick mechanism |
| 1-minute card shows 1:00 | Variable duration |

### `integration_test/app_test.dart`
Full end-to-end tests on a real emulator. Each test group is independent.

| Test group | Flow exercised |
|---|---|
| First launch onboarding | Welcome → Goal → Action → Confirm → Deck |
| Add card via FAB | Deck → Template browser sheet |
| Swipe to defer | Card swipe left removes from visible list |
| Settings screen | Header icon → Settings screen opens |
| Timer screen | Tap card → Timer countdown visible |

---

## In-Memory Database (How Repository Tests Work)

`test/unit/card_repository_test.dart` uses `sqflite_common_ffi` to run a real SQLite database in-process on the Dart VM — no Android or iOS runtime needed.

Each test:
1. Calls `setDatabasePathForTesting(inMemoryDatabasePath)` to redirect to RAM
2. Runs the actual production `CardRepository` code unchanged
3. Calls `resetDatabaseForTesting()` in `tearDown` to wipe the DB between tests

This means the repository tests catch real SQL bugs (wrong column names, wrong WHERE clauses, migration issues) without any emulator.

---

## Machine-Readable Output for AI Agents

### JSON test results

```bash
flutter test --reporter=json 2>&1 | tee build/test-results.json
```

Each line of output is a JSON object. Key fields:

```json
{ "type": "testDone", "testID": 5, "result": "success" }
{ "type": "testDone", "testID": 6, "result": "failure",
  "error": "Expected: 1\n  Actual: 0" }
```

An AI agent reads `result` to identify which test failed and `error` to understand why.

### Exit codes

| Exit code | Meaning |
|---|---|
| `0` | All tests passed |
| `1` | One or more tests failed |

---

## Adding New Tests

Follow the existing patterns:

- **New model?** Add a `test/unit/<model>_test.dart` covering `toMap`/`fromMap` and all computed properties.
- **New repository method?** Add a test group in `card_repository_test.dart` using `setDatabasePathForTesting(inMemoryDatabasePath)`.
- **New screen?** Add a `test/widgets/<screen>_test.dart`. Use `FakeCardsNotifier` or `ProviderScope` overrides to avoid the real database.
- **New user flow?** Add a test group in `integration_test/app_test.dart`.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `flutter test` exits 0 but no tests ran | Check that test files end in `_test.dart` |
| `sqflite_common_ffi` not found | Run `flutter pub get` |
| Integration test hangs | Ensure emulator is fully booted before running |
| Gradle `copyFlutterAssetsDebug` fails / `NativeAssetsManifest.json` missing | Run `flutter clean`, then `flutter pub get`, then retry |
| Widget test fails with "No MediaQuery widget found" | Wrap widget in `MaterialApp` in test |
| `SharedPreferences` MissingPluginException in widget test | Add `SharedPreferences.setMockInitialValues({})` in `setUp` |
