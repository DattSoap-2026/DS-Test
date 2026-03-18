import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/firebase/firebase_config.dart';
import '../../features/inventory/models/product.dart';
import '../../features/inventory/models/stock_movement.dart';
import '../../features/inventory/models/sync_queue.dart';
import '../database/isar_service.dart';
import '../utils/device_id_service.dart';
import '../utils/sync_logger.dart';
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

/// Handles bidirectional inventory synchronization.
class SyncService {
  SyncService._internal();

  static final SyncService instance = SyncService._internal();

  static const String productsCollection = 'products';
  static const String stockMovementsCollection = 'stock_movements';
  static const String lastSyncAtKey = 'inventory_sync_last_sync_at_v1';

  final IsarService _isarService = IsarService.instance;
  final SyncQueueService _queueService = SyncQueueService.instance;
  final DeviceIdService _deviceIdService = DeviceIdService.instance;
  final StreamController<SyncStatusSnapshot> _statusController =
      StreamController<SyncStatusSnapshot>.broadcast();

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

  /// Pushes local unsynced records and queued operations to Firestore.
  Future<void> pushToFirebase() async {
    if (_syncInProgress) {
      return;
    }
    _syncInProgress = true;
    _setSyncing(true);
    try {
      final firestore = firebaseServices.db;
      if (firestore == null) {
        return;
      }

      final queueItems = await _queueService.getAllPending();
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

      final operations = await compute(_prepareBatchOperations, rawOperations);
      if (operations.isEmpty) {
        await _refreshPendingCount();
        return;
      }

      WriteBatch batch = firestore.batch();
      final pendingCommit = <Map<String, dynamic>>[];

      for (final operation in operations) {
        final collectionName = operation['collectionName'] as String;
        final documentId = operation['documentId'] as String;
        final type = operation['operation'] as String;
        final payload = Map<String, dynamic>.from(
          operation['payload'] as Map<String, dynamic>,
        );

        try {
          final document = firestore.collection(collectionName).doc(documentId);
          if (type == 'delete') {
            batch.set(
              document,
              <String, dynamic>{
                'isDeleted': true,
                'lastModified': _toTimestamp(payload['lastModified']),
                'version': payload['version'],
                'deviceId': payload['deviceId'],
              },
              SetOptions(merge: true),
            );
          } else {
            batch.set(document, _firestorePayload(payload), SetOptions(merge: true));
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

      await _queueService.deleteOldProcessed();
      await _refreshPendingCount();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'pushToFirebase failed',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    } finally {
      _syncInProgress = false;
      _setSyncing(false);
    }
  }

  /// Pulls remote changes newer than the stored last sync timestamp.
  Future<void> pullFromFirebase() async {
    try {
      final firestore = firebaseServices.db;
      if (firestore == null) {
        return;
      }

      final preferences = await SharedPreferences.getInstance();
      final lastSyncTimestamp = preferences.getInt(lastSyncAtKey) ?? 0;
      final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);

      final productSnapshot = await firestore
          .collection(productsCollection)
          .where(
            'lastModified',
            isGreaterThan: Timestamp.fromDate(lastSyncTime),
          )
          .get();

      final movementSnapshot = await firestore
          .collection(stockMovementsCollection)
          .where(
            'timestamp',
            isGreaterThan: Timestamp.fromDate(lastSyncTime),
          )
          .get();

      final payload = <String, dynamic>{
        'products': productSnapshot.docs
            .map((doc) => <String, dynamic>{'id': doc.id, 'data': doc.data()})
            .toList(),
        'stockMovements': movementSnapshot.docs
            .map((doc) => <String, dynamic>{'id': doc.id, 'data': doc.data()})
            .toList(),
      };

      final normalized = await compute(_normalizePullPayload, payload);
      var latestRemoteChange = lastSyncTime;

      for (final rawProduct in normalized['products'] as List<dynamic>) {
        final remote = Product.fromJson(
          Map<String, dynamic>.from(rawProduct as Map<dynamic, dynamic>),
        );
        final local = await _isarService.products
            .filter()
            .firebaseIdEqualTo(remote.firebaseId)
            .findFirst();
        final resolution = ConflictResolver.resolveProduct(
          local: local,
          remote: remote.copyWith(isSynced: true),
        );

        await _isarService.isar.writeTxn(() async {
          await _isarService.products.put(
            resolution.product.copyWith(
              isSynced: true,
              lastSynced: DateTime.now(),
            ),
          );
        });

        if (remote.lastModified.isAfter(latestRemoteChange)) {
          latestRemoteChange = remote.lastModified;
        }
      }

      for (final rawMovement in normalized['stockMovements'] as List<dynamic>) {
        final remote = StockMovement.fromJson(
          Map<String, dynamic>.from(rawMovement as Map<dynamic, dynamic>),
        );
        final local = await _isarService.stockMovements
            .filter()
            .firebaseIdEqualTo(remote.firebaseId)
            .findFirst();
        final resolution = ConflictResolver.resolveStockMovement(
          local: local,
          remote: remote.copyWith(isSynced: true),
        );

        await _isarService.isar.writeTxn(() async {
          await _isarService.stockMovements.put(
            resolution.stockMovement.copyWith(isSynced: true),
          );
        });

        if (remote.timestamp.isAfter(latestRemoteChange)) {
          latestRemoteChange = remote.timestamp;
        }
      }

      await preferences.setInt(
        lastSyncAtKey,
        latestRemoteChange.millisecondsSinceEpoch,
      );
      _status = _status.copyWith(lastSyncTime: latestRemoteChange);
      _emitStatus();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'pullFromFirebase failed',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// Runs push followed by pull without blocking UI.
  Future<void> syncAllPending() async {
    unawaited(
      Future<void>(() async {
        await pushToFirebase();
        await pullFromFirebase();
        await _refreshPendingCount();
      }),
    );
  }

  Future<void> _applySuccessfulOperations(
    List<Map<String, dynamic>> operations,
  ) async {
    final deviceId = await _deviceIdService.getDeviceId();
    final processedAt = DateTime.now();

    await _isarService.isar.writeTxn(() async {
      for (final operation in operations) {
        final collectionName = operation['collectionName'] as String;
        final documentId = operation['documentId'] as String;
        final queueId = operation['queueId'] as int?;

        if (collectionName == productsCollection) {
          final existing = await _isarService.products
              .filter()
              .firebaseIdEqualTo(documentId)
              .findFirst();
          if (existing != null) {
            await _isarService.products.put(
              existing.copyWith(
                isSynced: true,
                lastSynced: processedAt,
                deviceId: existing.deviceId.isEmpty ? deviceId : existing.deviceId,
              ),
            );
          }
        }

        if (collectionName == stockMovementsCollection) {
          final existing = await _isarService.stockMovements
              .filter()
              .firebaseIdEqualTo(documentId)
              .findFirst();
          if (existing != null) {
            await _isarService.stockMovements.put(
              existing.copyWith(
                isSynced: true,
                deviceId: existing.deviceId.isEmpty ? deviceId : existing.deviceId,
              ),
            );
          }
        }

        if (queueId != null) {
          await _isarService.syncQueues.delete(queueId);
        }
      }
    });

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
        payload: Map<String, dynamic>.from(
          operation['payload'] as Map<String, dynamic>,
        ),
      );
    }
    await _refreshPendingCount();
  }

  Map<String, dynamic> _buildProductOperation(Product product) {
    return <String, dynamic>{
      'collectionName': productsCollection,
      'documentId': product.firebaseId,
      'operation': product.isDeleted ? 'delete' : 'update',
      'payload': product.toJson(),
      'queueId': null,
    };
  }

  Map<String, dynamic> _buildStockMovementOperation(StockMovement stockMovement) {
    return <String, dynamic>{
      'collectionName': stockMovementsCollection,
      'documentId': stockMovement.firebaseId,
      'operation': 'create',
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
    final lastModified = _toTimestamp(normalized['lastModified']);
    final lastSynced = _toTimestamp(normalized['lastSynced']);
    final timestamp = _toTimestamp(normalized['timestamp']);

    if (lastModified != null) {
      normalized['lastModified'] = lastModified;
    }
    if (lastSynced != null) {
      normalized['lastSynced'] = lastSynced;
    } else {
      normalized.remove('lastSynced');
    }
    if (timestamp != null) {
      normalized['timestamp'] = timestamp;
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
    final count = await _isarService.syncQueues
        .filter()
        .isFailedEqualTo(false)
        .count();
    _status = _status.copyWith(pendingCount: count);
    _emitStatus();
  }

  void _setSyncing(bool isSyncing) {
    _status = _status.copyWith(isSyncing: isSyncing);
    _emitStatus();
  }

  void _emitStatus() {
    if (!_statusController.isClosed) {
      _statusController.add(_status);
    }
  }
}

Map<String, dynamic> _normalizePullPayload(Map<String, dynamic> payload) {
  final products = (payload['products'] as List<dynamic>)
      .map((dynamic raw) {
        final entry = Map<String, dynamic>.from(raw as Map<dynamic, dynamic>);
        final data = Map<String, dynamic>.from(
          entry['data'] as Map<dynamic, dynamic>,
        );
        data['firebaseId'] = entry['id'];
        data['lastModified'] = _normalizeDate(data['lastModified']);
        data['lastSynced'] = _normalizeDate(data['lastSynced']);
        return data;
      })
      .toList();

  final stockMovements = (payload['stockMovements'] as List<dynamic>)
      .map((dynamic raw) {
        final entry = Map<String, dynamic>.from(raw as Map<dynamic, dynamic>);
        final data = Map<String, dynamic>.from(
          entry['data'] as Map<dynamic, dynamic>,
        );
        data['firebaseId'] = entry['id'];
        data['timestamp'] = _normalizeDate(data['timestamp']);
        return data;
      })
      .toList();

  return <String, dynamic>{
    'products': products,
    'stockMovements': stockMovements,
  };
}

List<Map<String, dynamic>> _prepareBatchOperations(
  List<Map<String, dynamic>> operations,
) {
  final deduped = <String, Map<String, dynamic>>{};
  for (final operation in operations) {
    final collectionName = operation['collectionName'] as String;
    final documentId = operation['documentId'] as String;
    if (documentId.isEmpty) {
      continue;
    }
    deduped['$collectionName::$documentId'] = operation;
  }
  return deduped.values.toList();
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
