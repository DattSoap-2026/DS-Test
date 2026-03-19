import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/stock_ledger_entity.dart';
import '../../services/database_service.dart';

/// Isar-first repository for stock ledger entries.
class StockLedgerRepository {
  StockLedgerRepository(
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

  /// Adds or updates a ledger entry locally first, then enqueues sync.
  Future<void> addLedgerEntry(StockLedgerEntity entity) async {
    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();
    final id = _ensureId(entity);
    final existing = await _dbService.stockLedgers.getById(id);

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
      await _dbService.stockLedgers.put(entity);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.stockLedger,
      documentId: entity.id,
      operation: existing == null ? 'create' : 'update',
      payload: entity.toJson(),
    );

    await _syncIfOnline();
  }

  /// Returns ledger entries for a product from Isar only.
  Future<List<StockLedgerEntity>> getLedgerByProduct(String productId) async {
    return _dbService.stockLedgers
        .filter()
        .productIdEqualTo(productId)
        .and()
        .isDeletedEqualTo(false)
        .sortByTransactionDateDesc()
        .findAll();
  }

  /// Returns ledger entries for a warehouse from Isar only.
  Future<List<StockLedgerEntity>> getLedgerByWarehouse(
    String warehouseId,
  ) async {
    return _dbService.stockLedgers
        .filter()
        .warehouseIdEqualTo(warehouseId)
        .and()
        .isDeletedEqualTo(false)
        .sortByTransactionDateDesc()
        .findAll();
  }

  /// Watches ledger entries for a product from Isar only.
  Stream<List<StockLedgerEntity>> watchLedgerByProduct(String productId) {
    return _dbService.stockLedgers
        .filter()
        .productIdEqualTo(productId)
        .and()
        .isDeletedEqualTo(false)
        .sortByTransactionDateDesc()
        .watch(fireImmediately: true);
  }

  /// Returns all active ledger entries from Isar only.
  Future<List<StockLedgerEntity>> getAllLedger() async {
    return _dbService.stockLedgers
        .filter()
        .isDeletedEqualTo(false)
        .sortByTransactionDateDesc()
        .findAll();
  }

  String _ensureId(StockLedgerEntity entity) {
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

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
