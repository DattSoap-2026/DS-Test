import 'dart:async';

import 'package:isar/isar.dart';

import '../../features/inventory/models/product.dart' as inventory_model;
import '../../features/inventory/models/stock_movement.dart' as inventory_model;
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

  /// Initializes Isar and ensures inventory sync schemas are available.
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

  /// Product collection accessor.
  IsarCollection<inventory_model.Product> get products =>
      DatabaseService.instance.inventorySyncProducts;

  /// Stock movement collection accessor.
  IsarCollection<inventory_model.StockMovement> get stockMovements =>
      DatabaseService.instance.inventorySyncStockMovements;

  /// Sync queue collection accessor.
  IsarCollection<inventory_model.SyncQueue> get syncQueues =>
      DatabaseService.instance.inventorySyncQueues;

  /// Watches active products ordered by last modified time.
  Stream<List<inventory_model.Product>> watchProducts() {
    try {
      return products
          .filter()
          .isDeletedEqualTo(false)
          .sortByLastModifiedDesc()
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
  Stream<List<inventory_model.Product>> watchLowStockProducts(int threshold) {
    try {
      return products
          .filter()
          .isDeletedEqualTo(false)
          .stockQuantityLessThan(threshold)
          .sortByStockQuantity()
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
  Stream<List<inventory_model.StockMovement>> watchStockMovements(
    String productFirebaseId,
  ) {
    try {
      return stockMovements
          .filter()
          .productFirebaseIdEqualTo(productFirebaseId)
          .sortByTimestampDesc()
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
