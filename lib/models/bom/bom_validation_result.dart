class BomValidationResult {
  final bool isValid;
  final String message;
  final String? violationType;
  final double? effectiveInputKg;
  final double? actualOutputKg;
  final double? yieldPercent;
  final double? actualYield;

  BomValidationResult._(
    this.isValid,
    this.message, {
    this.violationType,
    this.effectiveInputKg,
    this.actualOutputKg,
    this.yieldPercent,
    this.actualYield,
  });

  factory BomValidationResult.success({
    required double effectiveInputKg,
    required double actualOutputKg,
    required double yieldPercent,
  }) =>
      BomValidationResult._(
        true,
        'Validation passed',
        effectiveInputKg: effectiveInputKg,
        actualOutputKg: actualOutputKg,
        yieldPercent: yieldPercent,
      );

  factory BomValidationResult.missingMaterials({
    required List<String> missingMaterialIds,
  }) =>
      BomValidationResult._(
        false,
        'Missing materials: ${missingMaterialIds.join(", ")}',
        violationType: 'MISSING_MATERIALS',
      );

  factory BomValidationResult.ratioViolation({
    required String materialId,
    required double expected,
    required double actual,
    required double deviationPercent,
  }) =>
      BomValidationResult._(
        false,
        'Ratio violation for $materialId: expected $expected, got $actual (${deviationPercent.toStringAsFixed(1)}% deviation)',
        violationType: 'RATIO_VIOLATION',
      );

  factory BomValidationResult.yieldViolation({
    required double expectedYield,
    required double actualYield,
    required double deviationPercent,
  }) =>
      BomValidationResult._(
        false,
        'Yield violation: expected ${expectedYield.toStringAsFixed(1)}%, got ${actualYield.toStringAsFixed(1)}% (${deviationPercent.toStringAsFixed(1)}% deviation)',
        violationType: 'YIELD_VIOLATION',
        actualYield: actualYield,
      );

  factory BomValidationResult.error({required String message}) =>
      BomValidationResult._(false, message, violationType: 'ERROR');
}
