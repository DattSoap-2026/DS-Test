import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/sale_entity.dart';
import '../../services/database_service.dart';

class SalesRepository {
  static const int _salesPageSize = 500;
  static const Uuid _uuid = Uuid();

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  SalesRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  Future<List<SaleEntity>> _fetchAllSalesPaged() async {
    final allSales = <SaleEntity>[];
    var offset = 0;
    while (true) {
      final chunk = await _dbService.sales
          .filter()
          .isDeletedEqualTo(false)
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
    return _dbService.sales
        .filter()
        .tripIdEqualTo(tripId)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  // Get all pending dispatch sales (status 'pending_dispatch')
  Future<List<SaleEntity>> getPendingDispatchSales() async {
    return _dbService.sales
        .filter()
        .group(
          (query) =>
              query.statusEqualTo('pending_dispatch').or().statusEqualTo('pending'),
        )
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  // Get all sales for dealers
  Future<List<SaleEntity>> getDealerSales() async {
    return _dbService.sales
        .filter()
        .recipientTypeEqualTo('dealer')
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  // Get all sales (used by dashboards/reporting for advanced filters)
  Future<List<SaleEntity>> getAllSales() async {
    return _fetchAllSalesPaged();
  }

  /// Returns a sale by id from Isar only.
  Future<SaleEntity?> getSaleById(String id) async {
    return _dbService.sales
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Returns sales by month/year from Isar only.
  Future<List<SaleEntity>> getSalesByMonth(int month, int year) async {
    return _dbService.sales
        .filter()
        .monthEqualTo(month)
        .and()
        .yearEqualTo(year)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Returns sales for a salesman from Isar only.
  Future<List<SaleEntity>> getSalesBySalesman(String salesmanId) async {
    return _dbService.sales
        .filter()
        .salesmanIdEqualTo(salesmanId)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Returns sales for a customer from Isar only.
  Future<List<SaleEntity>> getSalesByCustomer(String customerId) async {
    return _dbService.sales
        .filter()
        .recipientTypeEqualTo('customer')
        .and()
        .recipientIdEqualTo(customerId)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Streams all non-deleted sales from Isar.
  Stream<List<SaleEntity>> watchAllSales() {
    return _dbService.sales
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  /// Streams sales for a salesman from Isar.
  Stream<List<SaleEntity>> watchSalesBySalesman(String salesmanId) {
    return _dbService.sales
        .filter()
        .salesmanIdEqualTo(salesmanId)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  // Get sales by date range and type
  Future<List<SaleEntity>> getDealerSalesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();
    return _dbService.sales
        .filter()
        .recipientTypeEqualTo('dealer')
        .and()
        .createdAtBetween(startStr, endStr)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  // Save or Update a Sale
  Future<void> saveSale(SaleEntity sale) async {
    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();
    final existing = await _dbService.sales.getById(_ensureId(sale));
    final createdAt = _ensureCreatedAt(sale, existing?.createdAt, now);
    final createdAtDate = DateTime.tryParse(createdAt) ?? now;

    sale
      ..createdAt = createdAt
      ..month = sale.month ?? createdAtDate.month
      ..year = sale.year ?? createdAtDate.year
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..deletedAt = null
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = deviceId;

    await _dbService.db.writeTxn(() async {
      await _dbService.sales.put(sale);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.sales,
      documentId: sale.id,
      operation: existing == null ? 'create' : 'update',
      payload: sale.toJson(),
    );

    await _syncIfOnline();
  }

  // Bulk Save (for syncing from remote)
  Future<void> saveSales(List<SaleEntity> sales) async {
    for (final sale in sales) {
      await saveSale(sale);
    }
  }

  /// Cancels a sale with a soft status update and queues sync.
  Future<void> cancelSale(
    String saleId,
    String reason,
    String cancelledBy,
  ) async {
    final sale = await _dbService.sales.getById(saleId);
    if (sale == null || sale.isDeleted) {
      return;
    }

    final now = DateTime.now();
    sale
      ..status = 'cancelled'
      ..cancelReason = reason
      ..cancelledBy = cancelledBy
      ..cancelledAt = now.toIso8601String()
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.sales.put(sale);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.sales,
      documentId: sale.id,
      operation: 'update',
      payload: sale.toJson(),
    );

    await _syncIfOnline();
  }

  /// Soft-deletes a sale and queues the delete operation.
  Future<void> deleteSale(String id) async {
    final sale = await _dbService.sales.getById(id);
    if (sale == null || sale.isDeleted) {
      return;
    }

    final now = DateTime.now();
    sale
      ..isDeleted = true
      ..deletedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.sales.put(sale);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.sales,
      documentId: sale.id,
      operation: 'delete',
      payload: sale.toJson(),
    );

    await _syncIfOnline();
  }

  // Get all un-synced sales
  Future<List<SaleEntity>> getPendingSyncSales() async {
    return _dbService.sales
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
  }

  String _ensureId(SaleEntity sale) {
    try {
      final normalized = sale.id.trim();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    } catch (_) {
      // Late initialization fallback.
    }
    final generated = _uuid.v4();
    sale.id = generated;
    return generated;
  }

  String _ensureCreatedAt(
    SaleEntity sale,
    String? existingCreatedAt,
    DateTime now,
  ) {
    try {
      final current = sale.createdAt.trim();
      if (current.isNotEmpty) {
        return current;
      }
    } catch (_) {
      // Late initialization fallback.
    }
    final fallback = existingCreatedAt ?? now.toIso8601String();
    sale.createdAt = fallback;
    return fallback;
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
