import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/utils/unit_converter.dart';

void main() {
  group('UnitConverter — toBaseUnit', () {
    test('converts boxes to pcs', () {
      expect(UnitConverter.toBaseUnit(5, 12), 60);
    });

    test('handles fractional boxes', () {
      expect(UnitConverter.toBaseUnit(2.5, 12), 30);
    });

    test('returns input unchanged when factor <= 0', () {
      expect(UnitConverter.toBaseUnit(5, 0), 5);
      expect(UnitConverter.toBaseUnit(5, -1), 5);
    });
  });

  group('UnitConverter — toSecondaryUnit', () {
    test('converts pcs to boxes', () {
      expect(UnitConverter.toSecondaryUnit(60, 12), 5);
    });

    test('handles non-exact division', () {
      expect(UnitConverter.toSecondaryUnit(74, 12), closeTo(6.1667, 0.001));
    });

    test('returns input unchanged when factor <= 0', () {
      expect(UnitConverter.toSecondaryUnit(5, 0), 5);
      expect(UnitConverter.toSecondaryUnit(5, -1), 5);
    });
  });

  group('UnitConverter — fullSecondaryUnits', () {
    test('floors correctly for whole quantities', () {
      expect(UnitConverter.fullSecondaryUnits(72, 12), 6);
    });

    test('floors correctly for fractional quantities', () {
      expect(UnitConverter.fullSecondaryUnits(74, 12), 6);
      expect(UnitConverter.fullSecondaryUnits(74.5, 12), 6);
    });

    test('returns 0 for less than one full unit', () {
      expect(UnitConverter.fullSecondaryUnits(5, 12), 0);
    });

    test('returns 0 when factor <= 1', () {
      expect(UnitConverter.fullSecondaryUnits(100, 1), 0);
      expect(UnitConverter.fullSecondaryUnits(100, 0.5), 0);
    });

    test('handles zero quantity', () {
      expect(UnitConverter.fullSecondaryUnits(0, 12), 0);
    });
  });

  group('UnitConverter — remainingBaseUnits (int, backward-compat)', () {
    test('returns truncated integer remainder', () {
      expect(UnitConverter.remainingBaseUnits(74, 12), 2);
    });

    test('truncates fractional remainder to int', () {
      // 74.5 % 12 = 2.5 → truncated to 2
      expect(UnitConverter.remainingBaseUnits(74.5, 12), 2);
    });

    test('returns 0 for exact division', () {
      expect(UnitConverter.remainingBaseUnits(72, 12), 0);
    });

    test('returns baseQty as int when factor <= 1', () {
      expect(UnitConverter.remainingBaseUnits(5, 1), 5);
      expect(UnitConverter.remainingBaseUnits(5.7, 0.5), 5);
    });
  });

  group('UnitConverter — remainingBaseUnitsExact (double)', () {
    test('returns exact fractional remainder for 74.5 Pcs / 12', () {
      expect(
        UnitConverter.remainingBaseUnitsExact(74.5, 12),
        closeTo(2.5, 0.001),
      );
    });

    test('returns 0.0 for exact division', () {
      expect(UnitConverter.remainingBaseUnitsExact(72, 12), closeTo(0, 0.001));
    });

    test('returns exact remainder for whole numbers', () {
      expect(UnitConverter.remainingBaseUnitsExact(74, 12), closeTo(2, 0.001));
    });

    test('returns baseQty unchanged when factor <= 1', () {
      expect(UnitConverter.remainingBaseUnitsExact(5.5, 1), 5.5);
      expect(UnitConverter.remainingBaseUnitsExact(5.5, 0), 5.5);
    });

    test('handles zero quantity', () {
      expect(UnitConverter.remainingBaseUnitsExact(0, 12), closeTo(0, 0.001));
    });
  });

  group('UnitConverter — formatDual', () {
    test('shows "6 Box + 2 Pcs" for 74 Pcs', () {
      final result = UnitConverter.formatDual(
        baseQty: 74,
        baseUnit: 'Pcs',
        secondaryUnit: 'Box',
        conversionFactor: 12,
      );
      expect(result, '6 Box + 2 Pcs');
    });

    test('shows "6 Box + 2.5 Pcs" for 74.5 Pcs (fractional fix)', () {
      final result = UnitConverter.formatDual(
        baseQty: 74.5,
        baseUnit: 'Pcs',
        secondaryUnit: 'Box',
        conversionFactor: 12,
      );
      expect(result, '6 Box + 2.5 Pcs');
    });

    test('shows "6 Box" for exact 72 Pcs', () {
      final result = UnitConverter.formatDual(
        baseQty: 72,
        baseUnit: 'Pcs',
        secondaryUnit: 'Box',
        conversionFactor: 12,
      );
      expect(result, '6 Box');
    });

    test('shows "6 Box + 0 Pcs" with showZeroLoose for exact 72', () {
      final result = UnitConverter.formatDual(
        baseQty: 72,
        baseUnit: 'Pcs',
        secondaryUnit: 'Box',
        conversionFactor: 12,
        showZeroLoose: true,
      );
      expect(result, '6 Box + 0 Pcs');
    });

    test('shows only loose when no full boxes', () {
      final result = UnitConverter.formatDual(
        baseQty: 5,
        baseUnit: 'Pcs',
        secondaryUnit: 'Box',
        conversionFactor: 12,
      );
      expect(result, '5 Pcs');
    });

    test('shows plain format when no secondary unit', () {
      final result = UnitConverter.formatDual(baseQty: 60, baseUnit: 'Pcs');
      expect(result, '60 Pcs');
    });

    test('shows plain format when conversionFactor is 1', () {
      final result = UnitConverter.formatDual(
        baseQty: 60,
        baseUnit: 'Pcs',
        secondaryUnit: 'Box',
        conversionFactor: 1,
      );
      expect(result, '60 Pcs');
    });

    test('handles zero quantity', () {
      final result = UnitConverter.formatDual(
        baseQty: 0,
        baseUnit: 'Pcs',
        secondaryUnit: 'Box',
        conversionFactor: 12,
      );
      expect(result, '0 Pcs');
    });
  });

  group('UnitConverter — formatCompact', () {
    test('shows multi-line for boxes + loose', () {
      final result = UnitConverter.formatCompact(
        baseQty: 74,
        baseUnit: 'Pcs',
        secondaryUnit: 'Box',
        conversionFactor: 12,
      );
      expect(result, '6 Box\n+ 2 Pcs');
    });

    test('shows fractional loose in compact format', () {
      final result = UnitConverter.formatCompact(
        baseQty: 74.5,
        baseUnit: 'Pcs',
        secondaryUnit: 'Box',
        conversionFactor: 12,
      );
      expect(result, '6 Box\n+ 2.5 Pcs');
    });

    test('shows only boxes when exact division', () {
      final result = UnitConverter.formatCompact(
        baseQty: 72,
        baseUnit: 'Pcs',
        secondaryUnit: 'Box',
        conversionFactor: 12,
      );
      expect(result, '6 Box');
    });
  });

  group('UnitConverter — hasSecondaryUnit', () {
    test('returns true for valid secondary unit and factor > 1', () {
      expect(UnitConverter.hasSecondaryUnit('Box', 12), true);
    });

    test('returns false when secondaryUnit is null', () {
      expect(UnitConverter.hasSecondaryUnit(null, 12), false);
    });

    test('returns false when secondaryUnit is empty', () {
      expect(UnitConverter.hasSecondaryUnit('', 12), false);
    });

    test('returns false when conversionFactor is 1', () {
      expect(UnitConverter.hasSecondaryUnit('Box', 1), false);
    });

    test('returns false when conversionFactor < 1', () {
      expect(UnitConverter.hasSecondaryUnit('Box', 0.5), false);
    });
  });

  group('UnitConverter — validateConversionFactor', () {
    test('returns null when no secondary unit set', () {
      expect(
        UnitConverter.validateConversionFactor('5', secondaryUnitSet: false),
        null,
      );
    });

    test('returns error for invalid number', () {
      expect(
        UnitConverter.validateConversionFactor('abc', secondaryUnitSet: true),
        'Enter a valid number',
      );
    });

    test('returns error for value <= 1', () {
      expect(
        UnitConverter.validateConversionFactor('1', secondaryUnitSet: true),
        'Must be > 1 (e.g. 12 Pcs per Box)',
      );
      expect(
        UnitConverter.validateConversionFactor('0', secondaryUnitSet: true),
        'Must be > 1 (e.g. 12 Pcs per Box)',
      );
    });

    test('returns null for valid factor', () {
      expect(
        UnitConverter.validateConversionFactor('12', secondaryUnitSet: true),
        null,
      );
    });
  });
}
