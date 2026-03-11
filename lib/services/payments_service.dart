import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';
import 'package:isar/isar.dart' hide Query;
import 'package:flutter_app/core/constants/collection_registry.dart';
import '../constants/role_access_matrix.dart';
import 'offline_first_service.dart';
import 'database_service.dart';
import 'service_capability_guard.dart';
import '../data/local/entities/payment_entity.dart';
import '../data/local/entities/sale_entity.dart';
import '../data/local/entities/customer_entity.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import 'outbox_codec.dart';

const paymentLinksCollection = CollectionRegistry.paymentLinks;
const paymentsCollection = CollectionRegistry.payments;
const customersCollection = CollectionRegistry.customers;
const salesCollection = CollectionRegistry.sales;

// ... Models (ManualPayment, PaymentMode, PaymentLink, CreatePaymentLinkPayload) ...

enum PaymentMode { cash, cheque, transfer, online }

class ManualPayment {
  final String id;
  final String customerId;
  final String customerName;
  final String? saleId;
  final double amount;
  final PaymentMode mode;
  final String date;
  final String? reference;
  final String? notes;
  final String collectorId;
  final String collectorName;
  final String createdAt;

  ManualPayment({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.saleId,
    required this.amount,
    required this.mode,
    required this.date,
    this.reference,
    this.notes,
    required this.collectorId,
    required this.collectorName,
    required this.createdAt,
  });

  factory ManualPayment.fromJson(Map<String, dynamic> json) {
    return ManualPayment(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      saleId: json['saleId'] as String?,
      amount: (json['amount'] ?? 0).toDouble(),
      mode: PaymentMode.values.firstWhere(
        (e) => e.toString().split('.').last == json['mode'],
        orElse: () => PaymentMode.cash,
      ),
      date: json['date'] as String? ?? DateTime.now().toIso8601String(),
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      collectorId: json['collectorId'] as String,
      collectorName: json['collectorName'] as String? ?? 'Unknown',
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'saleId': saleId,
      'amount': amount,
      'mode': mode.toString().split('.').last,
      'date': date,
      'reference': reference,
      'notes': notes,
      'collectorId': collectorId,
      'collectorName': collectorName,
      'createdAt': createdAt,
    };
  }
}

class PaymentLink {
  final String id;
  final String saleId;
  final String customerId;
  final double amount;
  final String currency;
  final String description;
  final String status;
  final String? createdAt;
  final String? expiresAt;
  final String? paidAt;
  final String? paymentId;

  PaymentLink({
    required this.id,
    required this.saleId,
    required this.customerId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.status,
    this.createdAt,
    this.expiresAt,
    this.paidAt,
    this.paymentId,
  });

  factory PaymentLink.fromJson(Map<String, dynamic> json) {
    return PaymentLink(
      id: json['id'] as String,
      saleId: json['saleId'] as String,
      customerId: json['customerId'] as String,
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      paidAt: json['paidAt'] as String?,
      paymentId: json['paymentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'saleId': saleId,
      'customerId': customerId,
      'amount': amount,
      'currency': currency,
      'description': description,
      'status': status,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'paidAt': paidAt,
      'paymentId': paymentId,
    };
  }
}

class CreatePaymentLinkPayload {
  final String saleId;
  final String customerId;
  final double amount;
  final String description;
  final DateTime? expiresAt;

  CreatePaymentLinkPayload({
    required this.saleId,
    required this.customerId,
    required this.amount,
    required this.description,
    this.expiresAt,
  });
}

class PaymentsService extends OfflineFirstService {
  final DatabaseService _dbService;

  PaymentsService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

  ServiceCapabilityGuard get _capabilityGuard =>
      ServiceCapabilityGuard(auth: auth, dbService: _dbService);

  @override
  String get localStorageKey => 'local_payments';

  @override
  bool get useIsar => true;

  static const String _legacyMigrationFlag = 'migrated_payments_to_isar_v1';

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  double _round2(num value) => (value * 100).roundToDouble() / 100;

  bool _isSettled(double paid, double total) => _round2(paid) >= _round2(total);

  String _normalizeIsoTimestamp(dynamic value, {required String fallback}) {
    if (value is DateTime) return value.toIso8601String();
    final str = value?.toString();
    if (str != null && str.isNotEmpty) return str;
    return fallback;
  }

  Future<SaleEntity> _resolveSaleForPayment({
    required String customerId,
    String? saleId,
  }) async {
    if (saleId != null && saleId.isNotEmpty) {
      final sale = await _dbService.sales
          .filter()
          .idEqualTo(saleId)
          .findFirst();
      if (sale == null) {
        throw Exception('Linked invoice not found for payment.');
      }
      if (sale.status == 'cancelled') {
        throw Exception('Cannot record payment on a cancelled invoice.');
      }
      if (sale.recipientId != customerId) {
        throw Exception('Sale does not belong to this customer.');
      }
      return sale;
    }

    final candidates = await _dbService.sales
        .filter()
        .recipientIdEqualTo(customerId)
        .findAll();
    final openInvoices = candidates.where((sale) {
      if (sale.status == 'cancelled') return false;
      final total = sale.totalAmount ?? 0.0;
      final paid = sale.paidAmount ?? 0.0;
      final outstanding = _round2(total - paid);
      return outstanding > 0;
    }).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (openInvoices.isEmpty) {
      throw Exception('No open invoices for this customer.');
    }
    if (openInvoices.length > 1) {
      throw Exception('Multiple open invoices found. Please specify saleId.');
    }
    return openInvoices.first;
  }

  PaymentEntity _buildPaymentEntityFromMap(
    Map<String, dynamic> data, {
    required SyncStatus syncStatus,
  }) {
    final createdAt =
        data['createdAt']?.toString() ?? DateTime.now().toIso8601String();
    final updatedAt =
        DateTime.tryParse(data['updatedAt']?.toString() ?? '') ??
        DateTime.tryParse(createdAt) ??
        DateTime.now();

    return PaymentEntity()
      ..id = data['id']?.toString() ?? generateId()
      ..customerId = data['customerId']?.toString() ?? ''
      ..customerName = data['customerName']?.toString()
      ..saleId = data['saleId']?.toString()
      ..amount = _toDouble(data['amount']) ?? 0.0
      ..mode =
          data['mode']?.toString() ??
          PaymentMode.cash.toString().split('.').last
      ..date = data['date']?.toString() ?? createdAt
      ..reference = data['reference']?.toString()
      ..notes = data['notes']?.toString()
      ..collectorId = data['collectorId']?.toString() ?? ''
      ..collectorName = data['collectorName']?.toString()
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..syncStatus = syncStatus;
  }

  ManualPayment _paymentFromEntity(PaymentEntity entity) {
    return ManualPayment(
      id: entity.id,
      customerId: entity.customerId,
      customerName: entity.customerName ?? '',
      saleId: entity.saleId,
      amount: entity.amount,
      mode: PaymentMode.values.firstWhere(
        (e) => e.toString().split('.').last == entity.mode,
        orElse: () => PaymentMode.cash,
      ),
      date: entity.date,
      reference: entity.reference,
      notes: entity.notes,
      collectorId: entity.collectorId,
      collectorName: entity.collectorName ?? 'Unknown',
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
    );
  }

  Future<String> _enqueuePaymentForSync(
    Map<String, dynamic> paymentData,
  ) async {
    final paymentId = paymentData['id']?.toString();
    if (paymentId == null || paymentId.isEmpty) return '';

    final queueId = 'payments_$paymentId';
    final existing = await _dbService.syncQueue.getById(queueId);
    final now = DateTime.now();
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;
    final normalizedPayload = OutboxCodec.ensureCommandPayload(
      collection: paymentsCollection,
      action: 'add',
      payload: paymentData,
      existingMeta: existingMeta,
      queueId: queueId,
    );
    paymentData
      ..clear()
      ..addAll(normalizedPayload);

    final entity = SyncQueueEntity()
      ..id = queueId
      ..collection = paymentsCollection
      ..action = 'add'
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: normalizedPayload,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: true,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.put(entity);
    });
    return queueId;
  }

  Future<void> _dequeuePaymentForSync(String queueId) async {
    if (queueId.isEmpty) return;
    final existing = await _dbService.syncQueue.getById(queueId);
    if (existing == null) return;
    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.delete(existing.isarId);
    });
  }

  Future<bool> _queueAndSyncPayment(Map<String, dynamic> paymentData) async {
    final queueId = await _enqueuePaymentForSync(paymentData);
    if (db == null) return false;
    try {
      await performSync('add', paymentsCollection, paymentData);
      await _dequeuePaymentForSync(queueId);
      return true;
    } catch (e) {
      debugPrint('Error syncing payment queueId $queueId: $e');
      return false;
    }
  }

  Future<void> _migrateLegacyPaymentsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool(_legacyMigrationFlag) ?? false;
    if (migrated) return;

    final jsonStr = prefs.getString(localStorageKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      await prefs.setBool(_legacyMigrationFlag, true);
      return;
    }

    List<dynamic> legacyList;
    try {
      legacyList = jsonDecode(jsonStr) as List<dynamic>;
    } catch (e) {
      debugPrint('Error decoding legacy payments json: $e');
      return;
    }

    if (legacyList.isEmpty) {
      await prefs.setBool(_legacyMigrationFlag, true);
      return;
    }

    final existingPayments = await _dbService.payments.where().findAll();
    final existingIds = existingPayments.map((e) => e.id).toSet();

    final existingQueueItems = await _dbService.syncQueue
        .filter()
        .collectionEqualTo(paymentsCollection)
        .findAll();
    final queuedIds = <String>{};
    for (final item in existingQueueItems) {
      final decoded = OutboxCodec.decode(
        item.dataJson,
        fallbackQueuedAt: item.createdAt,
      );
      final id = decoded.payload['id']?.toString();
      if (id != null && id.isNotEmpty) queuedIds.add(id);
    }

    await _dbService.db.writeTxn(() async {
      for (final entry in legacyList) {
        if (entry is! Map) continue;
        final data = Map<String, dynamic>.from(entry);
        final id = data['id']?.toString();
        if (id == null || id.isEmpty) continue;
        if (existingIds.contains(id)) continue;

        final isSynced = data['isSynced'] == true;
        final needsSync = !isSynced;

        final entity = _buildPaymentEntityFromMap(
          data,
          syncStatus: needsSync ? SyncStatus.pending : SyncStatus.synced,
        );
        await _dbService.payments.put(entity);
        existingIds.add(id);

        if (needsSync && !queuedIds.contains(id)) {
          final queueEntity = SyncQueueEntity()
            ..id = 'payments_$id'
            ..collection = paymentsCollection
            ..action = 'add'
            ..dataJson = OutboxCodec.encodeEnvelope(
              payload: data,
              now: DateTime.now(),
              resetRetryState: true,
            )
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now()
            ..syncStatus = SyncStatus.pending;
          await _dbService.syncQueue.put(queueEntity);
          queuedIds.add(id);

          // Apply local balance updates for unsynced legacy payments
          final customerId = data['customerId']?.toString();
          if (customerId != null && customerId.isNotEmpty) {
            final customer = await _dbService.customers
                .filter()
                .idEqualTo(customerId)
                .findFirst();
            if (customer != null) {
              customer.balance =
                  customer.balance - (_toDouble(data['amount']) ?? 0.0);
              customer.updatedAt = DateTime.now();
              customer.syncStatus = SyncStatus.pending;
              await _dbService.customers.put(customer);
            }
          }

          final saleId = data['saleId']?.toString();
          if (saleId != null && saleId.isNotEmpty) {
            final sale = await _dbService.sales
                .filter()
                .idEqualTo(saleId)
                .findFirst();
            if (sale != null) {
              final totalAmount = sale.totalAmount ?? 0.0;
              final oldPaid = sale.paidAmount ?? 0.0;
              final newPaid = oldPaid + (_toDouble(data['amount']) ?? 0.0);
              sale.paidAmount = newPaid;
              sale.paymentStatus = _isSettled(newPaid, totalAmount)
                  ? 'paid'
                  : 'partial';
              sale.updatedAt = DateTime.now();
              sale.syncStatus = SyncStatus.pending;
              await _dbService.sales.put(sale);
            }
          }
        }
      }
    });

    await prefs.remove(localStorageKey);
    await prefs.setBool(_legacyMigrationFlag, true);
  }

  @override
  Future<void> performSync(
    String action,
    String collection,
    Map<String, dynamic> data,
  ) async {
    final firestore = db;
    if (firestore == null) return;

    if (action == 'add' && collection == paymentsCollection) {
      final paymentId = data['id']?.toString().trim();
      if (paymentId == null || paymentId.isEmpty) {
        throw Exception('Payment sync payload missing id.');
      }
      final commandKey =
          OutboxCodec.readIdempotencyKey(data) ??
          OutboxCodec.buildCommandKey(
            collection: paymentsCollection,
            action: action,
            payload: data,
          );

      final batch = firestore.batch();
      try {
        final docRef = firestore.collection(collection).doc(paymentId);
        final existingPaymentDoc = await docRef.get();
        if (existingPaymentDoc.exists) {
          // Idempotent replay guard: payment already applied in a previous commit.
          return;
        }

        final nowIso = DateTime.now().toIso8601String();

        // 1. Update Customer Balance
        final custRef = firestore
            .collection(customersCollection)
            .doc(data['customerId']);
        batch.update(custRef, {
          'balance': FieldValue.increment(-(data['amount'] as num).toDouble()),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 2. Update Sale (if linked)
        if (data['saleId'] != null) {
          final saleRef = firestore
              .collection(salesCollection)
              .doc(data['saleId']);
          final saleDoc = await saleRef.get();
          if (saleDoc.exists) {
            final saleData = saleDoc.data()!;
            final total = (saleData['totalAmount'] as num).toDouble();
            final currentPaid = (saleData['paidAmount'] as num? ?? 0)
                .toDouble();
            final newPaid = currentPaid + (data['amount'] as num).toDouble();
            final status = _isSettled(newPaid, total) ? 'paid' : 'partial';

            batch.update(saleRef, {
              'paidAmount': newPaid,
              'paymentStatus': status,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }

        // 3. Create Payment
        final createdAt = _normalizeIsoTimestamp(
          data['createdAt'],
          fallback: nowIso,
        );
        final updatedAt = _normalizeIsoTimestamp(
          data['updatedAt'],
          fallback: nowIso,
        );
        final updatedAtEpoch =
            DateTime.tryParse(updatedAt)?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch;
        batch.set(docRef, {
          ...data,
          OutboxCodec.idempotencyKeyField: commandKey,
          'createdAt': createdAt,
          'updatedAt': updatedAt,
          'updatedAtEpoch': updatedAtEpoch,
          'isSynced': true,
        });

        await batch.commit();
      } catch (e) {
        AppLogger.error('Payment sync batch failed', error: e, tag: 'Sync');
        rethrow;
      }
      return;
    }

    await super.performSync(action, collection, data);
  }

  Future<String?> addManualPayment({
    required String customerId,
    required String customerName,
    String? saleId,
    required double amount,
    required PaymentMode mode,
    required String date,
    String? reference,
    String? notes,
    required String collectorId,
    required String collectorName,
  }) async {
    try {
      await _migrateLegacyPaymentsIfNeeded();
      await _capabilityGuard.requireCapability(
        RoleCapability.paymentsCreate,
        operation: 'create manual payment',
      );
      final now = getCurrentTimestamp();
      final targetSale = await _resolveSaleForPayment(
        customerId: customerId,
        saleId: saleId,
      );
      if (targetSale.recipientType != 'customer') {
        throw Exception('Payments can only be linked to customer invoices.');
      }

      final resolvedSaleId = targetSale.id;
      final totalAmount = targetSale.totalAmount ?? 0.0;
      final currentPaid = targetSale.paidAmount ?? 0.0;
      final outstanding = _round2(totalAmount - currentPaid);
      if (outstanding <= 0) {
        throw Exception('Invoice is already settled.');
      }
      if (_round2(amount) > outstanding) {
        throw Exception('Payment exceeds outstanding amount (₹$outstanding).');
      }
      final newPaid = _round2(currentPaid + amount);
      final paymentStatus = _isSettled(newPaid, totalAmount)
          ? 'paid'
          : 'partial';

      // 1. Update Local Customer/Sale + Add Local Payment (Isar-first)
      final paymentId = generateId();
      await _dbService.db.writeTxn(() async {
        final customer = await _dbService.customers
            .filter()
            .idEqualTo(customerId)
            .findFirst();
        if (customer != null) {
          customer.balance = customer.balance - amount;
          customer.updatedAt = DateTime.now();
          customer.syncStatus = SyncStatus.pending;
          await _dbService.customers.put(customer);
        }

        final sale = await _dbService.sales
            .filter()
            .idEqualTo(resolvedSaleId)
            .findFirst();
        if (sale != null) {
          sale.paidAmount = newPaid;
          sale.paymentStatus = paymentStatus;
          sale.updatedAt = DateTime.now();
          sale.syncStatus = SyncStatus.pending;
          await _dbService.sales.put(sale);
        }

        final paymentEntity = PaymentEntity()
          ..id = paymentId
          ..customerId = customerId
          ..customerName = customerName
          ..saleId = resolvedSaleId
          ..amount = amount
          ..mode = mode.toString().split('.').last
          ..date = date
          ..reference = reference
          ..notes = notes
          ..collectorId = collectorId
          ..collectorName = collectorName
          ..createdAt = now
          ..updatedAt = DateTime.now()
          ..syncStatus = SyncStatus.pending;
        await _dbService.payments.put(paymentEntity);
      });

      final paymentData = {
        'id': paymentId,
        'customerId': customerId,
        'customerName': customerName,
        'saleId': resolvedSaleId,
        'amount': amount,
        'mode': mode.toString().split('.').last,
        'date': date,
        'reference': reference,
        'notes': notes,
        'collectorId': collectorId,
        'collectorName': collectorName,
        'createdAt': now,
        'isSynced': false,
      };

      final synced = await _queueAndSyncPayment(paymentData);

      if (synced) {
        await _dbService.db.writeTxn(() async {
          final existing = await _dbService.payments.get(fastHash(paymentId));
          if (existing != null) {
            existing.syncStatus = SyncStatus.synced;
            existing.updatedAt = DateTime.now();
            await _dbService.payments.put(existing);
          }
        });
      }

      return paymentId;
    } catch (e) {
      throw handleError(e, 'addManualPayment');
    }
  }

  Future<List<ManualPayment>> getPayments({
    String? customerId,
    int limit = 50,
  }) async {
    try {
      await _migrateLegacyPaymentsIfNeeded();

      // 1. Local (Isar)
      List<PaymentEntity> entities;
      if (customerId != null) {
        entities = await _dbService.payments
            .filter()
            .customerIdEqualTo(customerId)
            .findAll();
      } else {
        entities = await _dbService.payments.where().findAll();
      }

      // 2. Bootstrap
      if (entities.isEmpty) {
        final firestore = db;
        if (firestore != null) {
          try {
            Query query = firestore
                .collection(paymentsCollection)
                .orderBy('date', descending: true);
            if (customerId != null) {
              query = query.where('customerId', isEqualTo: customerId);
            }
            query = query.limit(limit);

            final snapshot = await query.get();
            final fetched = snapshot.docs.map((d) {
              final data = d.data() as Map<String, dynamic>? ?? {};
              data['id'] = d.id;
              return data;
            }).toList();

            if (fetched.isNotEmpty) {
              await _dbService.db.writeTxn(() async {
                for (final item in fetched) {
                  final entity = _buildPaymentEntityFromMap(
                    item,
                    syncStatus: SyncStatus.synced,
                  );
                  await _dbService.payments.put(entity);
                }
              });
              entities = await _dbService.payments.where().findAll();
            }
          } catch (e) {
            debugPrint('Error syncing legacy payments from firestore: $e');
          }
        }
      }

      var payments = entities.map(_paymentFromEntity).toList();

      if (customerId != null) {
        payments = payments.where((p) => p.customerId == customerId).toList();
      }

      payments.sort((a, b) => b.date.compareTo(a.date));
      if (payments.length > limit) payments = payments.take(limit).toList();

      return payments;
    } catch (e) {
      throw handleError(e, 'getPayments');
    }
  }

  Future<PaymentLink?> createPaymentLink(
    CreatePaymentLinkPayload payload,
  ) async {
    try {
      await _capabilityGuard.requireCapability(
        RoleCapability.paymentLinksCreate,
        operation: 'create payment link',
      );
      final expiresAt =
          payload.expiresAt ?? DateTime.now().add(const Duration(days: 7));
      final data = {
        'saleId': payload.saleId,
        'customerId': payload.customerId,
        'amount': payload.amount,
        'currency': 'INR',
        'description': payload.description,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

      final firestore = db;
      if (firestore == null) return null;

      final docRef = await firestore
          .collection(paymentLinksCollection)
          .add(data);
      return PaymentLink.fromJson({'id': docRef.id, ...data});
    } catch (e) {
      throw handleError(e, 'createPaymentLink');
    }
  }

  Future<PaymentLink?> getPaymentLink(String id) async {
    try {
      final firestore = db;
      if (firestore == null) return null;

      final docSnap = await firestore
          .collection(paymentLinksCollection)
          .doc(id)
          .get();
      if (docSnap.exists) {
        return PaymentLink.fromJson({
          'id': docSnap.id,
          ...(docSnap.data() ?? {}),
        });
      }
      return null;
    } catch (e) {
      throw handleError(e, 'getPaymentLink');
    }
  }

  Future<List<PaymentLink>> getPaymentLinksBySaleId(String saleId) async {
    try {
      final firestore = db;
      if (firestore == null) return [];

      final snapshot = await firestore
          .collection(paymentLinksCollection)
          .where('saleId', isEqualTo: saleId)
          .get();
      return snapshot.docs
          .map((doc) => PaymentLink.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw handleError(e, 'getPaymentLinksBySaleId');
    }
  }

  Future<bool> updatePaymentStatus(
    String linkId,
    String status, {
    String? paymentId,
  }) async {
    try {
      await _capabilityGuard.requireCapability(
        RoleCapability.paymentLinksUpdate,
        operation: 'update payment link status',
      );
      final firestore = db;
      if (firestore == null) return false;

      final docRef = firestore.collection(paymentLinksCollection).doc(linkId);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return false;
      final currentStatus = docSnap.get('status');
      if (currentStatus == status) return true;
      if (currentStatus == 'paid' && status != 'paid') return false;
      final updates = <String, dynamic>{'status': status};
      if (status == 'paid') {
        updates['paidAt'] = DateTime.now().toIso8601String();
      }
      if (paymentId != null) updates['paymentId'] = paymentId;
      await docRef.update(updates);
      return true;
    } catch (e) {
      throw handleError(e, 'updatePaymentStatus');
    }
  }

  Future<List<PaymentLink>> getPendingPaymentLinks() async {
    try {
      final firestore = db;
      if (firestore == null) return [];

      final snapshot = await firestore
          .collection(paymentLinksCollection)
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs
          .map((doc) => PaymentLink.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw handleError(e, 'getPendingPaymentLinks');
    }
  }

  String generatePaymentLinkUrl(String linkId) =>
      "https://dattsoap.com/pay/$linkId";
}
