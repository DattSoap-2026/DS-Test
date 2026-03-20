import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/optimistic_sync_payload.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../data/local/base_entity.dart';
import '../../data/local/entities/product_entity.dart';
import '../../data/local/entities/stock_ledger_entity.dart';
import '../../data/local/entities/stock_movement_entity.dart';
import '../../services/database_service.dart';
import '../../utils/app_logger.dart';

/// Canonical inventory repository backed by Isar entities.
class InventoryRepository {
  InventoryRepository(
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

  /// Fetches all active products from Isar.
  Future<List<ProductEntity>> getAllProducts() async {
    return _dbService.products
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  /// Watches all active products from Isar.
  Stream<List<ProductEntity>> watchAllProducts() {
    return _dbService.products
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true);
  }

  /// Returns a product by id when it is not soft-deleted.
  Future<ProductEntity?> getProductById(String id) async {
    return _dbService.products
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Returns a product by SKU when it is not soft-deleted.
  Future<ProductEntity?> getProductBySku(String sku) async {
    return _dbService.products
        .filter()
        .skuEqualTo(sku)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Searches active products by name or SKU from Isar only.
  Future<List<ProductEntity>> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      return getAllProducts();
    }

    return _dbService.products
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .group(
          (builder) => builder
              .nameContains(query, caseSensitive: false)
              .or()
              .skuContains(query, caseSensitive: false),
        )
        .sortByName()
        .findAll();
  }

  /// Returns products below the provided stock threshold.
  Future<List<ProductEntity>> getLowStockProducts(int threshold) async {
    return _dbService.products
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .stockLessThan(threshold.toDouble())
        .sortByStock()
        .findAll();
  }

  /// Watches products below the provided stock threshold.
  Stream<List<ProductEntity>> watchLowStockProducts(int threshold) {
    return _dbService.products
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .stockLessThan(threshold.toDouble())
        .sortByStock()
        .watch(fireImmediately: true);
  }

  /// Returns stock movements for a product from Isar only.
  Future<List<StockMovementEntity>> getStockMovements(String productId) async {
    return _dbService.stockMovements
        .filter()
        .productIdEqualTo(productId)
        .and()
        .isDeletedEqualTo(false)
        .sortByOccurredAtDesc()
        .findAll();
  }

  /// Watches stock movements for a product from Isar only.
  Stream<List<StockMovementEntity>> watchStockMovements(String productId) {
    return _dbService.stockMovements
        .filter()
        .productIdEqualTo(productId)
        .and()
        .isDeletedEqualTo(false)
        .sortByOccurredAtDesc()
        .watch(fireImmediately: true);
  }

  /// Applies a stock adjustment while preserving Isar-first behavior.
  Future<void> updateStock(String productId, double quantityDelta) async {
    if (quantityDelta == 0) {
      return;
    }

    if (quantityDelta > 0) {
      await addStock(productId, quantityDelta, 'ADJUSTMENT');
      return;
    }

    final success = await removeStock(
      productId,
      quantityDelta.abs(),
      'ADJUSTMENT',
    );
    if (!success) {
      throw StateError('Insufficient stock for product $productId');
    }
  }

  /// Saves a product locally first, then enqueues it for sync.
  Future<void> saveProduct(ProductEntity product) async {
    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();
    final productId = _ensureEntityId(product);
    final existing = await _dbService.products.getById(productId);

    product
      ..id = productId
      ..createdAt = product.createdAt ?? existing?.createdAt ?? now
      ..updatedAt = now
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = deviceId;

    await _dbService.db.writeTxn(() async {
      final current = await _dbService.products.getById(product.id);
      if (current != null) {
        product.stock = current.stock;
      } else {
        product.stock ??= 0.0;
      }
      product.encryptSensitiveFields();
      await _dbService.products.put(product);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.products,
      documentId: product.id,
      operation: existing == null ? 'create' : 'update',
      payload: product.toJson(),
    );

    await _syncIfOnline();
  }

  /// Saves a batch of products locally first, then enqueues each product.
  Future<void> saveProducts(List<ProductEntity> products) async {
    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();
    final operations = <Map<String, Object?>>[];

    for (final product in products) {
      final productId = _ensureEntityId(product);
      final existing = await _dbService.products.getById(productId);
      product
        ..id = productId
        ..createdAt = product.createdAt ?? existing?.createdAt ?? now
        ..updatedAt = now
        ..deletedAt = null
        ..syncStatus = SyncStatus.pending
        ..isSynced = false
        ..isDeleted = false
        ..lastSynced = null
        ..version = existing == null ? 1 : existing.version + 1
        ..deviceId = deviceId;
      operations.add(<String, Object?>{
        'documentId': productId,
        'operation': existing == null ? 'create' : 'update',
      });
    }

    await _dbService.db.writeTxn(() async {
      for (final product in products) {
        final current = await _dbService.products.getById(product.id);
        if (current != null) {
          product.stock = current.stock;
        } else {
          product.stock ??= 0.0;
        }
        product.encryptSensitiveFields();
      }
      await _dbService.products.putAll(products);
    });

    for (var index = 0; index < products.length; index++) {
      final product = products[index];
      final operation = operations[index];
      await _syncQueueService.addToQueue(
        collectionName: CollectionRegistry.products,
        documentId: operation['documentId']! as String,
        operation: operation['operation']! as String,
        payload: product.toJson(),
      );
    }

    await _syncIfOnline();
  }

  /// Soft-deletes a product locally and enqueues the delete sync.
  Future<void> deleteProduct(String productId) async {
    final existing = await _dbService.products.getById(productId);
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
      await _dbService.products.put(existing);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.products,
      documentId: existing.id,
      operation: 'delete',
      payload: existing.toJson(),
    );

    await _syncIfOnline();
  }

  /// Adds stock, creates movement and ledger records, and enqueues all changes.
  Future<void> addStock(
    String productId,
    double quantity,
    String reason, {
    String? warehouseId,
    String? referenceId,
    String? performedBy,
  }) async {
    await _changeStock(
      productId: productId,
      quantity: quantity,
      reason: reason,
      movementType: 'IN',
      warehouseId: warehouseId,
      referenceId: referenceId,
      performedBy: performedBy,
    );
  }

  /// Removes stock, creates movement and ledger records, and returns success.
  Future<bool> removeStock(
    String productId,
    double quantity,
    String reason, {
    String? warehouseId,
    String? referenceId,
    String? performedBy,
  }) async {
    final product = await getProductById(productId);
    if (product == null || (product.stock ?? 0.0) < quantity) {
      return false;
    }

    await _changeStock(
      productId: productId,
      quantity: quantity,
      reason: reason,
      movementType: 'OUT',
      warehouseId: warehouseId,
      referenceId: referenceId,
      performedBy: performedBy,
    );
    return true;
  }

  Future<void> _changeStock({
    required String productId,
    required double quantity,
    required String reason,
    required String movementType,
    String? warehouseId,
    String? referenceId,
    String? performedBy,
  }) async {
    final product = await getProductById(productId);
    if (product == null) {
      throw StateError('Product not found for $productId');
    }
    if (quantity <= 0) {
      return;
    }

    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();
    final previousProductSnapshot = ProductEntity.fromJson(product.toJson());
    final currentStock = product.stock ?? 0.0;
    final nextStock = movementType == 'IN'
        ? currentStock + quantity
        : currentStock - quantity;
    if (nextStock < 0) {
      throw StateError('Insufficient stock for $productId');
    }

    product
      ..stock = nextStock
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = deviceId;

    final movementId = _uuid.v4();
    final movement = StockMovementEntity()
      ..id = movementId
      ..productId = product.id
      ..productName = product.name
      ..quantityBase = quantity
      ..movementType = movementType
      ..reasonCode = reason
      ..referenceId = referenceId ?? movementId
      ..referenceType = 'inventory_stock_change'
      ..actorUid = deviceId
      ..occurredAt = now
      ..type = movementType
      ..source = warehouseId
      ..referenceNumber = referenceId
      ..userName = performedBy
      ..createdBy = performedBy
      ..notes = reason
      ..lastModified = now
      ..updatedAt = now
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = 1
      ..deviceId = deviceId;

    final ledger = StockLedgerEntity()
      ..id = _uuid.v4()
      ..productId = product.id
      ..warehouseId = warehouseId ?? ''
      ..transactionDate = now
      ..transactionType = movementType
      ..referenceId = referenceId ?? movementId
      ..quantityChange = movementType == 'IN' ? quantity : -quantity
      ..runningBalance = nextStock
      ..unit = product.baseUnit
      ..performedBy = performedBy ?? deviceId
      ..notes = reason
      ..updatedAt = now
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = 1
      ..deviceId = deviceId;

    await _dbService.db.writeTxn(() async {
      await _dbService.products.put(product);
      await _dbService.stockMovements.put(movement);
      await _dbService.stockLedger.put(ledger);
    });

    final rollbackOperations = <SyncRollbackOperation>[
      SyncRollbackOperation(
        collectionName: CollectionRegistry.products,
        documentId: previousProductSnapshot.id,
        action: 'put',
        payload: previousProductSnapshot.toJson(),
      ),
      SyncRollbackOperation(
        collectionName: CollectionRegistry.stockMovements,
        documentId: movement.id,
        action: 'delete',
      ),
      SyncRollbackOperation(
        collectionName: CollectionRegistry.stockLedger,
        documentId: ledger.id,
        action: 'delete',
      ),
    ];
    final groupId = 'stock_${product.id}_${now.microsecondsSinceEpoch}';
    final failureMessage =
        'Inventory sync failed after multiple retries. The stock change was reverted.';

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.products,
      documentId: product.id,
      operation: 'update',
      payload: OptimisticSyncEnvelope.wrap(
        payload: product.toJson(),
        groupId: groupId,
        rollbackOperations: rollbackOperations,
        failureMessage: failureMessage,
      ),
    );
    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.stockMovements,
      documentId: movement.id,
      operation: 'create',
      payload: OptimisticSyncEnvelope.wrap(
        payload: movement.toJson(),
        groupId: groupId,
        rollbackOperations: rollbackOperations,
        failureMessage: failureMessage,
      ),
    );
    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.stockLedger,
      documentId: ledger.id,
      operation: 'create',
      payload: OptimisticSyncEnvelope.wrap(
        payload: ledger.toJson(),
        groupId: groupId,
        rollbackOperations: rollbackOperations,
        failureMessage: failureMessage,
      ),
    );

    await _syncIfOnline();
  }

  String _ensureEntityId(BaseEntity entity) {
    try {
      final current = entity.id.trim();
      if (current.isNotEmpty) {
        return current;
      }
    } catch (_) {
      AppLogger.warning(
        'Generated a missing inventory entity id.',
        tag: 'InventoryRepo',
      );
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
