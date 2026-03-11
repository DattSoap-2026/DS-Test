class AttendanceAudit {
  final String editedBy;
  final DateTime editedAt;
  final String oldStatus;
  final String newStatus;
  final String reason;

  AttendanceAudit({
    required this.editedBy,
    required this.editedAt,
    required this.oldStatus,
    required this.newStatus,
    required this.reason,
  });

  Map<String, dynamic> toMap() => {
    'editedBy': editedBy,
    'editedAt': editedAt.toIso8601String(),
    'oldStatus': oldStatus,
    'newStatus': newStatus,
    'reason': reason,
  };

  factory AttendanceAudit.fromMap(Map<String, dynamic> map) => AttendanceAudit(
    editedBy: map['editedBy'] ?? 'Unknown',
    editedAt: DateTime.tryParse(map['editedAt'] ?? '') ?? DateTime.now(),
    oldStatus: map['oldStatus'] ?? '',
    newStatus: map['newStatus'] ?? '',
    reason: map['reason'] ?? '',
  );
}

class Attendance {
  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? remarks;
  final bool isManualEntry;
  final bool isOvertime;
  final DateTime updatedAt;
  final DateTime? markedAt;
  final bool isCorrected;
  final double? overtimeHours;
  final List<AttendanceAudit> auditLog;

  String? employeeName; // Hydrated field

  Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.remarks,
    this.isManualEntry = false,
    this.isOvertime = false,
    required this.updatedAt,
    this.markedAt,
    this.isCorrected = false,
    this.overtimeHours,
    this.auditLog = const [],
    this.employeeName,
  });

  Duration? get workedDuration {
    if (checkInTime != null && checkOutTime != null) {
      return checkOutTime!.difference(checkInTime!);
    }
    return null;
  }

  String get workedHoursFormatted {
    final duration = workedDuration;
    if (duration == null) return '-';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  bool get isWeeklyOffWorked =>
      status == 'WeeklyOffWorked' || (status == 'WeeklyOff' && isOvertime);

  DateTime get effectiveMarkedAt => markedAt ?? updatedAt;

  bool get isLocked =>
      DateTime.now().difference(effectiveMarkedAt).inHours >= 24;
}

class AttendanceSummary {
  final String employeeId;
  final int month;
  final int year;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int halfDays;
  final int leaveDays;
  final int weeklyOffWorkedDays;
  final int weeklyOffDays;
  final int totalWorkingDays;
  final double totalOvertimeHours;

  AttendanceSummary({
    required this.employeeId,
    required this.month,
    required this.year,
    this.presentDays = 0,
    this.absentDays = 0,
    this.lateDays = 0,
    this.halfDays = 0,
    this.leaveDays = 0,
    this.weeklyOffWorkedDays = 0,
    this.weeklyOffDays = 0,
    this.totalWorkingDays = 0,
    this.totalOvertimeHours = 0.0,
  });

  double get attendancePercentage {
    if (totalWorkingDays == 0) return 0;
    return (presentDays + halfDays * 0.5 + weeklyOffWorkedDays) /
        totalWorkingDays *
        100;
  }
}
