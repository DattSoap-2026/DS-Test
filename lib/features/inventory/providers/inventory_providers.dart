import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/sync/collection_registry.dart';
import '../../../data/local/entities/product_entity.dart';
import '../../../data/repositories/department_stock_repository.dart';
import '../../../data/repositories/inventory_location_repository.dart';
import '../../../data/repositories/opening_stock_repository.dart';
import '../../../data/repositories/stock_ledger_repository.dart';
import '../../../services/database_service.dart';
import '../repository/inventory_repository.dart';

export '../../../data/local/entities/product_entity.dart';
export '../../../data/local/entities/stock_movement_entity.dart';
export '../../../data/repositories/department_stock_repository.dart';
export '../../../data/repositories/inventory_location_repository.dart';
export '../../../data/repositories/opening_stock_repository.dart';
export '../../../data/repositories/stock_ledger_repository.dart';
export '../repository/inventory_repository.dart';

/// Feature inventory repository provider.
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(
    databaseService: DatabaseService.instance,
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

/// Opening stock repository provider.
final openingStockRepositoryProvider = Provider<OpeningStockRepository>((ref) {
  return OpeningStockRepository(
    DatabaseService.instance,
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

/// Stock ledger repository provider.
final stockLedgerRepositoryProvider = Provider<StockLedgerRepository>((ref) {
  return StockLedgerRepository(
    DatabaseService.instance,
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

/// Department stock repository provider.
final departmentStockRepositoryProvider =
    Provider<DepartmentStockRepository>((ref) {
      return DepartmentStockRepository(
        DatabaseService.instance,
        syncQueueService: ref.read(syncQueueServiceProvider),
        syncService: ref.read(syncServiceProvider),
        connectivityService: ref.read(connectivityServiceProvider),
        deviceIdService: ref.read(deviceIdProvider),
      );
    });

/// Inventory location repository provider.
final inventoryLocationRepositoryProvider =
    Provider<InventoryLocationRepository>((ref) {
      return InventoryLocationRepository(
        DatabaseService.instance,
        syncQueueService: ref.read(syncQueueServiceProvider),
        syncService: ref.read(syncServiceProvider),
        connectivityService: ref.read(connectivityServiceProvider),
        deviceIdService: ref.read(deviceIdProvider),
      );
    });

/// Watches all active products from Isar.
final allProductsProvider = StreamProvider<List<ProductEntity>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchAllProducts();
});

/// Watches low-stock products for a threshold.
final lowStockProvider = StreamProvider.family<List<ProductEntity>, int>((
  ref,
  threshold,
) {
  return ref.watch(inventoryRepositoryProvider).watchLowStockProducts(threshold);
});

/// Aggregated pending sync count for inventory-core collections.
final pendingInventorySyncCountProvider = FutureProvider<int>((ref) async {
  final queueService = ref.read(syncQueueServiceProvider);
  var total = 0;
  for (final collection in CollectionRegistry.inventoryCoreCollections) {
    total += await queueService.getPendingCount(collectionName: collection);
  }
  return total;
});
