import 'package:isar/isar.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/department_stock_entity.dart';
import '../../services/database_service.dart';

/// Isar-first repository for department stock snapshots.
class DepartmentStockRepository {
  DepartmentStockRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  /// Saves department stock locally first, then enqueues sync.
  Future<void> saveDepartmentStock(DepartmentStockEntity entity) async {
    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();
    final id = _composeId(entity.departmentName, entity.productId);
    final existing = await _dbService.departmentStocks.getById(id);

    entity
      ..id = id
      ..updatedAt = now
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false
      ..isSynced = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = deviceId;

    await _dbService.db.writeTxn(() async {
      await _dbService.departmentStocks.put(entity);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.departmentStocks,
      documentId: entity.id,
      operation: existing == null ? 'create' : 'update',
      payload: entity.toJson(),
    );

    await _syncIfOnline();
  }

  /// Returns all department stock rows for a department from Isar only.
  Future<List<DepartmentStockEntity>> getStockByDepartment(
    String departmentName,
  ) async {
    return _dbService.departmentStocks
        .filter()
        .departmentNameEqualTo(departmentName)
        .and()
        .isDeletedEqualTo(false)
        .sortByProductName()
        .findAll();
  }

  /// Returns all department stock rows for a product from Isar only.
  Future<List<DepartmentStockEntity>> getStockByProduct(String productId) async {
    return _dbService.departmentStocks
        .filter()
        .productIdEqualTo(productId)
        .and()
        .isDeletedEqualTo(false)
        .sortByDepartmentName()
        .findAll();
  }

  /// Watches all active department stock rows from Isar.
  Stream<List<DepartmentStockEntity>> watchAllDepartmentStock() {
    return _dbService.departmentStocks
        .filter()
        .isDeletedEqualTo(false)
        .sortByDepartmentName()
        .watch(fireImmediately: true);
  }

  /// Updates or creates a department stock row, then enqueues sync.
  Future<void> updateStock(
    String departmentName,
    String productId,
    double qty,
  ) async {
    final id = _composeId(departmentName, productId);
    final existing = await _dbService.departmentStocks.getById(id);
    final entity = existing ?? DepartmentStockEntity()
      ..departmentName = departmentName
      ..productId = productId
      ..productName = existing?.productName ?? productId
      ..unit = existing?.unit ?? 'Unit';

    entity.stock = qty;
    await saveDepartmentStock(entity);
  }

  String _composeId(String departmentName, String productId) {
    return '${departmentName.trim()}_${productId.trim()}';
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
