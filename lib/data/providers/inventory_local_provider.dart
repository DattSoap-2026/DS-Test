import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../data/local/base_entity.dart';
import '../../data/local/entities/department_stock_entity.dart';
import '../../data/local/entities/product_entity.dart';
import '../../data/local/entities/stock_ledger_entity.dart';
import '../../data/local/entities/stock_movement_entity.dart';
import '../../services/database_service.dart';

/// Stateless Isar data access layer for inventory entities.
///
/// Responsibilities:
/// - Local DB reads/writes for products, stock movements,
///   stock ledger entries, and department stock.
/// - No business logic, no calculations, no UI dependencies.
class InventoryLocalProvider {
  InventoryLocalProvider(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
    Uuid? uuid,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance,
       _uuid = uuid ?? const Uuid();

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;
  final Uuid _uuid;

  static const String productsCollection = CollectionRegistry.products;
  static const String stockMovementsCollection = CollectionRegistry.stockMovements;
  static const String stockLedgerCollection = CollectionRegistry.stockLedger;
  static const String departmentStocksCollection =
      CollectionRegistry.departmentStocks;
  static const int _pageSize = 500;

  // ── Products ──────────────────────────────────────────────

  Future<ProductEntity?> getProductById(String id) async {
    return _dbService.products.filter().idEqualTo(id).findFirst();
  }

  Future<List<ProductEntity>> getAllProducts() async {
    return _dbService.products.filter().isDeletedEqualTo(false).findAll();
  }

  Future<void> saveProduct(ProductEntity entity) async {
    final prepared = await _prepareProductForWrite(entity);
    await _dbService.db.writeTxn(() async {
      await _dbService.products.put(prepared.entity);
    });
    await _syncQueueService.addToQueue(
      collectionName: productsCollection,
      documentId: prepared.entity.id,
      operation: prepared.operation,
      payload: prepared.entity.toJson(),
    );
    await _syncIfOnline();
  }

  // ── Stock Movements ───────────────────────────────────────

  Future<List<StockMovementEntity>> getStockMovements({
    String? productId,
    String? movementType,
    DateTime? startDate,
    DateTime? endDate,
    int? limitCount,
  }) async {
    var query = _dbService.stockMovements.filter().isDeletedEqualTo(false);

    if (productId != null) {
      query = query.and().productIdEqualTo(productId);
    }
    if (movementType != null) {
      query = query.and().movementTypeEqualTo(movementType);
    }
    if (startDate != null) {
      query = query.and().createdAtGreaterThan(startDate);
    }
    if (endDate != null) {
      query = query.and().createdAtLessThan(endDate);
    }

    var results = await query.findAll();
    results.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (limitCount != null && results.length > limitCount) {
      results = results.sublist(0, limitCount);
    }
    return results;
  }

  Future<void> saveStockMovement(StockMovementEntity entity) async {
    final prepared = await _prepareStockMovementForWrite(entity);
    await _dbService.db.writeTxn(() async {
      await _dbService.stockMovements.put(prepared.entity);
    });
    await _syncQueueService.addToQueue(
      collectionName: stockMovementsCollection,
      documentId: prepared.entity.id,
      operation: prepared.operation,
      payload: prepared.entity.toJson(),
    );
    await _syncIfOnline();
  }

  Future<void> saveStockMovements(List<StockMovementEntity> entities) async {
    final prepared = <_PreparedInventoryWrite<StockMovementEntity>>[];
    for (final entity in entities) {
      prepared.add(await _prepareStockMovementForWrite(entity));
    }
    await _dbService.db.writeTxn(() async {
      await _dbService.stockMovements.putAll(
        prepared.map((entry) => entry.entity).toList(growable: false),
      );
    });
    for (final entry in prepared) {
      await _syncQueueService.addToQueue(
        collectionName: stockMovementsCollection,
        documentId: entry.entity.id,
        operation: entry.operation,
        payload: entry.entity.toJson(),
      );
    }
    await _syncIfOnline();
  }

  // ── Stock Ledger ──────────────────────────────────────────

  Future<List<StockLedgerEntity>> getStockLedgerEntries({
    String? productId,
    DateTime? startDate,
    DateTime? endDate,
    int? limitCount,
  }) async {
    var query = _dbService.stockLedger.filter().isDeletedEqualTo(false);

    if (productId != null && productId.trim().isNotEmpty) {
      query = query.and().productIdEqualTo(productId.trim());
    }
    if (startDate != null) {
      query = query.and().transactionDateGreaterThan(startDate, include: true);
    }
    if (endDate != null) {
      query = query.and().transactionDateLessThan(endDate, include: true);
    }

    final entries = <StockLedgerEntity>[];
    var offset = 0;
    while (true) {
      final chunk = await query.offset(offset).limit(_pageSize).findAll();
      if (chunk.isEmpty) break;
      entries.addAll(chunk);
      if (chunk.length < _pageSize) break;
      offset += _pageSize;
    }

    entries.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
    if (limitCount != null && entries.length > limitCount) {
      return entries.sublist(entries.length - limitCount);
    }
    return entries;
  }

  Future<void> saveLedgerEntry(StockLedgerEntity entity) async {
    final prepared = await _prepareLedgerForWrite(entity);
    await _dbService.db.writeTxn(() async {
      await _dbService.stockLedger.put(prepared.entity);
    });
    await _syncQueueService.addToQueue(
      collectionName: stockLedgerCollection,
      documentId: prepared.entity.id,
      operation: prepared.operation,
      payload: prepared.entity.toJson(),
    );
    await _syncIfOnline();
  }

  Future<void> saveLedgerEntries(List<StockLedgerEntity> entities) async {
    final prepared = <_PreparedInventoryWrite<StockLedgerEntity>>[];
    for (final entity in entities) {
      prepared.add(await _prepareLedgerForWrite(entity));
    }
    await _dbService.db.writeTxn(() async {
      await _dbService.stockLedger.putAll(
        prepared.map((entry) => entry.entity).toList(growable: false),
      );
    });
    for (final entry in prepared) {
      await _syncQueueService.addToQueue(
        collectionName: stockLedgerCollection,
        documentId: entry.entity.id,
        operation: entry.operation,
        payload: entry.entity.toJson(),
      );
    }
    await _syncIfOnline();
  }

  // ── Department Stock ──────────────────────────────────────

  Future<DepartmentStockEntity?> getDepartmentStock(
    String departmentName,
    String productId,
  ) async {
    final docId = '${departmentName}_$productId';
    return _dbService.departmentStocks.filter().idEqualTo(docId).findFirst();
  }

  Future<List<DepartmentStockEntity>> getDepartmentStocks(
    String departmentName,
  ) async {
    return _dbService.departmentStocks
        .filter()
        .departmentNameEqualTo(departmentName)
        .isDeletedEqualTo(false)
        .findAll();
  }

  Future<void> saveDepartmentStock(DepartmentStockEntity entity) async {
    final prepared = await _prepareDepartmentStockForWrite(entity);
    await _dbService.db.writeTxn(() async {
      await _dbService.departmentStocks.put(prepared.entity);
    });
    await _syncQueueService.addToQueue(
      collectionName: departmentStocksCollection,
      documentId: prepared.entity.id,
      operation: prepared.operation,
      payload: prepared.entity.toJson(),
    );
    await _syncIfOnline();
  }

  // ── Sync Queue ────────────────────────────────────────────

  Future<String> enqueueMovementForSync(
    Map<String, dynamic> data, {
    String action = 'add',
  }) async {
    final id = data['id']?.toString();
    if (id == null || id.isEmpty) return '';

    await _syncQueueService.addToQueue(
      collectionName: stockMovementsCollection,
      documentId: id,
      operation: action,
      payload: data,
    );
    return id;
  }

  Future<_PreparedInventoryWrite<ProductEntity>> _prepareProductForWrite(
    ProductEntity entity,
  ) async {
    final now = DateTime.now();
    final id = _ensureId(entity);
    final existing = await _dbService.products.getById(id);

    entity
      ..id = id
      ..createdAt = entity.createdAt ?? existing?.createdAt ?? now
      ..updatedAt = now
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    return _PreparedInventoryWrite(
      entity,
      existing == null ? 'create' : 'update',
    );
  }

  Future<_PreparedInventoryWrite<StockMovementEntity>>
  _prepareStockMovementForWrite(StockMovementEntity entity) async {
    final now = DateTime.now();
    final id = _ensureId(entity);
    final existing = await _dbService.stockMovements.getById(id);
    DateTime occurredAt;
    try {
      occurredAt = entity.occurredAt;
    } catch (_) {
      occurredAt = existing?.occurredAt ?? now;
    }

    entity
      ..id = id
      ..occurredAt = existing?.occurredAt ?? occurredAt
      ..updatedAt = now
      ..lastModified = now
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    return _PreparedInventoryWrite(
      entity,
      existing == null ? 'create' : 'update',
    );
  }

  Future<_PreparedInventoryWrite<StockLedgerEntity>> _prepareLedgerForWrite(
    StockLedgerEntity entity,
  ) async {
    final now = DateTime.now();
    final id = _ensureId(entity);
    final existing = await _dbService.stockLedger.getById(id);

    entity
      ..id = id
      ..updatedAt = now
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    return _PreparedInventoryWrite(
      entity,
      existing == null ? 'create' : 'update',
    );
  }

  Future<_PreparedInventoryWrite<DepartmentStockEntity>>
  _prepareDepartmentStockForWrite(DepartmentStockEntity entity) async {
    final now = DateTime.now();
    final id = _composeDepartmentStockId(entity.departmentName, entity.productId);
    final existing = await _dbService.departmentStocks.getById(id);

    entity
      ..id = id
      ..updatedAt = now
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    return _PreparedInventoryWrite(
      entity,
      existing == null ? 'create' : 'update',
    );
  }

  String _ensureId(BaseEntity entity) {
    try {
      final normalized = entity.id.trim();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    } catch (_) {
      // Late initialization fallback.
    }

    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
  }

  String _composeDepartmentStockId(String departmentName, String productId) {
    return '${departmentName.trim()}_${productId.trim()}';
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.trySync();
    }
  }
}

class _PreparedInventoryWrite<T> {
  _PreparedInventoryWrite(this.entity, this.operation);

  final T entity;
  final String operation;
}
