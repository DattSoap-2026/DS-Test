import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../core/sync/sync_service.dart';
import '../models/product.dart';
import '../repository/inventory_repository.dart';

export '../models/product.dart';
export '../models/stock_movement.dart';
export '../models/sync_queue.dart';
export '../repository/inventory_repository.dart';
export '../../../core/database/isar_service.dart';
export '../../../core/network/connectivity_service.dart';
export '../../../core/sync/sync_service.dart';

/// Singleton Isar service provider.
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService.instance;
});

/// Singleton sync service provider.
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService.instance;
});

/// Inventory repository provider.
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository();
});

/// Connectivity provider exposing online or offline status.
final connectivityProvider = StreamProvider<bool>((ref) {
  return ConnectivityService.instance.stream;
});

/// Watches all active products from Isar.
final allProductsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchAllProducts();
});

/// Watches low-stock products for a threshold.
final lowStockProvider = StreamProvider.family<List<Product>, int>((
  ref,
  threshold,
) {
  return ref.watch(inventoryRepositoryProvider).watchLowStockProducts(threshold);
});

/// Watches current sync status.
final syncStatusProvider = StreamProvider<SyncStatusSnapshot>((ref) async* {
  yield SyncService.instance.currentStatus;
  yield* SyncService.instance.statusStream;
});
