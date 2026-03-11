class PayrollRecord {
  final String id;
  final String employeeId;
  final String month; // YYYY-MM
  final DateTime generatedAt;
  final double totalHours;
  final double baseSalary;
  final double totalOvertimeHours;
  final double bonuses;
  final double deductions;
  final double emiDeduction;
  final double tdsDeduction;
  final double grossSalary;
  final double netSalary;
  final String status; // 'Draft', 'Finalized', 'Paid'
  final String? paymentReference;
  final DateTime? paidAt;

  // Display Helpers
  String get employeeName => _employeeName ?? 'Unknown';
  String? _employeeName; // Hydrated at runtime

  void setEmployeeName(String name) {
    _employeeName = name;
  }

  PayrollRecord({
    required this.id,
    required this.employeeId,
    required this.month,
    required this.generatedAt,
    required this.totalHours,
    required this.baseSalary,
    this.totalOvertimeHours = 0.0,
    this.bonuses = 0.0,
    this.deductions = 0.0,
    this.emiDeduction = 0.0,
    this.tdsDeduction = 0.0,
    required this.grossSalary,
    required this.netSalary,
    required this.status,
    this.paymentReference,
    this.paidAt,
  });
}
