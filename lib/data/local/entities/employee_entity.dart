import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../../../../modules/hr/models/employee_model.dart';

part 'employee_entity.g.dart';

/// SCHEMA NOTE:
/// v2 (current): Added baseMonthlySalary, hourlyRate, paymentMethod, bankDetails.
/// These fields are nullable so existing records without them remain valid (backward compat).
/// No explicit Isar schema migration needed - Isar handles adding nullable fields gracefully.

@Collection()
class EmployeeEntity extends BaseEntity {
  @Index(unique: true)
  late String employeeId;

  late String name;

  @Index()
  late String roleType; // 'worker', 'driver', 'office_staff', 'salesman'

  @Index()
  String? linkedUserId; // Firebase Auth UID if applicable

  late String department;
  late String mobile;
  late bool isActive;
  late DateTime createdAt;
  late int weeklyOffDay; // 1=Mon ... 7=Sun

  // ─── SALARY FIELDS (added v2) ─────────────────────────────────────────────
  // Nullable for backward compatibility with existing records that lack them.

  /// Fixed monthly salary (used for salaried employees).
  double? baseMonthlySalary;

  /// Per-hour rate (used for hourly/daily-wage employees).
  double? hourlyRate;

  /// Payment method: 'Bank Transfer', 'Cash', 'Cheque'
  String? paymentMethod;

  /// Bank account details or payment notes (stored as plain text; encrypt if needed).
  String? bankDetails;

  // ─── SHIFT FIELDS (added v2) ─────────────────────────────────────────────
  /// Shift start hour (24h, e.g. 9 = 9 AM). Used to determine late check-in.
  int? shiftStartHour; // e.g. 9

  /// Shift start minute.
  int? shiftStartMinute; // e.g. 0
  
  DateTime? joiningDate;
  DateTime? exitDate;
  double? overtimeMultiplier;

  // ─────────────────────────────────────────────────────────────────────────

  Employee toDomain() {
    final safeWeeklyOff = (weeklyOffDay >= 1 && weeklyOffDay <= 7)
        ? weeklyOffDay
        : DateTime.sunday;
    return Employee(
      employeeId: employeeId,
      name: name,
      roleType: roleType,
      linkedUserId: linkedUserId,
      department: department,
      mobile: mobile,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      weeklyOffDay: safeWeeklyOff,
      // Salary fields - safe null fallback
      baseMonthlySalary: baseMonthlySalary,
      hourlyRate: hourlyRate,
      paymentMethod: paymentMethod,
      bankDetails: bankDetails,
      shiftStartHour: shiftStartHour ?? 9,
      shiftStartMinute: shiftStartMinute ?? 0,
      joiningDate: joiningDate ?? createdAt, // Fallback to createdAt if missing
      exitDate: exitDate,
      overtimeMultiplier: overtimeMultiplier ?? 1.0,
    );
  }

  static EmployeeEntity fromDomain(Employee model) {
    final entity = EmployeeEntity()
      ..id = model.employeeId
      ..employeeId = model.employeeId
      ..name = model.name
      ..roleType = model.roleType
      ..linkedUserId = model.linkedUserId
      ..department = model.department
      ..mobile = model.mobile
      ..isActive = model.isActive
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt ?? DateTime.now()
      ..weeklyOffDay = model.weeklyOffDay
      // Salary fields
      ..baseMonthlySalary = model.baseMonthlySalary
      ..hourlyRate = model.hourlyRate
      ..paymentMethod = model.paymentMethod
      ..bankDetails = model.bankDetails
      ..shiftStartHour = model.shiftStartHour
      ..shiftStartMinute = model.shiftStartMinute
      ..joiningDate = model.joiningDate
      ..exitDate = model.exitDate
      ..overtimeMultiplier = model.overtimeMultiplier;

    return entity;
  }
}
