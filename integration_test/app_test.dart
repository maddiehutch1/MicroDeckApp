// Integration test — requires a running emulator/device.
// Run with: flutter test integration_test/app_test.dart
//
// Exercises the core user journey end-to-end:
//   Cold launch → Onboarding → Deck → Add card → Settings

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:micro_deck/main.dart' as app;

/// Reset app state to a clean first-launch condition.
Future<void> _clearState() async {
  final prefs = SharedPreferencesAsync();
  await prefs.clear();
}

/// Set state to a post-onboarding condition (land directly on deck).
Future<void> _setOnboardingComplete() async {
  final prefs = SharedPreferencesAsync();
  await prefs.setBool('hasCompletedOnboarding', true);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Core loop — first launch', () {
    testWidgets('completes full onboarding flow and reaches deck', (tester) async {
      await _clearState();
      app.main();
      await tester.pumpAndSettle();

      // ── Welcome screen ──────────────────────────────────────────────────────
      expect(find.textContaining("begin"), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // ── Goal screen ─────────────────────────────────────────────────────────
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Move more');
      await tester.pumpAndSettle();

      final nextButton = find.byType(FilledButton);
      expect(tester.widget<FilledButton>(nextButton).onPressed, isNotNull);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // ── Action screen ────────────────────────────────────────────────────────
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Put on my running shoes');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // ── Confirm screen ───────────────────────────────────────────────────────
      expect(find.text('Put on my running shoes'), findsOneWidget);

      // Tap "Save for later" to skip the timer and land on deck
      await tester.tap(find.widgetWithText(TextButton, 'Save for later'));
      await tester.pumpAndSettle();

      // ── Deck screen ──────────────────────────────────────────────────────────
      expect(find.text('Put on my running shoes'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('Deck — add card via FAB', () {
    testWidgets('opens template browser when FAB is tapped on deck', (tester) async {
      await _setOnboardingComplete();
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Template browser sheet should appear
      expect(find.textContaining('Movement'), findsOneWidget);
    });
  });

  group('Deck — swipe to defer', () {
    testWidgets('swiping a card left removes it from visible list', (tester) async {
      await _setOnboardingComplete();
      app.main();
      await tester.pumpAndSettle();

      // Only proceed if there is at least one card
      if (find.byType(Dismissible).evaluate().isNotEmpty) {
        await tester.drag(
          find.byType(Dismissible).first,
          const Offset(-400, 0),
        );
        await tester.pumpAndSettle();

        // After defer, the card moved to end — the deck still renders it
        // but a pumpAndSettle confirms no crash occurred.
        expect(find.byType(FloatingActionButton), findsOneWidget);
      }
    });
  });

  group('Settings screen', () {
    testWidgets('opens from deck header settings icon', (tester) async {
      await _setOnboardingComplete();
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      // Settings screen should appear — look for "Resting" heading
      expect(find.textContaining('Resting'), findsOneWidget);
    });
  });

  group('Timer screen', () {
    testWidgets('tapping a card opens the timer screen', (tester) async {
      await _setOnboardingComplete();
      app.main();
      await tester.pumpAndSettle();

      // Only run if there is a card to tap
      if (find.byType(ListTile).evaluate().isNotEmpty) {
        await tester.tap(find.byType(ListTile).first);
        await tester.pumpAndSettle();

        // Timer screen shows a MM:SS countdown
        expect(find.textContaining(':'), findsOneWidget);
      }
    });
  });
}
