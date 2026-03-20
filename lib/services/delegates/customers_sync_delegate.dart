import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:isar/isar.dart';

import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/customer_entity.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/sync_common_utils.dart';
import 'package:flutter_app/utils/app_logger.dart';

typedef ResolveSalesmanRouteScope = Future<List<String>> Function(
  firestore.FirebaseFirestore db,
  AppUser user,
);

typedef BuildCustomerSyncPayload =
    Map<String, dynamic> Function(CustomerEntity customer);

typedef DeletePartnerOutboxItem = Future<void> Function(
  String collection,
  String recordId,
);

typedef UpsertPartnerOutboxItem = Future<void> Function({
  required String collection,
  required String action,
  required String recordId,
  required Map<String, dynamic> data,
});

class CustomersSyncDelegate {
  final DatabaseService _dbService;
  final SyncCommonUtils _utils;
  final Future<void> Function({
    required String entityType,
    required SyncOperation operation,
    required int recordCount,
    required int durationMs,
    required bool success,
    String? errorMessage,
  })
  _recordMetric;
  final void Function(String step, Object error) _markSyncIssue;

  CustomersSyncDelegate({
    required DatabaseService dbService,
    required SyncCommonUtils utils,
    required Future<void> Function({
      required String entityType,
      required SyncOperation operation,
      required int recordCount,
      required int durationMs,
      required bool success,
      String? errorMessage,
    })
    recordMetric,
    required void Function(String step, Object error) markSyncIssue,
  }) : _dbService = dbService,
       _utils = utils,
       _recordMetric = recordMetric,
       _markSyncIssue = markSyncIssue;

  String _partnerOutboxId(String collection, String recordId) {
    return 'outbox_${collection}_$recordId';
  }

  Future<void> syncCustomers(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
    required ResolveSalesmanRouteScope resolveSalesmanRouteScope,
    required BuildCustomerSyncPayload buildCustomerSyncPayload,
    required DeletePartnerOutboxItem deletePartnerOutboxItem,
    required UpsertPartnerOutboxItem upsertPartnerOutboxItem,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      // 1. PUSH (per-record to avoid whole-batch failure)
      final pendingCustomers = await _dbService.customers
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      int failedCount = 0;
      if (pendingCustomers.isNotEmpty) {
        final queueIds = pendingCustomers
            .map((customer) => _partnerOutboxId('customers', customer.id))
            .toList(growable: false);
        final queuedRecords = await _dbService.syncQueue.getAllById(queueIds);
        final queuedSet = <String>{};
        for (var i = 0; i < queueIds.length; i++) {
          if (queuedRecords[i] != null) {
            queuedSet.add(queueIds[i]);
          }
        }

        for (final customer in pendingCustomers) {
          if (customer.syncStatus == SyncStatus.conflict) {
            continue;
          }

          final queueId = _partnerOutboxId('customers', customer.id);
          if (queuedSet.contains(queueId)) {
            continue;
          }

          try {
            final data = buildCustomerSyncPayload(customer)..remove('id');
            await db
                .collection(CollectionRegistry.customers)
                .doc(customer.id)
                .set(data, firestore.SetOptions(merge: true));

            await _dbService.db.writeTxn(() async {
              customer.syncStatus = SyncStatus.synced;
              customer.updatedAt = DateTime.now();
              await _dbService.customers.put(customer);
            });
            await deletePartnerOutboxItem('customers', customer.id);
            pushedCount++;
          } catch (e, stackTrace) {
            failedCount++;
            pushError ??= e.toString();
            AppLogger.error(
              'Error pushing customer ${customer.id}',
              error: e,
              stackTrace: stackTrace,
              tag: 'Sync',
            );
            await upsertPartnerOutboxItem(
              collection: 'customers',
              action: customer.isDeleted ? 'delete' : 'set',
              recordId: customer.id,
              data: buildCustomerSyncPayload(customer),
            );
          }
        }
      }

      if (failedCount > 0) {
        _markSyncIssue('customers push', '$failedCount record(s) failed');
      }
      pushSuccess = failedCount == 0;
    } catch (e) {
      AppLogger.error('Error pushing customers', error: e, tag: 'Sync');
      _markSyncIssue('customers push', e);
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _recordMetric(
        entityType: 'customers',
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
          : await _utils.getLastSyncTimestamp('customers');
      final docsById = <String, firestore.QueryDocumentSnapshot>{};
      final minRemoteUpdatedAt = lastSync;

      bool includeByDelta(Map<String, dynamic> data) {
        if (minRemoteUpdatedAt == null) return true;
        final remoteUpdatedAt = _utils.parseRemoteDate(
          data['updatedAt'] ?? data['lastUpdatedAt'] ?? data['createdAt'],
          fallback: DateTime.fromMillisecondsSinceEpoch(0),
        );
        return remoteUpdatedAt.isAfter(minRemoteUpdatedAt);
      }

      if (user.role == UserRole.salesman) {
        final assignedRoutes = await resolveSalesmanRouteScope(db, user);
        if (assignedRoutes.isEmpty) {
          pullSuccess = true; // No route assignment = no customer scope
          return;
        }

        final customersCollection = db.collection(CollectionRegistry.customers);
        final routeChunks = _utils.chunkList(assignedRoutes, 10);
        for (final chunk in routeChunks) {
          firestore.Query scopedQuery = customersCollection.where(
            'route',
            whereIn: chunk,
          );
          bool applyClientSideDeltaFilter = false;
          if (lastSync != null) {
            scopedQuery = scopedQuery.where(
              'updatedAt',
              isGreaterThan: lastSync.toIso8601String(),
            );
          }
          firestore.QuerySnapshot scopedSnapshot;
          try {
            scopedSnapshot = await scopedQuery.get();
          } catch (e) {
            final normalized = e.toString().toLowerCase();
            final isRecoverable =
                normalized.contains('failed-precondition') ||
                normalized.contains('requires an index');
            // [LOCKED] If remote composite index is missing, keep sync resilient:
            // pull scoped route set and apply updatedAt delta locally.
            if (lastSync != null && isRecoverable) {
              AppLogger.warning(
                'Customers route delta query fallback to route-only pull: $e',
                tag: 'Sync',
              );
              scopedSnapshot = await customersCollection
                  .where('route', whereIn: chunk)
                  .get();
              applyClientSideDeltaFilter = true;
            } else {
              rethrow;
            }
          }
          for (final doc in scopedSnapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (!applyClientSideDeltaFilter || includeByDelta(data)) {
              docsById[doc.id] = doc;
            }
          }

          // [LOCKED] Some customer rows persist route in salesRoute only.
          // Query both route fields to keep salesman scope stable.
          final salesRouteSnapshot = await customersCollection
              .where('salesRoute', whereIn: chunk)
              .get();
          for (final doc in salesRouteSnapshot.docs) {
            final data = doc.data();
            if (includeByDelta(data)) {
              docsById[doc.id] = doc;
            }
          }
        }
      } else {
        firestore.Query query = db.collection(CollectionRegistry.customers);
        if (lastSync != null) {
          query = query.where(
            'updatedAt',
            isGreaterThan: lastSync.toIso8601String(),
          );
        }
        final snapshot = await query.get();
        for (final doc in snapshot.docs) {
          docsById[doc.id] = doc;
        }
      }

      final customerDocs = docsById.values.toList();
      if (customerDocs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final ids = customerDocs.map((doc) => doc.id).toList(growable: false);
        final existingRecords = await _dbService.customers
            .filter()
            .anyOf(ids, (q, String id) => q.idEqualTo(id))
            .findAll();
        final existingMap = {
          for (final customer in existingRecords) customer.id: customer,
        };
        final customersToPut = <CustomerEntity>[];

        for (final doc in customerDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          // Conflict Detection
          final existing = existingMap[doc.id];
          if (existing != null) {
            await _utils.detectAndFlagConflict<CustomerEntity>(
              entityId: doc.id,
              entityType: 'customers',
              serverData: data,
              localEntity: existing,
              localToJson: (e) => e.toDomain().toJson(),
            );
            continue;
          }

          final createdAtIso = _utils
              .parseRemoteDate(data['createdAt'], fallback: updatedAt)
              .toIso8601String();
          final customer = CustomerEntity()
            ..id = doc.id
            ..shopName = data['shopName'] ?? ''
            ..ownerName = data['ownerName'] ?? ''
            ..mobile = data['mobile'] ?? ''
            ..alternateMobile = data['alternateMobile']
            ..email = data['email']
            ..address = data['address'] ?? ''
            ..addressLine2 = data['addressLine2']
            ..city = data['city']
            ..state = data['state']
            ..pincode = data['pincode']
            ..gstin = data['gstin']
            ..pan = data['pan']
            ..route = data['route'] ?? ''
            ..status = data['status'] ?? 'active'
            ..balance = (data['balance'] ?? 0).toDouble()
            ..creditLimit = (data['creditLimit'] as num?)?.toDouble()
            ..paymentTerms = data['paymentTerms']
            ..latitude = (data['latitude'] as num?)?.toDouble()
            ..longitude = (data['longitude'] as num?)?.toDouble()
            ..createdAt = createdAtIso
            ..createdBy = data['createdBy']?.toString()
            ..createdByName = data['createdByName']?.toString()
            ..syncStatus = SyncStatus.synced
            ..updatedAt = updatedAt;

          customer.encryptSensitiveFields();
          customersToPut.add(customer);
        }
        if (customersToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.customers.putAll(customersToPut);
          });
        }
        await _utils.setLastSyncTimestamp('customers', maxUpdatedAt);
        pulledCount = customerDocs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Customer sync (pull) failed', error: e, tag: 'Sync');
      _markSyncIssue('customers pull', e);
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _recordMetric(
        entityType: 'customers',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }
}
