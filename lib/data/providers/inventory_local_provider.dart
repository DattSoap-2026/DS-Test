import 'package:isar/isar.dart';
import '../../data/local/base_entity.dart';
import '../../data/local/entities/product_entity.dart';
import '../../data/local/entities/stock_movement_entity.dart';
import '../../data/local/entities/stock_ledger_entity.dart';
import '../../data/local/entities/department_stock_entity.dart';
import '../../data/local/entities/sync_queue_entity.dart';
import '../../services/database_service.dart';
import '../../services/outbox_codec.dart';

/// Stateless Isar data access layer for inventory entities.
///
/// Responsibilities:
/// - Local DB reads/writes for products, stock movements,
///   stock ledger entries, and department stock.
/// - No business logic, no calculations, no UI dependencies.
class InventoryLocalProvider {
  final DatabaseService _dbService;
  static const String stockMovementsCollection = 'stock_movements';
  static const String stockLedgerCollection = 'stock_ledger';
  static const int _pageSize = 500;

  InventoryLocalProvider(this._dbService);

  // ── Products ──────────────────────────────────────────────

  Future<ProductEntity?> getProductById(String id) async {
    return _dbService.products.filter().idEqualTo(id).findFirst();
  }

  Future<List<ProductEntity>> getAllProducts() async {
    return _dbService.products.filter().isDeletedEqualTo(false).findAll();
  }

  Future<void> saveProduct(ProductEntity entity) async {
    await _dbService.db.writeTxn(() async {
      await _dbService.products.put(entity);
    });
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
    await _dbService.db.writeTxn(() async {
      await _dbService.stockMovements.put(entity);
    });
  }

  Future<void> saveStockMovements(List<StockMovementEntity> entities) async {
    await _dbService.db.writeTxn(() async {
      await _dbService.stockMovements.putAll(entities);
    });
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
    await _dbService.db.writeTxn(() async {
      await _dbService.stockLedger.put(entity);
    });
  }

  Future<void> saveLedgerEntries(List<StockLedgerEntity> entities) async {
    await _dbService.db.writeTxn(() async {
      await _dbService.stockLedger.putAll(entities);
    });
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
    await _dbService.db.writeTxn(() async {
      await _dbService.departmentStocks.put(entity);
    });
  }

  // ── Sync Queue ────────────────────────────────────────────

  Future<String> enqueueMovementForSync(
    Map<String, dynamic> data, {
    String action = 'add',
  }) async {
    final id = data['id']?.toString();
    if (id == null || id.isEmpty) return '';

    final queueId = '${stockMovementsCollection}_$id';
    final existing = await _dbService.syncQueue.getById(queueId);
    final now = DateTime.now();
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;

    final entity = SyncQueueEntity()
      ..id = queueId
      ..collection = stockMovementsCollection
      ..action = action
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: data,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: true,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.put(entity);
    });
    return queueId;
  }
}
