import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:micro_deck/data/models/card_model.dart';
import 'package:micro_deck/screens/timer/timer_screen.dart';

const _testCard = CardModel(
  id: 'timer-test-card',
  actionLabel: 'Put on running shoes',
  goalLabel: 'Move more',
  durationSeconds: 120,
  sortOrder: 0,
  createdAt: 1000000,
);

Widget _wrap(CardModel card) => ProviderScope(
  child: MaterialApp(home: TimerScreen(card: card)),
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TimerScreen', () {
    testWidgets('displays initial countdown in MM:SS format', (tester) async {
      await tester.pumpWidget(_wrap(_testCard));
      await tester.pump();
      // 120 seconds = 02:00 (zero-padded minutes and seconds)
      expect(find.text('02:00'), findsOneWidget);
    });

    testWidgets('displays action label from card', (tester) async {
      await tester.pumpWidget(_wrap(_testCard));
      await tester.pump();
      expect(find.text('Put on running shoes'), findsOneWidget);
    });

    testWidgets('countdown is labelled for accessibility', (tester) async {
      // Timer.periodic does not advance with tester.pump in widget tests —
      // verify via the Semantics wrapper instead.
      await tester.pumpWidget(_wrap(_testCard));
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp(r'Time remaining:')), findsOneWidget);
    });

    testWidgets('short card (1 min) shows correct initial time', (
      tester,
    ) async {
      const shortCard = CardModel(
        id: 'short',
        actionLabel: 'Quick action',
        durationSeconds: 60,
        sortOrder: 0,
        createdAt: 0,
      );
      await tester.pumpWidget(_wrap(shortCard));
      await tester.pump();
      expect(find.text('01:00'), findsOneWidget);
    });
  });
}
