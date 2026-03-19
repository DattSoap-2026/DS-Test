import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../services/database_service.dart';
import '../local/base_entity.dart';
import '../local/entities/dispatch_entity.dart';

/// Isar-first repository for dispatch records.
class DispatchRepository {
  DispatchRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  static const Uuid _uuid = Uuid();

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  Future<void> saveDispatch(DispatchEntity dispatch) async {
    final id = _ensureId(dispatch);
    final existing = await _dbService.dispatches.getById(id);
    dispatch
      ..id = id
      ..dispatchId = _safeString(() => dispatch.dispatchId, fallback: id)
      ..createdAt = _ensureDate(() => dispatch.createdAt, existing?.createdAt)
      ..status = _safeString(() => dispatch.status, fallback: 'created')
      ..itemsJson = _safeString(() => dispatch.itemsJson, fallback: '[]');

    await _stampForSync(dispatch, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.dispatches.put(dispatch);
    });

    await _enqueue(
      dispatch,
      existing == null ? 'create' : 'update',
    );
    await _syncIfOnline();
  }

  Future<void> updateDispatchStatus(String id, String status) async {
    final dispatch = await _dbService.dispatches.getById(id);
    if (dispatch == null || dispatch.isDeleted) {
      return;
    }
    dispatch.status = status;
    await _updateDispatch(dispatch);
  }

  Future<void> receiveDispatch(String id, DateTime receivedAt) async {
    final dispatch = await _dbService.dispatches.getById(id);
    if (dispatch == null || dispatch.isDeleted) {
      return;
    }
    dispatch
      ..status = 'received'
      ..receivedAt = receivedAt;
    await _updateDispatch(dispatch);
  }

  Future<List<DispatchEntity>> getAllDispatches() {
    return _dbService.dispatches
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<DispatchEntity?> getDispatchById(String id) {
    return _dbService.dispatches
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<List<DispatchEntity>> getDispatchesBySalesman(String salesmanId) {
    return _dbService.dispatches
        .filter()
        .salesmanIdEqualTo(salesmanId)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<DispatchEntity>> getDispatchesByStatus(String status) {
    return _dbService.dispatches
        .filter()
        .statusEqualTo(status)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<DispatchEntity>> getPendingDispatches() async {
    final all = await getAllDispatches();
    return all.where((dispatch) => dispatch.status != 'received').toList(growable: false);
  }

  Stream<List<DispatchEntity>> watchAllDispatches() {
    return _dbService.dispatches
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  Future<void> deleteDispatch(String id) async {
    final dispatch = await _dbService.dispatches.getById(id);
    if (dispatch == null || dispatch.isDeleted) {
      return;
    }

    dispatch
      ..isDeleted = true
      ..deletedAt = DateTime.now();

    await _stampDeleted(dispatch);
    await _dbService.db.writeTxn(() async {
      await _dbService.dispatches.put(dispatch);
    });

    await _enqueue(dispatch, 'delete');
    await _syncIfOnline();
  }

  Future<void> _updateDispatch(DispatchEntity dispatch) async {
    await _stampForSync(dispatch, dispatch);
    await _dbService.db.writeTxn(() async {
      await _dbService.dispatches.put(dispatch);
    });

    await _enqueue(dispatch, 'update');
    await _syncIfOnline();
  }

  Future<void> _stampForSync(BaseEntity entity, BaseEntity? existing) async {
    entity
      ..updatedAt = DateTime.now()
      ..deletedAt = entity.isDeleted ? entity.deletedAt : null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();
  }

  Future<void> _stampDeleted(BaseEntity entity) async {
    entity
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();
  }

  Future<void> _enqueue(DispatchEntity dispatch, String operation) {
    return _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.dispatches,
      documentId: dispatch.id,
      operation: operation,
      payload: dispatch.toJson(),
    );
  }

  String _ensureId(BaseEntity entity) {
    try {
      final current = entity.id.trim();
      if (current.isNotEmpty) {
        return current;
      }
    } catch (_) {
      // Late init fallback.
    }
    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
  }

  String _safeString(String Function() reader, {String fallback = ''}) {
    try {
      final value = reader().trim();
      return value.isEmpty ? fallback : value;
    } catch (_) {
      return fallback;
    }
  }

  DateTime _ensureDate(DateTime Function() reader, DateTime? fallback) {
    try {
      return reader();
    } catch (_) {
      return fallback ?? DateTime.now();
    }
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
