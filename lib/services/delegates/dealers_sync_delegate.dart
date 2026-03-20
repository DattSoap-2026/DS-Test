import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:isar/isar.dart';

import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/dealer_entity.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/sync_common_utils.dart';
import 'package:flutter_app/utils/app_logger.dart';

typedef BuildDealerSyncPayload =
    Map<String, dynamic> Function(DealerEntity dealer);

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

class DealersSyncDelegate {
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

  DealersSyncDelegate({
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

  Future<void> syncDealers(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
    required BuildDealerSyncPayload buildDealerSyncPayload,
    required DeletePartnerOutboxItem deletePartnerOutboxItem,
    required UpsertPartnerOutboxItem upsertPartnerOutboxItem,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      // 1. PUSH (per-record to avoid whole-batch failure)
      final pendingDealers = await _dbService.dealers
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      int failedCount = 0;
      if (pendingDealers.isNotEmpty) {
        final queueIds = pendingDealers
            .map((dealer) => _partnerOutboxId('dealers', dealer.id))
            .toList(growable: false);
        final queuedRecords = await _dbService.syncQueue.getAllById(queueIds);
        final queuedSet = <String>{};
        for (var i = 0; i < queueIds.length; i++) {
          if (queuedRecords[i] != null) {
            queuedSet.add(queueIds[i]);
          }
        }

        for (final dealer in pendingDealers) {
          if (dealer.syncStatus == SyncStatus.conflict) {
            continue;
          }

          final queueId = _partnerOutboxId('dealers', dealer.id);
          if (queuedSet.contains(queueId)) {
            continue;
          }

          try {
            final data = buildDealerSyncPayload(dealer)..remove('id');
            await db
                .collection(CollectionRegistry.dealers)
                .doc(dealer.id)
                .set(data, firestore.SetOptions(merge: true));

            await _dbService.db.writeTxn(() async {
              dealer.syncStatus = SyncStatus.synced;
              dealer.updatedAt = DateTime.now();
              await _dbService.dealers.put(dealer);
            });
            await deletePartnerOutboxItem('dealers', dealer.id);
            pushedCount++;
          } catch (e, stackTrace) {
            failedCount++;
            pushError ??= e.toString();
            AppLogger.error(
              'Error pushing dealer ${dealer.id}',
              error: e,
              stackTrace: stackTrace,
              tag: 'Sync',
            );
            await upsertPartnerOutboxItem(
              collection: 'dealers',
              action: dealer.isDeleted ? 'delete' : 'set',
              recordId: dealer.id,
              data: buildDealerSyncPayload(dealer),
            );
          }
        }
      }

      if (failedCount > 0) {
        _markSyncIssue('dealers push', '$failedCount record(s) failed');
      }
      pushSuccess = failedCount == 0;
    } catch (e) {
      AppLogger.error('Error pushing dealers', error: e, tag: 'Sync');
      _markSyncIssue('dealers push', e);
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _recordMetric(
        entityType: 'dealers',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    // 2. PULL with Delta
    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('dealers');
      firestore.Query query = db.collection(CollectionRegistry.dealers);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }
      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final ids = snapshot.docs.map((doc) => doc.id).toList(growable: false);
        final existingRecords = await _dbService.dealers
            .filter()
            .anyOf(ids, (q, String id) => q.idEqualTo(id))
            .findAll();
        final existingMap = {for (final dealer in existingRecords) dealer.id: dealer};
        final dealersToPut = <DealerEntity>[];

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          // Conflict Detection
          final existing = existingMap[doc.id];
          if (existing != null) {
            await _utils.detectAndFlagConflict<DealerEntity>(
              entityId: doc.id,
              entityType: 'dealers',
              serverData: data,
              localEntity: existing,
              localToJson: (e) => e.toDomain().toJson(),
            );
            continue;
          }

          final dealer = DealerEntity()
            ..id = doc.id
            ..name = data['name'] ?? ''
            ..contactPerson = data['contactPerson'] ?? ''
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
            ..status = data['status'] ?? 'active'
            ..commissionPercentage = (data['commissionPercentage'] as num?)
                ?.toDouble()
            ..paymentTerms = data['paymentTerms']
            ..territory = data['territory']
            ..assignedRouteId = data['assignedRouteId']
            ..assignedRouteName =
                data['assignedRouteName'] ??
                data['routeName'] ??
                data['territory']
            ..latitude = (data['latitude'] as num?)?.toDouble()
            ..longitude = (data['longitude'] as num?)?.toDouble()
            ..syncStatus = SyncStatus.synced
            ..createdAt = data['createdAt'] ?? updatedAt.toIso8601String()
            ..updatedAt = updatedAt;
          dealersToPut.add(dealer);
        }
        if (dealersToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.dealers.putAll(dealersToPut);
          });
        }
        await _utils.setLastSyncTimestamp('dealers', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Dealer sync pull failed', error: e, tag: 'Sync');
      _markSyncIssue('dealers pull', e);
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _recordMetric(
        entityType: 'dealers',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }
}
