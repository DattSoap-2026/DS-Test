import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/opening_stock_entity.dart';
import '../../services/database_service.dart';

/// Isar-first repository for opening stock entries.
class OpeningStockRepository {
  OpeningStockRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  static const Uuid _uuid = Uuid();

  /// Saves an opening stock entry locally first, then enqueues sync.
  Future<void> saveOpeningStock(OpeningStockEntity entity) async {
    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();
    final id = _ensureId(entity);
    final existing = await _dbService.openingStocks.getById(id);

    entity
      ..id = id
      ..createdAt = _resolveCreatedAt(entity, existing?.createdAt, now)
      ..createdBy = _resolveCreatedBy(entity, deviceId)
      ..updatedAt = now
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false
      ..isSynced = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = deviceId;

    await _dbService.db.writeTxn(() async {
      await _dbService.openingStocks.put(entity);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.openingStockEntries,
      documentId: entity.id,
      operation: existing == null ? 'create' : 'update',
      payload: entity.toJson(),
    );

    await _syncIfOnline();
  }

  /// Returns opening stock entries for a product from Isar only.
  Future<List<OpeningStockEntity>> getOpeningStockByProduct(
    String productId,
  ) async {
    return _dbService.openingStocks
        .filter()
        .productIdEqualTo(productId)
        .and()
        .isDeletedEqualTo(false)
        .sortByEntryDateDesc()
        .findAll();
  }

  /// Returns all opening stock entries from Isar only.
  Future<List<OpeningStockEntity>> getAllOpeningStock() async {
    return _dbService.openingStocks
        .filter()
        .isDeletedEqualTo(false)
        .sortByEntryDateDesc()
        .findAll();
  }

  /// Watches all active opening stock entries from Isar.
  Stream<List<OpeningStockEntity>> watchAllOpeningStock() {
    return _dbService.openingStocks
        .filter()
        .isDeletedEqualTo(false)
        .sortByEntryDateDesc()
        .watch(fireImmediately: true);
  }

  /// Soft-deletes an opening stock entry and enqueues the delete sync.
  Future<void> deleteOpeningStock(String id) async {
    final existing = await _dbService.openingStocks.getById(id);
    if (existing == null || existing.isDeleted) {
      return;
    }

    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();
    existing
      ..isDeleted = true
      ..deletedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = deviceId;

    await _dbService.db.writeTxn(() async {
      await _dbService.openingStocks.put(existing);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.openingStockEntries,
      documentId: existing.id,
      operation: 'delete',
      payload: existing.toJson(),
    );

    await _syncIfOnline();
  }

  String _ensureId(OpeningStockEntity entity) {
    try {
      final current = entity.id.trim();
      if (current.isNotEmpty) {
        return current;
      }
    } catch (_) {
      // Late initialization fallback.
    }
    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
  }

  DateTime _resolveCreatedAt(
    OpeningStockEntity entity,
    DateTime? existingCreatedAt,
    DateTime now,
  ) {
    try {
      return entity.createdAt;
    } catch (_) {
      return existingCreatedAt ?? now;
    }
  }

  String _resolveCreatedBy(OpeningStockEntity entity, String deviceId) {
    try {
      final current = entity.createdBy.trim();
      if (current.isNotEmpty) {
        return current;
      }
    } catch (_) {
      // Late initialization fallback.
    }
    entity.createdBy = deviceId;
    return deviceId;
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
