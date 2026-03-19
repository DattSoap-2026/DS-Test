import 'dart:async';

import 'package:isar/isar.dart';

import '../../data/local/entities/chat_message.dart';
import '../../data/local/entities/config_cache_entity.dart';
import '../../data/local/entities/product_entity.dart';
import '../../data/local/entities/purchase_order_entity.dart';
import '../../data/local/entities/stock_movement_entity.dart';
import '../../data/local/entities/supplier_entity.dart';
import '../../data/local/entities/warehouse_entity.dart';
import '../../data/local/entities/fuel_purchase_entity.dart';
import '../../features/inventory/models/sync_queue.dart' as inventory_model;
import '../../services/database_service.dart';
import '../utils/sync_logger.dart';

/// Singleton access point for the application's Isar instance.
class IsarService {
  IsarService._internal();

  static final IsarService instance = IsarService._internal();

  Isar? _isar;

  /// Returns the initialized Isar instance.
  Isar get isar {
    final current = _isar;
    if (current == null) {
      throw StateError('IsarService has not been initialized.');
    }
    return current;
  }

  /// Initializes Isar and ensures all schemas are available.
  Future<Isar> initialize({String? directory}) async {
    try {
      await DatabaseService.instance.init(directory: directory);
      _isar = DatabaseService.instance.db;
      return isar;
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to initialize IsarService',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      rethrow;
    }
  }

  /// Returns a generic collection handle for the registered schema.
  IsarCollection<T> collection<T>() => isar.collection<T>();

  /// Canonical product entity collection accessor.
  IsarCollection<ProductEntity> get products => DatabaseService.instance.products;

  /// Canonical stock movement entity collection accessor.
  IsarCollection<StockMovementEntity> get stockMovements =>
      DatabaseService.instance.stockMovements;

  /// Canonical product entity collection accessor.
  IsarCollection<ProductEntity> get productEntities =>
      DatabaseService.instance.products;

  /// Canonical stock movement entity collection accessor.
  IsarCollection<StockMovementEntity> get stockMovementEntities =>
      DatabaseService.instance.stockMovements;

  /// Supplier entity collection accessor.
  IsarCollection<SupplierEntity> get suppliers =>
      DatabaseService.instance.suppliers;

  /// Purchase order entity collection accessor.
  IsarCollection<PurchaseOrderEntity> get purchaseOrders =>
      DatabaseService.instance.purchaseOrders;

  /// Warehouse entity collection accessor.
  IsarCollection<WarehouseEntity> get warehouses =>
      DatabaseService.instance.warehouses;

  /// Fuel purchase entity collection accessor.
  IsarCollection<FuelPurchaseEntity> get fuelPurchases =>
      DatabaseService.instance.fuelPurchases;

  /// Generic config cache collection accessor.
  IsarCollection<ConfigCacheEntity> get configCacheEntries =>
      DatabaseService.instance.configCache;

  /// Local chat message cache accessor.
  IsarCollection<ChatMessage> get chatMessages =>
      DatabaseService.instance.chatMessages;

  /// Canonical sync queue collection accessor.
  IsarCollection<inventory_model.SyncQueue> get syncQueues =>
      DatabaseService.instance.inventorySyncQueues;

  /// Watches active products ordered by name.
  Stream<List<ProductEntity>> watchProducts() {
    try {
      return products
          .filter()
          .isDeletedEqualTo(false)
          .sortByName()
          .watch(fireImmediately: true);
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to watch products',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      rethrow;
    }
  }

  /// Watches low stock products for the provided threshold.
  Stream<List<ProductEntity>> watchLowStockProducts(int threshold) {
    try {
      return products
          .filter()
          .isDeletedEqualTo(false)
          .and()
          .stockLessThan(threshold.toDouble())
          .sortByStock()
          .watch(fireImmediately: true);
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to watch low stock products',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      rethrow;
    }
  }

  /// Watches current pending sync queue count.
  Stream<int> watchPendingQueueCount() {
    try {
      return syncQueues
          .filter()
          .isFailedEqualTo(false)
          .watch(fireImmediately: true)
          .map((items) => items.length);
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to watch pending queue count',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      rethrow;
    }
  }

  /// Watches stock movements for a product.
  Stream<List<StockMovementEntity>> watchStockMovements(String productId) {
    try {
      return stockMovements
          .filter()
          .productIdEqualTo(productId)
          .and()
          .isDeletedEqualTo(false)
          .sortByOccurredAtDesc()
          .watch(fireImmediately: true);
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to watch stock movements',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      rethrow;
    }
  }
}
