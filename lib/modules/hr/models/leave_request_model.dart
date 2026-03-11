class LeaveRequest {
  final String id;
  final String employeeId;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String? reason;
  final String status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime requestedAt;

  String? employeeName; // Hydrated field

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    this.reason,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    required this.requestedAt,
    this.employeeName,
  });

  LeaveRequest copyWith({
    String? status,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
  }) {
    return LeaveRequest(
      id: id,
      employeeId: employeeId,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      reason: reason,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      requestedAt: requestedAt,
      employeeName: employeeName,
    );
  }
}

class LeaveBalance {
  final String employeeId;
  final int sickLeave;
  final int casualLeave;
  final int earnedLeave;
  final int usedSick;
  final int usedCasual;
  final int usedEarned;

  LeaveBalance({
    required this.employeeId,
    this.sickLeave = 12,
    this.casualLeave = 12,
    this.earnedLeave = 15,
    this.usedSick = 0,
    this.usedCasual = 0,
    this.usedEarned = 0,
  });

  int get remainingSick => sickLeave - usedSick;
  int get remainingCasual => casualLeave - usedCasual;
  int get remainingEarned => earnedLeave - usedEarned;
  int get totalRemaining => remainingSick + remainingCasual + remainingEarned;
}

class LeaveDayBreakdown {
  final int calendarDays;
  final int chargeableDays;

  const LeaveDayBreakdown({
    required this.calendarDays,
    required this.chargeableDays,
  });
}
