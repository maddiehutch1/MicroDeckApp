import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:micro_deck/data/models/schedule_model.dart';

void main() {
  group('ScheduleModel', () {
    const schedule = ScheduleModel(
      id: 'sched-1',
      cardId: 'card-1',
      weekdays: [1, 3, 5], // Mon, Wed, Fri
      timeOfDayMinutes: 480, // 8:00 AM
      isRecurring: true,
      isActive: true,
    );

    test('toMap serialises all fields correctly', () {
      final map = schedule.toMap();
      expect(map['id'], 'sched-1');
      expect(map['cardId'], 'card-1');
      expect(jsonDecode(map['weekdays'] as String), [1, 3, 5]);
      expect(map['timeOfDayMinutes'], 480);
      expect(map['isRecurring'], 1);
      expect(map['isActive'], 1);
    });

    test('toMap encodes weekdays as JSON string', () {
      final map = schedule.toMap();
      expect(map['weekdays'], isA<String>());
      expect(jsonDecode(map['weekdays'] as String), isA<List>());
    });

    test('fromMap round-trips correctly', () {
      final restored = ScheduleModel.fromMap(schedule.toMap());
      expect(restored.id, schedule.id);
      expect(restored.cardId, schedule.cardId);
      expect(restored.weekdays, [1, 3, 5]);
      expect(restored.timeOfDayMinutes, 480);
      expect(restored.isRecurring, true);
      expect(restored.isActive, true);
    });

    test('fromMap decodes isRecurring=0 as false', () {
      final map = schedule.toMap()..['isRecurring'] = 0;
      expect(ScheduleModel.fromMap(map).isRecurring, false);
    });

    test('fromMap decodes isActive=0 as false', () {
      final map = schedule.toMap()..['isActive'] = 0;
      expect(ScheduleModel.fromMap(map).isActive, false);
    });

    test('hour getter returns correct hour from timeOfDayMinutes', () {
      expect(schedule.hour, 8); // 480 / 60 = 8
    });

    test('minute getter returns correct minute from timeOfDayMinutes', () {
      expect(schedule.minute, 0); // 480 % 60 = 0
    });

    test('hour and minute work for non-round times', () {
      const s = ScheduleModel(
        id: 'x',
        cardId: 'c',
        weekdays: [0],
        timeOfDayMinutes: 545, // 9:05 AM
      );
      expect(s.hour, 9);
      expect(s.minute, 5);
    });

    test('empty weekdays list serialises and restores', () {
      const s = ScheduleModel(
        id: 'x',
        cardId: 'c',
        weekdays: [],
        timeOfDayMinutes: 0,
      );
      final restored = ScheduleModel.fromMap(s.toMap());
      expect(restored.weekdays, isEmpty);
    });
  });
}
