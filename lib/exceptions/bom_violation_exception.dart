enum BomValidationType {
  success,
  noFormula,
  inputError,
  yieldError,
  wastageError,
}

class BomViolationException implements Exception {
  final String message;
  final List<String>? errors;
  final BomValidationType type;

  BomViolationException({
    required this.message,
    this.errors,
    required this.type,
  });

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return 'BOM Violation:\n${errors!.join('\n')}';
    }
    return 'BOM Violation: $message';
  }
}
