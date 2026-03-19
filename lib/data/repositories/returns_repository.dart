import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/return_entity.dart';
import '../../services/database_service.dart';

class ReturnsRepository {
  static const Uuid _uuid = Uuid();

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  ReturnsRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  // Save (Create/Update) Return Request
  Future<void> saveReturnRequest(ReturnEntity request) async {
    await saveReturn(request);
  }

  /// Saves a return locally first, then enqueues sync.
  Future<void> saveReturn(ReturnEntity request) async {
    final now = DateTime.now();
    final existing = await _dbService.returns.getById(_ensureId(request));
    final createdAt = _resolveCreatedAt(request, existing?.createdAt, now);

    request
      ..createdAt = createdAt
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..deletedAt = null
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.returns.put(request);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.returns,
      documentId: request.id,
      operation: existing == null ? 'create' : 'update',
      payload: request.toJson(),
    );

    await _syncIfOnline();
  }

  /// Approves a return and queues the update.
  Future<void> approveReturn(String id, String approvedBy) async {
    final request = await _dbService.returns.getById(id);
    if (request == null || request.isDeleted) {
      return;
    }

    request
      ..status = 'approved'
      ..approvedBy = approvedBy
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.returns.put(request);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.returns,
      documentId: request.id,
      operation: 'update',
      payload: request.toJson(),
    );

    await _syncIfOnline();
  }

  /// Rejects a return and queues the update.
  Future<void> rejectReturn(String id, String reason) async {
    final request = await _dbService.returns.getById(id);
    if (request == null || request.isDeleted) {
      return;
    }

    request
      ..status = 'rejected'
      ..disposition = reason
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.returns.put(request);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.returns,
      documentId: request.id,
      operation: 'update',
      payload: request.toJson(),
    );

    await _syncIfOnline();
  }

  // Get Pending Returns (for Sync)
  Future<List<ReturnEntity>> getPendingReturns() async {
    return _dbService.returns
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
  }

  // Get All Returns (for UI - Salesman History)
  Future<List<ReturnEntity>> getReturns({String? salesmanId}) async {
    if (salesmanId != null) {
      return _dbService.returns
          .filter()
          .salesmanIdEqualTo(salesmanId)
          .and()
          .isDeletedEqualTo(false)
          .sortByCreatedAtDesc()
          .findAll();
    }
    return _dbService.returns
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Returns all non-deleted returns from Isar.
  Future<List<ReturnEntity>> getAllReturns() async {
    return getReturns();
  }

  /// Returns salesman-specific non-deleted returns from Isar.
  Future<List<ReturnEntity>> getReturnsBySalesman(String salesmanId) async {
    return getReturns(salesmanId: salesmanId);
  }

  /// Streams all non-deleted returns from Isar.
  Stream<List<ReturnEntity>> watchAllReturns() {
    return _dbService.returns
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  String _ensureId(ReturnEntity request) {
    try {
      final normalized = request.id.trim();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    } catch (_) {
      // Late initialization fallback.
    }
    final generated = _uuid.v4();
    request.id = generated;
    return generated;
  }

  DateTime _resolveCreatedAt(
    ReturnEntity request,
    DateTime? existingCreatedAt,
    DateTime now,
  ) {
    try {
      return request.createdAt;
    } catch (_) {
      return existingCreatedAt ?? now;
    }
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
