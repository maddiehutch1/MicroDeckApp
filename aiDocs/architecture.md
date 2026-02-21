# Architecture — Micro-Deck
**Version:** 1.0
**Last Updated:** February 2026
**Scope:** MVP + v1 planning
**Package versions verified:** February 2026 from pub.dev / api.flutter.dev

---

## 1. Platform & Build

| Layer | Decision | Notes |
|---|---|---|
| Framework | Flutter (Dart) | Single codebase for iOS + Android |
| iOS target | iOS 16+ | Primary platform |
| Android target | Android 8.0 (API 26)+ | Same codebase, no platform-specific work in v1 |
| Flutter SDK min | 3.22.0+ | Required by `wakelock_plus` |
| Dart SDK min | 3.4.0+ | Required by `wakelock_plus` |
| iOS build pipeline | Codemagic CI/CD | Dev machine is Windows — Mac build happens in cloud |
| Backend | None | Offline-only. No network requests anywhere in v1. |

---

## 2. Dependencies (Verified Versions)

All versions fetched live from pub.dev — February 2026.

### MVP packages

| Package | Version | Purpose |
|---|---|---|
| `shared_preferences` | ^2.5.4 | Onboarding flag and simple boolean state |
| `sqflite` | ^2.4.2 | Card data — structured local storage |
| `path` | ^1.9.0 | Required by sqflite for db path construction |
| `wakelock_plus` | ^1.4.0 | Keep screen on during timer session |
| `flutter_riverpod` | ^3.2.1 | State management |
| `flutter_lints` | ^5.0.0 | Dev — linting |

### Packages deferred or excluded

| Package | Decision |
|---|---|
| `flutter_local_notifications` | Deferred — v1 Phase 3 (scheduling feature) |
| `in_app_purchase` | Deferred — v1 Phase 3 (freemium Pro unlock, one-time IAP) |
| `flutter_launcher_icons` | Deferred — Phase 4 (app icon generation) |
| `flutter_native_splash` | Deferred — Phase 4 (launch screen) |
| `go_router` | Deferred — Navigator 1.0 is sufficient for 6 MVP screens |
| `uuid` | Excluded from MVP — use `DateTime.now().millisecondsSinceEpoch.toString()` for IDs |
| `drift` | Excluded — sqflite with `onUpgrade` migrations is sufficient for v1 schema changes |
| Any analytics/crash SDK | Excluded — no telemetry by design, ever |

---

## 3. Key API Decisions

### HapticFeedback (Flutter SDK built-in)
- Import: `package:flutter/services.dart` — no package install needed
- Use `HapticFeedback.mediumImpact()` for timer completion (the "Silent Pulse")
- Test `HapticFeedback.successNotification()` on a real device before locking in — semantically it may fit better
- All methods are static and return `Future<void>`

### wakelock_plus
- Import: `package:wakelock_plus/wakelock_plus.dart`
- Enable in timer screen `initState`, disable in `dispose` — always per-widget, never globally
- Call `WidgetsFlutterBinding.ensureInitialized()` in `main()` before any wakelock calls
- No special permissions required on iOS or Android

### shared_preferences
- Import: `package:shared_preferences/shared_preferences.dart`
- Use `SharedPreferencesAsync` — the legacy `SharedPreferences.getInstance()` is deprecated as of 2.3.0
- Scope: simple boolean flags only. All structured card data goes in sqflite.

### sqflite
- Import: `package:sqflite/sqflite.dart` and `package:path/path.dart`
- DB file: `microdeck.db` at `getDatabasesPath()`
- Critical type rules — do not violate:
  - `DateTime` → store as `INTEGER` (millisecondsSinceEpoch) — not a SQLite type
  - `bool` → store as `INTEGER` (0 or 1) — not a SQLite type
  - Query results are read-only — copy to `Map<String, Object?>` before modifying
  - Inside transactions, use the `txn` object — never the outer `database`

### flutter_riverpod
- Import: `package:flutter_riverpod/flutter_riverpod.dart`
- Wrap app in `ProviderScope` at `main()`
- Use `NotifierProvider<CardsNotifier, List<CardModel>>` — no codegen, no `build_runner`
- Use `ConsumerWidget` for screens that only read providers; `ConsumerStatefulWidget` when local state is also needed (e.g., timer)
- Full docs: https://riverpod.dev

---

## 4. Data Models

All data is local. No backend. No user accounts. No telemetry.

### CardModel (MVP — sqflite `cards` table)

| Field | Type | Notes |
|---|---|---|
| `id` | TEXT | `DateTime.now().millisecondsSinceEpoch.toString()` |
| `goalLabel` | TEXT | Nullable — card can exist without a named goal |
| `actionLabel` | TEXT NOT NULL | Verb-first action label |
| `durationSeconds` | INTEGER | Default: 120 |
| `sortOrder` | INTEGER | Default: 0; ordered ASC |
| `createdAt` | INTEGER | millisecondsSinceEpoch |

### shared_preferences keys

| Key | Type | Phase | Purpose |
|---|---|---|---|
| `hasCompletedOnboarding` | bool | MVP | Controls Welcome screen — false = show, true = skip |
| `hasSeenExplainer` | bool | Phase 3 | Controls post-completion onboarding explainer — shown once only |
| `isProUnlocked` | bool | Phase 3 | Pro tier status — set after verified IAP; gates scheduling, archiving, unlimited cards |

### Schema migration plan (sqflite `onUpgrade`)

| DB Version | Change | Added in |
|---|---|---|
| v1 | `cards` table baseline | Phase 1 (MVP) |
| v2 | Add `isArchived INTEGER NOT NULL DEFAULT 0` to cards; add `deferrals` table | Phase 3 (Features 3 + 5) |
| v3 | Add `schedules` table | Phase 3 (Feature 8) |

**No separate goals table.** Goal is stored as plain `goalLabel TEXT` on each card (already in the MVP schema). This avoids a FK relationship for a field that's optional, denormalized by nature, and never queried independently.

### v2 — deferrals table

| Field | Type | Notes |
|---|---|---|
| `cardId` | TEXT NOT NULL | FK → cards.id |
| `deferredAt` | INTEGER NOT NULL | millisecondsSinceEpoch |

Archiving prompt logic: if a card has 3+ rows in `deferrals` with `deferredAt` in the past 7 days, show the gentle prompt on next deck load.

### v3 — schedules table (Pro)

| Field | Type | Notes |
|---|---|---|
| `id` | TEXT PRIMARY KEY | millisecondsSinceEpoch string |
| `cardId` | TEXT NOT NULL | FK → cards.id |
| `weekdays` | TEXT NOT NULL | JSON array of ints — 0=Sun … 6=Sat |
| `timeOfDayMinutes` | INTEGER NOT NULL | Minutes since midnight |
| `isRecurring` | INTEGER NOT NULL | Default: 1 |
| `isActive` | INTEGER NOT NULL | Default: 1 |

---

## 5. Folder Structure (Target)

```
lib/
├── main.dart                  # entry point — ProviderScope, runApp
├── app.dart                   # MaterialApp, theme, router
│
├── data/
│   ├── database.dart          # sqflite open/init
│   ├── models/
│   │   └── card_model.dart
│   └── repositories/
│       └── card_repository.dart   # CRUD — isolates sqflite from UI
│
├── providers/
│   └── cards_provider.dart    # Riverpod notifier + provider
│
└── screens/
    ├── welcome/
    │   └── welcome_screen.dart
    ├── onboarding/
    │   ├── onboarding_goal_screen.dart    # Screen 1A
    │   ├── onboarding_action_screen.dart  # Screen 1B
    │   └── onboarding_confirm_screen.dart # Screen 2
    ├── timer/
    │   └── timer_screen.dart
    └── deck/
        └── deck_screen.dart
```

---

## 6. Navigation (MVP)

Navigator 1.0 (imperative) — sufficient for 6 screens, no deep linking needed in MVP.

```
Welcome → OnboardingGoal → OnboardingAction → OnboardingConfirm
                                                       ↓           ↘
                                                   TimerScreen    DeckScreen
                                                       ↓
                                                   DeckScreen
```

- `hasCompletedOnboarding == true` on launch → skip directly to `DeckScreen`
- All onboarding screens push onto the Navigator stack
- `DeckScreen` is the root after onboarding — back button does not return to onboarding
- `TimerScreen` is pushed from `DeckScreen` (and from onboarding confirm)
- **Back gesture is blocked during an active timer session** — use `PopScope(canPop: false)` while running; allow pop only when paused or completed
- **"Just One" mode is an overlay on `DeckScreen`** — not a separate route, no Navigator push

---

## 7. Hard Constraints

These are non-negotiable. Ask before deviating.

- **No network requests** — ever, in v1. No http, no dio, no firebase.
- **No user accounts** — no auth, no login, no registration.
- **No analytics or crash reporting SDKs** that send data off-device.
- **No gamification** — no streaks, points, badges, or leaderboards.
- **Screen must stay on during timer** — `WakelockPlus.enable()` in timer `initState`, `WakelockPlus.disable()` in `dispose`. Always disable on exit — never leave wakelock enabled globally.
- **Back gesture blocked during active timer** — use `PopScope(canPop: false)` while timer is running. Allow pop only when paused or completed.
- **Timer pauses on app background** — listen to `AppLifecycleState` in `TimerScreen`; pause on `AppLifecycleState.paused`, resume on `AppLifecycleState.resumed`.
- **Use `SharedPreferencesAsync`** — not the legacy `SharedPreferences.getInstance()`.
- **Store DateTime as int** — millisecondsSinceEpoch. Never store as String or native DateTime in SQLite.
- **Store bool as int** — 0 or 1. Never store as native bool in SQLite.
- **No Riverpod codegen** — use `NotifierProvider` directly. Do not add `build_runner` or use `@riverpod` annotations.
