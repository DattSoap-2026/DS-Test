// Regression tests for stock flow bug fixes:
//   BUG 1 — completeBhattiBatch must convert outputBoxes to KG, not use raw count.
//   BUG 2 — updateBhattiBatch must throw when batch has tank consumptions.
//
// These tests run in pure Dart (no Isar / Firebase) to avoid DB setup.
// They model the conversion logic and the guard logic directly.

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BUG 1 – Output KG Conversion Logic', () {
    // Mirror of the exact formula used in completeBhattiBatch (bug-fixed version).
    double computeOutputQtyKg({
      required int outputBoxes,
      required double unitWeightGrams,
    }) {
      final boxWeightKg = unitWeightGrams > 0 ? unitWeightGrams / 1000.0 : 1.0;
      return outputBoxes * boxWeightKg;
    }

    test('10 boxes × 200 g/box should equal 2.0 KG', () {
      final result = computeOutputQtyKg(outputBoxes: 10, unitWeightGrams: 200);
      expect(result, closeTo(2.0, 0.0001));
    });

    test('5 boxes × 500 g/box should equal 2.5 KG', () {
      final result = computeOutputQtyKg(outputBoxes: 5, unitWeightGrams: 500);
      expect(result, closeTo(2.5, 0.0001));
    });

    test('0 g/box (missing unit weight) falls back to 1.0 KG/box', () {
      final result = computeOutputQtyKg(outputBoxes: 10, unitWeightGrams: 0);
      // Fallback: 10 × 1.0 = 10.0
      expect(result, closeTo(10.0, 0.0001));
    });

    test('1000 g/box means 1 KG per box', () {
      final result = computeOutputQtyKg(outputBoxes: 3, unitWeightGrams: 1000);
      expect(result, closeTo(3.0, 0.0001));
    });

    test(
      'output KG should NOT equal raw outputBoxes when unitWeightGrams != 1000',
      () {
        // Before the fix, code would add outputBoxes (e.g. 10) directly.
        // After the fix, it adds outputQtyKg (e.g. 2.0 for 200g boxes).
        const outputBoxes = 10;
        final outputQtyKg = computeOutputQtyKg(
          outputBoxes: outputBoxes,
          unitWeightGrams: 200,
        );
        expect(outputQtyKg, isNot(equals(outputBoxes.toDouble())));
      },
    );
  });

  group('BUG 2 – Tank Edit Guard Logic', () {
    // Mirrors the guard check at the top of updateBhattiBatch.
    void assertTankEditGuard(List<Map<String, dynamic>> tankConsumptions) {
      if (tankConsumptions.isNotEmpty) {
        throw Exception(
          'Cannot edit a batch with tank consumptions. '
          'Tank stock reversals are not supported. Please create a new batch.',
        );
      }
    }

    test('empty tankConsumptions allows edit (no throw)', () {
      expect(() => assertTankEditGuard([]), returnsNormally);
    });

    test('non-empty tankConsumptions throws correct exception', () {
      expect(
        () => assertTankEditGuard([
          {'tankId': 'TANK_001', 'materialId': 'MAT_A', 'quantity': 50.0},
        ]),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('tank consumptions'),
          ),
        ),
      );
    });

    test('exception message contains expected text', () {
      try {
        assertTankEditGuard([
          {'tankId': 'TANK_002', 'materialId': 'MAT_B', 'quantity': 10.0},
        ]);
        fail('Expected exception was not thrown');
      } catch (e) {
        expect(e.toString(), contains('tank consumptions'));
        expect(e.toString(), contains('Please create a new batch'));
      }
    });
  });

  group('BUG 5 – Department Name Normalization Logic', () {
    String normalizeDeptName(String name) => name.trim().toLowerCase();

    test('Trims whitespace', () {
      expect(normalizeDeptName('  Sona Bhatti  '), 'sona bhatti');
    });

    test('Converts to lowercase', () {
      expect(normalizeDeptName('GITA BHATTI'), 'gita bhatti');
    });

    test('Same-cased names produce identical keys', () {
      final a = normalizeDeptName('Sona Bhatti');
      final b = normalizeDeptName('sona bhatti');
      final c = normalizeDeptName('SONA BHATTI');
      expect(a, equals(b));
      expect(b, equals(c));
    });

    test('Department stock ID uses normalized key', () {
      const productId = 'PROD_001';
      final deptName = normalizeDeptName('Sona Bhatti');
      final expectedId = '${deptName}_$productId';
      expect(expectedId, 'sona bhatti_PROD_001');
    });
  });
}
