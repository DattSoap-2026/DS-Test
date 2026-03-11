import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'payroll_record_entity.g.dart';

@Collection()
class PayrollRecordEntity extends BaseEntity {
  @Index()
  late String employeeId;

  @Index()
  late String month; // YYYY-MM

  late DateTime generatedAt;

  // Calculated Metrics
  double totalHours = 0.0;
  double baseSalary = 0.0; // Snapshot of salary at time of generation
  double totalOvertimeHours = 0.0;
  double bonuses = 0.0;
  double deductions = 0.0;

  // Final calculation
  double netSalary = 0.0;

  @Index()
  late String status; // 'Draft', 'Finalized', 'Paid'

  String? paymentReference; // Check number / Transaction ID
  DateTime? paidAt;

  // Domain conversion methods can be added if we create a separate Domain Model.
  // For simplicity in this module, we might use the Entity directly or create a DTO.
}
