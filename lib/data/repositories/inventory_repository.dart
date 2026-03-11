import 'package:isar/isar.dart';
import '../local/base_entity.dart';
import '../local/entities/product_entity.dart';
import '../../services/database_service.dart';

class InventoryRepository {
  final DatabaseService _dbService;

  InventoryRepository(this._dbService);

  // Fetch all active (non-deleted) products - Local First
  Future<List<ProductEntity>> getAllProducts() async {
    return await _dbService.products
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  // Get product by SKU or ID
  Future<ProductEntity?> getProductById(String id) async {
    return await _dbService.products.filter().idEqualTo(id).findFirst();
  }

  Future<ProductEntity?> getProductBySku(String sku) async {
    return await _dbService.products.filter().skuEqualTo(sku).findFirst();
  }

  // Stock operations
  Future<void> updateStock(String productId, double quantityDelta) async {
    throw UnsupportedError(
      'Direct stock updates are blocked. Use InventoryService for stock changes.',
    );
  }

  // Create or Update Product - Local Commit
  Future<void> saveProduct(ProductEntity product) async {
    product.updatedAt = DateTime.now();
    product.syncStatus = SyncStatus.pending;
    product.encryptSensitiveFields();

    await _dbService.db.writeTxn(() async {
      final existing = await _dbService.products.getById(product.id);
      if (existing != null) {
        // ARCHITECTURE LOCK: preserve stock; only InventoryService can mutate it.
        product.stock = existing.stock;
      }
      await _dbService.products.put(product);
    });
  }

  // Bulk Save Products
  Future<void> saveProducts(List<ProductEntity> products) async {
    final now = DateTime.now();
    for (var p in products) {
      p.updatedAt = now;
      p.syncStatus = SyncStatus.pending;
      p.encryptSensitiveFields();
    }

    await _dbService.db.writeTxn(() async {
      await _dbService.products.putAll(products);
    });
  }
}
