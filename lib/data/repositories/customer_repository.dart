import 'dart:convert';

import 'package:isar/isar.dart';
import '../local/base_entity.dart';
import '../local/entities/customer_entity.dart';
import '../local/entities/sync_queue_entity.dart';
import '../../services/database_service.dart';
import '../../services/field_encryption_service.dart';

class CustomerRepository {
  final DatabaseService _dbService;
  final FieldEncryptionService _fieldEncryption =
      FieldEncryptionService.instance;
  static const String _collectionName = 'customers';

  CustomerRepository(this._dbService);

  String _queueId(String recordId) => 'outbox_${_collectionName}_$recordId';

  Map<String, dynamic> _buildOutboxPayload(CustomerEntity customer) {
    final payload = customer.toDomain().toJson();
    payload['updatedAt'] = customer.updatedAt.toIso8601String();
    payload['isDeleted'] = customer.isDeleted;
    return payload;
  }

  Future<void> _upsertOutboxInTxn(
    CustomerEntity customer, {
    required String action,
  }) async {
    _ensureCreatedAt(customer, DateTime.now());
    _ensureStatus(customer);
    final queueId = _queueId(customer.id);
    final existing = await _dbService.syncQueue.getById(queueId);
    final item = SyncQueueEntity()
      ..id = queueId
      ..collection = _collectionName
      ..action = action
      ..dataJson = jsonEncode(_buildOutboxPayload(customer))
      ..createdAt = existing?.createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now();
    await _dbService.syncQueue.put(item);
  }

  // ==================== READ OPERATIONS ====================

  /// Fetch all customers - Local First
  Future<List<CustomerEntity>> getAllCustomers() async {
    return await _dbService.customers
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .sortByShopName()
        .findAll();
  }

  /// Get customers by route
  Future<List<CustomerEntity>> getCustomersByRoute(String route) async {
    return await _dbService.customers
        .where()
        .filter()
        .routeEqualTo(route)
        .and()
        .isDeletedEqualTo(false)
        .sortByShopName()
        .findAll();
  }

  /// Get customers by multiple routes
  Future<List<CustomerEntity>> getCustomersByRoutes(List<String> routes) async {
    if (routes.isEmpty) return [];

    return await _dbService.customers
        .where()
        .filter()
        .anyOf(routes, (q, route) => q.routeEqualTo(route))
        .and()
        .isDeletedEqualTo(false)
        .sortByShopName()
        .findAll();
  }

  /// Get customers by status
  Future<List<CustomerEntity>> getCustomersByStatus(String status) async {
    return await _dbService.customers
        .where()
        .filter()
        .statusEqualTo(status)
        .and()
        .isDeletedEqualTo(false)
        .sortByShopName()
        .findAll();
  }

  /// Get single customer by ID
  Future<CustomerEntity?> getCustomerById(String id) async {
    return await _dbService.customers.filter().idEqualTo(id).findFirst();
  }

  /// Search customers by name or mobile
  Future<List<CustomerEntity>> searchCustomers(String query) async {
    final lowerQuery = query.toLowerCase();

    if (!_fieldEncryption.isEnabled) {
      return await _dbService.customers
          .where()
          .filter()
          .isDeletedEqualTo(false)
          .and()
          .group(
            (q) => q
                .shopNameContains(lowerQuery, caseSensitive: false)
                .or()
                .ownerNameContains(lowerQuery, caseSensitive: false)
                .or()
                .mobileContains(query),
          )
          .sortByShopName()
          .findAll();
    }

    final candidates = await _dbService.customers
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .sortByShopName()
        .findAll();

    return candidates.where((customer) {
      final shop = customer.shopName.toLowerCase();
      final owner = customer.ownerName.toLowerCase();
      final mobile = _fieldEncryption.decryptString(
        customer.mobile,
        'customer:${customer.id}:mobile',
      );

      return shop.contains(lowerQuery) ||
          owner.contains(lowerQuery) ||
          mobile.contains(query);
    }).toList();
  }

  /// Get customers with balance greater than zero
  Future<List<CustomerEntity>> getCustomersWithBalance() async {
    return await _dbService.customers
        .where()
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
      final createdAt = customer.createdAt;
      if (createdAt.trim().isNotEmpty) {
        return;
      }
    } catch (_) {
      // Missing createdAt is expected for some legacy/newly constructed entities.
    }
    customer.createdAt = now.toIso8601String();
  }

  void _ensureStatus(CustomerEntity customer) {
    try {
      final status = customer.status;
      if (status.trim().isNotEmpty) {
        return;
      }
    } catch (_) {
      // Missing status is expected for some legacy/newly constructed entities.
    }
    customer.status = 'active';
  }

  /// Create or Update Customer - Local Commit
  Future<void> saveCustomer(CustomerEntity customer) async {
    final now = DateTime.now();
    _ensureCreatedAt(customer, now);
    _ensureStatus(customer);
    customer.updatedAt = now;
    customer.syncStatus = SyncStatus.pending;
    customer.encryptSensitiveFields();

    await _dbService.db.writeTxn(() async {
      await _dbService.customers.put(customer);
      await _upsertOutboxInTxn(customer, action: 'set');
    });
  }

  /// Update customer balance (direct set)
  Future<void> updateBalance(String customerId, double newBalance) async {
    await _dbService.db.writeTxn(() async {
      final customer = await _dbService.customers
          .filter()
          .idEqualTo(customerId)
          .findFirst();

      if (customer != null) {
        customer.balance = newBalance;
        customer.updatedAt = DateTime.now();
        customer.syncStatus = SyncStatus.pending;
        await _dbService.customers.put(customer);
        await _upsertOutboxInTxn(customer, action: 'set');
      }
    });
  }

  /// Adjust customer balance (add/subtract)
  Future<void> adjustBalance(String customerId, double delta) async {
    await _dbService.db.writeTxn(() async {
      final customer = await _dbService.customers
          .filter()
          .idEqualTo(customerId)
          .findFirst();

      if (customer != null) {
        customer.balance = customer.balance + delta;
        customer.updatedAt = DateTime.now();
        customer.syncStatus = SyncStatus.pending;
        await _dbService.customers.put(customer);
        await _upsertOutboxInTxn(customer, action: 'set');
      }
    });
  }

  /// Bulk update customer status
  Future<void> bulkUpdateStatus(List<String> customerIds, String status) async {
    await _dbService.db.writeTxn(() async {
      for (final id in customerIds) {
        final customer = await _dbService.customers
            .filter()
            .idEqualTo(id)
            .findFirst();

        if (customer != null) {
          customer.status = status;
          customer.updatedAt = DateTime.now();
          customer.syncStatus = SyncStatus.pending;
          await _dbService.customers.put(customer);
          await _upsertOutboxInTxn(customer, action: 'set');
        }
      }
    });
  }

  /// Bulk update customer route sequences
  Future<void> updateRouteSequence(List<Map<String, dynamic>> updates) async {
    await _dbService.db.writeTxn(() async {
      for (final update in updates) {
        final id = update['customerId'] as String;
        final sequence = update['sequence'] as int;

        final customer = await _dbService.customers
            .filter()
            .idEqualTo(id)
            .findFirst();

        if (customer != null) {
          customer.routeSequence = sequence;
          customer.updatedAt = DateTime.now();
          customer.syncStatus = SyncStatus.pending;
          await _dbService.customers.put(customer);
          await _upsertOutboxInTxn(customer, action: 'set');
        }
      }
    });
  }

  /// Soft delete customer
  Future<void> deleteCustomer(String customerId) async {
    await _dbService.db.writeTxn(() async {
      final customer = await _dbService.customers
          .filter()
          .idEqualTo(customerId)
          .findFirst();

      if (customer != null) {
        customer.isDeleted = true;
        customer.updatedAt = DateTime.now();
        customer.syncStatus = SyncStatus.pending;
        await _dbService.customers.put(customer);
        await _upsertOutboxInTxn(customer, action: 'delete');
      }
    });
  }

  // ==================== SYNC SUPPORT ====================

  /// Get all pending customers (for sync)
  Future<List<CustomerEntity>> getPendingCustomers() async {
    return await _dbService.customers
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
  }

  /// Mark customer as synced
  Future<void> markAsSynced(String customerId) async {
    await _dbService.db.writeTxn(() async {
      final customer = await _dbService.customers
          .filter()
          .idEqualTo(customerId)
          .findFirst();

      if (customer != null) {
        customer.syncStatus = SyncStatus.synced;
        await _dbService.customers.put(customer);
        final queueItem = await _dbService.syncQueue.getById(
          _queueId(customer.id),
        );
        if (queueItem != null) {
          await _dbService.syncQueue.delete(queueItem.isarId);
        }
      }
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
}
