import 'package:flutter_test/flutter_test.dart';
import 'package:micro_deck/data/models/card_model.dart';

void main() {
  group('CardModel', () {
    const card = CardModel(
      id: 'test-id-1',
      actionLabel: 'Put on running shoes',
      durationSeconds: 120,
      sortOrder: 0,
      createdAt: 1000000,
      goalLabel: 'Move more',
      isArchived: false,
    );

    test('toMap serialises all fields correctly', () {
      final map = card.toMap();
      expect(map['id'], 'test-id-1');
      expect(map['actionLabel'], 'Put on running shoes');
      expect(map['goalLabel'], 'Move more');
      expect(map['durationSeconds'], 120);
      expect(map['sortOrder'], 0);
      expect(map['createdAt'], 1000000);
      expect(map['isArchived'], 0); // bool → int
    });

    test('toMap encodes isArchived=true as 1', () {
      const archived = CardModel(
        id: 'x',
        actionLabel: 'test',
        durationSeconds: 60,
        sortOrder: 0,
        createdAt: 0,
        isArchived: true,
      );
      expect(archived.toMap()['isArchived'], 1);
    });

    test('fromMap round-trips correctly', () {
      final restored = CardModel.fromMap(card.toMap());
      expect(restored.id, card.id);
      expect(restored.actionLabel, card.actionLabel);
      expect(restored.goalLabel, card.goalLabel);
      expect(restored.durationSeconds, card.durationSeconds);
      expect(restored.sortOrder, card.sortOrder);
      expect(restored.createdAt, card.createdAt);
      expect(restored.isArchived, card.isArchived);
    });

    test('fromMap handles null goalLabel', () {
      final map = card.toMap()..['goalLabel'] = null;
      final restored = CardModel.fromMap(map);
      expect(restored.goalLabel, isNull);
    });

    test(
      'fromMap handles missing isArchived (legacy rows default to false)',
      () {
        final map = card.toMap()..remove('isArchived');
        final restored = CardModel.fromMap(map);
        expect(restored.isArchived, false);
      },
    );

    test('durationLabel returns minutes as string', () {
      expect(card.durationLabel, '2 min');
    });

    test('durationLabel rounds down for non-exact minutes', () {
      const c = CardModel(
        id: 'x',
        actionLabel: 'test',
        durationSeconds: 90,
        sortOrder: 0,
        createdAt: 0,
      );
      expect(c.durationLabel, '1 min');
    });

    test('durationLabel handles 10 minutes', () {
      const c = CardModel(
        id: 'x',
        actionLabel: 'test',
        durationSeconds: 600,
        sortOrder: 0,
        createdAt: 0,
      );
      expect(c.durationLabel, '10 min');
    });
  });
}
