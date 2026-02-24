import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_deck/data/models/card_model.dart';
import 'package:micro_deck/providers/cards_provider.dart';
import 'package:micro_deck/screens/deck/deck_screen.dart';

// ── Fake notifier — returns pre-loaded cards without touching the database ──

class FakeCardsNotifier extends CardsNotifier {
  final List<CardModel> _initial;
  FakeCardsNotifier(this._initial);

  @override
  List<CardModel> build() => _initial;

  @override
  Future<void> loadCards() async => state = _initial;
}

Widget _wrapWith(List<CardModel> cards) => ProviderScope(
  overrides: [cardsProvider.overrideWith(() => FakeCardsNotifier(cards))],
  child: const MaterialApp(home: DeckScreen()),
);

CardModel _card({
  String id = 'card-1',
  String action = 'Put on running shoes',
  String goal = 'Move more',
  int sortOrder = 0,
}) => CardModel(
  id: id,
  actionLabel: action,
  goalLabel: goal,
  durationSeconds: 120,
  sortOrder: sortOrder,
  createdAt: 1000000,
);

void main() {
  group('DeckScreen — empty state', () {
    testWidgets('shows empty-state message when deck is empty', (tester) async {
      await tester.pumpWidget(_wrapWith([]));
      await tester.pump();
      expect(find.textContaining('Add your first card'), findsOneWidget);
    });

    testWidgets('FAB is present when deck is empty', (tester) async {
      await tester.pumpWidget(_wrapWith([]));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('DeckScreen — card list', () {
    testWidgets('shows card action label', (tester) async {
      await tester.pumpWidget(_wrapWith([_card()]));
      await tester.pump();
      expect(find.text('Put on running shoes'), findsOneWidget);
    });

    testWidgets('shows card goal label as sub-text', (tester) async {
      await tester.pumpWidget(_wrapWith([_card()]));
      await tester.pump();
      expect(find.text('Move more'), findsOneWidget);
    });

    testWidgets('shows duration badge', (tester) async {
      await tester.pumpWidget(_wrapWith([_card()]));
      await tester.pump();
      expect(find.text('2 min'), findsOneWidget);
    });

    testWidgets('shows multiple cards', (tester) async {
      final cards = [
        _card(id: 'a', action: 'Do push-ups', sortOrder: 0),
        _card(id: 'b', action: 'Fill water bottle', sortOrder: 1),
      ];
      await tester.pumpWidget(_wrapWith(cards));
      await tester.pump();
      expect(find.text('Do push-ups'), findsOneWidget);
      expect(find.text('Fill water bottle'), findsOneWidget);
    });

    testWidgets('FAB is present when cards exist', (tester) async {
      await tester.pumpWidget(_wrapWith([_card()]));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('DeckScreen — settings icon', () {
    testWidgets('settings icon button is present in header', (tester) async {
      await tester.pumpWidget(_wrapWith([]));
      await tester.pump();
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });
  });

  group('DeckScreen — Just One mode', () {
    testWidgets('Just One mode button is present in header', (tester) async {
      await tester.pumpWidget(_wrapWith([_card()]));
      await tester.pump();
      expect(find.byIcon(Icons.filter_1_outlined), findsOneWidget);
    });
  });
}
