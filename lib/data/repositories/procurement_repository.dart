import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../services/database_service.dart';
import '../local/base_entity.dart';
import '../local/entities/purchase_order_entity.dart';
import '../local/entities/supplier_entity.dart';
import '../local/entities/warehouse_entity.dart';

/// Isar-first repository for procurement and warehouse data.
class ProcurementRepository {
  ProcurementRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  static const Uuid _uuid = Uuid();

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  /// Saves a supplier locally first, then enqueues it for sync.
  Future<void> saveSupplier(SupplierEntity supplier) async {
    final id = _requiredId(() => supplier.id, 'Supplier id is required.');
    final now = DateTime.now();
    final existing = await _dbService.suppliers.getById(id);

    supplier
      ..id = id
      ..createdAt = supplier.createdAt ?? existing?.createdAt ?? now
      ..updatedAt = now
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false
      ..isSynced = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.suppliers.put(supplier);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.suppliers,
      documentId: supplier.id,
      operation: existing == null ? 'create' : 'update',
      payload: supplier.toJson(),
    );

    await _syncIfOnline();
  }

  /// Returns all active suppliers from Isar only.
  Future<List<SupplierEntity>> getAllSuppliers() {
    return _dbService.suppliers
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  /// Streams all active suppliers from Isar only.
  Stream<List<SupplierEntity>> watchAllSuppliers() {
    return _dbService.suppliers
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true);
  }

  /// Returns a supplier by id when it is not soft-deleted.
  Future<SupplierEntity?> getSupplierById(String id) {
    return _dbService.suppliers
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Searches suppliers by name, mobile, or GSTIN using Isar-backed data.
  Future<List<SupplierEntity>> searchSuppliers(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return getAllSuppliers();
    }

    final suppliers = await getAllSuppliers();
    return suppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(normalized) ||
          (supplier.mobile ?? '').toLowerCase().contains(normalized) ||
          (supplier.gstin ?? '').toLowerCase().contains(normalized);
    }).toList(growable: false);
  }

  /// Soft-deletes a supplier and enqueues the delete sync event.
  Future<void> deleteSupplier(String id) async {
    final supplier = await _dbService.suppliers.getById(id);
    if (supplier == null || supplier.isDeleted) {
      return;
    }

    final now = DateTime.now();
    supplier
      ..isDeleted = true
      ..deletedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.suppliers.put(supplier);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.suppliers,
      documentId: supplier.id,
      operation: 'delete',
      payload: supplier.toJson(),
    );

    await _syncIfOnline();
  }

  /// Saves a purchase order locally first, then enqueues it for sync.
  Future<void> savePurchaseOrder(PurchaseOrderEntity order) async {
    final now = DateTime.now();
    final id = _ensureId(() => order.id, (value) => order.id = value);
    final existing = await _dbService.purchaseOrders.getById(id);

    order
      ..id = id
      ..supplierId = _safeRead(() => order.supplierId)
      ..supplierName = _safeRead(() => order.supplierName)
      ..itemsJson = _safeRead(() => order.itemsJson, fallback: '[]')
      ..status = _safeRead(() => order.status, fallback: 'pending')
      ..orderDate = order.orderDate ?? existing?.orderDate ?? now
      ..createdAt = order.createdAt ?? existing?.createdAt ?? now
      ..updatedAt = now
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false
      ..isSynced = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.purchaseOrders.put(order);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.purchaseOrders,
      documentId: order.id,
      operation: existing == null ? 'create' : 'update',
      payload: order.toJson(),
    );

    await _syncIfOnline();
  }

  /// Returns all non-deleted purchase orders sorted by order date descending.
  Future<List<PurchaseOrderEntity>> getAllPurchaseOrders() {
    return _dbService.purchaseOrders
        .filter()
        .isDeletedEqualTo(false)
        .sortByOrderDateDesc()
        .findAll();
  }

  /// Streams all non-deleted purchase orders sorted by order date descending.
  Stream<List<PurchaseOrderEntity>> watchAllPurchaseOrders() {
    return _dbService.purchaseOrders
        .filter()
        .isDeletedEqualTo(false)
        .sortByOrderDateDesc()
        .watch(fireImmediately: true);
  }

  /// Returns a purchase order by id when it is not soft-deleted.
  Future<PurchaseOrderEntity?> getPurchaseOrderById(String id) {
    return _dbService.purchaseOrders
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Returns purchase orders for a supplier from Isar only.
  Future<List<PurchaseOrderEntity>> getOrdersBySupplier(String supplierId) {
    return _dbService.purchaseOrders
        .filter()
        .supplierIdEqualTo(supplierId)
        .and()
        .isDeletedEqualTo(false)
        .sortByOrderDateDesc()
        .findAll();
  }

  /// Returns purchase orders with a given status from Isar only.
  Future<List<PurchaseOrderEntity>> getOrdersByStatus(String status) {
    return _dbService.purchaseOrders
        .filter()
        .statusEqualTo(status)
        .and()
        .isDeletedEqualTo(false)
        .sortByOrderDateDesc()
        .findAll();
  }

  /// Marks a purchase order as approved and enqueues the update.
  Future<void> approveOrder(String id, String approvedBy) async {
    final order = await _dbService.purchaseOrders.getById(id);
    if (order == null || order.isDeleted) {
      return;
    }

    final now = DateTime.now();
    order
      ..status = 'approved'
      ..approvedBy = approvedBy
      ..approvedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _persistPurchaseOrderUpdate(order);
  }

  /// Marks a purchase order as received and enqueues the update.
  Future<void> receiveOrder(String id, DateTime receivedDate) async {
    final order = await _dbService.purchaseOrders.getById(id);
    if (order == null || order.isDeleted) {
      return;
    }

    order
      ..status = 'received'
      ..receivedDate = receivedDate
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _persistPurchaseOrderUpdate(order);
  }

  /// Marks a purchase order as cancelled and enqueues the update.
  Future<void> cancelOrder(String id, String reason) async {
    final order = await _dbService.purchaseOrders.getById(id);
    if (order == null || order.isDeleted) {
      return;
    }

    order
      ..status = 'cancelled'
      ..cancelReason = reason
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _persistPurchaseOrderUpdate(order);
  }

  /// Soft-deletes a purchase order and enqueues the delete sync event.
  Future<void> deletePurchaseOrder(String id) async {
    final order = await _dbService.purchaseOrders.getById(id);
    if (order == null || order.isDeleted) {
      return;
    }

    final now = DateTime.now();
    order
      ..isDeleted = true
      ..deletedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.purchaseOrders.put(order);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.purchaseOrders,
      documentId: order.id,
      operation: 'delete',
      payload: order.toJson(),
    );

    await _syncIfOnline();
  }

  /// Saves a warehouse locally first, then enqueues it for sync.
  Future<void> saveWarehouse(WarehouseEntity warehouse) async {
    final now = DateTime.now();
    final id = _ensureId(
      () => warehouse.id,
      (value) => warehouse.id = value,
      fallback: _safeRead(() => warehouse.code),
    );
    final existing = await _dbService.warehouses.getById(id);

    warehouse
      ..id = id
      ..name = _safeRead(() => warehouse.name)
      ..code = _safeRead(() => warehouse.code, fallback: id)
      ..type = _safeRead(() => warehouse.type, fallback: 'main')
      ..createdAt = warehouse.createdAt ?? existing?.createdAt ?? now
      ..updatedAt = now
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false
      ..isSynced = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.warehouses.put(warehouse);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.warehouses,
      documentId: warehouse.id,
      operation: existing == null ? 'create' : 'update',
      payload: warehouse.toJson(),
    );

    await _syncIfOnline();
  }

  /// Returns all active warehouses from Isar only.
  Future<List<WarehouseEntity>> getAllWarehouses() {
    return _dbService.warehouses
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .isActiveEqualTo(true)
        .sortByName()
        .findAll();
  }

  /// Streams all non-deleted warehouses from Isar only.
  Stream<List<WarehouseEntity>> watchAllWarehouses() {
    return _dbService.warehouses
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true);
  }

  /// Returns a warehouse by id when it is not soft-deleted.
  Future<WarehouseEntity?> getWarehouseById(String id) {
    return _dbService.warehouses
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Returns a warehouse by code when it is not soft-deleted.
  Future<WarehouseEntity?> getWarehouseByCode(String code) {
    return _dbService.warehouses
        .filter()
        .codeEqualTo(code)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Returns the primary warehouse when one is configured.
  Future<WarehouseEntity?> getPrimaryWarehouse() {
    return _dbService.warehouses
        .filter()
        .isPrimaryEqualTo(true)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Soft-deletes a warehouse and enqueues the delete sync event.
  Future<void> deleteWarehouse(String id) async {
    final warehouse = await _dbService.warehouses.getById(id);
    if (warehouse == null || warehouse.isDeleted) {
      return;
    }

    final now = DateTime.now();
    warehouse
      ..isActive = false
      ..isDeleted = true
      ..deletedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.warehouses.put(warehouse);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.warehouses,
      documentId: warehouse.id,
      operation: 'delete',
      payload: warehouse.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> _persistPurchaseOrderUpdate(PurchaseOrderEntity order) async {
    await _dbService.db.writeTxn(() async {
      await _dbService.purchaseOrders.put(order);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.purchaseOrders,
      documentId: order.id,
      operation: 'update',
      payload: order.toJson(),
    );

    await _syncIfOnline();
  }

  String _requiredId(String Function() reader, String message) {
    final id = _safeRead(reader);
    if (id.isEmpty) {
      throw ArgumentError(message);
    }
    return id;
  }

  String _ensureId(
    String Function() reader,
    void Function(String) writer, {
    String fallback = '',
  }) {
    final current = _safeRead(reader, fallback: fallback);
    if (current.isNotEmpty) {
      writer(current);
      return current;
    }

    final generated = _uuid.v4();
    writer(generated);
    return generated;
  }

  String _safeRead(String Function() reader, {String fallback = ''}) {
    try {
      return reader().trim();
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
