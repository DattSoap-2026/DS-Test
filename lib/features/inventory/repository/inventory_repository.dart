import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../core/sync/sync_queue_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/utils/device_id_service.dart';
import '../../../core/utils/sync_logger.dart';
import '../models/product.dart';
import '../models/stock_movement.dart';

/// Inventory repository using Isar as the primary source of truth.
class InventoryRepository {
  InventoryRepository({
    IsarService? isarService,
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _isarService = isarService ?? IsarService.instance,
       _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  static const String _productsCollection = 'products';
  static const String _stockMovementsCollection = 'stock_movements';
  static const String _operationCreate = 'create';
  static const String _operationUpdate = 'update';
  static const String _operationDelete = 'delete';
  static const String _typeIn = 'IN';
  static const String _typeOut = 'OUT';

  final IsarService _isarService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  /// Saves a product locally, enqueues sync, and triggers background sync when online.
  Future<Product> saveProduct(Product product) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final documentId = product.firebaseId.isEmpty
          ? firestore.collection(_productsCollection).doc().id
          : product.firebaseId;
      final deviceId = await _deviceIdService.getDeviceId();
      final existing = await _isarService.products
          .filter()
          .firebaseIdEqualTo(documentId)
          .findFirst();
      final now = DateTime.now();

      final localProduct = product.copyWith(
        firebaseId: documentId,
        isSynced: false,
        isDeleted: false,
        lastModified: now,
        lastSynced: null,
        version: (existing?.version ?? 0) + 1,
        deviceId: deviceId,
      );

      await _isarService.isar.writeTxn(() async {
        await _isarService.products.put(localProduct);
      });

      await _syncQueueService.addToQueue(
        collectionName: _productsCollection,
        documentId: documentId,
        operation: existing == null ? _operationCreate : _operationUpdate,
        payload: localProduct.toJson(),
      );

      if (_connectivityService.isOnline) {
        await _syncService.syncAllPending();
      }

      return localProduct;
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to save product',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      rethrow;
    }
  }

  /// Soft-deletes a product locally, enqueues the delete sync, and triggers sync when online.
  Future<void> deleteProduct(String firebaseId) async {
    try {
      final existing = await _isarService.products
          .filter()
          .firebaseIdEqualTo(firebaseId)
          .findFirst();
      if (existing == null) {
        return;
      }

      final deleted = existing.copyWith(
        isDeleted: true,
        isSynced: false,
        lastModified: DateTime.now(),
        lastSynced: null,
        version: existing.version + 1,
      );

      await _isarService.isar.writeTxn(() async {
        await _isarService.products.put(deleted);
      });

      await _syncQueueService.addToQueue(
        collectionName: _productsCollection,
        documentId: firebaseId,
        operation: _operationDelete,
        payload: deleted.toJson(),
      );

      if (_connectivityService.isOnline) {
        await _syncService.syncAllPending();
      }
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to delete product',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      rethrow;
    }
  }

  /// Adds stock to a product, creates a stock movement, and syncs when online.
  Future<void> addStock(
    String productFirebaseId,
    int quantity,
    String reason,
  ) async {
    try {
      await _changeStock(
        productFirebaseId: productFirebaseId,
        quantity: quantity,
        reason: reason,
        movementType: _typeIn,
      );
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to add stock',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      rethrow;
    }
  }

  /// Removes stock if available, creates a stock movement, and returns success state.
  Future<bool> removeStock(
    String productFirebaseId,
    int quantity,
    String reason,
  ) async {
    try {
      final product = await _isarService.products
          .filter()
          .firebaseIdEqualTo(productFirebaseId)
          .findFirst();
      if (product == null || product.stockQuantity < quantity) {
        return false;
      }

      await _changeStock(
        productFirebaseId: productFirebaseId,
        quantity: quantity,
        reason: reason,
        movementType: _typeOut,
      );
      return true;
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to remove stock',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      return false;
    }
  }

  /// Returns all non-deleted products from Isar.
  Future<List<Product>> getAllProducts() async {
    try {
      return _isarService.products
          .filter()
          .isDeletedEqualTo(false)
          .sortByName()
          .findAll();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to get all products',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      return <Product>[];
    }
  }

  /// Streams all non-deleted products from Isar.
  Stream<List<Product>> watchAllProducts() {
    return _isarService.watchProducts();
  }

  /// Searches products by name or sku.
  Future<List<Product>> searchProducts(String query) async {
    try {
      if (query.trim().isEmpty) {
        return getAllProducts();
      }
      return _isarService.products
          .filter()
          .isDeletedEqualTo(false)
          .group(
            (queryBuilder) => queryBuilder
                .nameContains(query, caseSensitive: false)
                .or()
                .skuContains(query, caseSensitive: false),
          )
          .sortByName()
          .findAll();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to search products',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      return <Product>[];
    }
  }

  /// Returns products below the provided stock threshold.
  Future<List<Product>> getLowStockProducts(int threshold) async {
    try {
      return _isarService.products
          .filter()
          .isDeletedEqualTo(false)
          .stockQuantityLessThan(threshold)
          .sortByStockQuantity()
          .findAll();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to get low stock products',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      return <Product>[];
    }
  }

  /// Streams products below the provided threshold.
  Stream<List<Product>> watchLowStockProducts(int threshold) {
    return _isarService.watchLowStockProducts(threshold);
  }

  /// Returns all stock movements for a product.
  Future<List<StockMovement>> getStockMovements(String productFirebaseId) async {
    try {
      return _isarService.stockMovements
          .filter()
          .productFirebaseIdEqualTo(productFirebaseId)
          .sortByTimestampDesc()
          .findAll();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to get stock movements',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      return <StockMovement>[];
    }
  }

  /// Streams stock movements for a product.
  Stream<List<StockMovement>> watchStockMovements(String productFirebaseId) {
    return _isarService.watchStockMovements(productFirebaseId);
  }

  Future<void> _changeStock({
    required String productFirebaseId,
    required int quantity,
    required String reason,
    required String movementType,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final product = await _isarService.products
          .filter()
          .firebaseIdEqualTo(productFirebaseId)
          .findFirst();
      if (product == null) {
        throw StateError('Product not found for $productFirebaseId');
      }

      final deviceId = await _deviceIdService.getDeviceId();
      final movementId = firestore.collection(_stockMovementsCollection).doc().id;
      final now = DateTime.now();
      final updatedQuantity = movementType == _typeIn
          ? product.stockQuantity + quantity
          : product.stockQuantity - quantity;

      final updatedProduct = product.copyWith(
        stockQuantity: updatedQuantity,
        isSynced: false,
        lastModified: now,
        lastSynced: null,
        version: product.version + 1,
        deviceId: deviceId,
      );
      final stockMovement = StockMovement()
        ..firebaseId = movementId
        ..productFirebaseId = productFirebaseId
        ..type = movementType
        ..quantity = quantity
        ..reason = reason
        ..timestamp = now
        ..isSynced = false
        ..deviceId = deviceId;

      await _isarService.isar.writeTxn(() async {
        await _isarService.products.put(updatedProduct);
        await _isarService.stockMovements.put(stockMovement);
      });

      await _syncQueueService.addToQueue(
        collectionName: _productsCollection,
        documentId: productFirebaseId,
        operation: _operationUpdate,
        payload: updatedProduct.toJson(),
      );
      await _syncQueueService.addToQueue(
        collectionName: _stockMovementsCollection,
        documentId: movementId,
        operation: _operationCreate,
        payload: stockMovement.toJson(),
      );

      if (_connectivityService.isOnline) {
        await _syncService.syncAllPending();
      }
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to change stock',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      rethrow;
    }
  }
}
