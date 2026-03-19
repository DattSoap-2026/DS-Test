import 'dart:async';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../services/database_service.dart';
import '../local/base_entity.dart';
import '../local/entities/advance_entity.dart';
import '../local/entities/attendance_entity.dart';
import '../local/entities/employee_document_entity.dart';
import '../local/entities/employee_entity.dart';
import '../local/entities/holiday_entity.dart';
import '../local/entities/leave_request_entity.dart';
import '../local/entities/payroll_record_entity.dart';
import '../local/entities/performance_review_entity.dart';

/// Isar-first repository for HR entities.
class HrRepository {
  HrRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService =
           connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  static const Uuid _uuid = Uuid();

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  Future<void> saveEmployee(EmployeeEntity employee) async {
    final id = _requiredId(employee, 'Employee id is required');
    final existing = await _dbService.employees.getById(id);
    final now = DateTime.now();

    employee
      ..id = id
      ..employeeId = employee.employeeId.trim().isEmpty
          ? id
          : employee.employeeId.trim()
      ..name = employee.name.trim()
      ..roleType = _normalizeText(employee.roleType, fallback: 'worker')
      ..department = employee.department.trim()
      ..assignedRoutes = List<String>.from(employee.assignedRoutes)
      ..mobile = employee.mobile.trim()
      ..isActive = employee.isActive
      ..createdAt =
          existing?.createdAt ?? _resolveDate(() => employee.createdAt, now)
      ..weeklyOffDay = _safeWeekday(employee.weeklyOffDay)
      ..shiftStartHour ??= 9
      ..shiftStartMinute ??= 0
      ..joiningDate ??= existing?.joiningDate ?? employee.createdAt
      ..overtimeMultiplier ??= 1.0
      ..paymentMethod = _nullableTrim(employee.paymentMethod)
      ..bankDetails = _nullableTrim(employee.bankDetails);

    await _saveEntity(
      entity: employee,
      existing: existing,
      collectionName: CollectionRegistry.employees,
      payload: employee.toJson(),
      persist: () async {
        await _dbService.employees.put(employee);
      },
    );
  }

  Future<List<EmployeeEntity>> getAllEmployees() {
    return _dbService.employees
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .isActiveEqualTo(true)
        .sortByName()
        .findAll();
  }

  Future<List<EmployeeEntity>> getAllEmployeesIncludingInactive() {
    return _dbService.employees
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  Future<EmployeeEntity?> getEmployeeById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      return null;
    }

    final byId = await _dbService.employees
        .filter()
        .idEqualTo(normalizedId)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (byId != null) {
      return byId;
    }

    return _dbService.employees
        .filter()
        .employeeIdEqualTo(normalizedId)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<EmployeeEntity?> getEmployeeByLinkedUser(String linkedUserId) {
    final normalizedId = linkedUserId.trim();
    if (normalizedId.isEmpty) {
      return Future<EmployeeEntity?>.value(null);
    }

    return _dbService.employees
        .filter()
        .linkedUserIdEqualTo(normalizedId)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<List<EmployeeEntity>> getEmployeesByDepartment(String department) {
    return _dbService.employees
        .filter()
        .departmentEqualTo(department.trim())
        .and()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  Future<List<EmployeeEntity>> getEmployeesByRole(String roleType) {
    return _dbService.employees
        .filter()
        .roleTypeEqualTo(roleType.trim())
        .and()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  Future<List<EmployeeEntity>> searchEmployees(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return getAllEmployeesIncludingInactive();
    }

    final employees = await getAllEmployeesIncludingInactive();
    final results = employees
        .where((employee) {
          return employee.name.toLowerCase().contains(normalized) ||
              employee.employeeId.toLowerCase().contains(normalized) ||
              employee.mobile.toLowerCase().contains(normalized);
        })
        .toList(growable: false);
    results.sort((left, right) => left.name.compareTo(right.name));
    return results;
  }

  Stream<List<EmployeeEntity>> watchAllEmployees() {
    return _dbService.employees
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true);
  }

  Future<void> deactivateEmployee(String id) async {
    final employee = await getEmployeeById(id);
    if (employee == null || employee.isDeleted) {
      return;
    }

    employee
      ..isActive = false
      ..exitDate = DateTime.now();

    await _saveEntity(
      entity: employee,
      existing: employee,
      collectionName: CollectionRegistry.employees,
      payload: employee.toJson(),
      persist: () async {
        await _dbService.employees.put(employee);
      },
    );
  }

  Future<void> deleteEmployee(String id) async {
    final employee = await getEmployeeById(id);
    if (employee == null || employee.isDeleted) {
      return;
    }

    await _softDeleteEntity(
      entity: employee,
      collectionName: CollectionRegistry.employees,
      payload: employee.toJson(),
      persist: () async {
        await _dbService.employees.put(employee);
      },
    );
  }

  Future<void> saveAttendance(AttendanceEntity attendance) async {
    final id = _ensureId(attendance);
    final existing = await _dbService.attendances.getById(id);

    attendance
      ..id = id
      ..employeeId = attendance.employeeId.trim()
      ..date = _normalizeDateText(attendance.date)
      ..status = _normalizeText(attendance.status, fallback: 'Absent')
      ..checkInTime = _nullableTrim(attendance.checkInTime)
      ..checkOutTime = _nullableTrim(attendance.checkOutTime)
      ..remarks = _nullableTrim(attendance.remarks)
      ..auditLog = _nullableTrim(attendance.auditLog)
      ..markedAt ??= existing?.markedAt ?? DateTime.now();

    await _saveEntity(
      entity: attendance,
      existing: existing,
      collectionName: CollectionRegistry.attendances,
      payload: attendance.toJson(),
      persist: () async {
        await _dbService.attendances.put(attendance);
      },
    );
  }

  Future<List<AttendanceEntity>> getAttendanceByEmployee(
    String employeeId,
  ) async {
    final records = await _dbService.attendances
        .filter()
        .employeeIdEqualTo(employeeId.trim())
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortAttendance(records);
  }

  Future<List<AttendanceEntity>> getAttendanceByDate(DateTime date) async {
    final records = await _dbService.attendances
        .filter()
        .dateEqualTo(_dateKey(date))
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortAttendance(records);
  }

  Future<AttendanceEntity?> getAttendanceByEmployeeAndDate(
    String employeeId,
    DateTime date,
  ) {
    return _dbService.attendances
        .filter()
        .employeeIdEqualTo(employeeId.trim())
        .and()
        .dateEqualTo(_dateKey(date))
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<List<AttendanceEntity>> getAttendanceByMonth(
    String employeeId,
    int month,
    int year,
  ) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    final records = await _dbService.attendances
        .filter()
        .employeeIdEqualTo(employeeId.trim())
        .and()
        .dateBetween(_dateKey(start), _dateKey(end))
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortAttendance(records);
  }

  Future<List<AttendanceEntity>> getAllAttendance() async {
    final records = await _dbService.attendances
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortAttendance(records);
  }

  Stream<List<AttendanceEntity>> watchAttendanceByEmployee(String employeeId) {
    return _dbService.attendances
        .filter()
        .employeeIdEqualTo(employeeId.trim())
        .and()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map(_sortAttendance);
  }

  Future<void> markAttendance(AttendanceEntity attendance) async {
    final normalizedDate = _normalizeDateText(attendance.date);
    final existing = await _dbService.attendances
        .filter()
        .employeeIdEqualTo(attendance.employeeId.trim())
        .and()
        .dateEqualTo(normalizedDate)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();

    final entity = existing ?? AttendanceEntity();
    final isCorrection = existing != null;

    entity
      ..id = existing?.id ?? _ensureId(attendance)
      ..employeeId = attendance.employeeId.trim()
      ..date = normalizedDate
      ..checkInTime = _nullableTrim(attendance.checkInTime)
      ..checkOutTime = _nullableTrim(attendance.checkOutTime)
      ..status = _normalizeText(attendance.status, fallback: 'Absent')
      ..checkInLatitude = attendance.checkInLatitude
      ..checkInLongitude = attendance.checkInLongitude
      ..checkOutLatitude = attendance.checkOutLatitude
      ..checkOutLongitude = attendance.checkOutLongitude
      ..remarks = _nullableTrim(attendance.remarks)
      ..isManualEntry = isCorrection ? true : attendance.isManualEntry
      ..isOvertime = attendance.isOvertime
      ..markedAt = existing?.markedAt ?? attendance.markedAt ?? DateTime.now()
      ..isCorrected = isCorrection ? true : attendance.isCorrected
      ..overtimeHours = attendance.overtimeHours
      ..auditLog = _nullableTrim(attendance.auditLog);

    await _saveEntity(
      entity: entity,
      existing: existing,
      collectionName: CollectionRegistry.attendances,
      payload: entity.toJson(),
      persist: () async {
        await _dbService.attendances.put(entity);
      },
    );
  }

  Future<void> deleteAttendance(String id) async {
    final attendance = await _dbService.attendances
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (attendance == null) {
      return;
    }

    await _softDeleteEntity(
      entity: attendance,
      collectionName: CollectionRegistry.attendances,
      payload: attendance.toJson(),
      persist: () async {
        await _dbService.attendances.put(attendance);
      },
    );
  }

  Future<void> saveLeaveRequest(LeaveRequestEntity request) async {
    final id = _ensureId(request);
    final existing = await _dbService.leaveRequests.getById(id);

    request
      ..id = id
      ..employeeId = request.employeeId.trim()
      ..leaveType = _normalizeText(request.leaveType)
      ..startDate = _normalizeIsoText(
        request.startDate,
        fallback: DateTime.now(),
      )
      ..endDate = _normalizeIsoText(request.endDate, fallback: DateTime.now())
      ..reason = _nullableTrim(request.reason)
      ..status = _normalizeText(request.status, fallback: 'Pending')
      ..approvedBy = _nullableTrim(request.approvedBy)
      ..approvedAt = _nullableIso(request.approvedAt)
      ..rejectionReason = _nullableTrim(request.rejectionReason)
      ..requestedAt = _normalizeIsoText(
        request.requestedAt,
        fallback: DateTime.now(),
      );

    await _saveEntity(
      entity: request,
      existing: existing,
      collectionName: CollectionRegistry.leaveRequests,
      payload: request.toJson(),
      persist: () async {
        await _dbService.leaveRequests.put(request);
      },
    );
  }

  Future<List<LeaveRequestEntity>> getLeaveRequestsByEmployee(
    String employeeId,
  ) async {
    final requests = await _dbService.leaveRequests
        .filter()
        .employeeIdEqualTo(employeeId.trim())
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    requests.sort(
      (left, right) => right.requestedAt.compareTo(left.requestedAt),
    );
    return requests;
  }

  Future<List<LeaveRequestEntity>> getPendingLeaveRequests() async {
    final requests = await getAllLeaveRequests();
    return requests
        .where((request) => _statusKey(request.status) == 'pending')
        .toList(growable: false);
  }

  Future<List<LeaveRequestEntity>> getLeaveRequestsByStatus(
    String status,
  ) async {
    final statusKey = _statusKey(status);
    final requests = await getAllLeaveRequests();
    return requests
        .where((request) => _statusKey(request.status) == statusKey)
        .toList(growable: false);
  }

  Future<List<LeaveRequestEntity>> getAllLeaveRequests() async {
    final requests = await _dbService.leaveRequests
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
    requests.sort(
      (left, right) => right.requestedAt.compareTo(left.requestedAt),
    );
    return requests;
  }

  Stream<List<LeaveRequestEntity>> watchPendingLeaveRequests() {
    return _dbService.leaveRequests
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((requests) {
          final filtered = requests
              .where((request) => _statusKey(request.status) == 'pending')
              .toList(growable: false);
          filtered.sort(
            (left, right) => right.requestedAt.compareTo(left.requestedAt),
          );
          return filtered;
        });
  }

  Future<void> approveLeave(String id, String approvedBy) async {
    final request = await _dbService.leaveRequests
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (request == null) {
      return;
    }

    request
      ..status = 'Approved'
      ..approvedBy = _normalizeText(approvedBy, fallback: 'system')
      ..approvedAt = DateTime.now().toIso8601String();

    await _saveEntity(
      entity: request,
      existing: request,
      collectionName: CollectionRegistry.leaveRequests,
      payload: request.toJson(),
      persist: () async {
        await _dbService.leaveRequests.put(request);
      },
    );
  }

  Future<void> rejectLeave(String id, String reason) async {
    final request = await _dbService.leaveRequests
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (request == null) {
      return;
    }

    request
      ..status = 'Rejected'
      ..rejectionReason = _normalizeText(reason)
      ..approvedAt = null
      ..approvedBy = null;

    await _saveEntity(
      entity: request,
      existing: request,
      collectionName: CollectionRegistry.leaveRequests,
      payload: request.toJson(),
      persist: () async {
        await _dbService.leaveRequests.put(request);
      },
    );
  }

  Future<void> deleteLeaveRequest(String id) async {
    final request = await _dbService.leaveRequests
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (request == null) {
      return;
    }

    await _softDeleteEntity(
      entity: request,
      collectionName: CollectionRegistry.leaveRequests,
      payload: request.toJson(),
      persist: () async {
        await _dbService.leaveRequests.put(request);
      },
    );
  }

  Future<void> saveAdvance(AdvanceEntity advance) async {
    final id = _ensureId(advance);
    final existing = await _dbService.advances.getById(id);

    advance
      ..id = id
      ..employeeId = advance.employeeId.trim()
      ..type = _normalizeText(advance.type, fallback: 'Advance')
      ..status = _normalizeText(advance.status, fallback: 'Pending')
      ..requestDate = _normalizeIsoText(
        advance.requestDate,
        fallback: DateTime.now(),
      )
      ..approvedDate = _nullableIso(advance.approvedDate)
      ..approvedBy = _nullableTrim(advance.approvedBy)
      ..rejectionReason = _nullableTrim(advance.rejectionReason)
      ..purpose = _nullableTrim(advance.purpose)
      ..remarks = _nullableTrim(advance.remarks);

    await _saveEntity(
      entity: advance,
      existing: existing,
      collectionName: CollectionRegistry.advances,
      payload: advance.toJson(),
      persist: () async {
        await _dbService.advances.put(advance);
      },
    );
  }

  Future<List<AdvanceEntity>> getAdvancesByEmployee(String employeeId) async {
    final advances = await _dbService.advances
        .filter()
        .employeeIdEqualTo(employeeId.trim())
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    advances.sort(
      (left, right) => right.requestDate.compareTo(left.requestDate),
    );
    return advances;
  }

  Future<List<AdvanceEntity>> getPendingAdvances() async {
    final advances = await getAllAdvances();
    return advances
        .where((advance) => _statusKey(advance.status) == 'pending')
        .toList(growable: false);
  }

  Future<List<AdvanceEntity>> getAllAdvances() async {
    final advances = await _dbService.advances
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
    advances.sort(
      (left, right) => right.requestDate.compareTo(left.requestDate),
    );
    return advances;
  }

  Stream<List<AdvanceEntity>> watchAdvancesByEmployee(String employeeId) {
    return _dbService.advances
        .filter()
        .employeeIdEqualTo(employeeId.trim())
        .and()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((advances) {
          advances.sort(
            (left, right) => right.requestDate.compareTo(left.requestDate),
          );
          return advances;
        });
  }

  Stream<List<AdvanceEntity>> watchPendingAdvances() {
    return _dbService.advances
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((advances) {
          final filtered = advances
              .where((advance) => _statusKey(advance.status) == 'pending')
              .toList(growable: false);
          filtered.sort(
            (left, right) => right.requestDate.compareTo(left.requestDate),
          );
          return filtered;
        });
  }

  Future<void> approveAdvance(String id, String approvedBy) async {
    final advance = await _dbService.advances
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (advance == null) {
      return;
    }

    advance
      ..status = 'Approved'
      ..approvedBy = _normalizeText(approvedBy, fallback: 'system')
      ..approvedDate = DateTime.now().toIso8601String();

    await _saveEntity(
      entity: advance,
      existing: advance,
      collectionName: CollectionRegistry.advances,
      payload: advance.toJson(),
      persist: () async {
        await _dbService.advances.put(advance);
      },
    );
  }

  Future<void> rejectAdvance(String id, String reason) async {
    final advance = await _dbService.advances
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (advance == null) {
      return;
    }

    advance
      ..status = 'Rejected'
      ..rejectionReason = _normalizeText(reason)
      ..approvedDate = null
      ..approvedBy = null;

    await _saveEntity(
      entity: advance,
      existing: advance,
      collectionName: CollectionRegistry.advances,
      payload: advance.toJson(),
      persist: () async {
        await _dbService.advances.put(advance);
      },
    );
  }

  Future<void> recordEmiPayment(String id, double paidAmount) async {
    final advance = await _dbService.advances
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (advance == null) {
      return;
    }

    final nextPaidAmount = advance.paidAmount + paidAmount;
    advance
      ..paidAmount = nextPaidAmount
      ..status = nextPaidAmount >= advance.amount ? 'Cleared' : advance.status;

    await _saveEntity(
      entity: advance,
      existing: advance,
      collectionName: CollectionRegistry.advances,
      payload: advance.toJson(),
      persist: () async {
        await _dbService.advances.put(advance);
      },
    );
  }

  Future<void> deleteAdvance(String id) async {
    final advance = await _dbService.advances
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (advance == null) {
      return;
    }

    await _softDeleteEntity(
      entity: advance,
      collectionName: CollectionRegistry.advances,
      payload: advance.toJson(),
      persist: () async {
        await _dbService.advances.put(advance);
      },
    );
  }

  Future<void> savePayrollRecord(PayrollRecordEntity record) async {
    final id = _ensureId(record);
    final existing = await _dbService.payrollRecords.getById(id);

    record
      ..id = id
      ..employeeId = record.employeeId.trim()
      ..month = record.month.trim()
      ..generatedAt = _resolveDate(() => record.generatedAt, DateTime.now())
      ..status = _normalizeText(record.status, fallback: 'Draft')
      ..paymentReference = _nullableTrim(record.paymentReference);

    await _saveEntity(
      entity: record,
      existing: existing,
      collectionName: CollectionRegistry.payrollRecords,
      payload: record.toJson(),
      persist: () async {
        await _dbService.payrollRecords.put(record);
      },
    );
  }

  Future<List<PayrollRecordEntity>> getPayrollByEmployee(
    String employeeId,
  ) async {
    final records = await _dbService.payrollRecords
        .filter()
        .employeeIdEqualTo(employeeId.trim())
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    records.sort((left, right) => right.month.compareTo(left.month));
    return records;
  }

  Future<List<PayrollRecordEntity>> getPayrollByMonth(String month) async {
    final records = await _dbService.payrollRecords
        .filter()
        .monthEqualTo(month.trim())
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    records.sort((left, right) => left.employeeId.compareTo(right.employeeId));
    return records;
  }

  Future<PayrollRecordEntity?> getPayrollByEmployeeAndMonth(
    String employeeId,
    String month,
  ) {
    return _dbService.payrollRecords
        .filter()
        .employeeIdEqualTo(employeeId.trim())
        .and()
        .monthEqualTo(month.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<List<PayrollRecordEntity>> getAllPayrollRecords() async {
    final records = await _dbService.payrollRecords
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
    records.sort((left, right) {
      final monthCompare = right.month.compareTo(left.month);
      if (monthCompare != 0) {
        return monthCompare;
      }
      return left.employeeId.compareTo(right.employeeId);
    });
    return records;
  }

  Stream<List<PayrollRecordEntity>> watchPayrollByEmployee(String employeeId) {
    return _dbService.payrollRecords
        .filter()
        .employeeIdEqualTo(employeeId.trim())
        .and()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((records) {
          records.sort((left, right) => right.month.compareTo(left.month));
          return records;
        });
  }

  Future<void> markPayrollPaid(String id, String paymentReference) async {
    final record = await _dbService.payrollRecords
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (record == null) {
      return;
    }

    record
      ..status = 'Paid'
      ..paidAt = DateTime.now()
      ..paymentReference = paymentReference.trim();

    await _saveEntity(
      entity: record,
      existing: record,
      collectionName: CollectionRegistry.payrollRecords,
      payload: record.toJson(),
      persist: () async {
        await _dbService.payrollRecords.put(record);
      },
    );
  }

  Future<void> deletePayrollRecord(String id) async {
    final record = await _dbService.payrollRecords
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (record == null) {
      return;
    }

    await _softDeleteEntity(
      entity: record,
      collectionName: CollectionRegistry.payrollRecords,
      payload: record.toJson(),
      persist: () async {
        await _dbService.payrollRecords.put(record);
      },
    );
  }

  Future<void> savePerformanceReview(PerformanceReviewEntity review) async {
    final id = _ensureId(review);
    final existing = await _dbService.performanceReviews.getById(id);

    review
      ..id = id
      ..employeeId = review.employeeId.trim()
      ..reviewerId = review.reviewerId.trim()
      ..reviewPeriod = review.reviewPeriod.trim()
      ..reviewDate = _normalizeIsoText(
        review.reviewDate,
        fallback: DateTime.now(),
      )
      ..strengths = _nullableTrim(review.strengths)
      ..improvements = _nullableTrim(review.improvements)
      ..goals = _nullableTrim(review.goals)
      ..employeeComments = _nullableTrim(review.employeeComments)
      ..managerComments = _nullableTrim(review.managerComments)
      ..status = _normalizeText(review.status, fallback: 'Draft');

    await _saveEntity(
      entity: review,
      existing: existing,
      collectionName: CollectionRegistry.performanceReviews,
      payload: review.toJson(),
      persist: () async {
        await _dbService.performanceReviews.put(review);
      },
    );
  }

  Future<List<PerformanceReviewEntity>> getReviewsByEmployee(
    String employeeId,
  ) async {
    final reviews = await _dbService.performanceReviews
        .filter()
        .employeeIdEqualTo(employeeId.trim())
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    reviews.sort((left, right) => right.reviewDate.compareTo(left.reviewDate));
    return reviews;
  }

  Future<List<PerformanceReviewEntity>> getReviewsByPeriod(
    String reviewPeriod,
  ) async {
    final reviews = await _dbService.performanceReviews
        .filter()
        .reviewPeriodEqualTo(reviewPeriod.trim())
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    reviews.sort((left, right) => right.reviewDate.compareTo(left.reviewDate));
    return reviews;
  }

  Future<List<PerformanceReviewEntity>> getAllReviews() async {
    final reviews = await _dbService.performanceReviews
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
    reviews.sort((left, right) => right.reviewDate.compareTo(left.reviewDate));
    return reviews;
  }

  Stream<List<PerformanceReviewEntity>> watchReviewsByEmployee(
    String employeeId,
  ) {
    return _dbService.performanceReviews
        .filter()
        .employeeIdEqualTo(employeeId.trim())
        .and()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((reviews) {
          reviews.sort(
            (left, right) => right.reviewDate.compareTo(left.reviewDate),
          );
          return reviews;
        });
  }

  Future<void> deletePerformanceReview(String id) async {
    final review = await _dbService.performanceReviews
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (review == null) {
      return;
    }

    await _softDeleteEntity(
      entity: review,
      collectionName: CollectionRegistry.performanceReviews,
      payload: review.toJson(),
      persist: () async {
        await _dbService.performanceReviews.put(review);
      },
    );
  }

  Future<void> saveEmployeeDocument(EmployeeDocumentEntity document) async {
    final id = _ensureId(document);
    final existing = await _dbService.employeeDocuments.getById(id);

    document
      ..id = id
      ..employeeId = document.employeeId.trim()
      ..documentType = document.documentType.trim()
      ..documentName = document.documentName.trim()
      ..documentNumber = _nullableTrim(document.documentNumber)
      ..filePath = document.filePath.trim()
      ..cloudUrl = _nullableTrim(document.cloudUrl)
      ..expiryDate = _nullableIso(document.expiryDate)
      ..verifiedBy = _nullableTrim(document.verifiedBy)
      ..verifiedDate = _nullableIso(document.verifiedDate)
      ..remarks = _nullableTrim(document.remarks);

    await _saveEntity(
      entity: document,
      existing: existing,
      collectionName: CollectionRegistry.employeeDocuments,
      payload: _employeeDocumentSyncPayload(document),
      persist: () async {
        await _dbService.employeeDocuments.put(document);
      },
    );
  }

  Future<List<EmployeeDocumentEntity>> getDocumentsByEmployee(
    String employeeId,
  ) async {
    final documents = await _dbService.employeeDocuments
        .filter()
        .employeeIdEqualTo(employeeId.trim())
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    documents.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return documents;
  }

  Future<List<EmployeeDocumentEntity>> getExpiringDocuments(
    int daysAhead,
  ) async {
    final documents = await getAllDocuments();
    final threshold = DateTime.now().add(Duration(days: daysAhead));
    return documents
        .where((document) {
          final expiryDate = _tryParseIso(document.expiryDate);
          if (expiryDate == null) {
            return false;
          }
          return !expiryDate.isAfter(threshold);
        })
        .toList(growable: false);
  }

  Future<List<EmployeeDocumentEntity>> getAllDocuments() async {
    final documents = await _dbService.employeeDocuments
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
    documents.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return documents;
  }

  Stream<List<EmployeeDocumentEntity>> watchDocumentsByEmployee(
    String employeeId,
  ) {
    return _dbService.employeeDocuments
        .filter()
        .employeeIdEqualTo(employeeId.trim())
        .and()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((documents) {
          documents.sort(
            (left, right) => right.updatedAt.compareTo(left.updatedAt),
          );
          return documents;
        });
  }

  Future<void> verifyDocument(String id, String verifiedBy) async {
    final document = await _dbService.employeeDocuments
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (document == null) {
      return;
    }

    document
      ..isVerified = true
      ..verifiedBy = _normalizeText(verifiedBy, fallback: 'system')
      ..verifiedDate = DateTime.now().toIso8601String();

    await _saveEntity(
      entity: document,
      existing: document,
      collectionName: CollectionRegistry.employeeDocuments,
      payload: _employeeDocumentSyncPayload(document),
      persist: () async {
        await _dbService.employeeDocuments.put(document);
      },
    );
  }

  Future<void> deleteDocument(String id) async {
    final document = await _dbService.employeeDocuments
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (document == null) {
      return;
    }

    await _softDeleteEntity(
      entity: document,
      collectionName: CollectionRegistry.employeeDocuments,
      payload: _employeeDocumentSyncPayload(document),
      persist: () async {
        await _dbService.employeeDocuments.put(document);
      },
    );
  }

  Future<void> saveHoliday(HolidayEntity holiday) async {
    final id = _ensureId(holiday);
    final existing = await _dbService.holidays.getById(id);

    holiday
      ..id = id
      ..name = holiday.name.trim()
      ..date = _normalizeDateText(holiday.date)
      ..description = _nullableTrim(holiday.description);

    await _saveEntity(
      entity: holiday,
      existing: existing,
      collectionName: CollectionRegistry.holidays,
      payload: holiday.toJson(),
      persist: () async {
        await _dbService.holidays.put(holiday);
      },
    );
  }

  Future<List<HolidayEntity>> getAllHolidays() async {
    final holidays = await _dbService.holidays
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
    holidays.sort((left, right) => left.date.compareTo(right.date));
    return holidays;
  }

  Future<List<HolidayEntity>> getHolidaysByYear(int year) async {
    final holidays = await _dbService.holidays
        .filter()
        .dateBetween('$year-01-01', '$year-12-31')
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    holidays.sort((left, right) => left.date.compareTo(right.date));
    return holidays;
  }

  Future<bool> isHoliday(DateTime date) async {
    final holiday = await _dbService.holidays
        .filter()
        .dateEqualTo(_dateKey(date))
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    return holiday != null;
  }

  Stream<List<HolidayEntity>> watchAllHolidays() {
    return _dbService.holidays
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((holidays) {
          holidays.sort((left, right) => left.date.compareTo(right.date));
          return holidays;
        });
  }

  Future<void> deleteHoliday(String id) async {
    final holiday = await _dbService.holidays
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (holiday == null) {
      return;
    }

    await _softDeleteEntity(
      entity: holiday,
      collectionName: CollectionRegistry.holidays,
      payload: holiday.toJson(),
      persist: () async {
        await _dbService.holidays.put(holiday);
      },
    );
  }

  Future<void> _saveEntity({
    required BaseEntity entity,
    required BaseEntity? existing,
    required String collectionName,
    required Map<String, dynamic> payload,
    required Future<void> Function() persist,
  }) async {
    await _stampForSync(entity, existing);
    await _dbService.db.writeTxn(() async {
      await persist();
    });
    await _enqueue(
      collectionName,
      entity.id,
      existing == null ? 'create' : 'update',
      payload,
    );
    await _syncIfOnline();
  }

  Future<void> _softDeleteEntity({
    required BaseEntity entity,
    required String collectionName,
    required Map<String, dynamic> payload,
    required Future<void> Function() persist,
  }) async {
    entity
      ..isDeleted = true
      ..deletedAt = DateTime.now();

    await _stampDeleted(entity);
    await _dbService.db.writeTxn(() async {
      await persist();
    });
    await _enqueue(collectionName, entity.id, 'delete', payload);
    await _syncIfOnline();
  }

  Future<void> _stampForSync(BaseEntity entity, BaseEntity? existing) async {
    entity
      ..updatedAt = DateTime.now()
      ..deletedAt = entity.isDeleted ? entity.deletedAt : null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();
  }

  Future<void> _stampDeleted(BaseEntity entity) async {
    entity
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();
  }

  Future<void> _enqueue(
    String collectionName,
    String documentId,
    String operation,
    Map<String, dynamic> payload,
  ) {
    return _syncQueueService.addToQueue(
      collectionName: collectionName,
      documentId: documentId,
      operation: operation,
      payload: payload,
    );
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  Map<String, dynamic> _employeeDocumentSyncPayload(
    EmployeeDocumentEntity document,
  ) {
    final payload = document.toJson();
    payload.remove('filePath');
    return payload;
  }

  List<AttendanceEntity> _sortAttendance(List<AttendanceEntity> records) {
    records.sort((left, right) => right.date.compareTo(left.date));
    return records;
  }

  String _requiredId(BaseEntity entity, String message) {
    final current = _currentId(entity);
    if (current.isEmpty) {
      throw ArgumentError(message);
    }
    return current;
  }

  String _ensureId(BaseEntity entity) {
    final current = _currentId(entity);
    if (current.isNotEmpty) {
      return current;
    }
    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
  }

  String _currentId(BaseEntity entity) {
    try {
      return entity.id.trim();
    } catch (_) {
      return '';
    }
  }

  DateTime _resolveDate(DateTime Function() reader, DateTime fallback) {
    try {
      return reader();
    } catch (_) {
      return fallback;
    }
  }

  int _safeWeekday(int weekday) {
    if (weekday < 1 || weekday > 7) {
      return DateTime.sunday;
    }
    return weekday;
  }

  String _normalizeText(String? value, {String fallback = ''}) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? fallback : normalized;
  }

  String? _nullableTrim(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  String _normalizeIsoText(String? value, {required DateTime fallback}) {
    return _tryParseIso(value)?.toIso8601String() ?? fallback.toIso8601String();
  }

  String? _nullableIso(String? value) {
    return _tryParseIso(value)?.toIso8601String();
  }

  DateTime? _tryParseIso(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return DateTime.tryParse(normalized);
  }

  String _normalizeDateText(String value) {
    final parsed = _tryParseIso(value);
    if (parsed != null) {
      return _dateKey(parsed);
    }

    final trimmed = value.trim();
    if (trimmed.length >= 10) {
      return trimmed.substring(0, 10);
    }
    return _dateKey(DateTime.now());
  }

  String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T').first;
  }

  String _statusKey(String value) => value.trim().toLowerCase();
}
