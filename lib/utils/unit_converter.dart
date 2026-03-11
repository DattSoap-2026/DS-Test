// LOCKED — Central unit conversion utility for DattSoap ERP.
//
// RULE: Stock is ALWAYS stored in base units (Pcs/Bottle).
// Display in secondary units (Box) happens only in the UI layer.
// ALL conversion logic MUST pass through this class. Never inline math.
//
// Business rule: 1 Box = N Pcs (conversionFactor = N, e.g. 12)

class UnitConverter {
  UnitConverter._(); // prevent instantiation

  // ─────────────────────────────────────────────────────────────
  // CORE MATH
  // ─────────────────────────────────────────────────────────────

  /// Convert secondary-unit qty (Boxes) → base-unit qty (Pcs).
  /// e.g. 5 Boxes × 12 = 60 Pcs
  ///
  /// RESERVED: This method is the designated entry point for any future UI
  /// feature that allows users to input quantities in secondary units (e.g., "5 Boxes").
  /// Until such a UI exists, quantity is always entered in base units and this
  /// method is intentionally unused. Do not remove.
  static double toBaseUnit(double secondaryQty, double conversionFactor) {
    if (conversionFactor <= 0) return secondaryQty;
    return secondaryQty * conversionFactor;
  }

  /// Convert base-unit qty (Pcs) → secondary-unit qty (Boxes).
  /// e.g. 60 Pcs ÷ 12 = 5 Boxes
  static double toSecondaryUnit(double baseQty, double conversionFactor) {
    if (conversionFactor <= 0) return baseQty;
    return baseQty / conversionFactor;
  }

  /// How many complete secondary units (Boxes) are in [baseQty].
  /// e.g. 74 Pcs → 6 Boxes (6 × 12 = 72)
  static int fullSecondaryUnits(double baseQty, double conversionFactor) {
    if (conversionFactor <= 1) return 0;
    return (baseQty / conversionFactor).floor();
  }

  /// Remainder pcs after filling complete secondary units (truncated to int).
  /// e.g. 74.5 Pcs → 2 Pcs loose (truncated from 2.5)
  /// NOTE: This truncates fractional remainders. For accurate display, use
  /// [remainingBaseUnitsExact] instead.
  static int remainingBaseUnits(double baseQty, double conversionFactor) {
    if (conversionFactor <= 1) return baseQty.toInt();
    return (baseQty % conversionFactor).toInt();
  }

  /// Remainder pcs after filling complete secondary units (exact double).
  /// e.g. 74.5 Pcs → 2.5 Pcs loose (74.5 - 72)
  /// Preferred for display formatting to avoid losing fractional quantities.
  static double remainingBaseUnitsExact(
    double baseQty,
    double conversionFactor,
  ) {
    if (conversionFactor <= 1) return baseQty;
    return baseQty % conversionFactor;
  }

  // ─────────────────────────────────────────────────────────────
  // DISPLAY FORMATTING
  // ─────────────────────────────────────────────────────────────

  /// UI display: "6 Box + 2 Pcs" or "60 Pcs" or just "60"
  static String formatDual({
    required double baseQty,
    required String baseUnit,
    String? secondaryUnit,
    double conversionFactor = 1,
    bool showZeroLoose = false,
  }) {
    final hasSecondary =
        secondaryUnit != null &&
        secondaryUnit.isNotEmpty &&
        conversionFactor > 1;

    if (!hasSecondary) {
      return '${_formatQty(baseQty)} $baseUnit';
    }

    final boxes = fullSecondaryUnits(baseQty, conversionFactor);
    final loose = remainingBaseUnitsExact(baseQty, conversionFactor);
    final looseStr = _formatQty(loose);

    if (boxes > 0 && loose > 0.001) {
      return '$boxes $secondaryUnit + $looseStr $baseUnit';
    } else if (boxes > 0) {
      return showZeroLoose
          ? '$boxes $secondaryUnit + 0 $baseUnit'
          : '$boxes $secondaryUnit';
    } else {
      return '$looseStr $baseUnit';
    }
  }

  /// Compact display for table cells: "6 Box\n2 Pcs" or just "60 Pcs"
  static String formatCompact({
    required double baseQty,
    required String baseUnit,
    String? secondaryUnit,
    double conversionFactor = 1,
  }) {
    final hasSecondary =
        secondaryUnit != null &&
        secondaryUnit.isNotEmpty &&
        conversionFactor > 1;

    if (!hasSecondary) {
      return '${_formatQty(baseQty)} $baseUnit';
    }

    final boxes = fullSecondaryUnits(baseQty, conversionFactor);
    final loose = remainingBaseUnitsExact(baseQty, conversionFactor);
    final looseStr = _formatQty(loose);

    if (boxes > 0 && loose > 0.001) {
      return '$boxes $secondaryUnit\n+ $looseStr $baseUnit';
    } else if (boxes > 0) {
      return '$boxes $secondaryUnit';
    } else {
      return '$looseStr $baseUnit';
    }
  }

  // ─────────────────────────────────────────────────────────────
  // VALIDATION
  // ─────────────────────────────────────────────────────────────

  /// Returns true when the conversion factor is valid for use.
  /// A factor of 1 means "single-unit product" — Box mode not applicable.
  static bool hasSecondaryUnit(String? secondaryUnit, double conversionFactor) {
    return secondaryUnit != null &&
        secondaryUnit.isNotEmpty &&
        conversionFactor > 1;
  }

  /// Validates a conversion factor string from UI input.
  /// Returns error message or null if valid.
  static String? validateConversionFactor(
    String? value, {
    bool secondaryUnitSet = false,
  }) {
    if (!secondaryUnitSet) return null; // Not required if no secondary unit
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 1) {
      return 'Must be > 1 (e.g. 12 Pcs per Box)';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // INTERNAL HELPERS
  // ─────────────────────────────────────────────────────────────

  /// Format a quantity for display: show as int if whole, otherwise 1 decimal.
  static String _formatQty(double qty) {
    if ((qty - qty.roundToDouble()).abs() < 0.001) {
      return qty.round().toString();
    }
    return qty.toStringAsFixed(1);
  }
}
