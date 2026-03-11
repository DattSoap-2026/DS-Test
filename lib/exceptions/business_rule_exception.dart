class BusinessRuleException implements Exception {
  BusinessRuleException(this.message);

  final String message;

  @override
  String toString() => message;
}
