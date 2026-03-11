import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart'; // Added
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/sync_analytics_service.dart';
import 'package:flutter_app/services/outbox_codec.dart';
import 'package:flutter_app/utils/app_logger.dart';

// Import all entities for Conflict Persistence
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/sale_entity.dart';
import 'package:flutter_app/data/local/entities/return_entity.dart';
import 'package:flutter_app/data/local/entities/customer_entity.dart';
import 'package:flutter_app/data/local/entities/dealer_entity.dart';
import 'package:flutter_app/data/local/entities/attendance_entity.dart';
import 'package:flutter_app/data/local/entities/sales_target_entity.dart';
import 'package:flutter_app/data/local/entities/payroll_record_entity.dart';
import 'package:flutter_app/data/local/entities/unit_entity.dart';
import 'package:flutter_app/data/local/entities/category_entity.dart';
import 'package:flutter_app/data/local/entities/product_type_entity.dart';
import 'package:flutter_app/data/local/entities/employee_entity.dart';
import 'package:flutter_app/data/local/entities/leave_request_entity.dart';
import 'package:flutter_app/data/local/entities/advance_entity.dart';
import 'package:flutter_app/data/local/entities/performance_review_entity.dart';
import 'package:flutter_app/data/local/entities/employee_document_entity.dart';

class SyncCommonUtils {
  final DatabaseService dbService;
  final SyncAnalyticsService analyticsService;

  SyncCommonUtils({required this.dbService, required this.analyticsService});

  static const String lastSyncPrefix = 'last_sync_';

  Future<DateTime?> getLastSyncTimestamp(String collection) async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString('$lastSyncPrefix$collection');
    return iso != null ? DateTime.tryParse(iso) : null;
  }

  Future<void> setLastSyncTimestamp(
    String collection,
    DateTime timestamp,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$lastSyncPrefix$collection',
      timestamp.toIso8601String(),
    );
  }

  Future<void> deleteQueueItem({
    required String collection,
    required Map<String, dynamic> payload,
    String? explicitRecordKey,
  }) async {
    final queueId = OutboxCodec.buildQueueId(
      collection,
      payload,
      explicitRecordKey: explicitRecordKey,
    );
    final queued = await dbService.syncQueue.get(fastHash(queueId));
    if (queued != null) {
      await dbService.syncQueue.delete(queued.isarId);
    }
  }

  Future<void> recordMetric({
    required String? userId,
    required String entityType,
    required SyncOperation operation,
    required int recordCount,
    required int durationMs,
    required bool success,
    String? errorMessage,
  }) async {
    if (userId == null) return;
    await analyticsService.recordSyncMetric(
      userId: userId,
      entityType: entityType,
      operation: operation,
      recordCount: recordCount,
      durationMs: durationMs,
      success: success,
      errorMessage: errorMessage,
    );
  }

  List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
    if (list.isEmpty) return [];
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
  }

  DateTime parseRemoteDate(dynamic value, {DateTime? fallback}) {
    if (value == null) return fallback ?? DateTime.now();
    if (value is DateTime) return value;
    if (value is firestore.Timestamp) return value.toDate();
    if (value is String) {
      return DateTime.tryParse(value) ?? (fallback ?? DateTime.now());
    }
    return fallback ?? DateTime.now();
  }

  Future<void> detectAndFlagConflict<T extends BaseEntity>({
    required String entityId,
    required String entityType,
    required Map<String, dynamic> serverData,
    required T? localEntity,
    required Map<String, dynamic> Function(T) localToJson,
  }) async {
    if (localEntity == null) return;

    final serverUpdatedStr = serverData['updatedAt'];
    if (serverUpdatedStr == null) return;

    final serverUpdatedAt = parseRemoteDate(serverUpdatedStr);
    final localUpdatedAt = localEntity.updatedAt;

    if (serverUpdatedAt.isAfter(localUpdatedAt)) {
      final localData = localToJson(localEntity);

      bool hasStructureConflict = false;
      for (var key in localData.keys) {
        if (key == 'updatedAt' || key == 'syncStatus') continue;
        if (serverData[key] != localData[key]) {
          hasStructureConflict = true;
          break;
        }
      }

      if (hasStructureConflict) {
        AppLogger.warning(
          'Conflict detected for $entityType: $entityId. Server is newer.',
          tag: 'Sync',
        );
        localEntity.syncStatus = SyncStatus.conflict;
        await persistConflictEntity(entityType, localEntity);
      }
    }
  }

  Future<void> persistConflictEntity(
    String entityType,
    BaseEntity localEntity,
  ) async {
    switch (entityType) {
      case 'users':
        await dbService.users.put(localEntity as UserEntity);
        return;
      case 'products':
        await dbService.products.put(localEntity as ProductEntity);
        return;
      case 'sales':
        await dbService.sales.put(localEntity as SaleEntity);
        return;
      case 'returns':
        await dbService.returns.put(localEntity as ReturnEntity);
        return;
      case 'customers':
        await dbService.customers.put(localEntity as CustomerEntity);
        return;
      case 'dealers':
        await dbService.dealers.put(localEntity as DealerEntity);
        return;
      case 'attendances':
        await dbService.attendances.put(localEntity as AttendanceEntity);
        return;
      case 'sales_targets':
        await dbService.salesTargets.put(localEntity as SalesTargetEntity);
        return;
      case 'payroll_records':
        await dbService.payrollRecords.put(localEntity as PayrollRecordEntity);
        return;
      case 'units':
        await dbService.units.put(localEntity as UnitEntity);
        return;
      case 'product_categories':
        await dbService.categories.put(localEntity as CategoryEntity);
        return;
      case 'product_types':
        await dbService.productTypes.put(localEntity as ProductTypeEntity);
        return;
      case 'employees':
        await dbService.employees.put(localEntity as EmployeeEntity);
        return;
      case 'leave_requests':
        await dbService.leaveRequests.put(localEntity as LeaveRequestEntity);
        return;
      case 'advances':
        await dbService.advances.put(localEntity as AdvanceEntity);
        return;
      case 'performance_reviews':
        await dbService.performanceReviews.put(
          localEntity as PerformanceReviewEntity,
        );
        return;
      case 'employee_documents':
        await dbService.employeeDocuments.put(
          localEntity as EmployeeDocumentEntity,
        );
        return;
    }
  }

  String _partnerOutboxId(String collection, String recordId) {
    return 'partner_outbox_${collection}_$recordId';
  }

  Future<bool> isPartnerOutboxQueued(String collection, String recordId) async {
    final queueId = _partnerOutboxId(collection, recordId);
    final existing = await dbService.syncQueue.getById(queueId);
    return existing != null;
  }

  Future<void> deletePartnerOutboxItem(
    String collection,
    String recordId,
  ) async {
    final queueId = _partnerOutboxId(collection, recordId);
    final existing = await dbService.syncQueue.getById(queueId);
    if (existing == null) return;
    await dbService.db.writeTxn(() async {
      await dbService.syncQueue.delete(existing.isarId);
    });
  }

  Future<void> upsertPartnerOutboxItem({
    required String collection,
    required String action,
    required String recordId,
    required Map<String, dynamic> data,
  }) async {
    final queueId = _partnerOutboxId(collection, recordId);
    final existing = await dbService.syncQueue.getById(queueId);
    final now = DateTime.now();
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;
    final entity = SyncQueueEntity()
      ..id = queueId
      ..collection = collection
      ..action = action
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: data,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: true,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await dbService.db.writeTxn(() async {
      await dbService.syncQueue.put(entity);
    });
  }
}
