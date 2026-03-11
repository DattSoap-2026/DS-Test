import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../services/master_data_service.dart';
import '../data/local/entities/department_stock_entity.dart';
import '../data/local/entities/stock_balance_entity.dart';
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
      
      final balances = await db.db.stockBalanceEntitys
          .filter()
          .productIdEqualTo(productId)
          .isDeletedEqualTo(false)
          .findAll();

      double mainStock = 0;
      double gitaStock = 0;
      double sonaStock = 0;

      for (final balance in balances) {
        final loc = balance.locationId.toLowerCase();
        if (loc == 'warehouse_main') {
          mainStock += balance.quantity;
        } else if (loc.contains('gita')) {
          gitaStock += balance.quantity;
        } else if (loc.contains('sona')) {
          sonaStock += balance.quantity;
        }
      }

      return [
        WarehouseStock(
          warehouseId: 'Main',
          warehouseName: 'Main Warehouse',
          stock: mainStock,
        ),
        WarehouseStock(
          warehouseId: 'Gita_Shed',
          warehouseName: 'Gita Shed',
          stock: gitaStock,
        ),
        WarehouseStock(
          warehouseId: 'Sona_Shed',
          warehouseName: 'Sona Shed',
          stock: sonaStock,
        ),
      ];
    });
