import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../services/database_service.dart';
import '../../../data/local/entities/attendance_entity.dart';
import '../../../data/local/base_entity.dart';
import '../models/attendance_model.dart';
import '../../../data/local/entities/employee_entity.dart';

import '../../../services/offline_first_service.dart';
import '../../../core/firebase/firebase_config.dart';
import '../../../services/field_encryption_service.dart';

class AttendanceService extends OfflineFirstService with ChangeNotifier {
  final DatabaseService _dbService;
  final FieldEncryptionService _fieldEncryption =
      FieldEncryptionService.instance;

  static const double _geoMagnitude = 1.0;
  static const int _attendanceSchemaVersion = 2;
  static const String _attendanceSchemaKey = 'attendance_schema_version';
  Future<void>? _schemaEnsureFuture;

  AttendanceService(FirebaseServices firebase, this._dbService)
    : super(firebase, _dbService);

  Future<void> _ensureAttendanceSchema() {
    _schemaEnsureFuture ??= _runAttendanceSchemaMigration();
    return _schemaEnsureFuture!;
  }

  Future<void> _runAttendanceSchemaMigration() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_attendanceSchemaKey) ?? 1;
    if (stored >= _attendanceSchemaVersion) return;

    final existing = await _dbService.attendances.where().findAll();
    if (existing.isNotEmpty) {
      final now = DateTime.now();
      await _dbService.db.writeTxn(() async {
        for (final entry in existing) {
          entry
            ..updatedAt = now
            ..syncStatus = SyncStatus.pending;
        }
        await _dbService.attendances.putAll(existing);
      });
      debugPrint(
        'Attendance schema migration preserved ${existing.length} local records (marked pending for safe resync).',
      );
    }

    await prefs.setInt(_attendanceSchemaKey, _attendanceSchemaVersion);
  }

  @override
  String get localStorageKey => 'local_attendances';

  @override
  bool get useIsar => true;

  @override
  Future<void> performSync(
    String action,
    String collection,
    Map<String, dynamic> data,
  ) async {
    final firestore = db;
    if (firestore == null) return;

    // Use default crud unless logic requires specific handling
    await super.performSync(action, collection, data);
  }

  /// Mark check-in for an employee
  Future<Attendance> checkIn({
    required String employeeId,
    double? latitude,
    double? longitude,
  }) async {
    await _ensureAttendanceSchema();
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Fetch employee for shift info
    final emp = await _dbService.employees
        .filter()
        .employeeIdEqualTo(employeeId)
        .findFirst();

    // Check if already checked in today
    final existing = await _dbService.attendances
        .filter()
        .employeeIdEqualTo(employeeId)
        .dateEqualTo(today)
        .findFirst();

    if (existing != null && existing.checkInTime != null) {
      throw Exception('Already checked in today');
    }

    final id = existing?.id ?? const Uuid().v4();

    // Late threshold calculation using employee's specific shift start
    bool isLate = false;
    if (emp != null) {
      final shiftStart = DateTime(
        now.year,
        now.month,
        now.day,
        emp.shiftStartHour ?? 9,
        emp.shiftStartMinute ?? 0,
      );
      // Late if checked in after shift start (allowing a 15-min grace period)
      isLate = now.isAfter(shiftStart.add(const Duration(minutes: 15)));
    } else {
      // Default to 10 AM if employee not found locally
      isLate = now.hour >= 10;
    }

    final entity = existing ?? AttendanceEntity()
      ..id = id
      ..employeeId = employeeId
      ..date = today;

    entity
      ..checkInTime = now.toIso8601String()
      ..checkInLatitude = latitude
      ..checkInLongitude = longitude
      ..status = isLate ? 'Late' : 'Present'
      ..isOvertime = false
      ..overtimeHours = 0
      ..markedAt = entity.markedAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    final syncPayload = {
      'id': entity.id,
      'employeeId': entity.employeeId,
      'date': entity.date,
      'checkInTime': entity.checkInTime,
      'checkInLatitude': entity.checkInLatitude,
      'checkInLongitude': entity.checkInLongitude,
      'status': entity.status,
      'isOvertime': entity.isOvertime,
      'overtimeHours': entity.overtimeHours,
      'markedAt': entity.markedAt?.toIso8601String(),
      'isCorrected': entity.isCorrected,
      'auditLog': entity.auditLog,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };

    _encryptAttendanceEntity(entity);

    await _dbService.db.writeTxn(() async {
      await _dbService.attendances.put(entity);
    });

    // Queue Sync
    await syncToFirebase('set', syncPayload, collectionName: 'attendances');

    notifyListeners();
    return _toDomain(entity);
  }

  /// Mark check-out for an employee
  Future<Attendance> checkOut({
    required String employeeId,
    double? latitude,
    double? longitude,
  }) async {
    await _ensureAttendanceSchema();
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final existing = await _dbService.attendances
        .filter()
        .employeeIdEqualTo(employeeId)
        .dateEqualTo(today)
        .findFirst();

    if (existing == null || existing.checkInTime == null) {
      throw Exception('Not checked in today');
    }

    if (existing.checkOutTime != null) {
      throw Exception('Already checked out');
    }

    final checkIn = DateTime.parse(existing.checkInTime!);
    final workedDuration = now.difference(checkIn);
    final workedHours = workedDuration.inMinutes / 60.0;

    // Overtime: Assume standard 8-hour shift. Anything beyond 9 hours (including 1h break) is OT.
    // Or simpler: anything beyond 8 hours is OT. Use 8.0 as standard.
    double otHours = 0.0;
    if (workedHours > 8.0) {
      otHours = workedHours - 8.0;
    }

    existing
      ..checkOutTime = now.toIso8601String()
      ..checkOutLatitude = latitude
      ..checkOutLongitude = longitude
      ..status = workedHours < 4 ? 'HalfDay' : existing.status
      ..isOvertime =
          otHours >
          0.5 // Threshold for marking OT e.g. 30 mins
      ..overtimeHours = otHours
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    final syncPayload = {
      'id': existing.id,
      'checkOutTime': existing.checkOutTime,
      'checkOutLatitude': existing.checkOutLatitude,
      'checkOutLongitude': existing.checkOutLongitude,
      'status': existing.status,
      'isOvertime': existing.isOvertime,
      'overtimeHours': existing.overtimeHours,
      'markedAt': existing.markedAt?.toIso8601String(),
      'isCorrected': existing.isCorrected,
      'auditLog': existing.auditLog,
      'updatedAt': existing.updatedAt.toIso8601String(),
    };

    _encryptAttendanceEntity(existing);

    await _dbService.db.writeTxn(() async {
      await _dbService.attendances.put(existing);
    });

    // Queue Sync
    await syncToFirebase('update', syncPayload, collectionName: 'attendances');

    notifyListeners();
    return _toDomain(existing);
  }

  /// Get today's attendance status for an employee
  Future<Attendance?> getTodayAttendance(String employeeId) async {
    await _ensureAttendanceSchema();
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final entity = await _dbService.attendances
        .filter()
        .employeeIdEqualTo(employeeId)
        .dateEqualTo(today)
        .findFirst();

    return entity != null ? _toDomain(entity) : null;
  }

  /// Get attendance for a date range
  Future<List<Attendance>> getAttendanceByDateRange(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await _ensureAttendanceSchema();
    final entities = await _dbService.attendances
        .filter()
        .employeeIdEqualTo(employeeId)
        .findAll();

    return entities
        .where((e) {
          final date = DateTime.parse(e.date);
          return !date.isBefore(startDate) && !date.isAfter(endDate);
        })
        .map(_toDomain)
        .toList();
  }

  /// Get monthly summary
  Future<AttendanceSummary> getMonthlySummary(
    String employeeId,
    int month,
    int year,
  ) async {
    await _ensureAttendanceSchema();
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final records = await getAttendanceByDateRange(
      employeeId,
      startDate,
      endDate,
    );

    int present = 0,
        absent = 0,
        late = 0,
        halfDay = 0,
        onLeave = 0,
        woWorked = 0;

    int scheduledWeeklyOffs = 0;
    int weeklyOffDay = DateTime.sunday; // Default to Sunday

    // Fetch employee for WO policy
    final emp = await _dbService.employees
        .filter()
        .employeeIdEqualTo(employeeId)
        .findFirst();
    if (emp != null) {
      if (emp.weeklyOffDay != 0) {
        weeklyOffDay = emp.weeklyOffDay;
      }
    }

    // Calculate scheduled WO days
    for (int i = 1; i <= endDate.day; i++) {
      final date = DateTime(year, month, i);
      if (date.weekday == weeklyOffDay) {
        scheduledWeeklyOffs++;
      }
    }

    for (var r in records) {
      if (r.status == 'WeeklyOffWorked') {
        woWorked++;
        continue;
      }
      switch (r.status) {
        case 'Present':
          present++;
          break;
        case 'Late':
          late++;
          present++;
          break;
        case 'HalfDay':
          halfDay++;
          break;
        case 'OnLeave':
          onLeave++;
          break;
        case 'Absent':
          absent++;
          break;
      }
    }

    return AttendanceSummary(
      employeeId: employeeId,
      month: month,
      year: year,
      presentDays: present,
      absentDays: absent,
      lateDays: late,
      halfDays: halfDay,
      leaveDays: onLeave,
      weeklyOffWorkedDays: woWorked,
      weeklyOffDays: scheduledWeeklyOffs,
      totalWorkingDays: endDate.day - scheduledWeeklyOffs - onLeave,
    );
  }

  Future<List<Attendance>> getAttendancesForMonth(DateTime month) async {
    await _ensureAttendanceSchema();
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);
    final startStr =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endStr =
        '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    final entities = await _dbService.attendances
        .filter()
        .dateBetween(startStr, endStr)
        .findAll();

    return entities.map(_toDomain).toList();
  }

  /// Mark manual attendance (admin only)
  Future<void> markManualAttendance({
    required String employeeId,
    required DateTime date,
    required String status,
    String? remarks,
    bool isOvertime = false,
    double? overtimeHours,
  }) async {
    await _ensureAttendanceSchema();
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final now = DateTime.now();

    var existing = await _dbService.attendances
        .filter()
        .employeeIdEqualTo(employeeId)
        .dateEqualTo(dateStr)
        .findFirst();

    final entity = existing ?? AttendanceEntity()
      ..id = const Uuid().v4()
      ..employeeId = employeeId
      ..date = dateStr;

    entity
      ..status = status
      ..remarks = remarks
      ..isManualEntry = true
      ..isOvertime = isOvertime
      ..overtimeHours = overtimeHours
      ..markedAt = entity.markedAt ?? now
      ..isCorrected = entity.isCorrected
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    final syncPayload = {
      'id': entity.id,
      'employeeId': entity.employeeId,
      'date': entity.date,
      'status': entity.status,
      'remarks': entity.remarks,
      'isManualEntry': entity.isManualEntry,
      'isOvertime': entity.isOvertime,
      'overtimeHours': entity.overtimeHours,
      'markedAt': entity.markedAt?.toIso8601String(),
      'isCorrected': entity.isCorrected,
      'auditLog': entity.auditLog,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };

    _encryptAttendanceEntity(entity);

    await _dbService.db.writeTxn(() async {
      await _dbService.attendances.put(entity);
    });

    await syncToFirebase('set', syncPayload, collectionName: 'attendances');

    notifyListeners();
  }

  Future<Attendance> markDailyAttendance({
    required String employeeId,
    required DateTime date,
    required String status,
    String? remarks,
    bool isOvertime = false,
    double? overtimeHours,
  }) async {
    await _ensureAttendanceSchema();
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final now = DateTime.now();

    final existing = await _dbService.attendances
        .filter()
        .employeeIdEqualTo(employeeId)
        .dateEqualTo(dateStr)
        .findFirst();

    if (existing != null) {
      throw Exception('Attendance already marked for this day');
    }

    final entity = AttendanceEntity()
      ..id = '${employeeId}_$dateStr'
      ..employeeId = employeeId
      ..date = dateStr;

    entity
      ..status = status
      ..remarks = remarks
      ..isManualEntry = true
      ..isOvertime = isOvertime
      ..overtimeHours = overtimeHours
      ..markedAt = now
      ..isCorrected = false
      ..auditLog = null
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    final syncPayload = {
      'id': entity.id,
      'employeeId': entity.employeeId,
      'date': entity.date,
      'status': entity.status,
      'remarks': entity.remarks,
      'isManualEntry': entity.isManualEntry,
      'isOvertime': entity.isOvertime,
      'overtimeHours': entity.overtimeHours,
      'markedAt': entity.markedAt?.toIso8601String(),
      'isCorrected': entity.isCorrected,
      'auditLog': entity.auditLog,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };

    _encryptAttendanceEntity(entity);

    await _dbService.db.writeTxn(() async {
      await _dbService.attendances.put(entity);
    });

    await syncToFirebase('set', syncPayload, collectionName: 'attendances');

    notifyListeners();
    return _toDomain(entity);
  }

  Future<Attendance> correctDailyAttendance({
    required String employeeId,
    required DateTime date,
    required String status,
    required String userId,
    required String userName,
    String? remarks,
    bool forceUnlock = false,
  }) async {
    await _ensureAttendanceSchema();
    const validStatuses = [
      'Present',
      'Absent',
      'Late',
      'HalfDay',
      'OnLeave',
      'WeeklyOffWorked',
      'WeeklyOff',
    ];
    if (!validStatuses.contains(status)) {
      throw Exception('Invalid correction status');
    }
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final now = DateTime.now();

    final existing = await _dbService.attendances
        .filter()
        .employeeIdEqualTo(employeeId)
        .dateEqualTo(dateStr)
        .findFirst();

    if (existing == null) {
      throw Exception('Attendance not found for this day');
    }

    final originalMarkedAt = existing.markedAt ?? existing.updatedAt;
    final lockAt = originalMarkedAt.add(const Duration(hours: 24));

    // Lock logic: If > 24h and not forced, deny.
    if (now.isAfter(lockAt) && !forceUnlock) {
      throw Exception(
        'Attendance is permanently locked. Admin override required.',
      );
    }

    final wasStatus = existing.status;
    if (wasStatus == status && existing.remarks == remarks) {
      return _toDomain(existing);
    }

    // Create Audit Log
    final auditEntry = AttendanceAudit(
      editedBy: '$userName ($userId)',
      editedAt: now,
      oldStatus: wasStatus,
      newStatus: status,
      reason: remarks ?? 'Correction',
    );

    List<dynamic> logs = [];
    if (existing.auditLog != null && existing.auditLog!.isNotEmpty) {
      try {
        logs = jsonDecode(existing.auditLog!);
      } catch (e) {
        debugPrint('Error decoding attendance audit logs: $e');
      }
    }
    logs.add(auditEntry.toMap());

    existing
      ..status = status
      ..remarks = remarks
      ..markedAt =
          originalMarkedAt // Keep original marked time
      ..isCorrected = true
      ..auditLog = jsonEncode(logs)
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    final syncPayload = {
      'id': existing.id,
      'employeeId': existing.employeeId,
      'date': existing.date,
      'status': existing.status,
      'remarks': existing.remarks,
      'isManualEntry': existing.isManualEntry,
      'isOvertime': existing.isOvertime,
      'overtimeHours': existing.overtimeHours,
      'markedAt': existing.markedAt?.toIso8601String(),
      'isCorrected': existing.isCorrected,
      'auditLog': existing.auditLog,
      'updatedAt': existing.updatedAt.toIso8601String(),
    };

    _encryptAttendanceEntity(existing);

    await _dbService.db.writeTxn(() async {
      await _dbService.attendances.put(existing);
    });

    await syncToFirebase('update', syncPayload, collectionName: 'attendances');

    notifyListeners();
    return _toDomain(existing);
  }

  Attendance _toDomain(AttendanceEntity e) {
    // Decrypt if needed
    final checkInLat = e.checkInLatitude != null
        ? _fieldEncryption.decryptDouble(
            e.checkInLatitude!,
            _attendanceCtx(e, 'checkInLat'),
            magnitude: _geoMagnitude,
          )
        : null;
    final checkInLng = e.checkInLongitude != null
        ? _fieldEncryption.decryptDouble(
            e.checkInLongitude!,
            _attendanceCtx(e, 'checkInLng'),
            magnitude: _geoMagnitude,
          )
        : null;
    final checkOutLat = e.checkOutLatitude != null
        ? _fieldEncryption.decryptDouble(
            e.checkOutLatitude!,
            _attendanceCtx(e, 'checkOutLat'),
            magnitude: _geoMagnitude,
          )
        : null;
    final checkOutLng = e.checkOutLongitude != null
        ? _fieldEncryption.decryptDouble(
            e.checkOutLongitude!,
            _attendanceCtx(e, 'checkOutLng'),
            magnitude: _geoMagnitude,
          )
        : null;

    List<AttendanceAudit> audits = [];
    if (e.auditLog != null) {
      try {
        final List<dynamic> list = jsonDecode(e.auditLog!);
        audits = list.map((m) => AttendanceAudit.fromMap(m)).toList();
      } catch (e) {
        debugPrint('Error decoding attendance audit entity logs: $e');
      }
    }

    return Attendance(
      id: e.id,
      employeeId: e.employeeId,
      date: DateTime.parse(e.date),
      updatedAt: e.updatedAt,
      markedAt: e.markedAt,
      checkInTime: e.checkInTime != null
          ? DateTime.parse(e.checkInTime!)
          : null,
      checkOutTime: e.checkOutTime != null
          ? DateTime.parse(e.checkOutTime!)
          : null,
      status: e.status,
      checkInLatitude: checkInLat,
      checkInLongitude: checkInLng,
      checkOutLatitude: checkOutLat,
      checkOutLongitude: checkOutLng,
      remarks: e.remarks == null
          ? null
          : _fieldEncryption.decryptString(
              e.remarks!,
              _attendanceCtx(e, 'remarks'),
            ),
      isManualEntry: e.isManualEntry,
      isOvertime: e.isOvertime,
      isCorrected: e.isCorrected,
      overtimeHours: e.overtimeHours,
      auditLog: audits,
    );
  }

  String _attendanceCtx(AttendanceEntity e, String field) {
    return 'attendance:${e.id}:${e.date}:$field';
  }

  void _encryptAttendanceEntity(AttendanceEntity e) {
    if (!_fieldEncryption.isEnabled) return;
    if (e.checkInLatitude != null) {
      e.checkInLatitude = _fieldEncryption.encryptDouble(
        e.checkInLatitude!,
        _attendanceCtx(e, 'checkInLat'),
        magnitude: _geoMagnitude,
      );
    }
    if (e.checkInLongitude != null) {
      e.checkInLongitude = _fieldEncryption.encryptDouble(
        e.checkInLongitude!,
        _attendanceCtx(e, 'checkInLng'),
        magnitude: _geoMagnitude,
      );
    }
    if (e.checkOutLatitude != null) {
      e.checkOutLatitude = _fieldEncryption.encryptDouble(
        e.checkOutLatitude!,
        _attendanceCtx(e, 'checkOutLat'),
        magnitude: _geoMagnitude,
      );
    }
    if (e.checkOutLongitude != null) {
      e.checkOutLongitude = _fieldEncryption.encryptDouble(
        e.checkOutLongitude!,
        _attendanceCtx(e, 'checkOutLng'),
        magnitude: _geoMagnitude,
      );
    }
    if (e.remarks != null) {
      e.remarks = _fieldEncryption.encryptString(
        e.remarks!,
        _attendanceCtx(e, 'remarks'),
      );
    }
  }
}
