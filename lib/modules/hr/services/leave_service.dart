import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../core/sync/sync_queue_service.dart';
import '../../../data/local/entities/attendance_entity.dart';
import '../../../services/database_service.dart';
import '../../../data/local/entities/employee_entity.dart';
import '../../../data/local/entities/leave_request_entity.dart';
import '../../../data/local/base_entity.dart';
import '../models/leave_request_model.dart';
import 'hr_service.dart';

class LeaveService with ChangeNotifier {
  final DatabaseService _dbService;
  final HrService _hrService;
  static const String _collection = 'leave_requests';

  // Maharashtra Shops & Establishments (2017) baseline:
  // - Casual leave: 8 days per calendar year.
  // - Earned leave: 1 day for every 20 days worked
  //   (pro-rata rule for < 240 days handled separately).
  static const int _casualLeavePerYear = 8;
  static const int _earnedLeaveAccrualDivisor = 20;
  static const int _earnedLeaveMinWorkedDaysForFullRule = 240;
  static const int _earnedLeaveProRataDivisor = 60;
  static const int _earnedLeaveProRataCap = 5;
  static const int _earnedLeaveMinServiceMonthsForProRata = 3;

  // Company policy defaults (non-statutory, configurable in future):
  static const int _sickLeavePerYear = 8;

  // Statutory maternity baseline (Maternity Benefit Amendment, 2017):
  static const int _maternityLeaveDays = 26 * 7;

  static const List<String> _supportedLeaveTypes = <String>[
    'Casual',
    'Sick',
    'Earned',
    'Unpaid',
    'Maternity',
  ];

  LeaveService(this._dbService, this._hrService);

  List<String> get supportedLeaveTypes => _supportedLeaveTypes;

  Future<void> _enqueueOutbox(
    Map<String, dynamic> payload, {
    String action = 'set',
  }) async {
    final documentId = payload['id']?.toString().trim() ?? '';
    if (documentId.isEmpty) {
      return;
    }
    await SyncQueueService.instance.addToQueue(
      collectionName: _collection,
      documentId: documentId,
      operation: action,
      payload: payload,
    );
  }

  Map<String, dynamic> _toSyncPayload(LeaveRequestEntity entity) {
    String leaveType;
    try {
      leaveType = _normalizeLeaveType(entity.leaveType);
    } catch (_) {
      leaveType = entity.leaveType;
    }
    return <String, dynamic>{
      'id': entity.id,
      'employeeId': entity.employeeId,
      'leaveType': leaveType,
      'startDate': entity.startDate,
      'endDate': entity.endDate,
      'totalDays': entity.totalDays,
      'reason': entity.reason,
      'status': _normalizeStatus(entity.status),
      'approvedBy': entity.approvedBy,
      'approvedAt': entity.approvedAt,
      'rejectionReason': entity.rejectionReason,
      'requestedAt': entity.requestedAt,
      'isDeleted': entity.isDeleted,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };
  }

  String _normalizeStatus(String status) {
    final value = status.trim().toLowerCase();
    switch (value) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  String _normalizeLeaveType(String leaveType) {
    final value = leaveType.trim().toLowerCase();
    switch (value) {
      case 'casual':
      case 'cl':
        return 'Casual';
      case 'sick':
      case 'sl':
      case 'medical':
        return 'Sick';
      case 'earned':
      case 'el':
      case 'privilege':
      case 'pl':
        return 'Earned';
      case 'unpaid':
      case 'lwp':
      case 'withoutpay':
      case 'without pay':
        return 'Unpaid';
      case 'maternity':
      case 'maternity leave':
        return 'Maternity';
      default:
        throw Exception('Unsupported leave type: $leaveType');
    }
  }

  int _safeWeeklyOffDay(int? day) {
    if (day == null || day < 1 || day > 7) return DateTime.sunday;
    return day;
  }

  Future<int> _resolveWeeklyOffDay(String employeeId) async {
    final emp = await _dbService.employees
        .filter()
        .employeeIdEqualTo(employeeId)
        .findFirst();
    return _safeWeeklyOffDay(emp?.weeklyOffDay);
  }

  int _calendarDaysInRange(DateTime startDate, DateTime endDate) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return end.difference(start).inDays + 1;
  }

  int _chargeableDaysInRange(
    DateTime startDate,
    DateTime endDate, {
    required int weeklyOffDay,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    var cursor = start;
    var chargeable = 0;
    while (!cursor.isAfter(end)) {
      if (cursor.weekday != weeklyOffDay) {
        chargeable++;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return chargeable;
  }

  Future<LeaveDayBreakdown> getLeaveDayBreakdown({
    required String employeeId,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final normalizedType = _normalizeLeaveType(leaveType);
    final calendarDays = _calendarDaysInRange(startDate, endDate);
    if (normalizedType == 'Maternity') {
      return LeaveDayBreakdown(
        calendarDays: calendarDays,
        chargeableDays: calendarDays,
      );
    }

    final weeklyOffDay = await _resolveWeeklyOffDay(employeeId);
    final chargeableDays = _chargeableDaysInRange(
      startDate,
      endDate,
      weeklyOffDay: weeklyOffDay,
    );
    return LeaveDayBreakdown(
      calendarDays: calendarDays,
      chargeableDays: chargeableDays,
    );
  }

  int _monthsInServiceInCurrentYear(DateTime serviceStart) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final effectiveStart = serviceStart.isAfter(startOfYear)
        ? serviceStart
        : startOfYear;
    if (effectiveStart.isAfter(now)) return 0;

    final months = (now.year - effectiveStart.year) * 12 +
        (now.month - effectiveStart.month) +
        (now.day >= effectiveStart.day ? 1 : 0);
    return months < 0 ? 0 : months;
  }

  Future<int> _estimateWorkedDaysInCurrentYear(
    String employeeId, {
    required int weeklyOffDay,
    required DateTime serviceStart,
  }) async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final effectiveStart = serviceStart.isAfter(startOfYear)
        ? serviceStart
        : startOfYear;
    if (effectiveStart.isAfter(now)) return 0;

    final startStr =
        '${effectiveStart.year}-${effectiveStart.month.toString().padLeft(2, '0')}-${effectiveStart.day.toString().padLeft(2, '0')}';
    final endStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final attendances = await _dbService.attendances
        .filter()
        .employeeIdEqualTo(employeeId)
        .dateBetween(startStr, endStr)
        .findAll();

    final workedStatuses = <String>{
      'Present',
      'Late',
      'HalfDay',
      'WeeklyOffWorked',
    };
    final workedByAttendance = attendances
        .where((a) => !a.isDeleted && workedStatuses.contains(a.status))
        .length;

    if (workedByAttendance > 0) return workedByAttendance;

    // Fallback for sparse/legacy attendance data:
    // estimate scheduled working days by excluding weekly offs.
    var workedByCalendar = 0;
    var cursor = DateTime(
      effectiveStart.year,
      effectiveStart.month,
      effectiveStart.day,
    );
    final end = DateTime(now.year, now.month, now.day);
    while (!cursor.isAfter(end)) {
      if (cursor.weekday != weeklyOffDay) workedByCalendar++;
      cursor = cursor.add(const Duration(days: 1));
    }
    return workedByCalendar;
  }

  Future<int> _calculateEarnedLeaveEntitlement(
    String employeeId, {
    required DateTime serviceStart,
    required int weeklyOffDay,
  }) async {
    final workedDays = await _estimateWorkedDaysInCurrentYear(
      employeeId,
      weeklyOffDay: weeklyOffDay,
      serviceStart: serviceStart,
    );

    if (workedDays >= _earnedLeaveMinWorkedDaysForFullRule) {
      return workedDays ~/ _earnedLeaveAccrualDivisor;
    }

    final monthsInService = _monthsInServiceInCurrentYear(serviceStart);
    if (monthsInService >= _earnedLeaveMinServiceMonthsForProRata) {
      final proRata = workedDays ~/ _earnedLeaveProRataDivisor;
      return math.min(_earnedLeaveProRataCap, proRata);
    }

    return 0;
  }

  DateTime _safeParseDateTime(String? value, {DateTime? fallback}) {
    return DateTime.tryParse(value ?? '') ?? fallback ?? DateTime.now();
  }

  /// Validation: Prevent overlapping approved or pending leave
  Future<void> _checkLeaveCollision({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
    String? excludeId,
  }) async {
    final existingLeaves = await _dbService.leaveRequests
        .filter()
        .employeeIdEqualTo(employeeId)
        .isDeletedEqualTo(false)
        .findAll();

    for (final leave in existingLeaves) {
      if (excludeId != null && leave.id == excludeId) continue;
      final normalizedStatus = _normalizeStatus(leave.status);
      if (normalizedStatus != 'Approved' && normalizedStatus != 'Pending') {
        continue;
      }

      final existingStart = _safeParseDateTime(leave.startDate);
      final existingEnd = _safeParseDateTime(leave.endDate);

      // Overlap logic: (StartA <= EndB) and (EndA >= StartB)
      final overlaps = (startDate.isBefore(existingEnd) ||
              startDate.isAtSameMomentAs(existingEnd)) &&
          (endDate.isAfter(existingStart) ||
              endDate.isAtSameMomentAs(existingStart));

      if (overlaps) {
        throw Exception(
            'Leave collision detected! This employee already has a ${leave.status} leave from ${leave.startDate} to ${leave.endDate}.');
      }
    }
  }

  /// Apply for leave
  Future<LeaveRequest> applyLeave({
    required String employeeId,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    if (endDate.isBefore(startDate)) {
      throw Exception('End date cannot be before start date');
    }

    final normalizedType = _normalizeLeaveType(leaveType);
    final daysBreakdown = await getLeaveDayBreakdown(
      employeeId: employeeId,
      leaveType: normalizedType,
      startDate: startDate,
      endDate: endDate,
    );
    final chargeableDays = daysBreakdown.chargeableDays;
    final calendarDays = daysBreakdown.calendarDays;

    if (chargeableDays <= 0) {
      throw Exception(
        'Selected date range contains only weekly off days. Please select working days.',
      );
    }

    if (normalizedType == 'Sick' &&
        chargeableDays > 2 &&
        (reason == null || reason.trim().isEmpty)) {
      throw Exception(
        'Reason is required for sick leave above 2 working days.',
      );
    }

    if (normalizedType == 'Maternity' && calendarDays > _maternityLeaveDays) {
      throw Exception(
        'Maternity leave cannot exceed $_maternityLeaveDays days (26 weeks).',
      );
    }

    if (normalizedType == 'Casual' ||
        normalizedType == 'Sick' ||
        normalizedType == 'Earned') {
      final balance = await getLeaveBalance(employeeId);
      final remaining = switch (normalizedType) {
        'Casual' => balance.remainingCasual,
        'Sick' => balance.remainingSick,
        'Earned' => balance.remainingEarned,
        _ => 0,
      };
      if (chargeableDays > remaining) {
        throw Exception(
          '$normalizedType leave exceeded. Remaining: $remaining, requested: $chargeableDays.',
        );
      }
    }

    // Collision Check
    await _checkLeaveCollision(
      employeeId: employeeId,
      startDate: startDate,
      endDate: endDate,
    );

    final totalDays =
        normalizedType == 'Maternity' ? calendarDays : chargeableDays;
    final id = const Uuid().v4();
    final now = DateTime.now();

    final entity = LeaveRequestEntity()
      ..id = id
      ..employeeId = employeeId
      ..leaveType = normalizedType
      ..startDate = startDate.toIso8601String()
      ..endDate = endDate.toIso8601String()
      ..totalDays = totalDays
      ..reason = reason
      ..status = _normalizeStatus('Pending')
      ..requestedAt = now.toIso8601String()
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.leaveRequests.put(entity);
    });
    await _enqueueOutbox(_toSyncPayload(entity), action: 'set');

    notifyListeners();
    return _toDomain(entity);
  }

  /// Approve leave request
  Future<void> approveLeave(String id, String approvedBy) async {
    final requestId = id.trim();
    if (requestId.isEmpty) {
      throw Exception('Leave request id is required.');
    }
    final approver = approvedBy.trim().isEmpty ? 'Manager' : approvedBy.trim();

    final existing = await _dbService.leaveRequests
        .filter()
        .idEqualTo(requestId)
        .findFirst();
    if (existing == null || existing.isDeleted) {
      throw Exception('Leave request not found.');
    }

    final currentStatus = _normalizeStatus(existing.status);
    if (currentStatus != 'Pending') {
      throw Exception(
        'Only pending requests can be approved. Current status: $currentStatus.',
      );
    }

    final startDate = _safeParseDateTime(existing.startDate);
    final endDate = _safeParseDateTime(existing.endDate);
    if (endDate.isBefore(startDate)) {
      throw Exception('Invalid leave range: end date is before start date.');
    }

    await _checkLeaveCollision(
      employeeId: existing.employeeId,
      startDate: startDate,
      endDate: endDate,
      excludeId: requestId,
    );

    final normalizedType = _normalizeLeaveType(existing.leaveType);
    final requestedDays = existing.totalDays;
    if (requestedDays <= 0) {
      throw Exception('Invalid leave request: total days must be greater than 0.');
    }

    if (normalizedType == 'Casual' ||
        normalizedType == 'Sick' ||
        normalizedType == 'Earned') {
      final balance = await getLeaveBalance(existing.employeeId);
      final remaining = switch (normalizedType) {
        'Casual' => balance.remainingCasual,
        'Sick' => balance.remainingSick,
        'Earned' => balance.remainingEarned,
        _ => 0,
      };
      if (requestedDays > remaining) {
        throw Exception(
          '$normalizedType leave exceeded. Remaining: $remaining, requested: $requestedDays.',
        );
      }
    }

    LeaveRequestEntity? updated;
    await _dbService.db.writeTxn(() async {
      final entity = await _dbService.leaveRequests
          .filter()
          .idEqualTo(requestId)
          .findFirst();

      if (entity == null || entity.isDeleted) {
        throw Exception('Leave request not found.');
      }

      final latestStatus = _normalizeStatus(entity.status);
      if (latestStatus != 'Pending') {
        throw Exception(
          'Only pending requests can be approved. Current status: $latestStatus.',
        );
      }

      entity.status = _normalizeStatus('Approved');
      entity.approvedBy = approver;
      entity.approvedAt = DateTime.now().toIso8601String();
      entity.updatedAt = DateTime.now();
      entity.syncStatus = SyncStatus.pending;
      await _dbService.leaveRequests.put(entity);
      updated = entity;
    });
    if (updated != null) {
      await _enqueueOutbox(_toSyncPayload(updated!), action: 'update');
    }
    notifyListeners();
  }

  /// Reject leave request
  Future<void> rejectLeave(String id, String rejectedBy, String reason) async {
    final requestId = id.trim();
    if (requestId.isEmpty) {
      throw Exception('Leave request id is required.');
    }

    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw Exception('Rejection reason is required.');
    }
    final rejector = rejectedBy.trim().isEmpty ? 'Manager' : rejectedBy.trim();

    LeaveRequestEntity? updated;
    await _dbService.db.writeTxn(() async {
      final entity = await _dbService.leaveRequests
          .filter()
          .idEqualTo(requestId)
          .findFirst();

      if (entity == null || entity.isDeleted) {
        throw Exception('Leave request not found.');
      }

      final currentStatus = _normalizeStatus(entity.status);
      if (currentStatus != 'Pending') {
        throw Exception(
          'Only pending requests can be rejected. Current status: $currentStatus.',
        );
      }

      entity.status = _normalizeStatus('Rejected');
      entity.approvedBy = rejector;
      entity.rejectionReason = normalizedReason;
      entity.approvedAt = DateTime.now().toIso8601String();
      entity.updatedAt = DateTime.now();
      entity.syncStatus = SyncStatus.pending;
      await _dbService.leaveRequests.put(entity);
      updated = entity;
    });
    if (updated != null) {
      await _enqueueOutbox(_toSyncPayload(updated!), action: 'update');
    }
    notifyListeners();
  }

  /// Get pending requests (for managers)
  Future<List<LeaveRequest>> getPendingRequests() async {
    final entities = await _dbService.leaveRequests.where().findAll();
    final filtered = entities
        .where(
          (e) => !e.isDeleted && _normalizeStatus(e.status) == 'Pending',
        )
        .toList()
      ..sort(
        (a, b) => DateTime.parse(
          b.requestedAt,
        ).compareTo(DateTime.parse(a.requestedAt)),
      );
    return _hydrateList(filtered);
  }

  /// Get leave history for an employee
  Future<List<LeaveRequest>> getLeaveHistory(String employeeId) async {
    final entities = await _dbService.leaveRequests
        .filter()
        .employeeIdEqualTo(employeeId)
        .sortByRequestedAtDesc()
        .findAll();
    final active = entities.where((e) => !e.isDeleted).toList();
    return _hydrateList(active);
  }

  /// Calculate leave balance for an employee (current year)
  Future<LeaveBalance> getLeaveBalance(String employeeId) async {
    final year = DateTime.now().year;
    final startOfYear = DateTime(year, 1, 1);

    final requests = await _dbService.leaveRequests
        .filter()
        .employeeIdEqualTo(employeeId)
        .findAll();

    int usedSick = 0, usedCasual = 0, usedEarned = 0;

    for (var leave in requests.where((e) => !e.isDeleted)) {
      if (_normalizeStatus(leave.status) != 'Approved') continue;
      final reqDate = DateTime.parse(leave.startDate);
      if (reqDate.isAfter(startOfYear) ||
          reqDate.isAtSameMomentAs(startOfYear)) {
        String normalizedType;
        try {
          normalizedType = _normalizeLeaveType(leave.leaveType);
        } catch (_) {
          continue;
        }
        switch (normalizedType) {
          case 'Sick':
            usedSick += leave.totalDays;
            break;
          case 'Casual':
            usedCasual += leave.totalDays;
            break;
          case 'Earned':
            usedEarned += leave.totalDays;
            break;
        }
      }
    }

    final employee = await _dbService.employees
        .filter()
        .employeeIdEqualTo(employeeId)
        .findFirst();
    final serviceStart = employee?.joiningDate ?? employee?.createdAt;
    final weeklyOffDay = _safeWeeklyOffDay(employee?.weeklyOffDay);
    final earnedEntitlement = serviceStart == null
        ? 0
        : await _calculateEarnedLeaveEntitlement(
            employeeId,
            serviceStart: serviceStart,
            weeklyOffDay: weeklyOffDay,
          );

    return LeaveBalance(
      employeeId: employeeId,
      sickLeave: _sickLeavePerYear,
      casualLeave: _casualLeavePerYear,
      earnedLeave: earnedEntitlement,
      usedSick: usedSick,
      usedCasual: usedCasual,
      usedEarned: usedEarned,
    );
  }

  Future<List<LeaveRequest>> _hydrateList(
    List<LeaveRequestEntity> entities,
  ) async {
    final results = <LeaveRequest>[];
    for (var e in entities) {
      final req = _toDomain(e);
      final emp = await _hrService.getEmployee(e.employeeId);
      req.employeeName = emp?.name;
      results.add(req);
    }
    return results;
  }

  LeaveRequest _toDomain(LeaveRequestEntity e) {
    String normalizedType;
    try {
      normalizedType = _normalizeLeaveType(e.leaveType);
    } catch (_) {
      normalizedType = e.leaveType;
    }
    return LeaveRequest(
      id: e.id,
      employeeId: e.employeeId,
      leaveType: normalizedType,
      startDate: _safeParseDateTime(e.startDate),
      endDate: _safeParseDateTime(e.endDate),
      totalDays: e.totalDays,
      reason: e.reason,
      status: _normalizeStatus(e.status),
      approvedBy: e.approvedBy,
      approvedAt: e.approvedAt != null
          ? _safeParseDateTime(e.approvedAt)
          : null,
      rejectionReason: e.rejectionReason,
      requestedAt: _safeParseDateTime(e.requestedAt),
    );
  }
}
