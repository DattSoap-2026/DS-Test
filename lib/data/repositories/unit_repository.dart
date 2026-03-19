import 'package:isar/isar.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/unit_entity.dart';
import '../../services/database_service.dart';

class UnitRepository {
  UnitRepository(
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

  Future<List<UnitEntity>> getAllUnits() async {
    return _dbService.units
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  Stream<List<UnitEntity>> watchAllUnits() {
    return _dbService.units
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true);
  }

  Future<UnitEntity?> getUnitById(String id) async {
    return _dbService.units
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<UnitEntity?> getUnitByName(String name) async {
    return _dbService.units
        .filter()
        .nameEqualTo(name)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<void> saveUnit(UnitEntity unit) async {
    final now = DateTime.now();
    final entityId = unit.id.trim().isEmpty ? unit.name.trim() : unit.id.trim();
    final existing = await _dbService.units.getById(entityId);

    unit
      ..id = entityId
      ..createdAt = _resolveCreatedAt(unit, now)
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false
      ..isSynced = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.units.put(unit);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.units,
      documentId: unit.id,
      operation: existing == null ? 'create' : 'update',
      payload: unit.toJson(),
    );

    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  Future<void> deleteUnit(String idOrName) async {
    final existing = await _dbService.units.getById(idOrName) ??
        await _dbService.units.filter().nameEqualTo(idOrName).findFirst();
    if (existing == null || existing.isDeleted) {
      return;
    }

    final now = DateTime.now();
    existing
      ..isDeleted = true
      ..deletedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1;

    await _dbService.db.writeTxn(() async {
      await _dbService.units.put(existing);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.units,
      documentId: existing.id,
      operation: 'delete',
      payload: existing.toJson(),
    );

    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  String _resolveCreatedAt(UnitEntity unit, DateTime now) {
    try {
      if (unit.createdAt.trim().isNotEmpty) {
        return unit.createdAt;
      }
    } catch (_) {
      // Late initialization fallback.
    }
    return now.toIso8601String();
  }
}
