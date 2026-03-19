import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/inventory_location_entity.dart';
import '../../services/database_service.dart';

/// Isar-first repository for inventory locations.
class InventoryLocationRepository {
  InventoryLocationRepository(
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

  /// Saves a location locally first, then enqueues sync.
  Future<void> saveLocation(InventoryLocationEntity entity) async {
    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();
    final id = _ensureId(entity);
    final existing = await _dbService.inventoryLocations.getById(id);

    entity
      ..id = id
      ..updatedAt = now
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false
      ..isSynced = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = deviceId;

    await _dbService.db.writeTxn(() async {
      await _dbService.inventoryLocations.put(entity);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.inventoryLocations,
      documentId: entity.id,
      operation: existing == null ? 'create' : 'update',
      payload: entity.toJson(),
    );

    await _syncIfOnline();
  }

  /// Returns all active locations from Isar only.
  Future<List<InventoryLocationEntity>> getAllLocations() async {
    return _dbService.inventoryLocations
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  /// Returns a location by id when it is not soft-deleted.
  Future<InventoryLocationEntity?> getLocationById(String id) async {
    return _dbService.inventoryLocations
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Watches all active locations from Isar.
  Stream<List<InventoryLocationEntity>> watchAllLocations() {
    return _dbService.inventoryLocations
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true);
  }

  /// Soft-deletes a location locally and enqueues the delete sync.
  Future<void> deleteLocation(String id) async {
    final existing = await _dbService.inventoryLocations.getById(id);
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
      await _dbService.inventoryLocations.put(existing);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.inventoryLocations,
      documentId: existing.id,
      operation: 'delete',
      payload: existing.toJson(),
    );

    await _syncIfOnline();
  }

  String _ensureId(InventoryLocationEntity entity) {
    try {
      final current = entity.id.trim();
      if (current.isNotEmpty) {
        return current;
      }
    } catch (_) {
      // Late initialization fallback.
    }
    final fromCode = entity.code.trim();
    if (fromCode.isNotEmpty) {
      entity.id = fromCode;
      return fromCode;
    }
    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
