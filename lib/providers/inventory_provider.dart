import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../services/master_data_service.dart';
import '../data/local/entities/department_stock_entity.dart';
import '../data/local/entities/inventory_location_entity.dart';
import 'service_providers.dart';

final productTypesProvider = FutureProvider<List<DynamicProductType>>((
  ref,
) async {
  final service = ref.watch(masterDataServiceProvider);
  return service.getProductTypes();
});

final deptStocksProvider =
    FutureProvider.family<List<DepartmentStockEntity>, String>((
      ref,
      productId,
    ) async {
      final db = ref.watch(databaseServiceProvider);
      final allStocks = await db.db.departmentStockEntitys.where().findAll();
      return allStocks
          .where((s) => s.productId == productId && !s.isDeleted && s.stock > 0)
          .toList();
    });

class WarehouseStock {
  final String warehouseId;
  final String warehouseName;
  final double stock;

  WarehouseStock({
    required this.warehouseId,
    required this.warehouseName,
    required this.stock,
  });
}

final warehouseStocksProvider =
    FutureProvider.family<List<WarehouseStock>, String>((
      ref,
      productId,
    ) async {
      final db = ref.watch(databaseServiceProvider);
      final locations = await db.db.inventoryLocationEntitys
          .filter()
          .typeEqualTo(InventoryLocationEntity.warehouseType)
          .isActiveEqualTo(true)
          .isDeletedEqualTo(false)
          .findAll();

      final warehouseStocks = <WarehouseStock>[];
      for (final location in locations) {
        final deptStocks = await db.db.departmentStockEntitys
            .filter()
            .productIdEqualTo(productId)
            .departmentNameEqualTo(location.name)
            .isDeletedEqualTo(false)
            .findAll();

        final totalStock = deptStocks.fold<double>(0, (sum, s) => sum + s.stock);
        warehouseStocks.add(WarehouseStock(
          warehouseId: location.id,
          warehouseName: location.name,
          stock: totalStock,
        ));
      }

      return warehouseStocks;
    });
