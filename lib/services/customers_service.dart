import 'dart:async';
import 'package:isar/isar.dart';
import 'offline_first_service.dart';
import '../models/customer.dart';
import '../data/local/entities/customer_entity.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import 'outbox_codec.dart';
export '../models/customer.dart';

const customersCollection = 'customers';

class CustomersService extends OfflineFirstService {
  CustomersService(super.firebase, [super.dbService]);

  static const String _outboxCollection = 'customers';

  @override
  String get localStorageKey => 'local_customers';

  @override
  bool get useIsar => true;

  String _queueId(String id) => 'outbox_${_outboxCollection}_$id';

  Future<void> _upsertOutboxInTxn(
    CustomerEntity entity, {
    required String action,
  }) async {
    final queueId = _queueId(entity.id);
    final existing = await dbService.syncQueue.getById(queueId);
    final now = DateTime.now();
    final payload = entity.toDomain().toJson()
      ..['updatedAt'] = entity.updatedAt.toIso8601String()
      ..['isDeleted'] = entity.isDeleted;
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;

    final queue = SyncQueueEntity()
      ..id = queueId
      ..collection = _outboxCollection
      ..action = action
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: payload,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: true,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await dbService.syncQueue.put(queue);
  }

  // Get customers with filters (offline-first via Isar)
  Future<List<Customer>> getCustomers({
    String? route,
    List<String>? routes,
    String? status,
    int? limitCount,
  }) async {
    try {
      // If filtering by empty routes list, return empty
      if (routes != null && routes.isEmpty) {
        return [];
      }

      // 1. ALWAYS read from ISAR first
      var query = dbService.customers.filter().isDeletedEqualTo(false);

      if (route != null && route != 'all') {
        query = query.routeEqualTo(route);
      }

      if (routes != null && routes.isNotEmpty) {
        // Isar doesn't have a direct 'whereIn' for filtering, but we can use 'anyOf'
        // Actually, it's easier to use a loop or filter in memory if routes list is small,
        // but let's try to be efficient.
        // For simplicity and safety during migration:
      }

      var entities = await query.findAll();

      // 2. If local is empty, try to bootstrap from Firebase ONCE
      if (entities.isEmpty && (routes == null || routes.isEmpty)) {
        final items = await bootstrapFromFirebase(
          collectionName: customersCollection,
        );
        if (items.isNotEmpty) {
          // Convert Map to Entity and save to Isar
          await dbService.db.writeTxn(() async {
            for (final item in items) {
              final entity = CustomerEntity.fromDomain(Customer.fromJson(item));
              entity.syncStatus =
                  SyncStatus.synced; // Bootstrapped items are already on server
              await dbService.customers.put(entity);
            }
          });
          // Refresh entities
          entities = await query.findAll();
        }
      }

      // 3. Apply complex filters in memory
      var filtered = entities;
      if (routes != null && routes.isNotEmpty) {
        filtered = filtered.where((e) => routes.contains(e.route)).toList();
      }
      if (status != null) {
        filtered = filtered.where((e) => e.status == status).toList();
      }

      // 4. Apply limit
      if (limitCount != null && filtered.length > limitCount) {
        filtered = filtered.take(limitCount).toList();
      }

      // 5. Convert to Domain objects and DEDUPLICATE to prevent duplicate customers in UI
      final customers = filtered.map((e) => e.toDomain()).toList();
      return deduplicate(customers, (c) => c.id);
    } catch (e) {
      throw handleError(e, 'getCustomers');
    }
  }

  // Get single customer by ID (offline-first via Isar)
  Future<Customer?> getCustomerById(String id) async {
    try {
      // 1. Try Isar first
      final entity = await dbService.customers
          .filter()
          .idEqualTo(id)
          .findFirst();
      if (entity != null) return entity.toDomain();

      // 2. Fallback to Firebase if not found locally (maybe new or not synced yet)
      final firestore = db;
      if (firestore == null) return null;

      final docSnap = await firestore
          .collection(customersCollection)
          .doc(id)
          .get();
      if (docSnap.exists) {
        final data = Map<String, dynamic>.from(docSnap.data() as Map);
        data['id'] = docSnap.id;
        final customer = Customer.fromJson(data);

        // Background save to Isar for next time
        await dbService.db.writeTxn(() async {
          await dbService.customers.put(CustomerEntity.fromDomain(customer));
        });

        return customer;
      }

      return null;
    } catch (e) {
      throw handleError(e, 'getCustomerById');
    }
  }

  // Add customer (Isar-first)
  Future<String?> addCustomer({
    required String shopName,
    required String ownerName,
    required String mobile,
    String? alternateMobile,
    String? email,
    required String address,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? gstin,
    String? pan,
    required String route,
    int? routeSequence,
    String status = 'active',
    double balance = 0.0,
    double? creditLimit,
    String? paymentTerms,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final customerId = generateId();
      final now = getCurrentTimestamp();

      final customer = Customer(
        id: customerId,
        shopName: shopName,
        ownerName: ownerName,
        mobile: mobile,
        alternateMobile: alternateMobile,
        email: email,
        address: address,
        addressLine2: addressLine2,
        city: city,
        state: state,
        pincode: pincode,
        gstin: gstin,
        pan: pan,
        route: route,
        routeSequence: routeSequence,
        status: status,
        balance: balance,
        creditLimit: creditLimit,
        paymentTerms: paymentTerms,
        createdAt: now,
        updatedAt: now,
        latitude: latitude,
        longitude: longitude,
      );

      final entity = CustomerEntity.fromDomain(customer);
      entity.syncStatus = SyncStatus.pending;

      // 1. MANDATORY: Save to local ISAR FIRST
      await dbService.db.writeTxn(() async {
        await dbService.customers.put(entity);
        await _upsertOutboxInTxn(entity, action: 'set');
      });

      return customerId;
    } catch (e) {
      throw handleError(e, 'addCustomer');
    }
  }

  // Update customer (Isar-first)
  Future<bool> updateCustomer({
    required String id,
    String? shopName,
    String? ownerName,
    String? mobile,
    String? alternateMobile,
    String? email,
    String? address,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? gstin,
    String? pan,
    String? route,
    int? routeSequence,
    String? status,
    double? balance,
    double? creditLimit,
    String? paymentTerms,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final entity = await dbService.customers
          .filter()
          .idEqualTo(id)
          .findFirst();
      if (entity == null) {
        throw Exception('Customer not found in local storage.');
      }

      // Update fields
      if (shopName != null) entity.shopName = shopName;
      if (ownerName != null) entity.ownerName = ownerName;
      if (mobile != null) entity.mobile = mobile;
      if (alternateMobile != null) entity.alternateMobile = alternateMobile;
      if (email != null) entity.email = email;
      if (address != null) entity.address = address;
      if (addressLine2 != null) entity.addressLine2 = addressLine2;
      if (city != null) entity.city = city;
      if (state != null) entity.state = state;
      if (pincode != null) entity.pincode = pincode;
      if (gstin != null) entity.gstin = gstin;
      if (pan != null) entity.pan = pan;
      if (route != null) entity.route = route;
      if (routeSequence != null) entity.routeSequence = routeSequence;
      if (status != null) entity.status = status;
      if (balance != null) entity.balance = balance;
      if (creditLimit != null) entity.creditLimit = creditLimit;
      if (paymentTerms != null) entity.paymentTerms = paymentTerms;
      if (latitude != null) entity.latitude = latitude;
      if (longitude != null) entity.longitude = longitude;

      entity.updatedAt = DateTime.now();
      entity.syncStatus = SyncStatus.pending;
      entity.encryptSensitiveFields();

      // 1. Save to local ISAR
      await dbService.db.writeTxn(() async {
        await dbService.customers.put(entity);
        await _upsertOutboxInTxn(entity, action: 'set');
      });

      return true;
    } catch (e) {
      throw handleError(e, 'updateCustomer');
    }
  }

  // Bulk update customer status (Isar-first)
  Future<bool> bulkUpdateCustomerStatus(
    List<String> customerIds,
    String status,
  ) async {
    try {
      await dbService.db.writeTxn(() async {
        for (final id in customerIds) {
          final entity = await dbService.customers
              .filter()
              .idEqualTo(id)
              .findFirst();
          if (entity != null) {
            entity.status = status;
            entity.updatedAt = DateTime.now();
            entity.syncStatus = SyncStatus.pending;
            await dbService.customers.put(entity);
            await _upsertOutboxInTxn(entity, action: 'set');
          }
        }
      });
      return true;
    } catch (e) {
      throw handleError(e, 'bulkUpdateCustomerStatus');
    }
  }

  // Export customers (from Isar)
  Future<List<Customer>> exportCustomers() async {
    try {
      final entities = await dbService.customers
          .where()
          .sortByShopName()
          .findAll();
      return entities.map((e) => e.toDomain()).toList();
    } catch (e) {
      throw handleError(e, 'exportCustomers');
    }
  }

  // === Customer Balance Functions (Isar-first) ===

  Future<double> getCustomerBalance(String customerId) async {
    try {
      final entity = await dbService.customers
          .filter()
          .idEqualTo(customerId)
          .findFirst();
      return entity?.balance ?? 0.0;
    } catch (e) {
      handleError(e, 'getCustomerBalance');
      return 0.0;
    }
  }

  Future<bool> setCustomerBalance(String customerId, double newBalance) async {
    try {
      final entity = await dbService.customers
          .filter()
          .idEqualTo(customerId)
          .findFirst();
      if (entity != null) {
        entity.balance = newBalance;
        entity.updatedAt = DateTime.now();
        entity.syncStatus = SyncStatus.pending;
        await dbService.db.writeTxn(() async {
          await dbService.customers.put(entity);
          await _upsertOutboxInTxn(entity, action: 'set');
        });
        return true;
      }
      return false;
    } catch (e) {
      throw handleError(e, 'setCustomerBalance');
    }
  }

  Future<bool> adjustCustomerBalance(String customerId, double amount) async {
    try {
      await dbService.db.writeTxn(() async {
        final entity = await dbService.customers
            .filter()
            .idEqualTo(customerId)
            .findFirst();
        if (entity != null) {
          entity.balance += amount;
          entity.updatedAt = DateTime.now();
          entity.syncStatus = SyncStatus.pending;
          await dbService.customers.put(entity);
          await _upsertOutboxInTxn(entity, action: 'set');
        }
      });
      return true;
    } catch (e) {
      throw handleError(e, 'adjustCustomerBalance');
    }
  }

  Future<bool> deductAmountFromCustomer(
    String customerId,
    double amount,
  ) async {
    return adjustCustomerBalance(customerId, -amount);
  }

  Future<List<String>> getUniqueRoutes() async {
    try {
      final results = await dbService.customers
          .where()
          .distinctByRoute()
          .findAll();
      final routes = results.map((e) => e.route).toSet().toList();
      routes.sort();
      return routes;
    } catch (e) {
      throw handleError(e, 'getUniqueRoutes');
    }
  }
}
