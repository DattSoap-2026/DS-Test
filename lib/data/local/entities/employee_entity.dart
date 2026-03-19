import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';
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
  List<String> assignedRoutes = <String>[];
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
      assignedRoutes: List<String>.from(assignedRoutes),
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
      ..assignedRoutes = List<String>.from(model.assignedRoutes)
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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'employeeId': employeeId,
      'name': name,
      'roleType': roleType,
      'linkedUserId': linkedUserId,
      'department': department,
      'assignedRoutes': assignedRoutes,
      'mobile': mobile,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'weeklyOffDay': weeklyOffDay,
      'baseMonthlySalary': baseMonthlySalary,
      'hourlyRate': hourlyRate,
      'paymentMethod': paymentMethod,
      'bankDetails': bankDetails,
      'shiftStartHour': shiftStartHour,
      'shiftStartMinute': shiftStartMinute,
      'joiningDate': joiningDate?.toIso8601String(),
      'exitDate': exitDate?.toIso8601String(),
      'overtimeMultiplier': overtimeMultiplier,
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

  static EmployeeEntity fromJson(Map<String, dynamic> json) {
    final createdAt = parseDateOrNull(json['createdAt']) ?? DateTime.now();
    final joiningDate = parseDateOrNull(json['joiningDate']) ?? createdAt;
    final linkedUserId = parseString(json['linkedUserId']);
    final bankDetails = parseString(json['bankDetails']);
    final paymentMethod = parseString(json['paymentMethod']);

    return EmployeeEntity()
      ..id = parseString(json['id'])
      ..employeeId = parseString(
        json['employeeId'],
        fallback: parseString(json['id']),
      )
      ..name = parseString(json['name'])
      ..roleType = parseString(json['roleType'], fallback: 'worker')
      ..linkedUserId = linkedUserId.isEmpty ? null : linkedUserId
      ..department = parseString(json['department'])
      ..assignedRoutes = parseStringList(json['assignedRoutes']) ?? <String>[]
      ..mobile = parseString(json['mobile'])
      ..isActive = parseBool(json['isActive'], fallback: true)
      ..createdAt = createdAt
      ..weeklyOffDay = parseInt(json['weeklyOffDay'], fallback: DateTime.sunday)
      ..baseMonthlySalary = json['baseMonthlySalary'] == null
          ? null
          : parseDouble(json['baseMonthlySalary'])
      ..hourlyRate = json['hourlyRate'] == null
          ? null
          : parseDouble(json['hourlyRate'])
      ..paymentMethod = paymentMethod.isEmpty ? null : paymentMethod
      ..bankDetails = bankDetails.isEmpty ? null : bankDetails
      ..shiftStartHour = json['shiftStartHour'] == null
          ? null
          : parseInt(json['shiftStartHour'], fallback: 9)
      ..shiftStartMinute = json['shiftStartMinute'] == null
          ? null
          : parseInt(json['shiftStartMinute'], fallback: 0)
      ..joiningDate = joiningDate
      ..exitDate = parseDateOrNull(json['exitDate'])
      ..overtimeMultiplier = json['overtimeMultiplier'] == null
          ? null
          : parseDouble(json['overtimeMultiplier'], fallback: 1.0)
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
