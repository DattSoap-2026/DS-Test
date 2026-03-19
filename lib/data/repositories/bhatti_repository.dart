import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/firebase/firebase_config.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../services/bhatti_service.dart';
import '../../services/database_service.dart';
import '../../services/inventory_movement_engine.dart';
import '../../services/inventory_projection_service.dart';
import '../../services/inventory_service.dart';
import '../../services/tank_service.dart';
import '../local/base_entity.dart';
import '../local/entities/bhatti_batch_entity.dart';
import '../local/entities/bhatti_entry_entity.dart';
import '../local/entities/cutting_batch_entity.dart';
import '../local/entities/product_entity.dart';
import '../local/entities/stock_balance_entity.dart';
import '../local/entities/wastage_log_entity.dart';

/// Isar-first repository for Bhatti, cutting, and wastage operations.
class BhattiRepository {
  BhattiRepository(
    this._dbService, {
    FirebaseServices? firebaseServices,
    InventoryProjectionService? inventoryProjectionService,
    InventoryMovementEngine? inventoryMovementEngine,
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _inventoryProjectionService =
           inventoryProjectionService ?? InventoryProjectionService(_dbService),
       _inventoryMovementEngine = inventoryMovementEngine ??
           InventoryMovementEngine(
             _dbService,
             inventoryProjectionService ?? InventoryProjectionService(_dbService),
           ),
       _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance,
       _bhattiService = firebaseServices == null
           ? null
           : BhattiService(
               firebaseServices,
               _dbService,
               TankService(firebaseServices, _dbService),
               InventoryService(firebaseServices, _dbService),
               inventoryMovementEngine ??
                   InventoryMovementEngine(
                     _dbService,
                     inventoryProjectionService ??
                         InventoryProjectionService(_dbService),
                   ),
             );

  static const Uuid _uuid = Uuid();

  final DatabaseService _dbService;
  final InventoryProjectionService _inventoryProjectionService;
  final InventoryMovementEngine _inventoryMovementEngine;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;
  final BhattiService? _bhattiService;

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  String _normalizedToken(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _resolveBhattiKey(String bhattiId, String bhattiName) {
    final source = '$bhattiId $bhattiName'.toLowerCase();
    if (source.contains('gita')) return 'gita';
    if (source.contains('sona')) return 'sona';
    return '';
  }

  int _scoreSemiProductMatch(ProductEntity product, String key) {
    final normalizedKey = _normalizedToken(key);
    final name = product.name.toLowerCase();
    final normalizedName = _normalizedToken(name);
    final sku = product.sku.toLowerCase();
    final normalizedSku = _normalizedToken(sku);
    final category = (product.category ?? '').toLowerCase();
    final baseUnit = product.baseUnit.toLowerCase();

    var score = 0;
    if (normalizedName == normalizedKey) score += 1000;
    if (name == key) score += 900;
    if (normalizedName.startsWith(normalizedKey)) score += 500;
    if (name.startsWith('$key ') || name.endsWith(' $key') || name.contains(' $key ')) {
      score += 250;
    }
    if (normalizedSku == normalizedKey || normalizedSku.startsWith(normalizedKey)) {
      score += 180;
    } else if (normalizedSku.contains(normalizedKey)) {
      score += 120;
    }
    if (category.contains(key)) score += 80;
    if (name.contains(key)) score += 60;
    if (baseUnit.contains('box') || baseUnit.contains('batch')) score += 10;
    return score;
  }

  Future<ProductEntity?> _findSemiProductForBhatti({
    required String bhattiId,
    required String bhattiName,
  }) async {
    final bhattiKey = _resolveBhattiKey(bhattiId, bhattiName);
    if (bhattiKey.isEmpty) {
      return null;
    }

    final allProducts = await _dbService.products.where().findAll();
    final semiProducts = allProducts
        .where((product) => !product.isDeleted && product.itemType == 'Semi-Finished Good')
        .toList();
    if (semiProducts.isEmpty) {
      return null;
    }

    semiProducts.sort((left, right) {
      final scoreDiff =
          _scoreSemiProductMatch(right, bhattiKey) - _scoreSemiProductMatch(left, bhattiKey);
      if (scoreDiff != 0) {
        return scoreDiff;
      }
      return left.name.compareTo(right.name);
    });

    final best = semiProducts.first;
    return _scoreSemiProductMatch(best, bhattiKey) > 0 ? best : null;
  }

  String _semiFinishedVirtualLocationId(String bhattiId) {
    final token = _normalizedToken(bhattiId);
    return 'virtual:bhatti:${token.isEmpty ? 'unknown' : token}:output';
  }

  Future<void> _ensureWarehouseLocationReady() async {
    final existing = await _dbService.inventoryLocations.get(
      fastHash(InventoryProjectionService.warehouseMainLocationId),
    );
    if (existing != null) {
      return;
    }
    await _inventoryProjectionService.ensureCanonicalFoundation();
  }

  Future<void> _seedWarehouseBalanceInTxn({
    required String productId,
    required DateTime occurredAt,
  }) async {
    final balanceId = StockBalanceEntity.composeId(
      InventoryProjectionService.warehouseMainLocationId,
      productId,
    );
    final existing = await _dbService.stockBalances.get(fastHash(balanceId));
    if (existing != null) {
      return;
    }
    final product = await _dbService.products.getById(productId);
    final balance = StockBalanceEntity()
      ..id = balanceId
      ..locationId = InventoryProjectionService.warehouseMainLocationId
      ..productId = productId
      ..quantity = product?.stock ?? 0.0
      ..updatedAt = occurredAt
      ..syncStatus = product?.syncStatus ?? SyncStatus.pending
      ..isDeleted = false;
    await _dbService.stockBalances.put(balance);
  }

  Future<void> _applySemiStockAdjustmentForEntry({
    required String bhattiId,
    required String bhattiName,
    required String entryId,
    required int deltaOutputBoxes,
    required String actorUid,
    required DateTime updatedAt,
  }) async {
    final semiProduct = await _findSemiProductForBhatti(
      bhattiId: bhattiId,
      bhattiName: bhattiName,
    );
    if (semiProduct == null) {
      return;
    }

    final quantity = deltaOutputBoxes.abs().toDouble();
    if (quantity < 1e-9) {
      return;
    }
    if (deltaOutputBoxes < 0) {
      await _seedWarehouseBalanceInTxn(
        productId: semiProduct.id,
        occurredAt: updatedAt,
      );
    }

    final virtualBhattiLocationId = _semiFinishedVirtualLocationId(bhattiId);
    final command = deltaOutputBoxes > 0
        ? InventoryCommand.internalTransfer(
            sourceLocationId: virtualBhattiLocationId,
            destinationLocationId: InventoryProjectionService.warehouseMainLocationId,
            referenceId: entryId,
            productId: semiProduct.id,
            quantityBase: quantity,
            actorUid: actorUid,
            reasonCode: 'bhatti_semi_output',
            referenceType: 'bhatti_entry',
            createdAt: updatedAt,
          )
        : InventoryCommand.internalTransfer(
            sourceLocationId: InventoryProjectionService.warehouseMainLocationId,
            destinationLocationId: virtualBhattiLocationId,
            referenceId: entryId,
            productId: semiProduct.id,
            quantityBase: quantity,
            actorUid: actorUid,
            reasonCode: 'bhatti_semi_adjustment',
            referenceType: 'bhatti_entry',
            createdAt: updatedAt,
          );
    await _inventoryMovementEngine.applyCommandInTxn(command);
  }

  Future<String?> saveBhattiEntry({
    required DateTime date,
    required String bhattiId,
    required String bhattiName,
    String? teamCode,
    required int batchCount,
    required int outputBoxes,
    required double fuelConsumption,
    required String createdBy,
    required String createdByName,
    String? notes,
  }) async {
    final normalizedDate = _dateOnly(date);
    final entryId = '${bhattiId}_${normalizedDate.toIso8601String().split('T').first}';
    final entity = BhattiDailyEntryEntity()
      ..id = entryId
      ..date = normalizedDate
      ..bhattiId = bhattiId
      ..bhattiName = bhattiName
      ..teamCode = teamCode
      ..batchCount = batchCount
      ..outputBoxes = outputBoxes
      ..fuelConsumption = fuelConsumption
      ..createdBy = createdBy
      ..createdByName = createdByName
      ..createdAt = DateTime.now()
      ..notes = notes;

    await saveBhattiDailyEntry(entity);
    return entryId;
  }

  Future<void> saveBhattiDailyEntry(BhattiDailyEntryEntity entry) async {
    final id = _ensureBhattiEntryId(entry);
    final existing = await _dbService.bhattiEntries.getById(id);
    entry
      ..id = id
      ..date = _dateOnly(entry.date)
      ..createdAt = _ensureDate(() => entry.createdAt, existing?.createdAt)
      ..bhattiName = _safeString(() => entry.bhattiName)
      ..bhattiId = _safeString(() => entry.bhattiId)
      ..createdBy = _safeString(() => entry.createdBy)
      ..createdByName = _safeString(() => entry.createdByName)
      ..batchCount = entry.batchCount
      ..outputBoxes = entry.outputBoxes;

    await _ensureWarehouseLocationReady();
    await _stampForSync(entry, existing);
    await _dbService.db.writeTxn(() async {
      final previousOutputBoxes = existing?.outputBoxes ?? 0;
      await _dbService.bhattiEntries.put(entry);
      final deltaOutputBoxes = entry.outputBoxes - previousOutputBoxes;
      if (deltaOutputBoxes != 0) {
        await _applySemiStockAdjustmentForEntry(
          bhattiId: entry.bhattiId,
          bhattiName: entry.bhattiName,
          entryId: entry.id,
          deltaOutputBoxes: deltaOutputBoxes,
          actorUid: entry.createdBy.trim().isEmpty ? 'system' : entry.createdBy.trim(),
          updatedAt: entry.date,
        );
      }
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.bhattiDailyEntries,
      documentId: entry.id,
      operation: existing == null ? 'create' : 'update',
      payload: entry.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> saveBhattiBatch(BhattiBatchEntity batch) async {
    final id = _ensureId(batch);
    final existing = await _dbService.bhattiBatches.getById(id);
    batch
      ..id = id
      ..createdAt = _ensureDate(() => batch.createdAt, existing?.createdAt)
      ..status = _safeString(() => batch.status, fallback: 'cooking');

    await _stampForSync(batch, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.bhattiBatches.put(batch);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.bhattiBatches,
      documentId: batch.id,
      operation: existing == null ? 'create' : 'update',
      payload: batch.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> saveCuttingBatch(CuttingBatchEntity batch) async {
    final id = _ensureId(batch);
    final existing = await _dbService.cuttingBatches.getById(id);
    batch
      ..id = id
      ..createdAt = _ensureDate(() => batch.createdAt, existing?.createdAt)
      ..stage = _safeString(() => batch.stage, fallback: 'COMPLETED');

    await _stampForSync(batch, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.cuttingBatches.put(batch);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.cuttingBatches,
      documentId: batch.id,
      operation: existing == null ? 'create' : 'update',
      payload: batch.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> saveWastageLog(WastageLogEntity log) async {
    final id = _ensureId(log);
    final existing = await _dbService.wastageLogs.getById(id);
    log
      ..id = id
      ..createdAt = _ensureDate(() => log.createdAt, existing?.createdAt);

    await _stampForSync(log, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.wastageLogs.put(log);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.wastageLogs,
      documentId: log.id,
      operation: existing == null ? 'create' : 'update',
      payload: log.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> updateBatchStatus(String id, String status) async {
    final batch = await _dbService.bhattiBatches.getById(id);
    if (batch == null || batch.isDeleted) {
      return;
    }

    batch.status = status;
    await _stampForSync(batch, batch);
    await _dbService.db.writeTxn(() async {
      await _dbService.bhattiBatches.put(batch);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.bhattiBatches,
      documentId: batch.id,
      operation: 'update',
      payload: batch.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> completeBatch(String batchId, int outputBoxes) async {
    final batch = await _dbService.bhattiBatches.getById(batchId);
    if (batch == null || batch.isDeleted) {
      return;
    }

    batch
      ..status = 'completed'
      ..outputBoxes = outputBoxes;

    await _stampForSync(batch, batch);
    await _dbService.db.writeTxn(() async {
      await _dbService.bhattiBatches.put(batch);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.bhattiBatches,
      documentId: batch.id,
      operation: 'update',
      payload: batch.toJson(),
    );

    await _syncIfOnline();
  }

  Future<List<BhattiBatchEntity>> getAllBhattiBatches() {
    return _dbService.bhattiBatches
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<BhattiBatchEntity>> getBatchesByStatus(String status) {
    return _dbService.bhattiBatches
        .filter()
        .statusEqualTo(status)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<BhattiBatchEntity>> getBatchesByBhatti(String bhattiName) {
    return _dbService.bhattiBatches
        .filter()
        .bhattiNameEqualTo(bhattiName)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<BhattiDailyEntryEntity>> getAllDailyEntries() {
    return _dbService.bhattiEntries
        .filter()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<BhattiDailyEntryEntity>> getEntriesByDate(DateTime date) {
    final start = _dateOnly(date);
    final end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    return _dbService.bhattiEntries
        .filter()
        .dateBetween(start, end, includeUpper: true)
        .and()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<CuttingBatchEntity>> getAllCuttingBatches() {
    return _dbService.cuttingBatches
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<CuttingBatchEntity>> getCuttingBatchesByStatus(String status) {
    return _dbService.cuttingBatches
        .filter()
        .stageEqualTo(status)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<WastageLogEntity>> getAllWastageLogs() {
    return _dbService.wastageLogs
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Stream<List<BhattiBatchEntity>> watchAllBhattiBatches() {
    return _dbService.bhattiBatches
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<CuttingBatchEntity>> watchAllCuttingBatches() {
    return _dbService.cuttingBatches
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  Future<List<BhattiDailyEntryEntity>> getBhattiEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? bhattiId,
  }) async {
    var query = _dbService.bhattiEntries
        .filter()
        .dateBetween(startDate, endDate, includeUpper: true)
        .and()
        .isDeletedEqualTo(false);
    if (bhattiId != null && bhattiId.trim().isNotEmpty) {
      query = query.bhattiIdEqualTo(bhattiId.trim());
    }
    return query.sortByDateDesc().findAll();
  }

  Future<BhattiDailyEntryEntity?> getLatestBhattiEntry(String bhattiId) {
    return _dbService.bhattiEntries
        .filter()
        .bhattiIdEqualTo(bhattiId)
        .and()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findFirst();
  }

  Future<BhattiDailyEntryEntity?> getBhattiEntryByDate({
    required DateTime date,
    required String bhattiId,
  }) {
    final start = _dateOnly(date);
    final end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    return _dbService.bhattiEntries
        .filter()
        .bhattiIdEqualTo(bhattiId)
        .and()
        .dateBetween(start, end, includeUpper: true)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<void> fetchAndCacheBhattiEntries({
    required DateTime startDate,
    required DateTime endDate,
    String? bhattiId,
  }) async {
    final service = _bhattiService;
    if (service == null) {
      return;
    }
    final remoteEntries = await service.getDailyEntries(
      startDate: startDate,
      endDate: endDate,
      bhattiName: bhattiId,
    );
    if (remoteEntries.isEmpty) {
      return;
    }
    final entities = remoteEntries
        .map(BhattiDailyEntryEntity.fromFirebaseJson)
        .toList(growable: false);
    await _dbService.db.writeTxn(() async {
      await _dbService.bhattiEntries.putAll(entities);
    });
  }

  Future<void> _stampForSync(BaseEntity entity, BaseEntity? existing) async {
    entity
      ..updatedAt = DateTime.now()
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();
  }

  String _ensureId(BaseEntity entity) {
    try {
      final id = entity.id.trim();
      if (id.isNotEmpty) {
        return id;
      }
    } catch (_) {
      // Late init fallback.
    }
    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
  }

  String _ensureBhattiEntryId(BhattiDailyEntryEntity entry) {
    try {
      final id = entry.id.trim();
      if (id.isNotEmpty) {
        return id;
      }
    } catch (_) {
      // Late init fallback.
    }
    final generated = '${entry.bhattiId}_${_dateOnly(entry.date).toIso8601String().split('T').first}';
    entry.id = generated;
    return generated;
  }

  DateTime _ensureDate(DateTime Function() reader, DateTime? fallback) {
    try {
      return reader();
    } catch (_) {
      return fallback ?? DateTime.now();
    }
  }

  String _safeString(String Function() reader, {String fallback = ''}) {
    try {
      final value = reader().trim();
      return value.isEmpty ? fallback : value;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
