import 'package:flutter_test/flutter_test.dart';
import 'package:micro_deck/data/templates.dart';

void main() {
  group('starterTemplates', () {
    test('contains exactly 20 templates', () {
      expect(starterTemplates.length, 20);
    });

    test('every template has a non-empty actionLabel', () {
      for (final t in starterTemplates) {
        expect(
          t.actionLabel.trim(),
          isNotEmpty,
          reason: 'Template in area "${t.area}" has an empty actionLabel',
        );
      }
    });

    test('every template has a non-empty goalLabel', () {
      for (final t in starterTemplates) {
        expect(
          t.goalLabel.trim(),
          isNotEmpty,
          reason: 'Template "${t.actionLabel}" has an empty goalLabel',
        );
      }
    });

    test('every template has a non-empty area', () {
      for (final t in starterTemplates) {
        expect(t.area.trim(), isNotEmpty);
      }
    });

    test('all template areas are from the known set', () {
      const knownAreas = {'Movement', 'Focus', 'Connection', 'Rest'};
      for (final t in starterTemplates) {
        expect(
          knownAreas,
          contains(t.area),
          reason: '"${t.area}" is not a recognised template area',
        );
      }
    });

    test('each area has at least one template', () {
      for (final area in templateAreas) {
        final count = starterTemplates.where((t) => t.area == area).length;
        expect(count, greaterThan(0), reason: 'Area "$area" has no templates');
      }
    });

    test('templateAreas contains exactly 4 areas', () {
      expect(templateAreas.length, 4);
      expect(
        templateAreas,
        containsAll(['Movement', 'Focus', 'Connection', 'Rest']),
      );
    });

    test('no two templates share the same actionLabel', () {
      final labels = starterTemplates.map((t) => t.actionLabel).toList();
      final unique = labels.toSet();
      expect(
        unique.length,
        labels.length,
        reason: 'Duplicate actionLabels found',
      );
    });
  });
}
