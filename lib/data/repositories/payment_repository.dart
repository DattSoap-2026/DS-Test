import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/payment_entity.dart';
import '../../services/database_service.dart';

class PaymentRepository {
  static const Uuid _uuid = Uuid();

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  PaymentRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  /// Saves a payment locally first, then enqueues sync.
  Future<void> savePayment(PaymentEntity payment) async {
    final now = DateTime.now();
    final id = _ensureId(payment);
    final existing = await _dbService.payments.getById(id);

    payment
      ..id = id
      ..createdAt = payment.createdAt ?? existing?.createdAt ?? now.toIso8601String()
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..deletedAt = null
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.payments.put(payment);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.payments,
      documentId: payment.id,
      operation: existing == null ? 'create' : 'update',
      payload: payment.toJson(),
    );

    await _syncIfOnline();
  }

  /// Returns payments for a sale from Isar only.
  Future<List<PaymentEntity>> getPaymentsBySale(String saleId) async {
    return _dbService.payments
        .filter()
        .saleIdEqualTo(saleId)
        .and()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  /// Returns payments for a customer from Isar only.
  Future<List<PaymentEntity>> getPaymentsByCustomer(String customerId) async {
    return _dbService.payments
        .filter()
        .customerIdEqualTo(customerId)
        .and()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  /// Returns all non-deleted payments from Isar.
  Future<List<PaymentEntity>> getAllPayments() async {
    return _dbService.payments
        .filter()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  /// Returns payments in a date range from Isar only.
  Future<List<PaymentEntity>> getPaymentsByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    return _dbService.payments
        .filter()
        .dateBetween(from.toIso8601String(), to.toIso8601String())
        .and()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  /// Streams all non-deleted payments from Isar.
  Stream<List<PaymentEntity>> watchAllPayments() {
    return _dbService.payments
        .filter()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .watch(fireImmediately: true);
  }

  /// Soft-deletes a payment and enqueues the delete operation.
  Future<void> deletePayment(String id) async {
    final payment = await _dbService.payments.getById(id);
    if (payment == null || payment.isDeleted) {
      return;
    }

    final now = DateTime.now();
    payment
      ..isDeleted = true
      ..deletedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.payments.put(payment);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.payments,
      documentId: payment.id,
      operation: 'delete',
      payload: payment.toJson(),
    );

    await _syncIfOnline();
  }

  String _ensureId(PaymentEntity payment) {
    try {
      final normalized = payment.id.trim();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    } catch (_) {
      // Late initialization fallback.
    }
    final generated = _uuid.v4();
    payment.id = generated;
    return generated;
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
