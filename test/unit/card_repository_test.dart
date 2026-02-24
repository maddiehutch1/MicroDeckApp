import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:micro_deck/data/database.dart';
import 'package:micro_deck/data/models/card_model.dart';
import 'package:micro_deck/data/repositories/card_repository.dart';

CardModel _makeCard({
  String id = 'card-1',
  String action = 'Put on shoes',
  String? goal = 'Move more',
  int durationSeconds = 120,
  int sortOrder = 0,
  bool isArchived = false,
}) => CardModel(
  id: id,
  actionLabel: action,
  durationSeconds: durationSeconds,
  sortOrder: sortOrder,
  createdAt: DateTime.now().millisecondsSinceEpoch,
  goalLabel: goal,
  isArchived: isArchived,
);

void main() {
  late CardRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    setDatabasePathForTesting(inMemoryDatabasePath);
    repo = CardRepository();
  });

  tearDown(() async {
    await resetDatabaseForTesting();
  });

  group('CardRepository — insert & read', () {
    test('insertCard then getAllCards returns the card', () async {
      final card = _makeCard();
      await repo.insertCard(card);

      final cards = await repo.getAllCards();
      expect(cards.length, 1);
      expect(cards.first.id, card.id);
      expect(cards.first.actionLabel, card.actionLabel);
    });

    test('getAllCards excludes archived cards', () async {
      await repo.insertCard(_makeCard(id: 'a'));
      await repo.insertCard(_makeCard(id: 'b', isArchived: true));

      final cards = await repo.getAllCards();
      expect(cards.length, 1);
      expect(cards.first.id, 'a');
    });

    test('getAllCards returns cards ordered by sortOrder', () async {
      await repo.insertCard(_makeCard(id: 'c', sortOrder: 2));
      await repo.insertCard(_makeCard(id: 'a', sortOrder: 0));
      await repo.insertCard(_makeCard(id: 'b', sortOrder: 1));

      final cards = await repo.getAllCards();
      expect(cards.map((c) => c.id).toList(), ['a', 'b', 'c']);
    });

    test('getAllCards returns empty list when no cards exist', () async {
      final cards = await repo.getAllCards();
      expect(cards, isEmpty);
    });
  });

  group('CardRepository — delete', () {
    test('deleteCard removes the card from the deck', () async {
      final card = _makeCard();
      await repo.insertCard(card);
      await repo.deleteCard(card.id);

      final cards = await repo.getAllCards();
      expect(cards, isEmpty);
    });

    test('deleteCard on non-existent id does not throw', () async {
      await expectLater(repo.deleteCard('ghost-id'), completes);
    });
  });

  group('CardRepository — archive & restore', () {
    test('archiveCard hides card from getAllCards', () async {
      final card = _makeCard();
      await repo.insertCard(card);
      await repo.archiveCard(card.id);

      final active = await repo.getAllCards();
      expect(active, isEmpty);

      final archived = await repo.getAllArchivedCards();
      expect(archived.length, 1);
      expect(archived.first.id, card.id);
    });

    test('restoreCard returns card to active deck', () async {
      final card = _makeCard();
      await repo.insertCard(card);
      await repo.archiveCard(card.id);
      await repo.restoreCard(card.id);

      final active = await repo.getAllCards();
      expect(active.length, 1);
      expect(active.first.isArchived, false);
    });

    test('restoreCard appends card at end of sort order', () async {
      await repo.insertCard(_makeCard(id: 'first', sortOrder: 0));
      await repo.insertCard(_makeCard(id: 'second', sortOrder: 1));
      await repo.insertCard(_makeCard(id: 'torestore', sortOrder: 2));

      await repo.archiveCard('torestore');
      await repo.restoreCard('torestore');

      final cards = await repo.getAllCards();
      expect(cards.last.id, 'torestore');
    });
  });

  group('CardRepository — defer', () {
    test('deferCard moves card to end of sort order', () async {
      await repo.insertCard(_makeCard(id: 'a', sortOrder: 0));
      await repo.insertCard(_makeCard(id: 'b', sortOrder: 1));

      await repo.deferCard('a');

      final cards = await repo.getAllCards();
      expect(cards.first.id, 'b');
      expect(cards.last.id, 'a');
    });

    test('deferCard records a deferral entry', () async {
      final card = _makeCard();
      await repo.insertCard(card);
      await repo.deferCard(card.id);

      final count = await repo.getDeferralCount(
        card.id,
        7 * 24 * 60 * 60 * 1000,
      );
      expect(count, 1);
    });

    test('getDeferralCount returns 0 with no deferrals', () async {
      final card = _makeCard();
      await repo.insertCard(card);

      final count = await repo.getDeferralCount(card.id, 1000);
      expect(count, 0);
    });

    test('multiple deferrals accumulate correctly', () async {
      final card = _makeCard();
      await repo.insertCard(card);
      await repo.deferCard(card.id);
      await repo.deferCard(card.id);
      await repo.deferCard(card.id);

      final count = await repo.getDeferralCount(
        card.id,
        7 * 24 * 60 * 60 * 1000,
      );
      expect(count, 3);
    });
  });

  group('CardRepository — archive prompt', () {
    test(
      'getCardsNeedingArchivePrompt returns cards deferred 3+ times in 7 days',
      () async {
        final card = _makeCard();
        await repo.insertCard(card);

        await repo.deferCard(card.id);
        await repo.deferCard(card.id);
        await repo.deferCard(card.id);

        final candidates = await repo.getCardsNeedingArchivePrompt();
        expect(candidates.length, 1);
        expect(candidates.first.id, card.id);
      },
    );

    test(
      'getCardsNeedingArchivePrompt ignores cards deferred fewer than 3 times',
      () async {
        final card = _makeCard();
        await repo.insertCard(card);
        await repo.deferCard(card.id);
        await repo.deferCard(card.id);

        final candidates = await repo.getCardsNeedingArchivePrompt();
        expect(candidates, isEmpty);
      },
    );

    test(
      'getCardsNeedingArchivePrompt excludes already-archived cards',
      () async {
        final card = _makeCard();
        await repo.insertCard(card);
        await repo.deferCard(card.id);
        await repo.deferCard(card.id);
        await repo.deferCard(card.id);
        await repo.archiveCard(card.id);

        final candidates = await repo.getCardsNeedingArchivePrompt();
        expect(candidates, isEmpty);
      },
    );
  });

  group('CardRepository — active count', () {
    test('getActiveCardCount returns 0 when no cards exist', () async {
      expect(await repo.getActiveCardCount(), 0);
    });

    test('getActiveCardCount returns number of non-archived cards', () async {
      await repo.insertCard(_makeCard(id: 'a'));
      await repo.insertCard(_makeCard(id: 'b'));
      await repo.insertCard(_makeCard(id: 'c', isArchived: true));

      expect(await repo.getActiveCardCount(), 2);
    });
  });
}
