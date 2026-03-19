import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'employeeId': employeeId,
      'month': month,
      'generatedAt': generatedAt.toIso8601String(),
      'totalHours': totalHours,
      'baseSalary': baseSalary,
      'totalOvertimeHours': totalOvertimeHours,
      'bonuses': bonuses,
      'deductions': deductions,
      'netSalary': netSalary,
      'status': status,
      'paymentReference': paymentReference,
      'paidAt': paidAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastModified': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus.name,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  static PayrollRecordEntity fromJson(Map<String, dynamic> json) {
    final paymentReference = parseString(json['paymentReference']);

    return PayrollRecordEntity()
      ..id = parseString(json['id'])
      ..employeeId = parseString(json['employeeId'])
      ..month = parseString(json['month'])
      ..generatedAt = parseDate(json['generatedAt'])
      ..totalHours = parseDouble(json['totalHours'])
      ..baseSalary = parseDouble(json['baseSalary'])
      ..totalOvertimeHours = parseDouble(json['totalOvertimeHours'])
      ..bonuses = parseDouble(json['bonuses'])
      ..deductions = parseDouble(json['deductions'])
      ..netSalary = parseDouble(json['netSalary'])
      ..status = parseString(json['status'], fallback: 'Draft')
      ..paymentReference = paymentReference.isEmpty ? null : paymentReference
      ..paidAt = parseDateOrNull(json['paidAt'])
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }
}
