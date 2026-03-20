import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar/isar.dart';

import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/sale_entity.dart';
import 'package:flutter_app/data/local/entities/return_entity.dart';
import 'package:flutter_app/data/local/entities/payment_entity.dart';
import 'package:flutter_app/data/local/entities/route_session_entity.dart';
import 'package:flutter_app/data/local/entities/customer_visit_entity.dart';
import 'package:flutter_app/data/local/entities/sales_target_entity.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/services/visit_service.dart';
import 'package:flutter_app/utils/app_logger.dart';
import 'package:flutter_app/services/outbox_codec.dart';
import 'package:flutter_app/services/database_service.dart';

class SalesSyncDelegate {
  final DatabaseService _dbService;

  // We need access to these for metrics and issue tracking
  final Future<void> Function({
    required String entityType,
    required SyncOperation operation,
    required int recordCount,
    required int durationMs,
    required bool success,
    String? errorMessage,
  })
  recordMetric;

  final void Function(String context, Object error) markSyncIssue;

  final Future<DateTime?> Function(String entityType) getLastSyncTimestamp;
  final Future<void> Function(String entityType, DateTime timestamp)
  setLastSyncTimestamp;

  final Future<void> Function({
    required String collection,
    required Map<String, dynamic> payload,
    String? explicitRecordKey,
  })
  deleteQueueItem;

  final Future<void> Function({
    required BaseEntity? localEntity,
    required Map<String, dynamic> serverData,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> Function(BaseEntity) localToJson,
  })
  detectAndFlagConflict;

  final DateTime Function(dynamic value, {DateTime? fallback}) parseRemoteDate;
  final List<List<T>> Function<T>(List<T> list, int chunkSize) chunkList;

  SalesSyncDelegate({
    required DatabaseService dbService,
    required this.deleteQueueItem,
    required this.recordMetric,
    required this.markSyncIssue,
    required this.getLastSyncTimestamp,
    required this.setLastSyncTimestamp,
    required this.detectAndFlagConflict,
    required this.parseRemoteDate,
    required this.chunkList,
  }) : _dbService = dbService;

  int fastHash(String string) {
    var hash = 0xcbf29ce484222325;
    var i = 0;
    while (i < string.length) {
      final codeUnit = string.codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xFF;
      hash *= 0x100000001b3;
    }
    return hash;
  }

  bool _isRecoverableDeltaQueryError(Object error) {
    final normalized = error.toString().toLowerCase();
    return normalized.contains('failed-precondition') ||
        normalized.contains('requires an index');
  }

  bool _canPushSalesTargets(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.owner ||
        role == UserRole.salesManager ||
        role == UserRole.productionManager ||
        role == UserRole.dealerManager ||
        role == UserRole.dispatchManager;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  List<SaleItemEntity>? _parseRemoteSaleItems(
    dynamic rawItems, {
    required String docId,
  }) {
    if (rawItems is! List) {
      AppLogger.warning(
        'Skipping malformed sale doc $docId (items is not a list)',
        tag: 'Sync',
      );
      return null;
    }

    final items = <SaleItemEntity>[];
    for (final raw in rawItems) {
      if (raw is! Map) {
        AppLogger.warning(
          'Skipping malformed sale doc $docId (item entry is not a map)',
          tag: 'Sync',
        );
        return null;
      }
      final item = Map<String, dynamic>.from(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      );
      final productId = item['productId']?.toString().trim() ?? '';
      if (productId.isEmpty) {
        AppLogger.warning(
          'Skipping malformed sale doc $docId (item missing productId)',
          tag: 'Sync',
        );
        return null;
      }
      items.add(
        SaleItemEntity()
          ..productId = productId
          ..name = item['name']?.toString()
          ..quantity = _toInt(item['quantity'])
          ..price = _toDouble(item['price'])
          ..isFree = item['isFree'] == true
          ..discount = _toDouble(item['discount'])
          ..secondaryPrice = _toDouble(item['secondaryPrice'])
          ..conversionFactor = _toDouble(item['conversionFactor'])
          ..baseUnit = item['baseUnit']?.toString()
          ..secondaryUnit = item['secondaryUnit']?.toString()
          ..schemeName = item['schemeName']?.toString(),
      );
    }
    return items;
  }

  List<String>? _parseRemoteSaleProductIds(
    dynamic rawProductIds, {
    required List<SaleItemEntity> fallbackItems,
    required String docId,
  }) {
    if (rawProductIds != null && rawProductIds is! List) {
      AppLogger.warning(
        'Skipping malformed sale doc $docId (itemProductIds is not a list)',
        tag: 'Sync',
      );
      return null;
    }

    final parsed = <String>[];
    if (rawProductIds is List) {
      for (final value in rawProductIds) {
        final productId = value.toString().trim();
        if (productId.isNotEmpty) parsed.add(productId);
      }
    }
    if (parsed.isNotEmpty) return parsed;
    return fallbackItems
        .map((item) => item.productId?.trim() ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
  }

  SaleEntity? _mapRemoteSaleEntity({
    required String docId,
    required Map<String, dynamic> data,
    required DateTime updatedAt,
  }) {
    final parsedItems = _parseRemoteSaleItems(data['items'], docId: docId);
    if (parsedItems == null) return null;
    final parsedItemProductIds = _parseRemoteSaleProductIds(
      data['itemProductIds'],
      fallbackItems: parsedItems,
      docId: docId,
    );
    if (parsedItemProductIds == null) return null;

    return SaleEntity()
      ..id = docId
      ..updatedAt = updatedAt
      ..humanReadableId = data['humanReadableId']?.toString()
      ..recipientType = data['recipientType']?.toString() ?? 'customer'
      ..recipientId = data['recipientId']?.toString() ?? ''
      ..recipientName = data['recipientName']?.toString() ?? ''
      ..items = parsedItems
      ..itemProductIds = parsedItemProductIds
      ..subtotal = _toDouble(data['subtotal'])
      ..discountPercentage = _toDouble(data['discountPercentage'])
      ..discountAmount = _toDouble(data['discountAmount'])
      ..additionalDiscountPercentage = _toDouble(
        data['additionalDiscountPercentage'],
      )
      ..additionalDiscountAmount = _toDouble(data['additionalDiscountAmount'])
      ..taxableAmount = _toDouble(data['taxableAmount'])
      ..gstType = data['gstType']?.toString()
      ..gstPercentage = _toDouble(data['gstPercentage'])
      ..cgstAmount = _toDouble(data['cgstAmount'])
      ..sgstAmount = _toDouble(data['sgstAmount'])
      ..igstAmount = _toDouble(data['igstAmount'])
      ..totalAmount = _toDouble(data['totalAmount'])
      ..roundOff = _toDouble(data['roundOff'])
      ..tripId = data['tripId']?.toString()
      ..saleType = data['saleType']?.toString()
      ..createdByRole = data['createdByRole']?.toString()
      ..status = data['status']?.toString()
      ..dispatchRequired = data['dispatchRequired'] == true
      ..vehicleNumber = data['vehicleNumber']?.toString()
      ..route = data['route']?.toString()
      ..salesmanId = data['salesmanId']?.toString() ?? ''
      ..salesmanName = data['salesmanName']?.toString() ?? ''
      ..createdAt = data['createdAt']?.toString() ?? updatedAt.toIso8601String()
      ..paidAmount = _toDouble(data['paidAmount'])
      ..paymentStatus = data['paymentStatus']?.toString()
      ..month = _toInt(data['month'])
      ..year = _toInt(data['year'])
      ..syncStatus = SyncStatus.synced
      ..updatedAt = updatedAt;
  }

  Future<void> syncSalesData(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
  }) async {
    // 1. Sales
    await syncSales(db, user, forceRefresh: forceRefresh);

    // 2. Returns
    await syncReturns(db, user, forceRefresh: forceRefresh);

    // 3. Payments
    await syncPayments(db, user, forceRefresh: forceRefresh);

    // 4. Route Sessions
    await syncRouteSessions(db, user, forceRefresh: forceRefresh);

    // 5. Customer Visits
    await syncCustomerVisits(db, user, forceRefresh: forceRefresh);

    // 6. Sales Targets
    await syncSalesTargets(db, user, forceRefresh: forceRefresh);
  }

  Future<void> syncSales(
    firestore.FirebaseFirestore db,
    AppUser user, {
    String? firebaseUid,
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      // 1. PUSH (queue-owned, transactional-only)
      // SAFETY: Sales mutations must go through SalesService.performSync(add/edit)
      // via sync_queue processing. Direct upsert here bypasses stock/balance txns.
      final pendingSales = await _dbService.sales
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      if (pendingSales.isNotEmpty) {
        AppLogger.warning(
          'Found ${pendingSales.length} pending sales; skipping direct push. '
          'Transactional sync queue is authoritative for sales mutations.',
          tag: 'Sync',
        );
      }
      pushedCount = 0;
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing sales', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await recordMetric(
        entityType: 'sales',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    // 2. PULL with Role-Based Isolation & Delta
    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await getLastSyncTimestamp('sales');
      firestore.Query baseQuery = db.collection(CollectionRegistry.sales);

      if (user.role == UserRole.salesman) {
        final scopedFirebaseUid = firebaseUid?.trim();
        if (scopedFirebaseUid == null || scopedFirebaseUid.isEmpty) {
          throw StateError('Firebase UID must be provided for salesman sync.');
        }
        baseQuery = baseQuery.where('salesmanId', isEqualTo: scopedFirebaseUid);
      } else if (user.role == UserRole.dealerManager) {
        baseQuery = baseQuery.where('recipientType', isEqualTo: 'dealer');
      }

      firestore.Query query = baseQuery;
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      bool applyClientSideDeltaFilter = false;
      firestore.QuerySnapshot snapshot;
      try {
        snapshot = await query.get();
      } catch (e) {
        // [LOCKED] If a composite index is missing remotely, keep sync alive:
        // pull scoped data and apply delta on-device.
        if (lastSync != null && _isRecoverableDeltaQueryError(e)) {
          AppLogger.warning(
            'Sales delta query fallback to scoped full pull: $e',
            tag: 'Sync',
          );
          snapshot = await baseQuery.get();
          applyClientSideDeltaFilter = true;
        } else {
          rethrow;
        }
      }
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);

        final saleIds = snapshot.docs.map((d) => fastHash(d.id)).toList();
        final existingSales = await _dbService.sales.getAll(saleIds);
        final existingSalesMap = {
          for (int i = 0; i < snapshot.docs.length; i++)
            if (existingSales[i] != null)
              snapshot.docs[i].id: existingSales[i]!,
        };

        final salesToPut = <SaleEntity>[];

        for (final doc in snapshot.docs) {
          final rawData = doc.data();
          if (rawData is! Map) {
            AppLogger.warning(
              'Skipping malformed sale doc ${doc.id} (payload is not a map)',
              tag: 'Sync',
            );
            continue;
          }
          final data = Map<String, dynamic>.from(
            rawData.map((key, value) => MapEntry(key.toString(), value)),
          );

          DateTime updatedAt;
          try {
            updatedAt = parseRemoteDate(data['updatedAt'] ?? data['createdAt']);
          } catch (e) {
            AppLogger.warning(
              'Skipping malformed sale doc ${doc.id} (invalid updatedAt): $e',
              tag: 'Sync',
            );
            continue;
          }
          if (applyClientSideDeltaFilter &&
              lastSync != null &&
              !updatedAt.isAfter(lastSync)) {
            continue;
          }
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          // Conflict Detection
          final existing = existingSalesMap[doc.id];
          if (existing != null) {
            await detectAndFlagConflict(
              entityId: doc.id,
              entityType: 'sales',
              serverData: data,
              localEntity: existing,
              localToJson: (e) => (e as SaleEntity).toDomain().toJson(),
            );
            continue;
          }

          final sale = _mapRemoteSaleEntity(
            docId: doc.id,
            data: data,
            updatedAt: updatedAt,
          );
          if (sale == null) {
            continue;
          }
          salesToPut.add(sale);
        }

        if (salesToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.sales.putAll(salesToPut);
          });
        }
        await setLastSyncTimestamp('sales', maxUpdatedAt);
        pulledCount = salesToPut.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling sales', error: e, tag: 'Sync');
      markSyncIssue('sales pull', e);
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await recordMetric(
        entityType: 'sales',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncReturns(
    firestore.FirebaseFirestore db,
    AppUser user, {
    String? firebaseUid,
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      // 1. PUSH
      final pendingReturns = await _dbService.returns
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pendingReturns.isNotEmpty) {
        final chunks = chunkList(pendingReturns, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final req in chunk) {
            final domainReq = req.toDomain();
            final data = domainReq.toJson();
            final docRef = db
                .collection(CollectionRegistry.returns)
                .doc(req.id);
            batch.set(docRef, data, firestore.SetOptions(merge: true));
          }
          await batch.commit();
          await _dbService.db.writeTxn(() async {
            final updatedReturns = <ReturnEntity>[];
            for (final req in chunk) {
              req.syncStatus = SyncStatus.synced;
              updatedReturns.add(req);
            }
            if (updatedReturns.isNotEmpty) {
              await _dbService.returns.putAll(updatedReturns);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing returns', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await recordMetric(
        entityType: 'returns',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    // 2. PULL with Role Isolation & Delta
    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await getLastSyncTimestamp('returns');
      firestore.Query query = db.collection(CollectionRegistry.returns);

      if (user.role == UserRole.salesman) {
        final scopedFirebaseUid = firebaseUid?.trim();
        if (scopedFirebaseUid == null || scopedFirebaseUid.isEmpty) {
          throw StateError(
            'Firebase UID must be provided for salesman returns sync.',
          );
        }
        query = query.where('salesmanId', isEqualTo: scopedFirebaseUid);
      } else if (user.role == UserRole.dealerManager) {
        query = query.where('returnType', isEqualTo: 'dealer_return');
      }

      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);

        final returnIds = snapshot.docs.map((d) => fastHash(d.id)).toList();
        final existingReturns = await _dbService.returns.getAll(returnIds);
        final existingReturnsMap = {
          for (int i = 0; i < snapshot.docs.length; i++)
            if (existingReturns[i] != null)
              snapshot.docs[i].id: existingReturns[i]!,
        };

        final returnsToPut = <ReturnEntity>[];

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          // Conflict Detection
          final existing = existingReturnsMap[doc.id];
          if (existing != null) {
            await detectAndFlagConflict(
              entityId: doc.id,
              entityType: 'returns',
              serverData: data,
              localEntity: existing,
              localToJson: (e) => (e as ReturnEntity).toDomain().toJson(),
            );
            continue;
          }

          final entity = ReturnEntity()..id = doc.id;
          entity.returnType = data['returnType'] ?? 'stock_return';
          entity.salesmanId = data['salesmanId'] ?? '';
          entity.salesmanName = data['salesmanName'] ?? '';
          entity.items =
              (data['items'] as List?)
                  ?.map(
                    (e) => ReturnItemEntity()
                      ..productId = e['productId']
                      ..name = e['name']
                      ..quantity = (e['quantity'] as num?)?.toDouble() ?? 0.0
                      ..unit = e['unit'] ?? ''
                      ..price = (e['price'] as num?)?.toDouble(),
                  )
                  .toList() ??
              [];
          entity.reason = data['reason'] ?? '';
          entity.reasonCode = data['reasonCode'];
          entity.status = data['status'] ?? 'pending';
          entity.disposition = data['disposition'];
          entity.createdAt = parseRemoteDate(data['createdAt']);
          entity.approvedBy = data['approvedBy'];
          entity.syncStatus = SyncStatus.synced;
          entity.updatedAt = updatedAt;

          returnsToPut.add(entity);
        }

        if (returnsToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.returns.putAll(returnsToPut);
          });
        }
        await setLastSyncTimestamp('returns', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling returns', error: e, tag: 'Sync');
      markSyncIssue('returns pull', e);
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await recordMetric(
        entityType: 'returns',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncPayments(
    firestore.FirebaseFirestore db,
    AppUser currentUser, {
    String? firebaseUid,
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      // 1. PUSH
      final pending = await _dbService.payments
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pending.isNotEmpty) {
        final chunks = chunkList(pending, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final entry in chunk) {
            final payload = {
              'id': entry.id,
              'customerId': entry.customerId,
              'customerName': entry.customerName,
              'saleId': entry.saleId,
              'amount': entry.amount,
              'mode': entry.mode,
              'date': entry.date,
              'reference': entry.reference,
              'notes': entry.notes,
              'collectorId': entry.collectorId,
              'collectorName': entry.collectorName,
              'createdAt': entry.createdAt,
              'updatedAt': entry.updatedAt.toIso8601String(),
              'syncStatus': 'synced',
            };
            batch.set(
              db.collection(CollectionRegistry.payments).doc(entry.id),
              payload,
              firestore.SetOptions(merge: true),
            );
          }
          await batch.commit();

          await _dbService.db.writeTxn(() async {
            final updatedPayments = <PaymentEntity>[];
            for (final entry in chunk) {
              entry.syncStatus = SyncStatus.synced;
              updatedPayments.add(entry);
            }
            if (updatedPayments.isNotEmpty) {
              await _dbService.payments.putAll(updatedPayments);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing payments', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await recordMetric(
        entityType: 'payments',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    // 2. PULL
    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await getLastSyncTimestamp('payments');
      firestore.Query query = db.collection(CollectionRegistry.payments);

      if (!currentUser.isAdmin) {
        final scopedFirebaseUid = firebaseUid?.trim();
        if (scopedFirebaseUid == null || scopedFirebaseUid.isEmpty) {
          throw StateError(
            'Firebase UID must be provided for salesman payments sync.',
          );
        }
        query = query.where('recordedBy', isEqualTo: scopedFirebaseUid);
      }

      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final paymentsToPut = <PaymentEntity>[];

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;

          final updateStr = data['updatedAt'] ?? data['paymentDate'];
          final updatedAt =
              DateTime.tryParse(updateStr.toString()) ?? DateTime.now();
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          try {
            final entity = PaymentEntity()
              ..id = doc.id
              ..customerId = data['customerId']?.toString() ?? ''
              ..customerName = data['customerName']?.toString()
              ..saleId = data['saleId']?.toString()
              ..amount = (data['amount'] as num?)?.toDouble() ?? 0.0
              ..mode = data['mode']?.toString() ?? 'cash'
              ..date =
                  data['date']?.toString() ?? DateTime.now().toIso8601String()
              ..reference = data['reference']?.toString()
              ..notes = data['notes']?.toString()
              ..collectorId = data['collectorId']?.toString() ?? ''
              ..collectorName = data['collectorName']?.toString()
              ..createdAt =
                  data['createdAt']?.toString() ??
                  DateTime.now().toIso8601String()
              ..updatedAt = updatedAt
              ..syncStatus = SyncStatus.synced;
            paymentsToPut.add(entity);
          } catch (e) {
            AppLogger.error(
              'Error parsing payment ${doc.id}',
              error: e,
              tag: 'Sync',
            );
          }
        }

        if (paymentsToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.payments.putAll(paymentsToPut);
          });
        }
        await setLastSyncTimestamp('payments', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Payments sync pull failed', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await recordMetric(
        entityType: 'payments',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncRouteSessions(
    firestore.FirebaseFirestore db,
    AppUser currentUser, {
    String? firebaseUid,
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    const sessionsCollection = 'route_sessions';

    try {
      // 1. PUSH
      final pending = await _dbService.routeSessions
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pending.isNotEmpty) {
        final chunks = chunkList(pending, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final session in chunk) {
            batch.set(
              db.collection(sessionsCollection).doc(session.id),
              session.toDomain().toJson(),
              firestore.SetOptions(merge: true),
            );
          }
          await batch.commit();

          await _dbService.db.writeTxn(() async {
            final updatedSessions = <RouteSessionEntity>[];
            for (final session in chunk) {
              session.syncStatus = SyncStatus.synced;
              updatedSessions.add(session);
            }
            if (updatedSessions.isNotEmpty) {
              await _dbService.routeSessions.putAll(updatedSessions);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing route sessions', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await recordMetric(
        entityType: sessionsCollection,
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    // 2. PULL
    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await getLastSyncTimestamp(sessionsCollection);
      firestore.Query query = db.collection(sessionsCollection);

      if (!currentUser.isAdmin) {
        final scopedFirebaseUid = firebaseUid?.trim();
        if (scopedFirebaseUid == null || scopedFirebaseUid.isEmpty) {
          throw StateError(
            'Firebase UID must be provided for route sessions sync.',
          );
        }
        query = query.where('salesmanId', isEqualTo: scopedFirebaseUid);
      }

      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final sessionsToPut = <RouteSessionEntity>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          final updatedAt = parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          try {
            final domainModel = RouteSession.fromJson(data);
            final entity = RouteSessionEntity.fromDomain(domainModel);
            entity.syncStatus = SyncStatus.synced;
            sessionsToPut.add(entity);
          } catch (e) {
            AppLogger.error(
              'Error parsing route session ${doc.id}',
              error: e,
              tag: 'Sync',
            );
          }
        }

        if (sessionsToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.routeSessions.putAll(sessionsToPut);
          });
        }
        await setLastSyncTimestamp(sessionsCollection, maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Route session sync pull failed', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await recordMetric(
        entityType: sessionsCollection,
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncCustomerVisits(
    firestore.FirebaseFirestore db,
    AppUser currentUser, {
    String? firebaseUid,
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    const visitsCollection = 'customer_visits';

    try {
      // 1. PUSH
      final pending = await _dbService.customerVisits
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pending.isNotEmpty) {
        final chunks = chunkList(pending, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final visit in chunk) {
            batch.set(
              db.collection(visitsCollection).doc(visit.id),
              visit.toDomain().toJson(),
              firestore.SetOptions(merge: true),
            );
          }
          await batch.commit();

          await _dbService.db.writeTxn(() async {
            final updatedVisits = <CustomerVisitEntity>[];
            for (final visit in chunk) {
              visit.syncStatus = SyncStatus.synced;
              updatedVisits.add(visit);
            }
            if (updatedVisits.isNotEmpty) {
              await _dbService.customerVisits.putAll(updatedVisits);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing customer visits', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await recordMetric(
        entityType: visitsCollection,
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    // 2. PULL
    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await getLastSyncTimestamp(visitsCollection);
      firestore.Query query = db.collection(visitsCollection);

      if (!currentUser.isAdmin) {
        final scopedFirebaseUid = firebaseUid?.trim();
        if (scopedFirebaseUid == null || scopedFirebaseUid.isEmpty) {
          throw StateError(
            'Firebase UID must be provided for customer visits sync.',
          );
        }
        query = query.where('salesmanId', isEqualTo: scopedFirebaseUid);
      }

      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final visitsToPut = <CustomerVisitEntity>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          final updatedAt = parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          try {
            final domainModel = CustomerVisit.fromJson(data);
            final entity = CustomerVisitEntity.fromDomain(domainModel);
            entity.syncStatus = SyncStatus.synced;
            visitsToPut.add(entity);
          } catch (e) {
            AppLogger.error(
              'Error parsing customer visit ${doc.id}',
              error: e,
              tag: 'Sync',
            );
          }
        }

        if (visitsToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.customerVisits.putAll(visitsToPut);
          });
        }
        await setLastSyncTimestamp(visitsCollection, maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Customer visit sync pull failed', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await recordMetric(
        entityType: visitsCollection,
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncSalesTargets(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
  }) async {
    final pushStopwatch = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;
    try {
      // [LOCKED] Firestore rules allow sales target writes only for admin/manager roles.
      final canPush = _canPushSalesTargets(user.role);
      final pending = await _dbService.salesTargets
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      if (!canPush) {
        if (pending.isNotEmpty) {
          final queueIds = pending
              .map(
                (target) => OutboxCodec.buildQueueId('sales_targets', {
                  'id': target.id,
                }, explicitRecordKey: target.id),
              )
              .toList(growable: false);
          final queuedRecords = await _dbService.syncQueue.getAll(
            queueIds.map(fastHash).toList(growable: false),
          );
          final queueIsarIds = <int>[];
          for (final queued in queuedRecords) {
            if (queued != null) {
              queueIsarIds.add(queued.isarId);
            }
          }
          await _dbService.db.writeTxn(() async {
            for (final target in pending) {
              target.syncStatus = SyncStatus.synced;
              target.updatedAt = DateTime.now();
            }
            await _dbService.salesTargets.putAll(pending);
            if (queueIsarIds.isNotEmpty) {
              await _dbService.syncQueue.deleteAll(queueIsarIds);
            }
          });
          AppLogger.warning(
            'Skipped unauthorized sales target push for role ${user.role.value}; local pending targets reset.',
            tag: 'Sync',
          );
        }
        pushSuccess = true;
      } else {
        final queueIds = pending
            .map(
              (target) => OutboxCodec.buildQueueId('sales_targets', {
                'id': target.id,
              }, explicitRecordKey: target.id),
            )
            .toList(growable: false);
        final queuedRecords = await _dbService.syncQueue.getAll(
          queueIds.map(fastHash).toList(growable: false),
        );
        final queuedIsarIdByTargetId = <String, int>{};
        for (var i = 0; i < queueIds.length; i++) {
          final queued = queuedRecords[i];
          if (queued != null) {
            queuedIsarIdByTargetId[pending[i].id] = queued.isarId;
          }
        }
        final targetsToUpdate = <SalesTargetEntity>[];
        final queueIdsToDelete = <int>[];
        for (final target in pending) {
          try {
            final payload = target.toFirebaseJson();
            payload['isDeleted'] = target.isDeleted;
            if (target.routeTargetsJson != null &&
                target.routeTargetsJson!.isNotEmpty) {
              try {
                payload['routeTargets'] =
                    jsonDecode(target.routeTargetsJson!)
                        as Map<String, dynamic>;
              } catch (e) {
                AppLogger.warning(
                  'Error parsing routeTargetsJson for target ${target.id}: $e',
                  tag: 'Sync',
                );
              }
            }
            await db
                .collection(CollectionRegistry.salesTargets)
                .doc(target.id)
                .set(payload, firestore.SetOptions(merge: true));

            if (target.syncStatus != SyncStatus.conflict) {
              target.syncStatus = SyncStatus.synced;
              target.updatedAt = DateTime.now();
              targetsToUpdate.add(target);
            }
            final queuedIsarId = queuedIsarIdByTargetId[target.id];
            if (queuedIsarId != null) {
              queueIdsToDelete.add(queuedIsarId);
            }
            pushedCount++;
          } catch (e) {
            markSyncIssue('sales_targets push', e);
            pushError = e.toString();
          }
        }
        if (targetsToUpdate.isNotEmpty || queueIdsToDelete.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            if (targetsToUpdate.isNotEmpty) {
              await _dbService.salesTargets.putAll(targetsToUpdate);
            }
            if (queueIdsToDelete.isNotEmpty) {
              await _dbService.syncQueue.deleteAll(queueIdsToDelete);
            }
          });
        }
        pushSuccess = true;
      }
    } catch (e) {
      pushError = e.toString();
      markSyncIssue('sales_targets push', e);
    } finally {
      pushStopwatch.stop();
      await recordMetric(
        entityType: 'sales_targets',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: pushStopwatch.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final pullStopwatch = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;
    try {
      final lastSync = forceRefresh
          ? null
          : await getLastSyncTimestamp('sales_targets');
      firestore.Query baseQuery = db.collection(
        CollectionRegistry.salesTargets,
      );

      if (user.role == UserRole.salesman) {
        final scopedFirebaseUid = FirebaseAuth.instance.currentUser?.uid.trim();
        if (scopedFirebaseUid == null || scopedFirebaseUid.isEmpty) {
          throw StateError(
            'Firebase UID must be provided for salesman sales target sync.',
          );
        }
        baseQuery = baseQuery.where('salesmanId', isEqualTo: scopedFirebaseUid);
      }

      firestore.Query query = baseQuery;
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      bool applyClientSideDeltaFilter = false;
      firestore.QuerySnapshot snapshot;
      try {
        snapshot = await query.get();
      } catch (e) {
        // [LOCKED] If a composite index is missing remotely, keep sync alive:
        // pull scoped data and apply delta on-device.
        if (lastSync != null && _isRecoverableDeltaQueryError(e)) {
          AppLogger.warning(
            'Sales targets delta query fallback to scoped full pull: $e',
            tag: 'Sync',
          );
          snapshot = await baseQuery.get();
          applyClientSideDeltaFilter = true;
        } else {
          rethrow;
        }
      }
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);

        final targetIds = snapshot.docs.map((doc) => doc.id).toList();
        final existingTargetsList = await _dbService.salesTargets
            .filter()
            .anyOf(targetIds, (q, String id) => q.idEqualTo(id))
            .findAll();
        final existingTargetsMap = {
          for (final t in existingTargetsList) t.id: t,
        };

        final targetsToPut = <SalesTargetEntity>[];

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final id = doc.id;
          final updatedAt = parseRemoteDate(
            data['updatedAt'] ?? data['createdAt'],
          );
          if (applyClientSideDeltaFilter &&
              lastSync != null &&
              !updatedAt.isAfter(lastSync)) {
            continue;
          }
          if (updatedAt.isAfter(maxUpdatedAt)) {
            maxUpdatedAt = updatedAt;
          }

          final existing = existingTargetsMap[id];
          if (existing != null) {
            await detectAndFlagConflict(
              localEntity: existing,
              serverData: data,
              entityType: 'sales_targets',
              entityId: id,
              localToJson: (e) {
                final target = e as SalesTargetEntity;
                return <String, dynamic>{
                  'id': target.id,
                  'salesmanId': target.salesmanId,
                  'salesmanName': target.salesmanName,
                  'month': target.month,
                  'year': target.year,
                  'targetAmount': target.targetAmount,
                  'achievedAmount': target.achievedAmount,
                  'updatedAt': target.updatedAt.toIso8601String(),
                  'isDeleted': target.isDeleted,
                  'routeTargetsJson': target.routeTargetsJson,
                };
              },
            );
            continue;
          }

          final target = SalesTargetEntity.fromFirebaseJson({
            ...data,
            'id': id,
          });
          target.isDeleted = data['isDeleted'] == true;
          if (data['routeTargets'] is Map) {
            target.routeTargetsJson = jsonEncode(data['routeTargets']);
          }
          targetsToPut.add(target);
        }

        if (targetsToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.salesTargets.putAll(targetsToPut);
          });
        }
        await setLastSyncTimestamp('sales_targets', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error syncing sales targets', error: e, tag: 'Sync');
      markSyncIssue('sales_targets pull', e);
      pullError = e.toString();
    } finally {
      pullStopwatch.stop();
      await recordMetric(
        entityType: 'sales_targets',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: pullStopwatch.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }
}
