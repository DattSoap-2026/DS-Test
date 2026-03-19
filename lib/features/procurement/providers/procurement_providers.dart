import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/sync/collection_registry.dart';
import '../../../data/local/entities/purchase_order_entity.dart';
import '../../../data/local/entities/supplier_entity.dart';
import '../../../data/local/entities/warehouse_entity.dart';
import '../../../data/repositories/procurement_repository.dart';
import '../../../providers/service_providers.dart';

export '../../../data/local/entities/purchase_order_entity.dart';
export '../../../data/local/entities/supplier_entity.dart';
export '../../../data/local/entities/warehouse_entity.dart';
export '../../../data/repositories/procurement_repository.dart';

/// Shared procurement repository provider.
final procurementRepositoryProvider = Provider<ProcurementRepository>((ref) {
  return ProcurementRepository(
    ref.read(databaseServiceProvider),
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

/// Streams all active suppliers from Isar.
final allSuppliersProvider = StreamProvider<List<SupplierEntity>>((ref) {
  return ref.read(procurementRepositoryProvider).watchAllSuppliers();
});

/// Streams all warehouses from Isar.
final allWarehousesProvider = StreamProvider<List<WarehouseEntity>>((ref) {
  return ref.read(procurementRepositoryProvider).watchAllWarehouses();
});

/// Streams all purchase orders from Isar.
final allPurchaseOrdersProvider = StreamProvider<List<PurchaseOrderEntity>>((ref) {
  return ref.read(procurementRepositoryProvider).watchAllPurchaseOrders();
});

/// Streams pending purchase orders from Isar.
final pendingOrdersProvider = StreamProvider<List<PurchaseOrderEntity>>((ref) {
  return ref.read(procurementRepositoryProvider).watchAllPurchaseOrders().map((orders) {
    return orders
        .where((order) => !order.isDeleted && order.status == 'pending')
        .toList(growable: false);
  });
});

/// Aggregated pending sync count for procurement collections.
final pendingProcurementSyncCountProvider = FutureProvider<int>((ref) async {
  final queueService = ref.read(syncQueueServiceProvider);
  var total = 0;
  for (final collection in <String>[
    CollectionRegistry.suppliers,
    CollectionRegistry.purchaseOrders,
    CollectionRegistry.warehouses,
  ]) {
    total += await queueService.getPendingCount(collectionName: collection);
  }
  return total;
});
