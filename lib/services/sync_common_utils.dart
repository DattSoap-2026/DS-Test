import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_app/core/sync/conflict_resolver.dart';
import 'package:flutter_app/core/sync/sync_queue_service.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/sync_analytics_service.dart';
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
  String? _boundCursorUserId;

  SyncCommonUtils({required this.dbService, required this.analyticsService});

  static const String lastSyncPrefix = 'last_sync_';
  static const String syncCursorPrefix = 'sync_cursor_';

  void bindCursorUser(String? userId) {
    final normalized = userId?.trim();
    _boundCursorUserId = (normalized == null || normalized.isEmpty)
        ? null
        : normalized;
  }

  Future<DateTime?> getLastSyncTimestamp(String collection) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedCollection = collection.trim();
    final iso =
        prefs.getString(_syncCursorKey(normalizedCollection)) ??
        prefs.getString('$lastSyncPrefix$normalizedCollection');
    return iso != null ? DateTime.tryParse(iso) : null;
  }

  Future<void> setLastSyncTimestamp(
    String collection,
    DateTime timestamp,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedCollection = collection.trim();
    final encoded = timestamp.toIso8601String();
    await prefs.setString(_syncCursorKey(normalizedCollection), encoded);
    await prefs.setString('$lastSyncPrefix$normalizedCollection', encoded);
  }

  Future<void> deleteQueueItem({
    required String collection,
    required Map<String, dynamic> payload,
    String? explicitRecordKey,
  }) async {
    final recordId =
        explicitRecordKey?.trim().isNotEmpty == true
        ? explicitRecordKey!.trim()
        : (payload['id']?.toString().trim() ?? '');
    if (recordId.isEmpty) {
      return;
    }
    await SyncQueueService.instance.removeFromQueue(
      collectionName: collection,
      documentId: recordId,
    );
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
    final localData = localToJson(localEntity);
    final normalizedServerData = _normalizeServerPayload(
      entityType: entityType,
      entityId: entityId,
      serverData: serverData,
    );
    final resolution = await ConflictResolver.resolve(
      localRecord: localData,
      firebaseRecord: normalizedServerData,
      collectionName: entityType,
      documentId: entityId,
    );

    switch (resolution.action) {
      case SyncConflictAction.useFirebase:
      case SyncConflictAction.inSync:
        await _applyServerWinner(
          entityType: entityType,
          entityId: entityId,
          serverData: normalizedServerData,
        );
        await SyncQueueService.instance.removeFromQueue(
          collectionName: entityType,
          documentId: entityId,
        );
        return;
      case SyncConflictAction.pushLocal:
        AppLogger.info(
          'Keeping local $entityType/$entityId until it syncs.',
          tag: 'Sync',
        );
        return;
      case SyncConflictAction.manualResolution:
        localEntity.syncStatus = SyncStatus.conflict;
        await persistConflictEntity(entityType, localEntity);
        return;
    }
  }

  Future<void> persistConflictEntity(
    String entityType,
    BaseEntity localEntity,
  ) async {
    await dbService.db.writeTxn(() async {
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
    });
  }

  Future<bool> isPartnerOutboxQueued(String collection, String recordId) async {
    return SyncQueueService.instance.hasPendingItem(
      collectionName: collection,
      documentId: recordId,
    );
  }

  Future<void> deletePartnerOutboxItem(
    String collection,
    String recordId,
  ) async {
    await SyncQueueService.instance.removeFromQueue(
      collectionName: collection,
      documentId: recordId,
    );
  }

  Future<void> upsertPartnerOutboxItem({
    required String collection,
    required String action,
    required String recordId,
    required Map<String, dynamic> data,
  }) async {
    await SyncQueueService.instance.addToQueue(
      collectionName: collection,
      documentId: recordId,
      operation: action,
      payload: data,
    );
  }

  String _syncCursorKey(String collection) {
    final normalizedCollection = collection.trim();
    final currentUserId =
        _boundCursorUserId ??
        (FirebaseAuth.instance.currentUser?.uid.trim().isNotEmpty == true
            ? FirebaseAuth.instance.currentUser!.uid.trim()
            : 'anonymous');
    return '$syncCursorPrefix${normalizedCollection}_$currentUserId';
  }

  Map<String, dynamic> _normalizeServerPayload({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> serverData,
  }) {
    final normalized = <String, dynamic>{
      ...serverData.map((key, value) => MapEntry(key.toString(), _coerceValue(value))),
    };
    normalized['id'] = entityId;
    normalized['updatedAt'] ??=
        normalized['lastModified'] ??
        DateTime.now().toIso8601String();
    normalized['syncStatus'] ??= SyncStatus.synced.name;
    normalized['isSynced'] ??= true;
    normalized['isDeleted'] ??= normalized['isDeleted'] == true;
    return normalized;
  }

  dynamic _coerceValue(dynamic value) {
    if (value is firestore.Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is List) {
      return value.map(_coerceValue).toList(growable: false);
    }
    if (value is Map) {
      return value.map(
        (key, nestedValue) => MapEntry(
          key.toString(),
          _coerceValue(nestedValue),
        ),
      );
    }
    return value;
  }

  Future<void> _applyServerWinner({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> serverData,
  }) async {
    var handled = false;
    await dbService.db.writeTxn(() async {
      switch (entityType) {
        case 'users':
          handled = true;
          final entity = UserEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.users.put(entity);
          return;
        case 'sales':
          handled = true;
          final entity = SaleEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.sales.put(entity);
          return;
        case 'returns':
          handled = true;
          final entity = ReturnEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.returns.put(entity);
          return;
        case 'customers':
          handled = true;
          final entity = CustomerEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.customers.put(entity);
          return;
        case 'dealers':
          handled = true;
          final entity = DealerEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.dealers.put(entity);
          return;
        case 'attendances':
          handled = true;
          final entity = AttendanceEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.attendances.put(entity);
          return;
        case 'sales_targets':
          handled = true;
          final entity = SalesTargetEntity.fromFirebaseJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.salesTargets.put(entity);
          return;
        case 'payroll_records':
          handled = true;
          final entity = PayrollRecordEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.payrollRecords.put(entity);
          return;
        case 'units':
          handled = true;
          final entity = UnitEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.units.put(entity);
          return;
        case 'product_categories':
          handled = true;
          final entity = CategoryEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.categories.put(entity);
          return;
        case 'product_types':
          handled = true;
          final entity = ProductTypeEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.productTypes.put(entity);
          return;
        case 'employees':
          handled = true;
          final entity = EmployeeEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.employees.put(entity);
          return;
        case 'leave_requests':
          handled = true;
          final entity = LeaveRequestEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.leaveRequests.put(entity);
          return;
        case 'advances':
          handled = true;
          final entity = AdvanceEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.advances.put(entity);
          return;
        case 'performance_reviews':
          handled = true;
          final entity = PerformanceReviewEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.performanceReviews.put(entity);
          return;
        case 'employee_documents':
          handled = true;
          final entity = EmployeeDocumentEntity.fromJson(serverData)
            ..syncStatus = SyncStatus.synced
            ..isSynced = true;
          await dbService.employeeDocuments.put(entity);
          return;
      }
    });

    if (!handled) {
      AppLogger.warning(
        'No server-winner apply handler registered for $entityType/$entityId',
        tag: 'Sync',
      );
    }
  }
}
