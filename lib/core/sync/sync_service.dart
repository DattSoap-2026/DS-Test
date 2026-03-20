import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/firebase/firebase_config.dart';
import '../../data/local/base_entity.dart';
import '../../data/local/entities/alert_entity.dart';
import '../../data/local/entities/audit_log_entity.dart';
import '../../data/local/entities/customer_visit_entity.dart';
import '../../data/local/entities/product_entity.dart';
import '../../data/local/entities/route_session_entity.dart';
import '../../data/local/entities/sale_entity.dart';
import '../../data/local/entities/stock_movement_entity.dart';
import '../../data/local/entities/sync_metric_entity.dart';
import '../../data/local/entities/task_entity.dart';
import '../../data/local/entities/stock_ledger_entity.dart';
import '../../features/inventory/models/sync_queue.dart';
import '../../models/types/user_types.dart';
import '../../utils/ui_notifier.dart';
import '../network/connectivity_service.dart';
import '../../services/database_service.dart';
import '../database/isar_service.dart';
import '../utils/device_id_service.dart';
import '../utils/sync_logger.dart';
import 'collection_registry.dart';
import 'conflict_resolver.dart';
import 'optimistic_sync_payload.dart';
import 'sync_push_request_store.dart';
import 'sync_queue_service.dart';
import 'sync_request.dart';

typedef PullSyncExecutor = Future<void> Function(
  Set<SyncModule> modules, {
  bool forceRefresh,
  String source,
});

/// Snapshot of sync progress for UI/state consumers.
class SyncStatusSnapshot {
  /// Creates an immutable sync status snapshot.
  const SyncStatusSnapshot({
    required this.isSyncing,
    required this.lastSyncTime,
    required this.pendingCount,
    required this.failedCount,
    required this.isOnline,
  });

  final bool isSyncing;
  final DateTime? lastSyncTime;
  final int pendingCount;
  final int failedCount;
  final bool isOnline;

  /// Returns a copy with updated fields.
  SyncStatusSnapshot copyWith({
    bool? isSyncing,
    DateTime? lastSyncTime,
    int? pendingCount,
    int? failedCount,
    bool? isOnline,
  }) {
    return SyncStatusSnapshot(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingCount: pendingCount ?? this.pendingCount,
      failedCount: failedCount ?? this.failedCount,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

/// Per-collection sync status.
class CollectionSyncStatus {
  /// Creates a collection-specific sync status snapshot.
  const CollectionSyncStatus({
    required this.collectionName,
    required this.isSyncing,
    required this.lastSyncTime,
    required this.pendingCount,
    required this.failedCount,
  });

  final String collectionName;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final int pendingCount;
  final int failedCount;
}

/// Handles bidirectional synchronization for the offline-first app.
class SyncService {
  SyncService._internal();

  static final SyncService instance = SyncService._internal();

  static const String productsCollection = CollectionRegistry.products;
  static const String stockMovementsCollection =
      CollectionRegistry.stockMovements;
  static const String lastSyncAtKey = 'core_sync_last_sync_at_v2';
  static const String currentUserKey = 'sync_current_user_id_v1';

  final IsarService _isarService = IsarService.instance;
  final SyncQueueService _queueService = SyncQueueService.instance;
  final DeviceIdService _deviceIdService = DeviceIdService.instance;
  final StreamController<SyncStatusSnapshot> _statusController =
      StreamController<SyncStatusSnapshot>.broadcast();

  final ValueNotifier<bool> isSyncing = ValueNotifier<bool>(false);

  SyncStatusSnapshot _status = const SyncStatusSnapshot(
    isSyncing: false,
    lastSyncTime: null,
    pendingCount: 0,
    failedCount: 0,
    isOnline: false,
  );
  bool _syncInProgress = false;
  bool _isListening = false;
  bool _isDisposed = false;
  bool _attemptHadFailures = false;
  int _retryAttempt = 0;
  Timer? _retryTimer;
  StreamSubscription<bool>? _connectivitySubscription;
  PullSyncExecutor? _pullExecutor;
  AppUser? _currentUser;

  /// Sync status stream for Riverpod/UI consumption.
  Stream<SyncStatusSnapshot> get statusStream => _statusController.stream;

  /// Current sync status snapshot.
  SyncStatusSnapshot get currentStatus => _status;

  /// Latest authenticated app user context available to the sync pipeline.
  AppUser? get currentUser => _currentUser;

  /// Initializes sync status tracking.
  Future<void> initialize() async {
    if (_isDisposed || _isListening) {
      return;
    }
    _isListening = true;
    try {
      final preferences = await SharedPreferences.getInstance();
      final lastSyncTimestamp = preferences.getInt(lastSyncAtKey);
      _status = _status.copyWith(
        lastSyncTime: lastSyncTimestamp == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp),
        isOnline: ConnectivityService.instance.isOnline,
      );
      await _refreshPendingCount();
      await _refreshFailedCount();
      await _connectivitySubscription?.cancel();
      _connectivitySubscription = ConnectivityService.instance.stream.listen(
        _handleConnectivityChanged,
      );
      _emitStatus();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to initialize SyncService',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      _isListening = false;
    }
  }

  /// Attempts one full sync pass and lets failures schedule backoff retries.
  Future<void> trySync({
    Set<SyncModule>? modules,
    String source = 'manual',
  }) => syncAllPending(modules: modules, source: source);

  void registerPullExecutor(PullSyncExecutor executor) {
    _pullExecutor = executor;
  }

  void setCurrentUser(AppUser? user) {
    _currentUser = user;
    final userId = user?.id.trim();
    unawaited(() async {
      final preferences = await SharedPreferences.getInstance();
      if (userId == null || userId.isEmpty) {
        await preferences.remove(currentUserKey);
      } else {
        await preferences.setString(currentUserKey, userId);
      }
    }());
  }

  void clearCurrentUser() {
    _currentUser = null;
    unawaited(() async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(currentUserKey);
    }());
  }

  Future<void> processStoredPullRequests({
    String source = 'stored_request',
  }) async {
    if (_isDisposed || _syncInProgress) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    final persistedAppUserId = _currentUser?.id.trim().isNotEmpty == true
        ? _currentUser!.id.trim()
        : preferences.getString(currentUserKey);
    final storedRequests = await SyncPushRequestStore.instance.loadAll();
    if (storedRequests.isEmpty) {
      return;
    }

    final applicableRequests = storedRequests
        .where(
          (request) => !request.shouldSkipForCurrentUser(
            appUserId: persistedAppUserId,
            authUid: authUid,
          ),
        )
        .toList(growable: false);
    await SyncPushRequestStore.instance.clear();
    if (applicableRequests.isEmpty) {
      return;
    }

    try {
      await syncAllPending(
        modules: unionSyncModules(applicableRequests),
        source: source,
      );
    } catch (_) {
      for (final request in applicableRequests) {
        await SyncPushRequestStore.instance.enqueue(request);
      }
      rethrow;
    }
  }

  /// Pushes all pending local changes to Firebase.
  Future<void> pushAllPending() async {
    try {
      final firestore = firebaseServices.db;
      if (firestore == null) {
        return;
      }

      final queueItems = await _queueService.getPendingQueue();
      final products = await _isarService.products
          .filter()
          .isSyncedEqualTo(false)
          .findAll();
      final stockMovements = await _isarService.stockMovements
          .filter()
          .isSyncedEqualTo(false)
          .findAll();

      final rawOperations = <Map<String, dynamic>>[
        ...products.map(_buildProductOperation),
        ...stockMovements.map(_buildStockMovementOperation),
        ...queueItems.map(_buildQueueOperation),
      ];

      final operations = await compute(_dedupeOperations, rawOperations);
      if (operations.isEmpty) {
        await _refreshPendingCount();
        return;
      }

      WriteBatch batch = firestore.batch();
      final pendingCommit = <Map<String, dynamic>>[];

      for (final operation in operations) {
        final collectionName = operation['collectionName'] as String;
        final documentId = operation['documentId'] as String;
        final operationType = operation['operation'] as String;
        final payload = Map<String, dynamic>.from(
          operation['payload'] as Map<dynamic, dynamic>,
        );

        if (CollectionRegistry.isLocalOnly(collectionName) ||
            CollectionRegistry.isPullOnly(collectionName)) {
          final queueId = operation['queueId'] as int?;
          if (queueId != null) {
            await _queueService.markProcessed(queueId);
          }
          continue;
        }

        final document = firestore.collection(collectionName).doc(documentId);
        try {
          if (operationType == 'delete') {
            batch.set(
              document,
              <String, dynamic>{
                'isDeleted': true,
                'deletedAt': _toTimestamp(payload['deletedAt']),
                'lastModified': _toTimestamp(
                  payload['lastModified'] ?? payload['updatedAt'],
                ),
                'version': payload['version'],
                'deviceId': payload['deviceId'],
              },
              SetOptions(merge: true),
            );
          } else {
            batch.set(
              document,
              _firestorePayload(payload),
              SetOptions(merge: true),
            );
          }
          pendingCommit.add(operation);

          if (pendingCommit.length == 500) {
            await batch.commit();
            await _applySuccessfulOperations(pendingCommit);
            pendingCommit.clear();
            batch = firestore.batch();
          }
        } catch (error, stackTrace) {
          SyncLogger.instance.e(
            'Failed Firestore operation for $collectionName/$documentId',
            error: error,
            stackTrace: stackTrace,
            time: DateTime.now(),
          );
          await _handleOperationFailure(operation);
        }
      }

      if (pendingCommit.isNotEmpty) {
        try {
          await batch.commit();
          await _applySuccessfulOperations(pendingCommit);
        } catch (error, stackTrace) {
          SyncLogger.instance.e(
            'Failed to commit Firestore batch',
            error: error,
            stackTrace: stackTrace,
            time: DateTime.now(),
          );
          for (final operation in pendingCommit) {
            await _handleOperationFailure(operation);
          }
        }
      }

      await _queueService.clearOldFailed();
      await _refreshPendingCount();
      await _refreshFailedCount();
    } catch (error, stackTrace) {
      _attemptHadFailures = true;
      SyncLogger.instance.e(
        'pushAllPending failed',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// Compatibility alias retained for existing startup and feature code.
  Future<void> pushToFirebase() => pushAllPending();

  /// Pulls remote changes newer than the stored sync cursors.
  Future<void> pullAllChanges({
    Set<SyncModule>? modules,
    bool forceRefresh = false,
    String source = 'scheduled',
  }) async {
    try {
      final firestore = firebaseServices.db;
      if (firestore == null) {
        return;
      }

      final requestedModules = _expandRequestedModules(modules);
      DateTime? latestRemoteChange;

      if (requestedModules.contains(SyncModule.inventory)) {
        latestRemoteChange = _latestOf(
          latestRemoteChange,
          await _pullInventoryChanges(
            firestore,
            forceRefresh: forceRefresh,
          ),
        );
      }

      if (requestedModules.contains(SyncModule.core)) {
        latestRemoteChange = _latestOf(
          latestRemoteChange,
          await _pullCoreCollections(
            firestore,
            forceRefresh: forceRefresh,
          ),
        );
      }

      final delegateModules = requestedModules
          .where(
            (module) => module != SyncModule.inventory && module != SyncModule.core,
          )
          .toSet();
      if (delegateModules.isNotEmpty && _pullExecutor != null) {
        await _pullExecutor!(
          delegateModules,
          forceRefresh: forceRefresh,
          source: source,
        );
        latestRemoteChange = _latestOf(latestRemoteChange, DateTime.now());
      }

      if (latestRemoteChange != null) {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setInt(
          lastSyncAtKey,
          latestRemoteChange.millisecondsSinceEpoch,
        );
        _status = _status.copyWith(lastSyncTime: latestRemoteChange);
        _emitStatus();
      }
    } catch (error, stackTrace) {
      _attemptHadFailures = true;
      SyncLogger.instance.e(
        'pullAllChanges failed',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// Compatibility alias retained for existing startup and feature code.
  Future<void> pullFromFirebase({
    Set<SyncModule>? modules,
    bool forceRefresh = false,
    String source = 'scheduled',
  }) => pullAllChanges(
    modules: modules,
    forceRefresh: forceRefresh,
    source: source,
  );

  /// Returns the current sync status for a Firestore collection.
  Future<CollectionSyncStatus> getSyncStatusFor(String collectionName) async {
    final pendingCount = await _queueService.getPendingCount(
      collectionName: collectionName,
    );
    return CollectionSyncStatus(
      collectionName: collectionName,
      isSyncing: _status.isSyncing,
      lastSyncTime: _status.lastSyncTime,
      pendingCount: pendingCount,
      failedCount: _status.failedCount,
    );
  }

  /// Runs push followed by pull.
  Future<void> syncAllPending({
    Set<SyncModule>? modules,
    String source = 'manual',
  }) async {
    if (_isDisposed || _syncInProgress) {
      return;
    }
    _retryTimer?.cancel();
    _retryTimer = null;
    _attemptHadFailures = false;
    _syncInProgress = true;
    _setSyncing(true);
    try {
      await pushAllPending();
      await pullAllChanges(modules: modules, source: source);
      await _refreshPendingCount();
      await _refreshFailedCount();
    } finally {
      _syncInProgress = false;
      _setSyncing(false);
    }
    await _completeSyncAttempt();
  }

  Future<DateTime?> _pullInventoryChanges(
    FirebaseFirestore firestore, {
    bool forceRefresh = false,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final lastSyncTimestamp = forceRefresh
        ? 0
        : preferences.getInt(_syncCursorKey(SyncModule.inventory)) ?? 0;
    final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);
    final latestProductChange = await _pullProducts(firestore, lastSyncTime);
    final latestMovementChange = await _pullStockMovements(
      firestore,
      lastSyncTime,
    );
    final latestRemoteChange = _latestOf(latestProductChange, latestMovementChange);
    if (latestRemoteChange != null) {
      await preferences.setInt(
        _syncCursorKey(SyncModule.inventory),
        latestRemoteChange.millisecondsSinceEpoch,
      );
    }
    return latestRemoteChange;
  }

  Future<DateTime?> _pullCoreCollections(
    FirebaseFirestore firestore, {
    bool forceRefresh = false,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final lastSyncTimestamp = forceRefresh
        ? 0
        : preferences.getInt(_syncCursorKey(SyncModule.core)) ?? 0;
    final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);
    final latestAlertChange = await _pullAlerts(firestore, lastSyncTime);
    final latestAuditLogChange = await _pullAuditLogs(firestore, lastSyncTime);
    final latestTaskChange = await _pullTasks(firestore, lastSyncTime);
    final latestMetricChange = await _pullSyncMetrics(firestore, lastSyncTime);

    DateTime? latestRemoteChange;
    for (final candidate in <DateTime?>[
      latestAlertChange,
      latestAuditLogChange,
      latestTaskChange,
      latestMetricChange,
    ]) {
      latestRemoteChange = _latestOf(latestRemoteChange, candidate);
    }

    if (latestRemoteChange != null) {
      await preferences.setInt(
        _syncCursorKey(SyncModule.core),
        latestRemoteChange.millisecondsSinceEpoch,
      );
    }
    return latestRemoteChange;
  }

  Future<DateTime?> _pullProducts(
    FirebaseFirestore firestore,
    DateTime lastSyncTime,
  ) async {
    final snapshot = await firestore
        .collection(productsCollection)
        .where('updatedAt', isGreaterThan: Timestamp.fromDate(lastSyncTime))
        .orderBy('updatedAt')
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final rawDocuments = snapshot.docs
        .map((doc) => <String, dynamic>{'id': doc.id, 'data': doc.data()})
        .toList(growable: false);
    final normalized = await compute(_normalizeProductPayload, rawDocuments);

    DateTime? latestRemoteChange;
    for (final entry in normalized) {
      final remote = ProductEntity.fromJson(entry)
        ..syncStatus = SyncStatus.synced
        ..isSynced = true
        ..lastSynced = DateTime.now();
      final local = await _isarService.products
          .filter()
          .idEqualTo(remote.id)
          .findFirst();
      final resolution = await ConflictResolver.resolve(
        localRecord: local,
        firebaseRecord: remote,
        collectionName: productsCollection,
        documentId: remote.id,
      );

      if (resolution.action == SyncConflictAction.pushLocal && local != null) {
        await _queueService.addToQueue(
          collectionName: productsCollection,
          documentId: local.id,
          operation: local.isDeleted ? 'delete' : 'update',
          payload: local.toJson(),
        );
      } else {
        await _queueService.removeFromQueue(
          collectionName: productsCollection,
          documentId: remote.id,
        );
        await _isarService.isar.writeTxn(() async {
          await _isarService.products.put(remote);
        });
      }

      final remoteModified = remote.updatedAt;
      if (latestRemoteChange == null ||
          remoteModified.isAfter(latestRemoteChange)) {
        latestRemoteChange = remoteModified;
      }
    }

    return latestRemoteChange;
  }

  Future<DateTime?> _pullStockMovements(
    FirebaseFirestore firestore,
    DateTime lastSyncTime,
  ) async {
    final snapshot = await firestore
        .collection(stockMovementsCollection)
        .where('updatedAt', isGreaterThan: Timestamp.fromDate(lastSyncTime))
        .orderBy('updatedAt')
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final rawDocuments = snapshot.docs
        .map((doc) => <String, dynamic>{'id': doc.id, 'data': doc.data()})
        .toList(growable: false);
    final normalized = await compute(
      _normalizeStockMovementPayload,
      rawDocuments,
    );

    DateTime? latestRemoteChange;
    for (final entry in normalized) {
      final remote = StockMovementEntity.fromJson(entry)
        ..syncStatus = SyncStatus.synced
        ..isSynced = true
        ..lastSynced = DateTime.now();
      final local = await _isarService.stockMovements
          .filter()
          .idEqualTo(remote.id)
          .findFirst();
      final resolution = await ConflictResolver.resolve(
        localRecord: local,
        firebaseRecord: remote,
        collectionName: stockMovementsCollection,
        documentId: remote.id,
      );

      if (resolution.action == SyncConflictAction.pushLocal && local != null) {
        await _queueService.addToQueue(
          collectionName: stockMovementsCollection,
          documentId: local.id,
          operation: local.isDeleted ? 'delete' : 'create',
          payload: local.toJson(),
        );
      } else {
        await _queueService.removeFromQueue(
          collectionName: stockMovementsCollection,
          documentId: remote.id,
        );
        await _isarService.isar.writeTxn(() async {
          await _isarService.stockMovements.put(remote);
        });
      }

      final remoteModified = remote.occurredAt;
      if (latestRemoteChange == null ||
          remoteModified.isAfter(latestRemoteChange)) {
        latestRemoteChange = remoteModified;
      }
    }

    return latestRemoteChange;
  }

  Future<DateTime?> _pullAlerts(
    FirebaseFirestore firestore,
    DateTime lastSyncTime,
  ) {
    return _pullFlexibleCollection<AlertEntity>(
      firestore: firestore,
      collectionName: CollectionRegistry.alerts,
      lastSyncTime: lastSyncTime,
      fromJson: AlertEntity.fromJson,
      collectionOf: (database) => database.alerts,
      timestampOf: (entity) => entity.updatedAt,
    );
  }

  Future<DateTime?> _pullAuditLogs(
    FirebaseFirestore firestore,
    DateTime lastSyncTime,
  ) {
    return _pullFlexibleCollection<AuditLogEntity>(
      firestore: firestore,
      collectionName: CollectionRegistry.auditLogs,
      lastSyncTime: lastSyncTime,
      fromJson: AuditLogEntity.fromJson,
      collectionOf: (database) => database.auditLogs,
      timestampOf: (entity) => entity.createdAt,
      allowPushLocalResolution: false,
    );
  }

  Future<DateTime?> _pullTasks(
    FirebaseFirestore firestore,
    DateTime lastSyncTime,
  ) {
    return _pullFlexibleCollection<TaskEntity>(
      firestore: firestore,
      collectionName: CollectionRegistry.tasks,
      lastSyncTime: lastSyncTime,
      fromJson: TaskEntity.fromJson,
      collectionOf: (database) => database.tasks,
      timestampOf: (entity) => entity.updatedAt,
    );
  }

  Future<DateTime?> _pullSyncMetrics(
    FirebaseFirestore firestore,
    DateTime lastSyncTime,
  ) {
    return _pullFlexibleCollection<SyncMetricEntity>(
      firestore: firestore,
      collectionName: CollectionRegistry.syncMetrics,
      lastSyncTime: lastSyncTime,
      fromJson: SyncMetricEntity.fromJson,
      collectionOf: (database) => database.syncMetrics,
      timestampOf: (entity) => entity.updatedAt,
    );
  }

  Future<DateTime?> _pullFlexibleCollection<TEntity extends BaseEntity>({
    required FirebaseFirestore firestore,
    required String collectionName,
    required DateTime lastSyncTime,
    required TEntity Function(Map<String, dynamic>) fromJson,
    required IsarCollection<TEntity> Function(DatabaseService database)
    collectionOf,
    required DateTime Function(TEntity entity) timestampOf,
    bool allowPushLocalResolution = true,
  }) async {
    final remoteTimestampField = collectionName == CollectionRegistry.auditLogs
        ? 'createdAt'
        : 'updatedAt';
    final snapshot = await firestore
        .collection(collectionName)
        .where(
          remoteTimestampField,
          isGreaterThan: Timestamp.fromDate(lastSyncTime),
        )
        .orderBy(remoteTimestampField)
        .limit(500)
        .get();
    if (snapshot.docs.isEmpty) {
      return null;
    }

    final collection = collectionOf(DatabaseService.instance);
    DateTime? latestRemoteChange;
    for (final doc in snapshot.docs) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;

      final remote = fromJson(_normalizeFlexiblePayload(data))
        ..syncStatus = SyncStatus.synced
        ..isSynced = true
        ..lastSynced = DateTime.now();
      final remoteChangedAt = timestampOf(remote);
      if (remoteChangedAt.isBefore(lastSyncTime) &&
          !remoteChangedAt.isAtSameMomentAs(lastSyncTime)) {
        continue;
      }

      final local = await collection.get(remote.isarId);
      if (allowPushLocalResolution && local != null) {
        final resolution = await ConflictResolver.resolve(
          localRecord: local,
          firebaseRecord: remote,
          collectionName: collectionName,
          documentId: remote.id,
        );

        if (resolution.action == SyncConflictAction.pushLocal) {
          await _queueService.addToQueue(
            collectionName: collectionName,
            documentId: local.id,
            operation: local.isDeleted ? 'delete' : 'update',
            payload: _serializeEntity(local),
          );
          continue;
        }
        await _queueService.removeFromQueue(
          collectionName: collectionName,
          documentId: remote.id,
        );
      }

      await _isarService.isar.writeTxn(() async {
        await collection.put(remote);
      });

      if (latestRemoteChange == null ||
          remoteChangedAt.isAfter(latestRemoteChange)) {
        latestRemoteChange = remoteChangedAt;
      }
    }

    return latestRemoteChange;
  }

  Future<void> _applySuccessfulOperations(
    List<Map<String, dynamic>> operations,
  ) async {
    final deviceId = await _deviceIdService.getDeviceId();
    final processedAt = DateTime.now();
    final processedQueueIds = <int>[];

    await _isarService.isar.writeTxn(() async {
      for (final operation in operations) {
        final collectionName = operation['collectionName'] as String;
        final documentId = operation['documentId'] as String;
        final queueId = operation['queueId'] as int?;

        if (collectionName == productsCollection) {
          final existing = await _isarService.products
              .filter()
              .idEqualTo(documentId)
              .findFirst();
          if (existing != null) {
            existing
              ..syncStatus = SyncStatus.synced
              ..isSynced = true
              ..lastSynced = processedAt
              ..deviceId = existing.deviceId.isEmpty
                  ? deviceId
                  : existing.deviceId;
            await _isarService.products.put(existing);
          }
        }

        if (collectionName == stockMovementsCollection) {
          final existing = await _isarService.stockMovements
              .filter()
              .idEqualTo(documentId)
              .findFirst();
          if (existing != null) {
            existing
              ..syncStatus = SyncStatus.synced
              ..isSynced = true
              ..lastSynced = processedAt
              ..deviceId = existing.deviceId.isEmpty
                  ? deviceId
                  : existing.deviceId;
            await _isarService.stockMovements.put(existing);
          }
        }

        if (collectionName == CollectionRegistry.sales) {
          final existing = await DatabaseService.instance.sales
              .filter()
              .idEqualTo(documentId)
              .findFirst();
          if (existing != null) {
            existing
              ..syncStatus = SyncStatus.synced
              ..isSynced = true
              ..lastSynced = processedAt
              ..deviceId = existing.deviceId.isEmpty
                  ? deviceId
                  : existing.deviceId;
            await DatabaseService.instance.sales.put(existing);
          }
        }

        if (collectionName == CollectionRegistry.customerVisits) {
          final existing = await DatabaseService.instance.customerVisits
              .filter()
              .idEqualTo(documentId)
              .findFirst();
          if (existing != null) {
            existing
              ..syncStatus = SyncStatus.synced
              ..isSynced = true
              ..lastSynced = processedAt
              ..deviceId = existing.deviceId.isEmpty
                  ? deviceId
                  : existing.deviceId;
            await DatabaseService.instance.customerVisits.put(existing);
          }
        }

        if (collectionName == CollectionRegistry.routeSessions) {
          final existing = await DatabaseService.instance.routeSessions
              .filter()
              .idEqualTo(documentId)
              .findFirst();
          if (existing != null) {
            existing
              ..syncStatus = SyncStatus.synced
              ..isSynced = true
              ..lastSynced = processedAt
              ..deviceId = existing.deviceId.isEmpty
                  ? deviceId
                  : existing.deviceId;
            await DatabaseService.instance.routeSessions.put(existing);
          }
        }

        if (collectionName == CollectionRegistry.stockLedger) {
          final existing = await DatabaseService.instance.stockLedger
              .filter()
              .idEqualTo(documentId)
              .findFirst();
          if (existing != null) {
            existing
              ..syncStatus = SyncStatus.synced
              ..isSynced = true
              ..lastSynced = processedAt
              ..deviceId = existing.deviceId.isEmpty
                  ? deviceId
                  : existing.deviceId;
            await DatabaseService.instance.stockLedger.put(existing);
          }
        }

        if (queueId != null) {
          processedQueueIds.add(queueId);
        }
      }
    });

    for (final queueId in processedQueueIds) {
      await _queueService.markProcessed(queueId);
    }

    _status = _status.copyWith(lastSyncTime: processedAt);
    _emitStatus();
  }

  Future<void> _handleOperationFailure(Map<String, dynamic> operation) async {
    _attemptHadFailures = true;
    final queueId = operation['queueId'] as int?;
    if (queueId != null) {
      await _queueService.incrementRetry(queueId);
      final failedItem = await _isarService.syncQueues.get(queueId);
      if (failedItem != null && failedItem.isFailed) {
        await _handleTerminalQueueFailure(failedItem);
      }
    } else {
      await _queueService.addToQueue(
        collectionName: operation['collectionName'] as String,
        documentId: operation['documentId'] as String,
        operation: operation['operation'] as String,
        payload: operation['payload'],
      );
    }
    await _refreshPendingCount();
    await _refreshFailedCount();
  }

  Map<String, dynamic> _buildProductOperation(ProductEntity product) {
    return <String, dynamic>{
      'collectionName': productsCollection,
      'documentId': product.id,
      'operation': product.isDeleted ? 'delete' : 'update',
      'payload': product.toJson(),
      'queueId': null,
    };
  }

  Map<String, dynamic> _buildStockMovementOperation(
    StockMovementEntity stockMovement,
  ) {
    return <String, dynamic>{
      'collectionName': stockMovementsCollection,
      'documentId': stockMovement.id,
      'operation': stockMovement.isDeleted ? 'delete' : 'create',
      'payload': stockMovement.toJson(),
      'queueId': null,
    };
  }

  Map<String, dynamic> _buildQueueOperation(SyncQueue queue) {
    final decoded = jsonDecode(queue.payload);
    final normalizedDecoded = decoded is Map<String, dynamic>
        ? decoded
        : Map<String, dynamic>.from(decoded as Map);
    return <String, dynamic>{
      'collectionName': queue.collectionName,
      'documentId': queue.documentId,
      'operation': queue.operation,
      'payload': OptimisticSyncEnvelope.extractPayload(normalizedDecoded),
      'decodedPayload': normalizedDecoded,
      'queueId': queue.id,
    };
  }

  Map<String, dynamic> _firestorePayload(Map<String, dynamic> payload) {
    final normalized = Map<String, dynamic>.from(payload);
    final timestampFields = <String>[
      'updatedAt',
      'lastModified',
      'lastSynced',
      'timestamp',
      'occurredAt',
      'createdAt',
      'deletedAt',
      'entryDate',
      'transactionDate',
      'expiryDate',
      'dueDate',
      'viewedAt',
      'notificationReadAt',
      'resolvedAt',
      'conflictDate',
      'paidAt',
      'verifiedDate',
      'approvedAt',
      'reviewDate',
      'requestDate',
      'approvedDate',
      'generatedAt',
    ];

    for (final field in timestampFields) {
      final timestamp = _toTimestamp(normalized[field]);
      if (timestamp != null) {
        normalized[field] = timestamp;
      } else if (normalized[field] == null) {
        normalized.remove(field);
      }
    }

    return normalized;
  }

  Timestamp? _toTimestamp(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Timestamp) {
      return value;
    }
    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return Timestamp.fromDate(parsed);
      }
    }
    return null;
  }

  Future<void> _handleTerminalQueueFailure(SyncQueue queueItem) async {
    final decodedPayload = _decodeQueuePayload(queueItem.payload);
    final rollbackOperations = OptimisticSyncEnvelope.extractRollbackOperations(
      decodedPayload,
    );
    if (rollbackOperations.isEmpty) {
      return;
    }

    final groupId = OptimisticSyncEnvelope.extractGroupId(decodedPayload);
    final failureMessage =
        OptimisticSyncEnvelope.extractFailureMessage(decodedPayload) ??
        'A pending change could not be synced and was reverted locally.';
    final queueIdsToClear = <Id>{queueItem.id};

    if (groupId != null) {
      final allQueueItems = await _queueService.getAllQueueItems();
      for (final item in allQueueItems) {
        final itemPayload = _decodeQueuePayload(item.payload);
        if (OptimisticSyncEnvelope.extractGroupId(itemPayload) == groupId) {
          queueIdsToClear.add(item.id);
        }
      }
    }

    await _applyRollbackOperations(rollbackOperations);
    for (final queueId in queueIdsToClear) {
      await _queueService.markProcessed(queueId);
    }
    UINotifier.showError(failureMessage);
  }

  Map<String, dynamic> _decodeQueuePayload(String encodedPayload) {
    final decoded = jsonDecode(encodedPayload);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return Map<String, dynamic>.from(decoded as Map);
  }

  Future<void> _applyRollbackOperations(
    List<SyncRollbackOperation> operations,
  ) async {
    for (final operation in operations) {
      await _applyRollbackOperation(operation);
    }
  }

  Future<void> _applyRollbackOperation(SyncRollbackOperation operation) async {
    switch (operation.action) {
      case 'delete':
        await _deleteLocalEntity(
          collectionName: operation.collectionName,
          documentId: operation.documentId,
        );
        return;
      case 'put':
      case 'restore':
        final payload = operation.payload;
        if (payload == null) {
          return;
        }
        await _restoreLocalEntity(
          collectionName: operation.collectionName,
          payload: payload,
        );
        return;
      default:
        return;
    }
  }

  Future<void> _restoreLocalEntity({
    required String collectionName,
    required Map<String, dynamic> payload,
  }) async {
    final database = DatabaseService.instance;
    await _isarService.isar.writeTxn(() async {
      switch (collectionName) {
        case CollectionRegistry.sales:
          await database.sales.put(SaleEntity.fromJson(payload));
          return;
        case CollectionRegistry.products:
          await database.products.put(ProductEntity.fromJson(payload));
          return;
        case CollectionRegistry.stockMovements:
          await database.stockMovements.put(StockMovementEntity.fromJson(payload));
          return;
        case CollectionRegistry.stockLedger:
          await database.stockLedger.put(StockLedgerEntity.fromJson(payload));
          return;
        case CollectionRegistry.customerVisits:
          await database.customerVisits.put(CustomerVisitEntity.fromJson(payload));
          return;
        case CollectionRegistry.routeSessions:
          await database.routeSessions.put(RouteSessionEntity.fromJson(payload));
          return;
      }
    });
  }

  Future<void> _deleteLocalEntity({
    required String collectionName,
    required String documentId,
  }) async {
    final database = DatabaseService.instance;
    await _isarService.isar.writeTxn(() async {
      switch (collectionName) {
        case CollectionRegistry.sales:
          final entity = await database.sales.filter().idEqualTo(documentId).findFirst();
          if (entity != null) {
            await database.sales.delete(entity.isarId);
          }
          return;
        case CollectionRegistry.products:
          final entity = await database.products
              .filter()
              .idEqualTo(documentId)
              .findFirst();
          if (entity != null) {
            await database.products.delete(entity.isarId);
          }
          return;
        case CollectionRegistry.stockMovements:
          final entity = await database.stockMovements
              .filter()
              .idEqualTo(documentId)
              .findFirst();
          if (entity != null) {
            await database.stockMovements.delete(entity.isarId);
          }
          return;
        case CollectionRegistry.stockLedger:
          final entity = await database.stockLedger
              .filter()
              .idEqualTo(documentId)
              .findFirst();
          if (entity != null) {
            await database.stockLedger.delete(entity.isarId);
          }
          return;
        case CollectionRegistry.customerVisits:
          final entity = await database.customerVisits
              .filter()
              .idEqualTo(documentId)
              .findFirst();
          if (entity != null) {
            await database.customerVisits.delete(entity.isarId);
          }
          return;
        case CollectionRegistry.routeSessions:
          final entity = await database.routeSessions
              .filter()
              .idEqualTo(documentId)
              .findFirst();
          if (entity != null) {
            await database.routeSessions.delete(entity.isarId);
          }
          return;
      }
    });
  }

  void _handleConnectivityChanged(bool online) {
    _status = _status.copyWith(isOnline: online);
    if (!online) {
      _retryTimer?.cancel();
      _retryTimer = null;
    } else {
      unawaited(processStoredPullRequests(source: 'connectivity_restored'));
    }
    _emitStatus();
  }

  Future<void> _completeSyncAttempt() async {
    if (_attemptHadFailures && await _shouldRetryPendingSync()) {
      _scheduleRetry();
      return;
    }
    _resetRetryState();
  }

  Future<bool> _shouldRetryPendingSync() async {
    if (_isDisposed) {
      return false;
    }
    final pendingCount = await _queueService.getPendingCount();
    if (pendingCount <= 0) {
      return false;
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _scheduleRetry() {
    if (_isDisposed) {
      return;
    }
    _retryAttempt += 1;
    final seconds = 1 << (_retryAttempt - 1);
    final delay = Duration(seconds: seconds > 300 ? 300 : seconds);
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      if (_isDisposed) {
        return;
      }
      unawaited(syncAllPending(source: 'backoff_retry'));
    });
    SyncLogger.instance.w(
      'Sync retry scheduled in ${delay.inSeconds}s.',
      time: DateTime.now(),
    );
  }

  void _resetRetryState() {
    _retryAttempt = 0;
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    _isListening = false;
    _resetRetryState();
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    isSyncing.dispose();
    if (!_statusController.isClosed) {
      await _statusController.close();
    }
  }

  Future<void> _refreshPendingCount() async {
    final count = await _queueService.getPendingCount();
    _status = _status.copyWith(pendingCount: count);
    _emitStatus();
  }

  Future<void> _refreshFailedCount() async {
    final failedCount = (await _queueService.getFailedQueue()).length;
    _status = _status.copyWith(failedCount: failedCount);
    _emitStatus();
  }

  void _setSyncing(bool syncing) {
    isSyncing.value = syncing;
    _status = _status.copyWith(isSyncing: syncing);
    _emitStatus();
  }

  void _emitStatus() {
    if (!_statusController.isClosed) {
      _statusController.add(_status);
    }
  }

  Set<SyncModule> _expandRequestedModules(Set<SyncModule>? modules) {
    if (modules == null || modules.isEmpty || modules.contains(SyncModule.all)) {
      return <SyncModule>{
        SyncModule.inventory,
        SyncModule.sales,
        SyncModule.masterData,
        SyncModule.customers,
        SyncModule.users,
        SyncModule.dealers,
        SyncModule.attendance,
        SyncModule.core,
      };
    }
    return Set<SyncModule>.from(modules);
  }

  DateTime? _latestOf(DateTime? current, DateTime? candidate) {
    if (candidate == null) {
      return current;
    }
    if (current == null || candidate.isAfter(current)) {
      return candidate;
    }
    return current;
  }

  String _syncCursorKey(SyncModule module) {
    final userKey =
        _currentUser?.id.trim().isNotEmpty == true
        ? _currentUser!.id.trim()
        : (FirebaseAuth.instance.currentUser?.uid.trim().isNotEmpty == true
              ? FirebaseAuth.instance.currentUser!.uid.trim()
              : 'anonymous');
    return 'sync_cursor_${module.wireName}_$userKey';
  }
}

Map<String, dynamic> _normalizeFlexiblePayload(Map<String, dynamic> data) {
  final normalized = Map<String, dynamic>.from(data);
  for (final field in <String>[
    'createdAt',
    'updatedAt',
    'lastModified',
    'deletedAt',
    'lastSynced',
    'dueDate',
    'viewedAt',
    'notificationReadAt',
    'timestamp',
    'requestDate',
    'approvedDate',
    'paidAt',
  ]) {
    normalized[field] = _normalizeDate(normalized[field]);
  }
  return normalized;
}

Map<String, dynamic> _serializeEntity(BaseEntity entity) {
  if (entity is ProductEntity) {
    return entity.toJson();
  }
  if (entity is StockMovementEntity) {
    return entity.toJson();
  }
  if (entity is AlertEntity) {
    return entity.toJson();
  }
  if (entity is TaskEntity) {
    return entity.toJson();
  }
  if (entity is SyncMetricEntity) {
    return entity.toJson();
  }
  if (entity is AuditLogEntity) {
    return entity.toJson();
  }
  return <String, dynamic>{'id': entity.id};
}

List<Map<String, dynamic>> _dedupeOperations(
  List<Map<String, dynamic>> operations,
) {
  final deduped = <String, Map<String, dynamic>>{};
  for (final operation in operations) {
    final collectionName = operation['collectionName'] as String? ?? '';
    final documentId = operation['documentId'] as String? ?? '';
    if (collectionName.isEmpty || documentId.isEmpty) {
      continue;
    }
    deduped['$collectionName::$documentId'] = operation;
  }
  return deduped.values.toList(growable: false);
}

List<Map<String, dynamic>> _normalizeProductPayload(
  List<Map<String, dynamic>> documents,
) {
  return documents.map((entry) {
    final data = Map<String, dynamic>.from(
      entry['data'] as Map<dynamic, dynamic>,
    );
    data['id'] = entry['id'];
    data['updatedAt'] = _normalizeDate(data['updatedAt'] ?? data['lastModified']);
    data['lastModified'] = _normalizeDate(
      data['lastModified'] ?? data['updatedAt'],
    );
    data['lastSynced'] = _normalizeDate(data['lastSynced']);
    data['createdAt'] = _normalizeDate(data['createdAt']);
    data['deletedAt'] = _normalizeDate(data['deletedAt']);
    return data;
  }).toList(growable: false);
}

List<Map<String, dynamic>> _normalizeStockMovementPayload(
  List<Map<String, dynamic>> documents,
) {
  return documents.map((entry) {
    final data = Map<String, dynamic>.from(
      entry['data'] as Map<dynamic, dynamic>,
    );
    data['id'] = entry['id'];
    data['timestamp'] = _normalizeDate(
      data['timestamp'] ?? data['occurredAt'] ?? data['lastModified'],
    );
    data['occurredAt'] = _normalizeDate(
      data['occurredAt'] ?? data['timestamp'] ?? data['lastModified'],
    );
    data['updatedAt'] = _normalizeDate(
      data['updatedAt'] ?? data['lastModified'] ?? data['timestamp'],
    );
    data['lastModified'] = _normalizeDate(
      data['lastModified'] ?? data['updatedAt'] ?? data['timestamp'],
    );
    data['lastSynced'] = _normalizeDate(data['lastSynced']);
    data['deletedAt'] = _normalizeDate(data['deletedAt']);
    return data;
  }).toList(growable: false);
}

String? _normalizeDate(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is Timestamp) {
    return value.toDate().toIso8601String();
  }
  if (value is DateTime) {
    return value.toIso8601String();
  }
  return value.toString();
}
