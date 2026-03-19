import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/customer_entity.dart';
import '../../services/database_service.dart';
import '../../services/field_encryption_service.dart';

class CustomerRepository {
  final DatabaseService _dbService;
  final FieldEncryptionService _fieldEncryption =
      FieldEncryptionService.instance;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  static const Uuid _uuid = Uuid();

  CustomerRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  // ==================== READ OPERATIONS ====================

  /// Fetch all customers - Local First
  Future<List<CustomerEntity>> getAllCustomers() async {
    return _dbService.customers
        .filter()
        .isDeletedEqualTo(false)
        .sortByShopName()
        .findAll();
  }

  /// Watches all non-deleted customers from Isar.
  Stream<List<CustomerEntity>> watchAllCustomers() {
    return _dbService.customers
        .filter()
        .isDeletedEqualTo(false)
        .sortByShopName()
        .watch(fireImmediately: true);
  }

  /// Get customers by route
  Future<List<CustomerEntity>> getCustomersByRoute(String route) async {
    return _dbService.customers
        .filter()
        .routeEqualTo(route)
        .and()
        .isDeletedEqualTo(false)
        .sortByShopName()
        .findAll();
  }

  /// Get customers by multiple routes
  Future<List<CustomerEntity>> getCustomersByRoutes(List<String> routes) async {
    if (routes.isEmpty) {
      return [];
    }

    return _dbService.customers
        .filter()
        .anyOf(routes, (query, route) => query.routeEqualTo(route))
        .and()
        .isDeletedEqualTo(false)
        .sortByShopName()
        .findAll();
  }

  /// Get customers by status
  Future<List<CustomerEntity>> getCustomersByStatus(String status) async {
    return _dbService.customers
        .filter()
        .statusEqualTo(status)
        .and()
        .isDeletedEqualTo(false)
        .sortByShopName()
        .findAll();
  }

  /// Get single customer by ID
  Future<CustomerEntity?> getCustomerById(String id) async {
    return _dbService.customers
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Gets a customer by mobile number from Isar only.
  Future<CustomerEntity?> getCustomerByMobile(String mobile) async {
    if (!_fieldEncryption.isEnabled) {
      return _dbService.customers
          .filter()
          .mobileEqualTo(mobile)
          .and()
          .isDeletedEqualTo(false)
          .findFirst();
    }

    final customers = await getAllCustomers();
    for (final customer in customers) {
      final decrypted = customer.toDomain().mobile;
      if (decrypted == mobile) {
        return customer;
      }
    }
    return null;
  }

  /// Search customers by name or mobile
  Future<List<CustomerEntity>> searchCustomers(String query) async {
    final lowerQuery = query.toLowerCase();

    if (!_fieldEncryption.isEnabled) {
      return _dbService.customers
          .filter()
          .isDeletedEqualTo(false)
          .and()
          .group(
            (builder) => builder
                .shopNameContains(lowerQuery, caseSensitive: false)
                .or()
                .ownerNameContains(lowerQuery, caseSensitive: false)
                .or()
                .mobileContains(query),
          )
          .sortByShopName()
          .findAll();
    }

    final candidates = await getAllCustomers();
    return candidates.where((customer) {
      final domain = customer.toDomain();
      return domain.shopName.toLowerCase().contains(lowerQuery) ||
          domain.ownerName.toLowerCase().contains(lowerQuery) ||
          domain.mobile.contains(query);
    }).toList(growable: false);
  }

  /// Get customers with balance greater than zero
  Future<List<CustomerEntity>> getCustomersWithBalance() async {
    return _dbService.customers
        .filter()
        .balanceGreaterThan(0)
        .and()
        .isDeletedEqualTo(false)
        .sortByShopName()
        .findAll();
  }

  // ==================== WRITE OPERATIONS ====================

  void _ensureCreatedAt(CustomerEntity customer, DateTime now) {
    try {
      final current = customer.createdAt;
      if (current.trim().isNotEmpty) {
        return;
      }
    } catch (_) {
      // Late initialization fallback.
    }
    customer.createdAt = now.toIso8601String();
  }

  void _ensureStatus(CustomerEntity customer) {
    try {
      final current = customer.status;
      if (current.trim().isNotEmpty) {
        return;
      }
    } catch (_) {
      // Late initialization fallback.
    }
    customer.status = 'active';
  }

  String _ensureId(CustomerEntity customer) {
    try {
      final current = customer.id.trim();
      if (current.isNotEmpty) {
        return current;
      }
    } catch (_) {
      // Late initialization fallback.
    }
    final generated = _uuid.v4();
    customer.id = generated;
    return generated;
  }

  /// Create or Update Customer - Local Commit
  Future<void> saveCustomer(CustomerEntity customer) async {
    final now = DateTime.now();
    final id = _ensureId(customer);
    final existing = await _dbService.customers.getById(id);
    _ensureCreatedAt(customer, now);
    _ensureStatus(customer);

    customer
      ..id = id
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..deletedAt = null
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();
    customer.encryptSensitiveFields();

    await _dbService.db.writeTxn(() async {
      await _dbService.customers.put(customer);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.customers,
      documentId: customer.id,
      operation: existing == null ? 'create' : 'update',
      payload: customer.toJson(),
    );

    await _syncIfOnline();
  }

  /// Update customer balance (direct set)
  Future<void> updateBalance(String customerId, double newBalance) async {
    await updateCustomerBalance(customerId, newBalance);
  }

  /// Updates customer balance and queues sync.
  Future<void> updateCustomerBalance(String customerId, double amount) async {
    final customer = await getCustomerById(customerId);
    if (customer == null) {
      return;
    }

    customer
      ..balance = amount
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.customers.put(customer);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.customers,
      documentId: customer.id,
      operation: 'update',
      payload: customer.toJson(),
    );

    await _syncIfOnline();
  }

  /// Adjust customer balance (add/subtract)
  Future<void> adjustBalance(String customerId, double delta) async {
    final customer = await getCustomerById(customerId);
    if (customer == null) {
      return;
    }

    customer
      ..balance = customer.balance + delta
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.customers.put(customer);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.customers,
      documentId: customer.id,
      operation: 'update',
      payload: customer.toJson(),
    );

    await _syncIfOnline();
  }

  /// Bulk update customer status
  Future<void> bulkUpdateStatus(List<String> customerIds, String status) async {
    final customers = <CustomerEntity>[];
    final deviceId = await _deviceIdService.getDeviceId();
    final now = DateTime.now();

    await _dbService.db.writeTxn(() async {
      for (final id in customerIds) {
        final customer = await _dbService.customers.getById(id);
        if (customer == null || customer.isDeleted) {
          continue;
        }
        customer
          ..status = status
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending
          ..isSynced = false
          ..lastSynced = null
          ..version += 1
          ..deviceId = deviceId;
        customers.add(customer);
        await _dbService.customers.put(customer);
      }
    });

    for (final customer in customers) {
      await _syncQueueService.addToQueue(
        collectionName: CollectionRegistry.customers,
        documentId: customer.id,
        operation: 'update',
        payload: customer.toJson(),
      );
    }

    await _syncIfOnline();
  }

  /// Bulk update customer route sequences
  Future<void> updateRouteSequence(List<Map<String, dynamic>> updates) async {
    final customers = <CustomerEntity>[];
    final deviceId = await _deviceIdService.getDeviceId();
    final now = DateTime.now();

    await _dbService.db.writeTxn(() async {
      for (final update in updates) {
        final id = update['customerId']?.toString() ?? '';
        final sequence = update['sequence'] as int? ?? 0;
        final customer = await _dbService.customers.getById(id);
        if (customer == null || customer.isDeleted) {
          continue;
        }
        customer
          ..routeSequence = sequence
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending
          ..isSynced = false
          ..lastSynced = null
          ..version += 1
          ..deviceId = deviceId;
        customers.add(customer);
        await _dbService.customers.put(customer);
      }
    });

    for (final customer in customers) {
      await _syncQueueService.addToQueue(
        collectionName: CollectionRegistry.customers,
        documentId: customer.id,
        operation: 'update',
        payload: customer.toJson(),
      );
    }

    await _syncIfOnline();
  }

  /// Soft delete customer
  Future<void> deleteCustomer(String customerId) async {
    final customer = await getCustomerById(customerId);
    if (customer == null) {
      return;
    }

    final now = DateTime.now();
    customer
      ..isDeleted = true
      ..deletedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.customers.put(customer);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.customers,
      documentId: customer.id,
      operation: 'delete',
      payload: customer.toJson(),
    );

    await _syncIfOnline();
  }

  // ==================== SYNC SUPPORT ====================

  /// Get all pending customers (for sync)
  Future<List<CustomerEntity>> getPendingCustomers() async {
    return _dbService.customers
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
  }

  /// Mark customer as synced
  Future<void> markAsSynced(String customerId) async {
    final customer = await _dbService.customers.getById(customerId);
    if (customer == null) {
      return;
    }

    customer
      ..syncStatus = SyncStatus.synced
      ..isSynced = true
      ..lastSynced = DateTime.now();

    await _dbService.db.writeTxn(() async {
      await _dbService.customers.put(customer);
    });
  }

  /// Batch save customers (used during sync pull)
  Future<void> saveAllCustomers(List<CustomerEntity> customers) async {
    await _dbService.db.writeTxn(() async {
      if (_fieldEncryption.isEnabled) {
        for (final customer in customers) {
          customer.encryptSensitiveFields();
        }
      }
      await _dbService.customers.putAll(customers);
    });
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
