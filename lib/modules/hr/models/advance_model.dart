class Advance {
  final String id;
  final String employeeId;
  final String type; // 'Advance', 'Loan'
  final double amount;
  final double paidAmount;
  final String status;
  final DateTime requestDate;
  final DateTime? approvedDate;
  final String? approvedBy;
  final String? rejectionReason;
  final String? purpose;
  final int? emiMonths;
  final double? emiAmount;
  final String? remarks;

  String? employeeName; // Hydrated field

  Advance({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.amount,
    this.paidAmount = 0,
    required this.status,
    required this.requestDate,
    this.approvedDate,
    this.approvedBy,
    this.rejectionReason,
    this.purpose,
    this.emiMonths,
    this.emiAmount,
    this.remarks,
    this.employeeName,
  });

  double get remainingAmount => amount - paidAmount;
  bool get isCleared => remainingAmount <= 0;

  double get progressPercent {
    if (amount == 0) return 0;
    return (paidAmount / amount) * 100;
  }

  int? get remainingEmis {
    if (emiAmount == null || emiAmount == 0) return null;
    return (remainingAmount / emiAmount!).ceil();
  }
}

class AdvanceSummary {
  final String employeeId;
  final double totalAdvances;
  final double totalLoans;
  final double totalOutstanding;
  final int activeAdvances;
  final int activeLoans;

  AdvanceSummary({
    required this.employeeId,
    this.totalAdvances = 0,
    this.totalLoans = 0,
    this.totalOutstanding = 0,
    this.activeAdvances = 0,
    this.activeLoans = 0,
  });
}
