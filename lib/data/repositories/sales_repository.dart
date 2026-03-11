import 'package:isar/isar.dart';
import '../local/entities/sale_entity.dart';
import '../../services/database_service.dart';
import '../local/base_entity.dart';

class SalesRepository {
  static const int _salesPageSize = 500;
  final DatabaseService _dbService;

  SalesRepository(this._dbService);

  Future<List<SaleEntity>> _fetchAllSalesPaged() async {
    final allSales = <SaleEntity>[];
    var offset = 0;
    while (true) {
      final chunk = await _dbService.sales
          .where()
          .sortByCreatedAtDesc()
          .offset(offset)
          .limit(_salesPageSize)
          .findAll();
      if (chunk.isEmpty) {
        break;
      }
      allSales.addAll(chunk);
      if (chunk.length < _salesPageSize) {
        break;
      }
      offset += _salesPageSize;
    }
    return allSales;
  }

  // Get all sales for a specific trip
  Future<List<SaleEntity>> getSalesByTripId(String tripId) async {
    return await _dbService.sales
        .filter()
        .tripIdEqualTo(tripId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  // Get all pending dispatch sales (status 'pending_dispatch')
  Future<List<SaleEntity>> getPendingDispatchSales() async {
    return await _dbService.sales
        .filter()
        .statusEqualTo('pending_dispatch')
        .or()
        .statusEqualTo('pending')
        .sortByCreatedAtDesc()
        .findAll();
  }

  // Get all sales for dealers
  Future<List<SaleEntity>> getDealerSales() async {
    return await _dbService.sales
        .filter()
        .recipientTypeEqualTo('dealer')
        .sortByCreatedAtDesc()
        .findAll();
  }

  // Get all sales (used by dashboards/reporting for advanced filters)
  Future<List<SaleEntity>> getAllSales() async {
    return await _fetchAllSalesPaged();
  }

  // Get sales by date range and type
  Future<List<SaleEntity>> getDealerSalesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();
    return await _dbService.sales
        .filter()
        .recipientTypeEqualTo('dealer')
        .createdAtBetween(startStr, endStr)
        .sortByCreatedAtDesc()
        .findAll();
  }

  // Save or Update a Sale
  Future<void> saveSale(SaleEntity sale) async {
    sale.syncStatus = SyncStatus.pending;
    sale.updatedAt = DateTime.now();

    await _dbService.db.writeTxn(() async {
      await _dbService.sales.put(sale);
    });
  }

  // Bulk Save (for syncing from remote)
  Future<void> saveSales(List<SaleEntity> sales) async {
    await _dbService.db.writeTxn(() async {
      await _dbService.sales.putAll(sales);
    });
  }

  // Get all un-synced sales
  Future<List<SaleEntity>> getPendingSyncSales() async {
    return await _dbService.sales
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
  }
}
