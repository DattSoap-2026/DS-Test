import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String employeeId;
  final String name;
  final String roleType;
  final String? linkedUserId;
  final String department;
  final String mobile;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ─── Salary ─────────────────────────────────────────────────────────────
  final double? baseMonthlySalary;
  final double? hourlyRate;
  final String? paymentMethod; // 'Bank Transfer', 'Cash', 'Cheque'
  final String? bankDetails; // Account No, IFSC, etc.
  final String? panNumber;
  final bool isTdsApplicable;
  final double tdsPercentage; // e.g. 10.0 for 10%

  // ─── Shift ──────────────────────────────────────────────────────────────
  final int weeklyOffDay; // 1=Mon ... 7=Sun
  final int shiftStartHour; // 24h format e.g. 9 = 9 AM
  final int shiftStartMinute; // e.g. 0
  final DateTime joiningDate;
  final DateTime? exitDate;
  final double overtimeMultiplier; // e.g. 1.0, 1.5, 2.0

  Employee({
    required this.employeeId,
    required this.name,
    required this.roleType,
    this.linkedUserId,
    required this.department,
    required this.mobile,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.baseMonthlySalary,
    this.hourlyRate,
    this.paymentMethod,
    this.bankDetails,
    this.panNumber,
    this.isTdsApplicable = false,
    this.tdsPercentage = 0.0,
    this.weeklyOffDay = DateTime.sunday,
    this.shiftStartHour = 9, // Default 9 AM
    this.shiftStartMinute = 0,
    required this.joiningDate,
    this.exitDate,
    this.overtimeMultiplier = 1.0,
  });

  /// Whether this employee is paid per-hour or monthly.
  bool get isHourly => hourlyRate != null && hourlyRate! > 0;
  bool get isMonthly => baseMonthlySalary != null && baseMonthlySalary! > 0;

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'name': name,
      'roleType': roleType,
      'linkedUserId': linkedUserId,
      'department': department,
      'mobile': mobile,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      if (baseMonthlySalary != null) 'baseMonthlySalary': baseMonthlySalary,
      if (hourlyRate != null) 'hourlyRate': hourlyRate,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (bankDetails != null) 'bankDetails': bankDetails,
      if (panNumber != null) 'panNumber': panNumber,
      'isTdsApplicable': isTdsApplicable,
      'tdsPercentage': tdsPercentage,
      'weeklyOffDay': weeklyOffDay,
      'shiftStartHour': shiftStartHour,
      'shiftStartMinute': shiftStartMinute,
      'joiningDate': joiningDate.toIso8601String(),
      if (exitDate != null) 'exitDate': exitDate!.toIso8601String(),
      'overtimeMultiplier': overtimeMultiplier,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      employeeId: map['employeeId'] ?? '',
      name: map['name'] ?? '',
      roleType: map['roleType'] ?? 'worker',
      linkedUserId: map['linkedUserId'],
      department: map['department'] ?? '',
      mobile: map['mobile'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      baseMonthlySalary: (map['baseMonthlySalary'] as num?)?.toDouble(),
      hourlyRate: (map['hourlyRate'] as num?)?.toDouble(),
      paymentMethod: map['paymentMethod'],
      bankDetails: map['bankDetails'],
      panNumber: map['panNumber'],
      isTdsApplicable: map['isTdsApplicable'] ?? false,
      tdsPercentage: (map['tdsPercentage'] as num?)?.toDouble() ?? 0.0,
      weeklyOffDay:
          (map['weeklyOffDay'] as num?)?.toInt() ?? DateTime.sunday,
      shiftStartHour: (map['shiftStartHour'] as num?)?.toInt() ?? 9,
      shiftStartMinute: (map['shiftStartMinute'] as num?)?.toInt() ?? 0,
      joiningDate: map['joiningDate'] != null
          ? DateTime.parse(map['joiningDate'])
          : (map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now()),
      exitDate: map['exitDate'] != null ? DateTime.parse(map['exitDate']) : null,
      overtimeMultiplier: (map['overtimeMultiplier'] as num?)?.toDouble() ?? 1.0,
    );
  }

  factory Employee.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Employee.fromMap(data);
  }
}
