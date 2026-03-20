import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/data/local/entities/advance_entity.dart';
import 'package:flutter_app/data/local/entities/attendance_entity.dart';
import 'package:flutter_app/data/local/entities/employee_document_entity.dart';
import 'package:flutter_app/data/local/entities/employee_entity.dart';
import 'package:flutter_app/data/local/entities/leave_request_entity.dart';
import 'package:flutter_app/data/local/entities/payroll_record_entity.dart';
import 'package:flutter_app/data/local/entities/performance_review_entity.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/services/field_encryption_service.dart';
import 'package:flutter_app/services/outbox_codec.dart';
import 'package:flutter_app/services/sync_common_utils.dart';
import 'package:flutter_app/utils/app_logger.dart';
import 'package:isar/isar.dart';

class HrSyncDelegate {
  final DatabaseService _dbService;
  final SyncCommonUtils _utils;
  final Future<void> Function({
    required String entityType,
    required SyncOperation operation,
    required int recordCount,
    required int durationMs,
    required bool success,
    String? errorMessage,
  })
  _recordMetric;
  final void Function(String step, Object error) _markSyncIssue;

  HrSyncDelegate({
    required DatabaseService dbService,
    required SyncCommonUtils utils,
    required Future<void> Function({
      required String entityType,
      required SyncOperation operation,
      required int recordCount,
      required int durationMs,
      required bool success,
      String? errorMessage,
    })
    recordMetric,
    required void Function(String step, Object error) markSyncIssue,
  }) : _dbService = dbService,
       _utils = utils,
       _recordMetric = recordMetric,
       _markSyncIssue = markSyncIssue;

  Future<void> syncAllHr(
    firestore.FirebaseFirestore db, {
    required String? firebaseUid,
    bool isManagerOrAdmin = false,
    bool forceRefresh = false,
  }) async {
    await syncEmployees(db, forceRefresh: forceRefresh);
    await syncAttendances(db, firebaseUid: firebaseUid, isManagerOrAdmin: isManagerOrAdmin, forceRefresh: forceRefresh);
    await syncLeaveRequests(db, firebaseUid: firebaseUid, isManagerOrAdmin: isManagerOrAdmin, forceRefresh: forceRefresh);
    await syncAdvances(db, firebaseUid: firebaseUid, isManagerOrAdmin: isManagerOrAdmin, forceRefresh: forceRefresh);
    await syncPerformanceReviews(db, firebaseUid: firebaseUid, isManagerOrAdmin: isManagerOrAdmin, forceRefresh: forceRefresh);
    await syncEmployeeDocuments(db, firebaseUid: firebaseUid, isManagerOrAdmin: isManagerOrAdmin, forceRefresh: forceRefresh);
    await syncPayrolls(db, firebaseUid: firebaseUid, isManagerOrAdmin: isManagerOrAdmin, forceRefresh: forceRefresh);
  }

  Map<String, dynamic> _employeeToJson(EmployeeEntity entity) {
    return <String, dynamic>{
      'id': entity.id,
      'employeeId': entity.employeeId,
      'name': entity.name,
      'roleType': entity.roleType,
      'linkedUserId': entity.linkedUserId,
      'department': entity.department,
      'mobile': entity.mobile,
      'isActive': entity.isActive,
      'createdAt': entity.createdAt.toIso8601String(),
      'weeklyOffDay': entity.weeklyOffDay,
      'isDeleted': entity.isDeleted,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _leaveToJson(LeaveRequestEntity entity) {
    return <String, dynamic>{
      'id': entity.id,
      'employeeId': entity.employeeId,
      'leaveType': entity.leaveType,
      'startDate': entity.startDate,
      'endDate': entity.endDate,
      'totalDays': entity.totalDays,
      'reason': entity.reason,
      'status': entity.status,
      'approvedBy': entity.approvedBy,
      'approvedAt': entity.approvedAt,
      'rejectionReason': entity.rejectionReason,
      'requestedAt': entity.requestedAt,
      'isDeleted': entity.isDeleted,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _advanceToJson(AdvanceEntity entity) {
    return <String, dynamic>{
      'id': entity.id,
      'employeeId': entity.employeeId,
      'type': entity.type,
      'amount': entity.amount,
      'paidAmount': entity.paidAmount,
      'status': entity.status,
      'requestDate': entity.requestDate,
      'approvedDate': entity.approvedDate,
      'approvedBy': entity.approvedBy,
      'rejectionReason': entity.rejectionReason,
      'purpose': entity.purpose,
      'emiMonths': entity.emiMonths,
      'emiAmount': entity.emiAmount,
      'remarks': entity.remarks,
      'isDeleted': entity.isDeleted,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _performanceReviewToJson(
    PerformanceReviewEntity entity,
  ) {
    return <String, dynamic>{
      'id': entity.id,
      'employeeId': entity.employeeId,
      'reviewerId': entity.reviewerId,
      'reviewPeriod': entity.reviewPeriod,
      'reviewDate': entity.reviewDate,
      'qualityScore': entity.qualityScore,
      'productivityScore': entity.productivityScore,
      'attendanceScore': entity.attendanceScore,
      'teamworkScore': entity.teamworkScore,
      'initiativeScore': entity.initiativeScore,
      'overallRating': entity.overallRating,
      'strengths': entity.strengths,
      'improvements': entity.improvements,
      'goals': entity.goals,
      'employeeComments': entity.employeeComments,
      'managerComments': entity.managerComments,
      'status': entity.status,
      'isDeleted': entity.isDeleted,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _employeeDocumentToJson(EmployeeDocumentEntity entity) {
    return <String, dynamic>{
      'id': entity.id,
      'employeeId': entity.employeeId,
      'documentType': entity.documentType,
      'documentName': entity.documentName,
      'documentNumber': entity.documentNumber,
      'filePath': entity.filePath,
      'cloudUrl': entity.cloudUrl,
      'expiryDate': entity.expiryDate,
      'isVerified': entity.isVerified,
      'verifiedBy': entity.verifiedBy,
      'verifiedDate': entity.verifiedDate,
      'remarks': entity.remarks,
      'isDeleted': entity.isDeleted,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _buildAttendancePushPayload(
    AttendanceEntity entity,
    FieldEncryptionService encryption,
  ) {
    final ctxPrefix = 'attendance:${entity.id}:${entity.date}:';
    final checkInLat = entity.checkInLatitude != null
        ? (encryption.isEnabled
              ? encryption.decryptDouble(
                  entity.checkInLatitude!,
                  '${ctxPrefix}checkInLat',
                  magnitude: 1.0,
                )
              : entity.checkInLatitude)
        : null;
    final checkInLng = entity.checkInLongitude != null
        ? (encryption.isEnabled
              ? encryption.decryptDouble(
                  entity.checkInLongitude!,
                  '${ctxPrefix}checkInLng',
                  magnitude: 1.0,
                )
              : entity.checkInLongitude)
        : null;
    final checkOutLat = entity.checkOutLatitude != null
        ? (encryption.isEnabled
              ? encryption.decryptDouble(
                  entity.checkOutLatitude!,
                  '${ctxPrefix}checkOutLat',
                  magnitude: 1.0,
                )
              : entity.checkOutLatitude)
        : null;
    final checkOutLng = entity.checkOutLongitude != null
        ? (encryption.isEnabled
              ? encryption.decryptDouble(
                  entity.checkOutLongitude!,
                  '${ctxPrefix}checkOutLng',
                  magnitude: 1.0,
                )
              : entity.checkOutLongitude)
        : null;
    final remarks = entity.remarks != null
        ? (encryption.isEnabled
              ? encryption.decryptString(entity.remarks!, '${ctxPrefix}remarks')
              : entity.remarks)
        : null;

    return <String, dynamic>{
      'id': entity.id,
      'employeeId': entity.employeeId,
      'date': entity.date,
      'checkInTime': entity.checkInTime,
      'checkInLatitude': checkInLat,
      'checkInLongitude': checkInLng,
      'checkOutTime': entity.checkOutTime,
      'checkOutLatitude': checkOutLat,
      'checkOutLongitude': checkOutLng,
      'status': entity.status,
      'remarks': remarks,
      'isManualEntry': entity.isManualEntry,
      'isOvertime': entity.isOvertime,
      'overtimeHours': entity.overtimeHours,
      'markedAt': entity.markedAt?.toIso8601String(),
      'isCorrected': entity.isCorrected,
      'auditLog': entity.auditLog,
      'isDeleted': entity.isDeleted,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };
  }

  Future<void> syncPayrolls(
    firestore.FirebaseFirestore db, {
    required String? firebaseUid,
    bool isManagerOrAdmin = false,
    bool forceRefresh = false,
  }) async {
    final fieldEncryption = FieldEncryptionService.instance;
    final cutoff = DateTime.now().subtract(const Duration(days: 60));

    try {
      var query = db
          .collection(CollectionRegistry.payrollRecords)
          .where('generatedAt', isGreaterThan: cutoff.toIso8601String());

      // UID-based filtering for ownership-sensitive data
      if (!isManagerOrAdmin) {
        assert(firebaseUid != null && firebaseUid.isNotEmpty);
        query = query.where('employeeId', isEqualTo: firebaseUid);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        final ids = snapshot.docs.map((doc) {
          final data = doc.data();
          return '${data['employeeId']}_${data['month']}';
        }).toList();

        final existingRecordsList = await _dbService.payrollRecords
            .filter()
            .anyOf(ids, (q, String id) => q.idEqualTo(id))
            .findAll();
        final existingRecordsMap = {
          for (final record in existingRecordsList) record.id: record,
        };

        final recordsToPut = <PayrollRecordEntity>[];

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final employeeId = data['employeeId'];
          final month = data['month'];
          final id = '${employeeId}_$month';

          final existing = existingRecordsMap[id];

          if (existing == null) {
            final entity = PayrollRecordEntity()
              ..id = id
              ..updatedAt = DateTime.now()
              ..employeeId = employeeId
              ..month = month
              ..generatedAt = _utils.parseRemoteDate(data['generatedAt'])
              ..totalHours = (data['totalHours'] as num?)?.toDouble() ?? 0.0
              ..baseSalary = (data['baseSalary'] as num?)?.toDouble() ?? 0.0
              ..netSalary = (data['netSalary'] as num?)?.toDouble() ?? 0.0
              ..status = data['status']
              ..syncStatus = SyncStatus.synced;

            if (fieldEncryption.isEnabled) {
              final ctxPrefix = 'payroll:$employeeId:$month:';
              entity.totalHours = fieldEncryption.encryptDouble(
                entity.totalHours,
                '${ctxPrefix}totalHours',
                magnitude: 1e3,
              );
              entity.baseSalary = fieldEncryption.encryptDouble(
                entity.baseSalary,
                '${ctxPrefix}baseSalary',
                magnitude: 1e5,
              );
              entity.totalOvertimeHours = fieldEncryption.encryptDouble(
                entity.totalOvertimeHours,
                '${ctxPrefix}totalOvertimeHours',
                magnitude: 1e3,
              );
              entity.bonuses = fieldEncryption.encryptDouble(
                entity.bonuses,
                '${ctxPrefix}bonuses',
                magnitude: 1e5,
              );
              entity.deductions = fieldEncryption.encryptDouble(
                entity.deductions,
                '${ctxPrefix}deductions',
                magnitude: 1e5,
              );
              entity.netSalary = fieldEncryption.encryptDouble(
                entity.netSalary,
                '${ctxPrefix}netSalary',
                magnitude: 1e5,
              );
              if (entity.paymentReference != null) {
                entity.paymentReference = fieldEncryption.encryptString(
                  entity.paymentReference!,
                  '${ctxPrefix}paymentRef',
                );
              }
            }

            recordsToPut.add(entity);
          } else {
            if (existing.status != data['status']) {
              existing.status = data['status'];
              existing.syncStatus = SyncStatus.synced;
              recordsToPut.add(existing);
            }
          }
        }

        if (recordsToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.payrollRecords.putAll(recordsToPut);
          });
        }
      }
    } catch (e) {
      AppLogger.error('Sync Payroll Error', error: e, tag: 'Sync');
      _markSyncIssue('payroll pull', e);
    }
  }

  Future<void> syncAttendances(
    firestore.FirebaseFirestore db, {
    required String? firebaseUid,
    bool isManagerOrAdmin = false,
    bool forceRefresh = false,
  }) async {
    final fieldEncryption = FieldEncryptionService.instance;

    final pushStopwatch = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;
    try {
      final pending = await _dbService.attendances
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      final queueIds = pending
          .map(
            (entity) => OutboxCodec.buildQueueId(
              'attendances',
              {'id': entity.id},
              explicitRecordKey: entity.id,
            ),
          )
          .toList(growable: false);
      final queuedRecords = await _dbService.syncQueue.getAll(
        queueIds.map(fastHash).toList(growable: false),
      );
      final queuedIsarIdByEntityId = <String, int>{};
      for (var i = 0; i < queueIds.length; i++) {
        final queued = queuedRecords[i];
        if (queued != null) {
          queuedIsarIdByEntityId[pending[i].id] = queued.isarId;
        }
      }
      final attendancesToUpdate = <AttendanceEntity>[];
      final queueIdsToDelete = <int>[];

      for (final entity in pending) {
        try {
          final payload = _buildAttendancePushPayload(entity, fieldEncryption);
          await db
              .collection(CollectionRegistry.attendances)
              .doc(entity.id)
              .set(payload, firestore.SetOptions(merge: true));
          if (entity.syncStatus != SyncStatus.conflict) {
            entity.syncStatus = SyncStatus.synced;
            entity.updatedAt = DateTime.now();
            attendancesToUpdate.add(entity);
          }
          final queuedIsarId = queuedIsarIdByEntityId[entity.id];
          if (queuedIsarId != null) {
            queueIdsToDelete.add(queuedIsarId);
          }
          pushedCount++;
        } catch (e) {
          _markSyncIssue('attendances push', e);
          pushError = e.toString();
        }
      }
      if (attendancesToUpdate.isNotEmpty || queueIdsToDelete.isNotEmpty) {
        await _dbService.db.writeTxn(() async {
          if (attendancesToUpdate.isNotEmpty) {
            await _dbService.attendances.putAll(attendancesToUpdate);
          }
          if (queueIdsToDelete.isNotEmpty) {
            await _dbService.syncQueue.deleteAll(queueIdsToDelete);
          }
        });
      }
      pushSuccess = true;
    } catch (e) {
      pushError = e.toString();
      _markSyncIssue('attendances push', e);
    } finally {
      pushStopwatch.stop();
      await _recordMetric(
        entityType: 'attendances',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: pushStopwatch.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final pullStopwatch = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;
    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('attendances');
      firestore.Query<Map<String, dynamic>> query = db
          .collection(CollectionRegistry.attendances)
          .where('updatedAt', isNull: false);

      // UID-based filtering for ownership-sensitive data
      if (!isManagerOrAdmin) {
        assert(firebaseUid != null && firebaseUid.isNotEmpty);
        query = query.where('employeeId', isEqualTo: firebaseUid);
      }

      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);

        final ids = snapshot.docs.map((doc) => doc.id).toList();
        final existingRecords = await _dbService.attendances.getAllById(ids);
        final existingMap = {
          for (int i = 0; i < ids.length; i++)
            if (existingRecords[i] != null) ids[i]: existingRecords[i]!,
        };

        final attendancesToPut = <AttendanceEntity>[];

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final id = doc.id;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) {
            maxUpdatedAt = updatedAt;
          }

          final existing = existingMap[id];
          if (existing != null) {
            await _utils.detectAndFlagConflict(
              localEntity: existing,
              serverData: data,
              entityType: 'attendances',
              entityId: id,
              localToJson: (e) {
                final attendance = e;
                return <String, dynamic>{
                  'id': attendance.id,
                  'employeeId': attendance.employeeId,
                  'date': attendance.date,
                  'checkInTime': attendance.checkInTime,
                  'checkOutTime': attendance.checkOutTime,
                  'status': attendance.status,
                  'remarks': attendance.remarks,
                  'isManualEntry': attendance.isManualEntry,
                  'isOvertime': attendance.isOvertime,
                  'overtimeHours': attendance.overtimeHours,
                  'markedAt': attendance.markedAt?.toIso8601String(),
                  'isCorrected': attendance.isCorrected,
                  'auditLog': attendance.auditLog,
                  'updatedAt': attendance.updatedAt.toIso8601String(),
                  'isDeleted': attendance.isDeleted,
                };
              },
            );
            continue;
          }

          final employeeId = data['employeeId'] as String?;
          final date = data['date'] as String?;
          var local = existing;
          if (local == null) {
            if (employeeId == null || date == null) {
              continue;
            }
            local = AttendanceEntity()
              ..id = id
              ..employeeId = employeeId
              ..date = date;
          }

          local.isDeleted = data['isDeleted'] == true;
          local.updatedAt = updatedAt;
          local.syncStatus = SyncStatus.synced;

          if (!local.isDeleted) {
            local.checkInTime = data['checkInTime']?.toString();
            local.checkInLatitude = (data['checkInLatitude'] as num?)
                ?.toDouble();
            local.checkInLongitude = (data['checkInLongitude'] as num?)
                ?.toDouble();
            local.checkOutTime = data['checkOutTime']?.toString();
            local.checkOutLatitude = (data['checkOutLatitude'] as num?)
                ?.toDouble();
            local.checkOutLongitude = (data['checkOutLongitude'] as num?)
                ?.toDouble();
            local.status = data['status']?.toString() ?? local.status;
            local.remarks = data['remarks']?.toString();
            local.isManualEntry = data['isManualEntry'] as bool? ?? false;
            local.isOvertime = data['isOvertime'] as bool? ?? local.isOvertime;
            local.isCorrected =
                data['isCorrected'] as bool? ?? local.isCorrected;
            local.markedAt = data['markedAt'] != null
                ? DateTime.tryParse(data['markedAt'].toString()) ??
                      local.markedAt
                : local.markedAt;
            local.overtimeHours =
                (data['overtimeHours'] as num?)?.toDouble() ??
                local.overtimeHours;
            local.auditLog = data['auditLog']?.toString();

            if (fieldEncryption.isEnabled) {
              final ctxPrefix = 'attendance:${local.id}:${local.date}:';
              if (local.checkInLatitude != null) {
                local.checkInLatitude = fieldEncryption.encryptDouble(
                  local.checkInLatitude!,
                  '${ctxPrefix}checkInLat',
                  magnitude: 1.0,
                );
              }
              if (local.checkInLongitude != null) {
                local.checkInLongitude = fieldEncryption.encryptDouble(
                  local.checkInLongitude!,
                  '${ctxPrefix}checkInLng',
                  magnitude: 1.0,
                );
              }
              if (local.checkOutLatitude != null) {
                local.checkOutLatitude = fieldEncryption.encryptDouble(
                  local.checkOutLatitude!,
                  '${ctxPrefix}checkOutLat',
                  magnitude: 1.0,
                );
              }
              if (local.checkOutLongitude != null) {
                local.checkOutLongitude = fieldEncryption.encryptDouble(
                  local.checkOutLongitude!,
                  '${ctxPrefix}checkOutLng',
                  magnitude: 1.0,
                );
              }
              if (local.remarks != null) {
                local.remarks = fieldEncryption.encryptString(
                  local.remarks!,
                  '${ctxPrefix}remarks',
                );
              }
            }
          }

          attendancesToPut.add(local);
        }

        if (attendancesToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.attendances.putAll(attendancesToPut);
          });
        }
        pulledCount = snapshot.docs.length;
        await _utils.setLastSyncTimestamp('attendances', maxUpdatedAt);
      }
      pullSuccess = true;
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        AppLogger.warning(
          'Skipping attendances sync: Permission denied',
          tag: 'Sync',
        );
        pullSuccess = true;
      } else {
        AppLogger.error('Sync Attendances Error', error: e, tag: 'Sync');
        _markSyncIssue('attendances pull', e);
        pullError = e.toString();
      }
    } finally {
      pullStopwatch.stop();
      await _recordMetric(
        entityType: 'attendances',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: pullStopwatch.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncEmployees(
    firestore.FirebaseFirestore db, {
    bool forceRefresh = false,
  }) async {
    final pushStopwatch = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;
    try {
      final pending = await _dbService.employees
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      final queueIds = pending
          .map(
            (entity) => OutboxCodec.buildQueueId(
              'employees',
              {'id': entity.id},
              explicitRecordKey: entity.id,
            ),
          )
          .toList(growable: false);
      final queuedRecords = await _dbService.syncQueue.getAll(
        queueIds.map(fastHash).toList(growable: false),
      );
      final queuedIsarIdByEntityId = <String, int>{};
      for (var i = 0; i < queueIds.length; i++) {
        final queued = queuedRecords[i];
        if (queued != null) {
          queuedIsarIdByEntityId[pending[i].id] = queued.isarId;
        }
      }
      final employeesToUpdate = <EmployeeEntity>[];
      final queueIdsToDelete = <int>[];
      for (final employee in pending) {
        try {
          final payload = _employeeToJson(employee);
          await db
              .collection(CollectionRegistry.employees)
              .doc(employee.employeeId)
              .set(payload, firestore.SetOptions(merge: true));
          if (employee.syncStatus != SyncStatus.conflict) {
            employee.syncStatus = SyncStatus.synced;
            employee.updatedAt = DateTime.now();
            employeesToUpdate.add(employee);
          }
          final queuedIsarId = queuedIsarIdByEntityId[employee.id];
          if (queuedIsarId != null) {
            queueIdsToDelete.add(queuedIsarId);
          }
          pushedCount++;
        } catch (e) {
          _markSyncIssue('employees push', e);
          pushError = e.toString();
        }
      }
      if (employeesToUpdate.isNotEmpty || queueIdsToDelete.isNotEmpty) {
        await _dbService.db.writeTxn(() async {
          if (employeesToUpdate.isNotEmpty) {
            await _dbService.employees.putAll(employeesToUpdate);
          }
          if (queueIdsToDelete.isNotEmpty) {
            await _dbService.syncQueue.deleteAll(queueIdsToDelete);
          }
        });
      }
      pushSuccess = true;
    } catch (e) {
      pushError = e.toString();
      _markSyncIssue('employees push', e);
    } finally {
      pushStopwatch.stop();
      await _recordMetric(
        entityType: 'employees',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: pushStopwatch.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final pullStopwatch = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;
    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('employees');
      firestore.Query query = db.collection(CollectionRegistry.employees);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }
      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        var maxUpdatedAt = lastSync ?? DateTime(2000);

        final employeeIds = snapshot.docs
            .map(
              (doc) =>
                  (doc.data() as Map<String, dynamic>)['employeeId']
                      ?.toString() ??
                  doc.id,
            )
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        final existingEmployees = await _dbService.employees
            .filter()
            .anyOf(employeeIds, (q, String id) => q.employeeIdEqualTo(id))
            .findAll();
        final existingMap = {
          for (final emp in existingEmployees) emp.employeeId: emp,
        };

        final employeesToPut = <EmployeeEntity>[];

        for (final doc in snapshot.docs) {
          final data = Map<String, dynamic>.from(
            doc.data() as Map<String, dynamic>,
          );
          final employeeId = (data['employeeId']?.toString() ?? doc.id).trim();
          if (employeeId.isEmpty) continue;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) {
            maxUpdatedAt = updatedAt;
          }

          final existing = existingMap[employeeId];
          if (existing != null) {
            await _utils.detectAndFlagConflict(
              entityId: existing.id,
              entityType: 'employees',
              serverData: data,
              localEntity: existing,
              localToJson: (e) => _employeeToJson(e),
            );
            continue;
          }

          final entity = existing ?? EmployeeEntity();
          final remoteId = data['id']?.toString().trim();
          entity.id = (remoteId != null && remoteId.isNotEmpty)
              ? remoteId
              : employeeId;
          entity.employeeId = employeeId;
          entity.name = data['name']?.toString() ?? existing?.name ?? '';
          entity.roleType =
              data['roleType']?.toString() ?? existing?.roleType ?? 'worker';
          entity.linkedUserId = data['linkedUserId']?.toString();
          entity.department =
              data['department']?.toString() ?? existing?.department ?? '';
          entity.mobile = data['mobile']?.toString() ?? existing?.mobile ?? '';
          entity.isActive = data['isActive'] as bool? ?? true;
          entity.weeklyOffDay =
              (data['weeklyOffDay'] as num?)?.toInt() ?? DateTime.sunday;
          entity.createdAt = _utils.parseRemoteDate(
            data['createdAt'],
            fallback: existing?.createdAt ?? updatedAt,
          );
          entity.isDeleted = data['isDeleted'] == true;
          entity.updatedAt = updatedAt;
          entity.syncStatus = SyncStatus.synced;

          employeesToPut.add(entity);
        }

        if (employeesToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.employees.putAll(employeesToPut);
          });
        }
        pulledCount = snapshot.docs.length;
        await _utils.setLastSyncTimestamp('employees', maxUpdatedAt);
      }
      pullSuccess = true;
    } catch (e) {
      pullError = e.toString();
      _markSyncIssue('employees pull', e);
    } finally {
      pullStopwatch.stop();
      await _recordMetric(
        entityType: 'employees',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: pullStopwatch.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncLeaveRequests(
    firestore.FirebaseFirestore db, {
    required String? firebaseUid,
    bool isManagerOrAdmin = false,
    bool forceRefresh = false,
  }) async {
    final pushStopwatch = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;
    try {
      final pending = await _dbService.leaveRequests
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      final queueIds = pending
          .map(
            (entity) => OutboxCodec.buildQueueId(
              'leave_requests',
              {'id': entity.id},
              explicitRecordKey: entity.id,
            ),
          )
          .toList(growable: false);
      final queuedRecords = await _dbService.syncQueue.getAll(
        queueIds.map(fastHash).toList(growable: false),
      );
      final queuedIsarIdByEntityId = <String, int>{};
      for (var i = 0; i < queueIds.length; i++) {
        final queued = queuedRecords[i];
        if (queued != null) {
          queuedIsarIdByEntityId[pending[i].id] = queued.isarId;
        }
      }
      final leavesToUpdate = <LeaveRequestEntity>[];
      final queueIdsToDelete = <int>[];
      for (final leave in pending) {
        try {
          final payload = _leaveToJson(leave);
          await db
              .collection(CollectionRegistry.leaveRequests)
              .doc(leave.id)
              .set(payload, firestore.SetOptions(merge: true));
          if (leave.syncStatus != SyncStatus.conflict) {
            leave.syncStatus = SyncStatus.synced;
            leave.updatedAt = DateTime.now();
            leavesToUpdate.add(leave);
          }
          final queuedIsarId = queuedIsarIdByEntityId[leave.id];
          if (queuedIsarId != null) {
            queueIdsToDelete.add(queuedIsarId);
          }
          pushedCount++;
        } catch (e) {
          _markSyncIssue('leave_requests push', e);
          pushError = e.toString();
        }
      }
      if (leavesToUpdate.isNotEmpty || queueIdsToDelete.isNotEmpty) {
        await _dbService.db.writeTxn(() async {
          if (leavesToUpdate.isNotEmpty) {
            await _dbService.leaveRequests.putAll(leavesToUpdate);
          }
          if (queueIdsToDelete.isNotEmpty) {
            await _dbService.syncQueue.deleteAll(queueIdsToDelete);
          }
        });
      }
      pushSuccess = true;
    } catch (e) {
      pushError = e.toString();
      _markSyncIssue('leave_requests push', e);
    } finally {
      pushStopwatch.stop();
      await _recordMetric(
        entityType: 'leave_requests',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: pushStopwatch.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final pullStopwatch = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;
    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('leave_requests');
      firestore.Query query = db.collection(CollectionRegistry.leaveRequests);

      // UID-based filtering for ownership-sensitive data
      if (!isManagerOrAdmin) {
        assert(firebaseUid != null && firebaseUid.isNotEmpty);
        query = query.where('employeeId', isEqualTo: firebaseUid);
      }
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }
      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        var maxUpdatedAt = lastSync ?? DateTime(2000);

        final ids = snapshot.docs
            .map(
              (doc) =>
                  (doc.data() as Map<String, dynamic>)['id']?.toString() ??
                  doc.id,
            )
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        final existingRecords = await _dbService.leaveRequests.getAllById(ids);
        final existingMap = {
          for (int i = 0; i < ids.length; i++)
            if (existingRecords[i] != null) ids[i]: existingRecords[i]!,
        };

        final entitiesToPut = <LeaveRequestEntity>[];

        for (final doc in snapshot.docs) {
          final data = Map<String, dynamic>.from(
            doc.data() as Map<String, dynamic>,
          );
          final id = (data['id']?.toString() ?? doc.id).trim();
          if (id.isEmpty) continue;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) {
            maxUpdatedAt = updatedAt;
          }

          final existing = existingMap[id];
          if (existing != null) {
            await _utils.detectAndFlagConflict(
              entityId: id,
              entityType: 'leave_requests',
              serverData: data,
              localEntity: existing,
              localToJson: (e) => _leaveToJson(e),
            );
            continue;
          }

          final entity = existing ?? LeaveRequestEntity();
          entity.id = id;
          entity.employeeId =
              data['employeeId']?.toString() ?? existing?.employeeId ?? '';
          entity.leaveType =
              data['leaveType']?.toString() ?? existing?.leaveType ?? '';
          entity.startDate =
              data['startDate']?.toString() ?? existing?.startDate ?? '';
          entity.endDate =
              data['endDate']?.toString() ?? existing?.endDate ?? '';
          entity.totalDays =
              (data['totalDays'] as num?)?.toInt() ?? existing?.totalDays ?? 0;
          entity.reason = data['reason']?.toString();
          entity.status =
              data['status']?.toString() ?? existing?.status ?? 'Pending';
          entity.approvedBy = data['approvedBy']?.toString();
          entity.approvedAt = data['approvedAt']?.toString();
          entity.rejectionReason = data['rejectionReason']?.toString();
          entity.requestedAt =
              data['requestedAt']?.toString() ??
              existing?.requestedAt ??
              updatedAt.toIso8601String();
          entity.isDeleted = data['isDeleted'] == true;
          entity.updatedAt = updatedAt;
          entity.syncStatus = SyncStatus.synced;

          entitiesToPut.add(entity);
        }

        if (entitiesToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.leaveRequests.putAll(entitiesToPut);
          });
        }
        pulledCount = snapshot.docs.length;
        await _utils.setLastSyncTimestamp('leave_requests', maxUpdatedAt);
      }
      pullSuccess = true;
    } catch (e) {
      pullError = e.toString();
      _markSyncIssue('leave_requests pull', e);
    } finally {
      pullStopwatch.stop();
      await _recordMetric(
        entityType: 'leave_requests',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: pullStopwatch.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncAdvances(
    firestore.FirebaseFirestore db, {
    required String? firebaseUid,
    bool isManagerOrAdmin = false,
    bool forceRefresh = false,
  }) async {
    final pushStopwatch = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;
    try {
      final pending = await _dbService.advances
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      final queueIds = pending
          .map(
            (entity) => OutboxCodec.buildQueueId(
              'advances',
              {'id': entity.id},
              explicitRecordKey: entity.id,
            ),
          )
          .toList(growable: false);
      final queuedRecords = await _dbService.syncQueue.getAll(
        queueIds.map(fastHash).toList(growable: false),
      );
      final queuedIsarIdByEntityId = <String, int>{};
      for (var i = 0; i < queueIds.length; i++) {
        final queued = queuedRecords[i];
        if (queued != null) {
          queuedIsarIdByEntityId[pending[i].id] = queued.isarId;
        }
      }
      final advancesToUpdate = <AdvanceEntity>[];
      final queueIdsToDelete = <int>[];
      for (final advance in pending) {
        try {
          final payload = _advanceToJson(advance);
          await db
              .collection(CollectionRegistry.advances)
              .doc(advance.id)
              .set(payload, firestore.SetOptions(merge: true));
          if (advance.syncStatus != SyncStatus.conflict) {
            advance.syncStatus = SyncStatus.synced;
            advance.updatedAt = DateTime.now();
            advancesToUpdate.add(advance);
          }
          final queuedIsarId = queuedIsarIdByEntityId[advance.id];
          if (queuedIsarId != null) {
            queueIdsToDelete.add(queuedIsarId);
          }
          pushedCount++;
        } catch (e) {
          _markSyncIssue('advances push', e);
          pushError = e.toString();
        }
      }
      if (advancesToUpdate.isNotEmpty || queueIdsToDelete.isNotEmpty) {
        await _dbService.db.writeTxn(() async {
          if (advancesToUpdate.isNotEmpty) {
            await _dbService.advances.putAll(advancesToUpdate);
          }
          if (queueIdsToDelete.isNotEmpty) {
            await _dbService.syncQueue.deleteAll(queueIdsToDelete);
          }
        });
      }
      pushSuccess = true;
    } catch (e) {
      pushError = e.toString();
      _markSyncIssue('advances push', e);
    } finally {
      pushStopwatch.stop();
      await _recordMetric(
        entityType: 'advances',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: pushStopwatch.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final pullStopwatch = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;
    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('advances');
      firestore.Query query = db.collection(CollectionRegistry.advances);

      // UID-based filtering for ownership-sensitive data
      if (!isManagerOrAdmin) {
        assert(firebaseUid != null && firebaseUid.isNotEmpty);
        query = query.where('employeeId', isEqualTo: firebaseUid);
      }
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }
      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        var maxUpdatedAt = lastSync ?? DateTime(2000);

        final ids = snapshot.docs
            .map(
              (doc) =>
                  (doc.data() as Map<String, dynamic>)['id']?.toString() ??
                  doc.id,
            )
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        final existingRecords = await _dbService.advances.getAllById(ids);
        final existingMap = {
          for (int i = 0; i < ids.length; i++)
            if (existingRecords[i] != null) ids[i]: existingRecords[i]!,
        };

        final entitiesToPut = <AdvanceEntity>[];

        for (final doc in snapshot.docs) {
          final data = Map<String, dynamic>.from(
            doc.data() as Map<String, dynamic>,
          );
          final id = (data['id']?.toString() ?? doc.id).trim();
          if (id.isEmpty) continue;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) {
            maxUpdatedAt = updatedAt;
          }

          final existing = existingMap[id];
          if (existing != null) {
            await _utils.detectAndFlagConflict(
              entityId: id,
              entityType: 'advances',
              serverData: data,
              localEntity: existing,
              localToJson: (e) => _advanceToJson(e),
            );
            continue;
          }

          final entity = existing ?? AdvanceEntity();
          entity.id = id;
          entity.employeeId =
              data['employeeId']?.toString() ?? existing?.employeeId ?? '';
          entity.type = data['type']?.toString() ?? existing?.type ?? 'Advance';
          entity.amount =
              (data['amount'] as num?)?.toDouble() ?? existing?.amount ?? 0.0;
          entity.paidAmount =
              (data['paidAmount'] as num?)?.toDouble() ??
              existing?.paidAmount ??
              0.0;
          entity.status =
              data['status']?.toString() ?? existing?.status ?? 'Pending';
          entity.requestDate =
              data['requestDate']?.toString() ??
              existing?.requestDate ??
              updatedAt.toIso8601String();
          entity.approvedDate = data['approvedDate']?.toString();
          entity.approvedBy = data['approvedBy']?.toString();
          entity.rejectionReason = data['rejectionReason']?.toString();
          entity.purpose = data['purpose']?.toString();
          entity.emiMonths = (data['emiMonths'] as num?)?.toInt();
          entity.emiAmount = (data['emiAmount'] as num?)?.toDouble();
          entity.remarks = data['remarks']?.toString();
          entity.isDeleted = data['isDeleted'] == true;
          entity.updatedAt = updatedAt;
          entity.syncStatus = SyncStatus.synced;

          entitiesToPut.add(entity);
        }

        if (entitiesToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.advances.putAll(entitiesToPut);
          });
        }
        pulledCount = snapshot.docs.length;
        await _utils.setLastSyncTimestamp('advances', maxUpdatedAt);
      }
      pullSuccess = true;
    } catch (e) {
      pullError = e.toString();
      _markSyncIssue('advances pull', e);
    } finally {
      pullStopwatch.stop();
      await _recordMetric(
        entityType: 'advances',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: pullStopwatch.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncPerformanceReviews(
    firestore.FirebaseFirestore db, {
    required String? firebaseUid,
    bool isManagerOrAdmin = false,
    bool forceRefresh = false,
  }) async {
    final pushStopwatch = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;
    try {
      final pending = await _dbService.performanceReviews
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      final queueIds = pending
          .map(
            (entity) => OutboxCodec.buildQueueId(
              'performance_reviews',
              {'id': entity.id},
              explicitRecordKey: entity.id,
            ),
          )
          .toList(growable: false);
      final queuedRecords = await _dbService.syncQueue.getAll(
        queueIds.map(fastHash).toList(growable: false),
      );
      final queuedIsarIdByEntityId = <String, int>{};
      for (var i = 0; i < queueIds.length; i++) {
        final queued = queuedRecords[i];
        if (queued != null) {
          queuedIsarIdByEntityId[pending[i].id] = queued.isarId;
        }
      }
      final reviewsToUpdate = <PerformanceReviewEntity>[];
      final queueIdsToDelete = <int>[];
      for (final review in pending) {
        try {
          final payload = _performanceReviewToJson(review);
          await db
              .collection(CollectionRegistry.performanceReviews)
              .doc(review.id)
              .set(payload, firestore.SetOptions(merge: true));
          if (review.syncStatus != SyncStatus.conflict) {
            review.syncStatus = SyncStatus.synced;
            review.updatedAt = DateTime.now();
            reviewsToUpdate.add(review);
          }
          final queuedIsarId = queuedIsarIdByEntityId[review.id];
          if (queuedIsarId != null) {
            queueIdsToDelete.add(queuedIsarId);
          }
          pushedCount++;
        } catch (e) {
          _markSyncIssue('performance_reviews push', e);
          pushError = e.toString();
        }
      }
      if (reviewsToUpdate.isNotEmpty || queueIdsToDelete.isNotEmpty) {
        await _dbService.db.writeTxn(() async {
          if (reviewsToUpdate.isNotEmpty) {
            await _dbService.performanceReviews.putAll(reviewsToUpdate);
          }
          if (queueIdsToDelete.isNotEmpty) {
            await _dbService.syncQueue.deleteAll(queueIdsToDelete);
          }
        });
      }
      pushSuccess = true;
    } catch (e) {
      pushError = e.toString();
      _markSyncIssue('performance_reviews push', e);
    } finally {
      pushStopwatch.stop();
      await _recordMetric(
        entityType: 'performance_reviews',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: pushStopwatch.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final pullStopwatch = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;
    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('performance_reviews');
      firestore.Query query = db.collection(CollectionRegistry.performanceReviews);

      // UID-based filtering for ownership-sensitive data
      if (!isManagerOrAdmin) {
        assert(firebaseUid != null && firebaseUid.isNotEmpty);
        query = query.where('employeeId', isEqualTo: firebaseUid);
      }
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }
      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        var maxUpdatedAt = lastSync ?? DateTime(2000);

        final ids = snapshot.docs
            .map(
              (doc) =>
                  (doc.data() as Map<String, dynamic>)['id']?.toString() ??
                  doc.id,
            )
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        final existingRecords = await _dbService.performanceReviews.getAllById(
          ids,
        );
        final existingMap = {
          for (int i = 0; i < ids.length; i++)
            if (existingRecords[i] != null) ids[i]: existingRecords[i]!,
        };

        final entitiesToPut = <PerformanceReviewEntity>[];

        for (final doc in snapshot.docs) {
          final data = Map<String, dynamic>.from(
            doc.data() as Map<String, dynamic>,
          );
          final id = (data['id']?.toString() ?? doc.id).trim();
          if (id.isEmpty) continue;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) {
            maxUpdatedAt = updatedAt;
          }

          final existing = existingMap[id];
          if (existing != null) {
            await _utils.detectAndFlagConflict(
              entityId: id,
              entityType: 'performance_reviews',
              serverData: data,
              localEntity: existing,
              localToJson: (e) => _performanceReviewToJson(e),
            );
            continue;
          }

          final entity = existing ?? PerformanceReviewEntity();
          entity.id = id;
          entity.employeeId =
              data['employeeId']?.toString() ?? existing?.employeeId ?? '';
          entity.reviewerId =
              data['reviewerId']?.toString() ?? existing?.reviewerId ?? '';
          entity.reviewPeriod =
              data['reviewPeriod']?.toString() ?? existing?.reviewPeriod ?? '';
          entity.reviewDate =
              data['reviewDate']?.toString() ??
              existing?.reviewDate ??
              updatedAt.toIso8601String();
          entity.qualityScore = (data['qualityScore'] as num?)?.toInt();
          entity.productivityScore = (data['productivityScore'] as num?)
              ?.toInt();
          entity.attendanceScore = (data['attendanceScore'] as num?)?.toInt();
          entity.teamworkScore = (data['teamworkScore'] as num?)?.toInt();
          entity.initiativeScore = (data['initiativeScore'] as num?)?.toInt();
          entity.overallRating = (data['overallRating'] as num?)?.toDouble();
          entity.strengths = data['strengths']?.toString();
          entity.improvements = data['improvements']?.toString();
          entity.goals = data['goals']?.toString();
          entity.employeeComments = data['employeeComments']?.toString();
          entity.managerComments = data['managerComments']?.toString();
          entity.status =
              data['status']?.toString() ?? existing?.status ?? 'Draft';
          entity.isDeleted = data['isDeleted'] == true;
          entity.updatedAt = updatedAt;
          entity.syncStatus = SyncStatus.synced;

          entitiesToPut.add(entity);
        }

        if (entitiesToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.performanceReviews.putAll(entitiesToPut);
          });
        }
        pulledCount = snapshot.docs.length;
        await _utils.setLastSyncTimestamp('performance_reviews', maxUpdatedAt);
      }
      pullSuccess = true;
    } catch (e) {
      pullError = e.toString();
      _markSyncIssue('performance_reviews pull', e);
    } finally {
      pullStopwatch.stop();
      await _recordMetric(
        entityType: 'performance_reviews',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: pullStopwatch.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncEmployeeDocuments(
    firestore.FirebaseFirestore db, {
    required String? firebaseUid,
    bool isManagerOrAdmin = false,
    bool forceRefresh = false,
  }) async {
    final pushStopwatch = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;
    try {
      final pending = await _dbService.employeeDocuments
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      final queueIds = pending
          .map(
            (entity) => OutboxCodec.buildQueueId(
              'employee_documents',
              {'id': entity.id},
              explicitRecordKey: entity.id,
            ),
          )
          .toList(growable: false);
      final queuedRecords = await _dbService.syncQueue.getAll(
        queueIds.map(fastHash).toList(growable: false),
      );
      final queuedIsarIdByEntityId = <String, int>{};
      for (var i = 0; i < queueIds.length; i++) {
        final queued = queuedRecords[i];
        if (queued != null) {
          queuedIsarIdByEntityId[pending[i].id] = queued.isarId;
        }
      }
      final documentsToUpdate = <EmployeeDocumentEntity>[];
      final queueIdsToDelete = <int>[];
      for (final document in pending) {
        try {
          final payload = _employeeDocumentToJson(document);
          await db
              .collection(CollectionRegistry.employeeDocuments)
              .doc(document.id)
              .set(payload, firestore.SetOptions(merge: true));
          if (document.syncStatus != SyncStatus.conflict) {
            document.syncStatus = SyncStatus.synced;
            document.updatedAt = DateTime.now();
            documentsToUpdate.add(document);
          }
          final queuedIsarId = queuedIsarIdByEntityId[document.id];
          if (queuedIsarId != null) {
            queueIdsToDelete.add(queuedIsarId);
          }
          pushedCount++;
        } catch (e) {
          _markSyncIssue('employee_documents push', e);
          pushError = e.toString();
        }
      }
      if (documentsToUpdate.isNotEmpty || queueIdsToDelete.isNotEmpty) {
        await _dbService.db.writeTxn(() async {
          if (documentsToUpdate.isNotEmpty) {
            await _dbService.employeeDocuments.putAll(documentsToUpdate);
          }
          if (queueIdsToDelete.isNotEmpty) {
            await _dbService.syncQueue.deleteAll(queueIdsToDelete);
          }
        });
      }
      pushSuccess = true;
    } catch (e) {
      pushError = e.toString();
      _markSyncIssue('employee_documents push', e);
    } finally {
      pushStopwatch.stop();
      await _recordMetric(
        entityType: 'employee_documents',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: pushStopwatch.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final pullStopwatch = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;
    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('employee_documents');
      firestore.Query query = db.collection(CollectionRegistry.employeeDocuments);

      // UID-based filtering for ownership-sensitive data
      if (!isManagerOrAdmin) {
        assert(firebaseUid != null && firebaseUid.isNotEmpty);
        query = query.where('employeeId', isEqualTo: firebaseUid);
      }
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }
      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        var maxUpdatedAt = lastSync ?? DateTime(2000);

        final ids = snapshot.docs
            .map(
              (doc) =>
                  (doc.data() as Map<String, dynamic>)['id']?.toString() ??
                  doc.id,
            )
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        final existingRecords = await _dbService.employeeDocuments.getAllById(
          ids,
        );
        final existingMap = {
          for (int i = 0; i < ids.length; i++)
            if (existingRecords[i] != null) ids[i]: existingRecords[i]!,
        };

        final entitiesToPut = <EmployeeDocumentEntity>[];

        for (final doc in snapshot.docs) {
          final data = Map<String, dynamic>.from(
            doc.data() as Map<String, dynamic>,
          );
          final id = (data['id']?.toString() ?? doc.id).trim();
          if (id.isEmpty) continue;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) {
            maxUpdatedAt = updatedAt;
          }

          final existing = existingMap[id];
          if (existing != null) {
            await _utils.detectAndFlagConflict(
              entityId: id,
              entityType: 'employee_documents',
              serverData: data,
              localEntity: existing,
              localToJson: (e) => _employeeDocumentToJson(e),
            );
            continue;
          }

          final entity = existing ?? EmployeeDocumentEntity();
          entity.id = id;
          entity.employeeId =
              data['employeeId']?.toString() ?? existing?.employeeId ?? '';
          entity.documentType =
              data['documentType']?.toString() ?? existing?.documentType ?? '';
          entity.documentName =
              data['documentName']?.toString() ?? existing?.documentName ?? '';
          entity.documentNumber = data['documentNumber']?.toString();
          entity.filePath =
              data['filePath']?.toString() ?? existing?.filePath ?? '';
          entity.cloudUrl = data['cloudUrl']?.toString();
          entity.expiryDate = data['expiryDate']?.toString();
          entity.isVerified = data['isVerified'] as bool? ?? entity.isVerified;
          entity.verifiedBy = data['verifiedBy']?.toString();
          entity.verifiedDate = data['verifiedDate']?.toString();
          entity.remarks = data['remarks']?.toString();
          entity.isDeleted = data['isDeleted'] == true;
          entity.updatedAt = updatedAt;
          entity.syncStatus = SyncStatus.synced;

          entitiesToPut.add(entity);
        }

        if (entitiesToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.employeeDocuments.putAll(entitiesToPut);
          });
        }
        pulledCount = snapshot.docs.length;
        await _utils.setLastSyncTimestamp('employee_documents', maxUpdatedAt);
      }
      pullSuccess = true;
    } catch (e) {
      pullError = e.toString();
      _markSyncIssue('employee_documents pull', e);
    } finally {
      pullStopwatch.stop();
      await _recordMetric(
        entityType: 'employee_documents',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: pullStopwatch.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }
}
