import 'package:isar/isar.dart';

import '../../../core/network/connectivity_service.dart';
import '../../../core/sync/sync_queue_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/utils/device_id_service.dart';
import '../../../data/local/entities/product_entity.dart';
import '../../../data/local/entities/stock_movement_entity.dart';
import '../../../data/repositories/inventory_repository.dart'
    as canonical_inventory;
import '../../../services/database_service.dart';

/// Compatibility repository for feature-layer inventory consumers.
class InventoryRepository {
  InventoryRepository({
    DatabaseService? databaseService,
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _dbService = databaseService ?? DatabaseService.instance,
       _repository = canonical_inventory.InventoryRepository(
         databaseService ?? DatabaseService.instance,
         syncQueueService: syncQueueService,
         syncService: syncService,
         connectivityService: connectivityService,
         deviceIdService: deviceIdService,
       );

  final DatabaseService _dbService;
  final canonical_inventory.InventoryRepository _repository;

  /// Saves a product via the canonical Isar-first repository.
  Future<ProductEntity> saveProduct(ProductEntity product) async {
    await _repository.saveProduct(product);
    return product;
  }

  /// Soft-deletes a product via the canonical Isar-first repository.
  Future<void> deleteProduct(String productId) {
    return _repository.deleteProduct(productId);
  }

  /// Adds stock via the canonical Isar-first repository.
  Future<void> addStock(String productId, int quantity, String reason) {
    return _repository.addStock(productId, quantity.toDouble(), reason);
  }

  /// Removes stock via the canonical Isar-first repository.
  Future<bool> removeStock(String productId, int quantity, String reason) {
    return _repository.removeStock(productId, quantity.toDouble(), reason);
  }

  /// Returns all active products from Isar.
  Future<List<ProductEntity>> getAllProducts() {
    return _repository.getAllProducts();
  }

  /// Streams all active products from Isar.
  Stream<List<ProductEntity>> watchAllProducts() {
    return _repository.watchAllProducts();
  }

  /// Searches products from Isar only.
  Future<List<ProductEntity>> searchProducts(String query) {
    return _repository.searchProducts(query);
  }

  /// Returns products below the provided stock threshold.
  Future<List<ProductEntity>> getLowStockProducts(int threshold) {
    return _repository.getLowStockProducts(threshold);
  }

  /// Streams products below the provided stock threshold.
  Stream<List<ProductEntity>> watchLowStockProducts(int threshold) {
    return _repository.watchLowStockProducts(threshold);
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

  /// Streams stock movements for a product from Isar only.
  Stream<List<StockMovementEntity>> watchStockMovements(String productId) {
    return _dbService.stockMovements
        .filter()
        .productIdEqualTo(productId)
        .and()
        .isDeletedEqualTo(false)
        .sortByOccurredAtDesc()
        .watch(fireImmediately: true);
  }
}
