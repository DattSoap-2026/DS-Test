import 'package:isar/isar.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/scheme_entity.dart';
import '../../services/database_service.dart';

class SchemeRepository {
  SchemeRepository(
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

  Future<List<SchemeEntity>> getAllSchemes({String? status}) async {
    var query = _dbService.schemes.filter().isDeletedEqualTo(false);
    if (status != null && status.trim().isNotEmpty && status != 'all') {
      query = query.and().statusEqualTo(status);
    }
    return query.sortByName().findAll();
  }

  Stream<List<SchemeEntity>> watchAllSchemes({String? status}) {
    var query = _dbService.schemes.filter().isDeletedEqualTo(false);
    if (status != null && status.trim().isNotEmpty && status != 'all') {
      query = query.and().statusEqualTo(status);
    }
    return query.sortByName().watch(fireImmediately: true);
  }

  Future<SchemeEntity?> getSchemeById(String id) async {
    return _dbService.schemes
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<void> saveScheme(SchemeEntity scheme) async {
    final now = DateTime.now();
    final entityId = scheme.id.trim().isEmpty
        ? _fallbackId(scheme.name)
        : scheme.id.trim();
    final existing = await _dbService.schemes.getById(entityId);

    scheme
      ..id = entityId
      ..createdAt = _resolveCreatedAt(scheme, now)
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false
      ..isSynced = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.schemes.put(scheme);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.schemes,
      documentId: scheme.id,
      operation: existing == null ? 'create' : 'update',
      payload: scheme.toJson(),
    );

    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  Future<void> deleteScheme(String id) async {
    final existing = await _dbService.schemes.getById(id);
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
      await _dbService.schemes.put(existing);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.schemes,
      documentId: existing.id,
      operation: 'delete',
      payload: existing.toJson(),
    );

    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  DateTime _resolveCreatedAt(SchemeEntity scheme, DateTime now) {
    try {
      return scheme.createdAt;
    } catch (_) {
      return now;
    }
  }

  String _fallbackId(String name) {
    final normalized = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    if (normalized.isNotEmpty) {
      return normalized;
    }
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
