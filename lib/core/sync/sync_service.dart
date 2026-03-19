import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/firebase/firebase_config.dart';
import '../../data/local/base_entity.dart';
import '../../data/local/entities/alert_entity.dart';
import '../../data/local/entities/audit_log_entity.dart';
import '../../data/local/entities/product_entity.dart';
import '../../data/local/entities/stock_movement_entity.dart';
import '../../data/local/entities/sync_metric_entity.dart';
import '../../data/local/entities/task_entity.dart';
import '../../features/inventory/models/sync_queue.dart';
import '../../services/database_service.dart';
import '../database/isar_service.dart';
import '../utils/device_id_service.dart';
import '../utils/sync_logger.dart';
import 'collection_registry.dart';
import 'conflict_resolver.dart';
import 'sync_queue_service.dart';

/// Snapshot of sync progress for UI/state consumers.
class SyncStatusSnapshot {
  /// Creates an immutable sync status snapshot.
  const SyncStatusSnapshot({
    required this.isSyncing,
    required this.lastSyncTime,
    required this.pendingCount,
  });

  final bool isSyncing;
  final DateTime? lastSyncTime;
  final int pendingCount;

  /// Returns a copy with updated fields.
  SyncStatusSnapshot copyWith({
    bool? isSyncing,
    DateTime? lastSyncTime,
    int? pendingCount,
  }) {
    return SyncStatusSnapshot(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingCount: pendingCount ?? this.pendingCount,
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
  });

  final String collectionName;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final int pendingCount;
}

/// Handles bidirectional synchronization for the offline-first app.
class SyncService {
  SyncService._internal();

  static final SyncService instance = SyncService._internal();

  static const String productsCollection = CollectionRegistry.products;
  static const String stockMovementsCollection =
      CollectionRegistry.stockMovements;
  static const String lastSyncAtKey = 'core_sync_last_sync_at_v2';

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
  );
  bool _syncInProgress = false;

  /// Sync status stream for Riverpod/UI consumption.
  Stream<SyncStatusSnapshot> get statusStream => _statusController.stream;

  /// Current sync status snapshot.
  SyncStatusSnapshot get currentStatus => _status;

  /// Initializes sync status tracking.
  Future<void> initialize() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final lastSyncTimestamp = preferences.getInt(lastSyncAtKey);
      _status = _status.copyWith(
        lastSyncTime: lastSyncTimestamp == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp),
      );
      await _refreshPendingCount();
      _emitStatus();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to initialize SyncService',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
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
    } catch (error, stackTrace) {
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

  /// Pulls remote changes newer than the stored last sync timestamp.
  Future<void> pullAllChanges() async {
    try {
      final firestore = firebaseServices.db;
      if (firestore == null) {
        return;
      }

      final preferences = await SharedPreferences.getInstance();
      final lastSyncTimestamp = preferences.getInt(lastSyncAtKey) ?? 0;
      final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);

      final latestProductChange = await _pullProducts(firestore, lastSyncTime);
      final latestMovementChange = await _pullStockMovements(
        firestore,
        lastSyncTime,
      );
      final latestAlertChange = await _pullAlerts(firestore, lastSyncTime);
      final latestAuditLogChange = await _pullAuditLogs(
        firestore,
        lastSyncTime,
      );
      final latestTaskChange = await _pullTasks(firestore, lastSyncTime);
      final latestMetricChange = await _pullSyncMetrics(
        firestore,
        lastSyncTime,
      );

      final latestRemoteChange = <DateTime>[
        lastSyncTime,
        if (latestProductChange != null) latestProductChange,
        if (latestMovementChange != null) latestMovementChange,
        if (latestAlertChange != null) latestAlertChange,
        if (latestAuditLogChange != null) latestAuditLogChange,
        if (latestTaskChange != null) latestTaskChange,
        if (latestMetricChange != null) latestMetricChange,
      ].reduce((value, element) => value.isAfter(element) ? value : element);

      await preferences.setInt(
        lastSyncAtKey,
        latestRemoteChange.millisecondsSinceEpoch,
      );
      _status = _status.copyWith(lastSyncTime: latestRemoteChange);
      _emitStatus();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'pullAllChanges failed',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// Compatibility alias retained for existing startup and feature code.
  Future<void> pullFromFirebase() => pullAllChanges();

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
    );
  }

  /// Runs push followed by pull.
  Future<void> syncAllPending() async {
    if (_syncInProgress) {
      return;
    }
    _syncInProgress = true;
    _setSyncing(true);
    try {
      await pushAllPending();
      await pullAllChanges();
      await _refreshPendingCount();
    } finally {
      _syncInProgress = false;
      _setSyncing(false);
    }
  }

  Future<DateTime?> _pullProducts(
    FirebaseFirestore firestore,
    DateTime lastSyncTime,
  ) async {
    final snapshot = await firestore
        .collection(productsCollection)
        .where('lastModified', isGreaterThan: Timestamp.fromDate(lastSyncTime))
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
        .where('timestamp', isGreaterThan: Timestamp.fromDate(lastSyncTime))
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
    final snapshot = await firestore.collection(collectionName).limit(500).get();
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
    final queueId = operation['queueId'] as int?;
    if (queueId != null) {
      await _queueService.incrementRetry(queueId);
    } else {
      await _queueService.addToQueue(
        collectionName: operation['collectionName'] as String,
        documentId: operation['documentId'] as String,
        operation: operation['operation'] as String,
        payload: operation['payload'],
      );
    }
    await _refreshPendingCount();
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
    return <String, dynamic>{
      'collectionName': queue.collectionName,
      'documentId': queue.documentId,
      'operation': queue.operation,
      'payload': jsonDecode(queue.payload) as Map<String, dynamic>,
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

  Future<void> _refreshPendingCount() async {
    final count = await _queueService.getPendingCount();
    _status = _status.copyWith(pendingCount: count);
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
