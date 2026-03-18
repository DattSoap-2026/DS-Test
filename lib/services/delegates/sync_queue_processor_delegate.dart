import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart'
    show debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:isar/isar.dart';

import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/data/local/entities/trip_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/sale_entity.dart';
import 'package:flutter_app/data/local/entities/return_entity.dart';
import 'package:flutter_app/data/local/entities/bhatti_entry_entity.dart';
import 'package:flutter_app/data/local/entities/production_entry_entity.dart';
import 'package:flutter_app/data/local/entities/customer_entity.dart';
import 'package:flutter_app/data/local/entities/dealer_entity.dart';
import 'package:flutter_app/data/local/entities/bhatti_batch_entity.dart';
import 'package:flutter_app/data/local/entities/tank_entity.dart';
import 'package:flutter_app/data/local/entities/tank_lot_entity.dart';
import 'package:flutter_app/data/local/entities/tank_transaction_entity.dart';
import 'package:flutter_app/data/local/entities/cutting_batch_entity.dart';
import 'package:flutter_app/data/local/entities/department_stock_entity.dart';
import 'package:flutter_app/data/local/entities/detailed_production_log_entity.dart';
import 'package:flutter_app/data/local/entities/duty_session_entity.dart';
import 'package:flutter_app/data/local/entities/employee_entity.dart';
import 'package:flutter_app/data/local/entities/route_session_entity.dart';
import 'package:flutter_app/data/local/entities/customer_visit_entity.dart';
import 'package:flutter_app/data/local/entities/opening_stock_entity.dart';
import 'package:flutter_app/data/local/entities/stock_ledger_entity.dart';
import 'package:flutter_app/data/local/entities/vehicle_entity.dart';
import 'package:flutter_app/data/local/entities/diesel_log_entity.dart';
import 'package:flutter_app/data/local/entities/sales_target_entity.dart';
import 'package:flutter_app/data/local/entities/scheme_entity.dart';
import 'package:flutter_app/data/local/entities/wastage_log_entity.dart';
import 'package:flutter_app/data/local/entities/payroll_record_entity.dart';
import 'package:flutter_app/data/local/entities/leave_request_entity.dart';
import 'package:flutter_app/data/local/entities/attendance_entity.dart';
import 'package:flutter_app/data/local/entities/advance_entity.dart';
import 'package:flutter_app/data/local/entities/holiday_entity.dart';
import 'package:flutter_app/data/local/entities/performance_review_entity.dart';
import 'package:flutter_app/data/local/entities/employee_document_entity.dart';
import 'package:flutter_app/data/local/entities/vehicle_issue_entity.dart';
import 'package:flutter_app/data/local/entities/maintenance_log_entity.dart';
import 'package:flutter_app/data/local/entities/tyre_log_entity.dart';
import 'package:flutter_app/data/local/entities/account_entity.dart';
import 'package:flutter_app/data/local/entities/voucher_entity.dart';
import 'package:flutter_app/data/local/entities/voucher_entry_entity.dart';
import 'package:flutter_app/data/local/entities/payment_entity.dart';
import 'package:flutter_app/data/local/entities/route_entity.dart';
import 'package:flutter_app/data/local/entities/tyre_stock_entity.dart';
import 'package:flutter_app/data/local/entities/category_entity.dart';
import 'package:flutter_app/data/local/entities/product_type_entity.dart';
import 'package:flutter_app/data/local/entities/custom_role_entity.dart';
import 'package:flutter_app/data/local/entities/dispatch_entity.dart';
import 'package:flutter_app/data/local/entities/stock_movement_entity.dart';
import 'package:flutter_app/data/local/entities/route_order_entity.dart';
import 'package:flutter_app/data/local/entities/alert_entity.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/data/local/entities/unit_entity.dart';
import 'package:flutter_app/models/types/alert_types.dart';
import 'package:flutter_app/modules/hr/services/attendance_service.dart';
import 'package:flutter_app/modules/hr/services/payroll_service.dart';
import 'package:flutter_app/services/bhatti_service.dart';
import 'package:flutter_app/services/cutting_batch_service.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/dispatch_service.dart';
import 'package:flutter_app/services/inventory_service.dart';
import 'package:flutter_app/services/master_data_service.dart';
import 'package:flutter_app/services/outbox_codec.dart';
import 'package:flutter_app/services/payments_service.dart';
import 'package:flutter_app/services/production_service.dart';
import 'package:flutter_app/services/returns_service.dart';
import 'package:flutter_app/services/sales_service.dart';
import 'package:flutter_app/services/remote_inventory_command_applier.dart';
import 'package:flutter_app/services/identity_revalidation_state.dart';
import 'package:flutter_app/utils/app_logger.dart';

typedef ResolvePaymentsService = PaymentsService Function();

class SyncQueueProcessorDelegate {
  /// Maximum items to process per sync cycle to avoid overwhelming
  /// the platform channel (especially on Windows desktop).
  static const int _maxBatchSize = 20;

  /// Cooldown delay after heavy Firestore transactions to prevent
  /// rapid-fire native SDK calls that crash the Windows platform channel.
  static const Duration _heavyOpCooldown = Duration(milliseconds: 200);
  final DatabaseService _dbService;
  final FirebaseServices _firebase;
  final SalesService _salesService;
  final InventoryService _inventoryService;
  final ReturnsService _returnsService;
  final DispatchService _dispatchService;
  final ProductionService _productionService;
  final BhattiService _bhattiService;
  final CuttingBatchService _cuttingBatchService;
  final PayrollService _payrollService;
  final AttendanceService _attendanceService;
  final MasterDataService _masterDataService;
  final ResolvePaymentsService _resolvePaymentsService;
  final Future<void> Function() _migrateLegacyQueue;
  final void Function(String step, Object error) _markSyncIssue;
  final Future<void> Function() _updatePendingCount;
  final Future<void> Function({
    required String entityType,
    required SyncOperation operation,
    required int recordCount,
    required int durationMs,
    required bool success,
    String? errorMessage,
  })
  _recordMetric;

  SyncQueueProcessorDelegate({
    required DatabaseService dbService,
    required FirebaseServices firebase,
    required SalesService salesService,
    required InventoryService inventoryService,
    required ReturnsService returnsService,
    required DispatchService dispatchService,
    required ProductionService productionService,
    required BhattiService bhattiService,
    required CuttingBatchService cuttingBatchService,
    required PayrollService payrollService,
    required AttendanceService attendanceService,
    required MasterDataService masterDataService,
    required ResolvePaymentsService resolvePaymentsService,
    required Future<void> Function() migrateLegacyQueue,
    required void Function(String step, Object error) markSyncIssue,
    required Future<void> Function() updatePendingCount,
    required Future<void> Function({
      required String entityType,
      required SyncOperation operation,
      required int recordCount,
      required int durationMs,
      required bool success,
      String? errorMessage,
    })
    recordMetric,
  }) : _dbService = dbService,
       _firebase = firebase,
       _salesService = salesService,
       _inventoryService = inventoryService,
       _returnsService = returnsService,
       _dispatchService = dispatchService,
       _productionService = productionService,
       _bhattiService = bhattiService,
       _cuttingBatchService = cuttingBatchService,
       _payrollService = payrollService,
       _attendanceService = attendanceService,
       _masterDataService = masterDataService,
       _resolvePaymentsService = resolvePaymentsService,
       _migrateLegacyQueue = migrateLegacyQueue,
       _markSyncIssue = markSyncIssue,
       _updatePendingCount = updatePendingCount,
       _recordMetric = recordMetric;

  Future<void> processSyncQueue() async {
    final db = _firebase.db;
    if (db == null) return;

    final authUser = _firebase.auth?.currentUser;
    if (authUser == null) {
      AppLogger.warning(
        'User not authenticated. Queue processing blocked.',
        tag: 'Sync',
      );
      return;
    }
    final identityValidated = await IdentityRevalidationState.isValidatedForUid(
      authUser.uid,
    );
    if (!identityValidated) {
      AppLogger.warning(
        'Identity revalidation pending. Queue processing blocked in read-only mode.',
        tag: 'Sync',
      );
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    AppLogger.info('Processing Sync Queue (Isar)...', tag: 'Sync');
    final stopwatch = Stopwatch()..start();
    int processed = 0;
    int failed = 0;
    int skippedBackoff = 0;
    int skippedForeign = 0;
    int skippedPermanent = 0;
    bool success = false;
    String? error;

    try {
      await _dedupeExistingSyncConflictAlerts();

      AppLogger.debug('Calling _migrateLegacyQueue...', tag: 'Sync_Trace');
      await _migrateLegacyQueue();
      AppLogger.debug('Migrated legacy queue successfully.', tag: 'Sync_Trace');

      AppLogger.debug(
        'Fetching queue items with findAll()...',
        tag: 'Sync_Trace',
      );
      final queueItems = await _dbService.syncQueue
          .where()
          .sortByTimestamp()
          .findAll();
      AppLogger.debug(
        'Fetched ${queueItems.length} items from syncQueue.',
        tag: 'Sync_Trace',
      );

      if (queueItems.isEmpty) {
        AppLogger.success('Sync Queue Empty.', tag: 'Sync');
        success = true;
        return;
      }

      AppLogger.debug(
        'Converting queue items to workItems...',
        tag: 'Sync_Trace',
      );
      final allWorkItems = queueItems
          .map((item) => _QueueWorkItem.from(item))
          .toList(growable: false);
      // Limit batch size to avoid overwhelming the Firestore native SDK.
      final workItems = allWorkItems.length > _maxBatchSize
          ? allWorkItems.sublist(0, _maxBatchSize)
          : allWorkItems;
      if (allWorkItems.length > _maxBatchSize) {
        AppLogger.info(
          'Queue has ${allWorkItems.length} items, processing first $_maxBatchSize this cycle.',
          tag: 'Sync',
        );
      }
      AppLogger.debug(
        'Converted to ${workItems.length} workItems (of ${allWorkItems.length} total).',
        tag: 'Sync_Trace',
      );

      for (final item in workItems) {
        AppLogger.debug(
          'Processing item ${item.entity.id} for ${item.entity.collection}[${item.entity.action}]',
          tag: 'Sync_Trace',
        );
        final data = item.data;
        final meta = item.meta;
        var syncData = data;

        if (!_shouldProcessQueueItemForCurrentSession(item, authUser)) {
          skippedForeign++;
          AppLogger.info(
            'Skipping queue item owned by another user session: ${item.entity.id}',
            tag: 'Sync',
          );
          continue;
        }

        if (OutboxCodec.isPermanentFailure(meta)) {
          await _dbService.db.writeTxn(() async {
            await _dbService.syncQueue.delete(item.entity.isarId);
          });
          AppLogger.info(
            'Auto-deleted permanent failure: ${item.entity.id}',
            tag: 'Sync',
          );
          skippedPermanent++;
          continue;
        }

        // --- QUEUE ITEM EXPIRY CHECK (Audit Recommendation #2) ---
        // Auto-mark stuck items (>7 days old + exceeds maxAttempts) as permanent failure.
        final firstQueuedRaw = meta['firstQueuedAt']?.toString();
        final firstQueued = firstQueuedRaw != null
            ? DateTime.tryParse(firstQueuedRaw)
            : null;
        final attemptCountForExpiry =
            (meta['attemptCount'] as num?)?.toInt() ?? 0;
        final maxAttemptsForExpiry =
            (meta['maxAttempts'] as num?)?.toInt() ??
            OutboxCodec.defaultMaxAttempts;
        if (firstQueued != null) {
          final age = DateTime.now().difference(firstQueued);
          if (age.inDays >= 7 && attemptCountForExpiry >= maxAttemptsForExpiry) {
            // Mark as permanent failure and create admin alert
            final expiredMeta = <String, dynamic>{
              ...meta,
              'permanentFailure': true,
              'attemptCount':
                  meta['maxAttempts'] ?? OutboxCodec.defaultMaxAttempts,
              'lastError':
                  'Expired: item stuck >7 days with >20 retries. Admin review required.',
              'nextRetryAt': null,
            };
            final now = DateTime.now();
            final collection = item.entity.collection;
            final action = item.entity.action;
            final alertId =
                'stuck_queue_${_normalizeAlertToken(collection)}_${_normalizeAlertToken(action)}_${item.entity.id.hashCode.abs()}';

            await _dbService.db.writeTxn(() async {
              item.entity
                ..dataJson = OutboxCodec.encodeEnvelope(
                  payload: data,
                  existingMeta: expiredMeta,
                  now: now,
                  resetRetryState: false,
                )
                ..updatedAt = now
                ..syncStatus = SyncStatus.conflict;
              await _dbService.syncQueue.put(item.entity);

              // Create admin alert for stuck item
              final alert = AlertEntity();
              await _dbService.alerts.put(
                alert
                  ..id = alertId
                  ..alertId = alertId
                  ..title = 'Stuck Queue Item'
                  ..message =
                      'Sync item for $collection [$action] has been stuck for ${age.inDays} days ($attemptCountForExpiry retries). ID: ${item.entity.id}. Please review and resolve manually.'
                  ..severity = AlertSeverity.critical
                  ..type = AlertType.other
                  ..relatedId = item.entity.id
                  ..createdAt = now
                  ..updatedAt = now
                  ..isRead = false,
              );
            });
            AppLogger.warning(
              'Queue item expired (stuck >7 days, >=$maxAttemptsForExpiry retries): ${item.entity.id}',
              tag: 'Sync',
            );
            _markSyncIssue(
              'sync_queue',
              'Expired stuck item: ${item.entity.collection}/${item.entity.action} (${item.entity.id})',
            );
            skippedPermanent++;
            continue;
          }
        }
        // ---------------------------------------------------------

        if (!OutboxCodec.shouldRetryNow(meta)) {
          // Special case: Opening stock items should retry immediately
          // to avoid blocking system initialization
          final collection = item.entity.collection;
          if (collection == 'opening_stock_entries' || 
              collection == 'inventory_commands') {
            AppLogger.info(
              'Bypassing backoff for system-level operation: $collection',
              tag: 'Sync',
            );
          } else {
            skippedBackoff++;
            continue;
          }
        }

        try {
          final collection = item.entity.collection;
          final action = item.entity.action;
          final id = data['id']?.toString();
          syncData = _applyIdempotencyForCriticalMutation(
            collection: collection,
            action: action,
            payload: data,
            meta: meta,
            queueId: item.entity.id,
          );
          _assertDeterministicMutationId(
            collection: collection,
            action: action,
            payload: syncData,
          );

          if (collection == 'customers' || collection == 'dealers') {
            if (id == null || id.trim().isEmpty) {
              throw Exception(
                'Invalid partner outbox payload: missing id for $collection',
              );
            }

            AppLogger.debug(
              'Calling _getEntitySafely for local partner...',
              tag: 'Sync_Trace',
            );
            final local = await _getEntitySafely(collection, id);
            AppLogger.debug(
              'Fetched local partner: ${local != null}',
              tag: 'Sync_Trace',
            );
            if (local != null && local.syncStatus == SyncStatus.conflict) {
              throw Exception(
                '${collection == 'customers' ? 'Customer' : 'Dealer'} $id is in conflict state. Outbox retained.',
              );
            }

            final payload = Map<String, dynamic>.from(syncData)..remove('id');
            final docRef = db.collection(collection).doc(id);
            switch (action) {
              case 'delete':
                await docRef.set({
                  'isDeleted': true,
                  'updatedAt':
                      payload['updatedAt'] ?? DateTime.now().toIso8601String(),
                }, firestore.SetOptions(merge: true));
                break;
              case 'add':
              case 'set':
              case 'update':
                await docRef.set(payload, firestore.SetOptions(merge: true));
                break;
            }
          } else if (collection == 'sales') {
            AppLogger.debug(
              'Calling performSync for sales...',
              tag: 'Sync_Trace',
            );
            debugPrint(
              "[SalesSync] Starting Firestore write - platform: ${kIsWeb ? 'web' : defaultTargetPlatform.name}",
            );
            await (_salesService as dynamic).performSync(
              action,
              collection,
              syncData,
            );
            debugPrint('[SalesSync] Firestore write completed successfully');
            AppLogger.debug(
              'Finished performSync for sales.',
              tag: 'Sync_Trace',
            );
          } else if (collection == 'sales_voucher_posts') {
            await (_salesService as dynamic).processQueuedSalesVoucherPost(
              syncData,
            );
          } else if (collection == 'stock_movements' ||
              collection == 'department_stocks' ||
              collection == 'dispatches' ||
              collection == 'salesman_returns') {
            await (_inventoryService as dynamic).performSync(
              action,
              collection,
              syncData,
            );
          } else if (collection == 'returns') {
            await (_returnsService as dynamic).performSync(
              action,
              collection,
              syncData,
            );
          } else if (collection == 'payments') {
            await _resolvePaymentsService().performSync(
              action,
              collection,
              syncData,
            );
          } else if (collection == 'delivery_trips') {
            await (_dispatchService as dynamic).performSync(
              action,
              collection,
              syncData,
            );
          } else if (collection == 'detailed_production_logs' ||
              collection == 'production_entries') {
            await (_productionService as dynamic).performSync(
              action,
              collection,
              syncData,
            );
          } else if (collection == 'bhatti_batches') {
            await (_bhattiService as dynamic).performSync(
              action,
              collection,
              syncData,
            );
          } else if (collection == 'cutting_batches') {
            await (_cuttingBatchService as dynamic).performSync(
              action,
              collection,
              syncData,
            );
          } else if (collection == 'payroll_records') {
            await _payrollService.performSync(action, collection, syncData);
          } else if (collection == 'attendances') {
            await _attendanceService.performSync(action, collection, syncData);
          } else if (collection == 'product_categories' ||
              collection == 'product_types' ||
              collection == 'units') {
            await _masterDataService.performSync(action, collection, syncData);
          } else if (collection == 'inventory_commands') {
            final applier = RemoteInventoryCommandApplier(db);
            await applier.applyCommand(syncData);
            // Cooldown after heavy Firestore transaction to prevent
            // native platform channel overload on Windows.
            await Future<void>.delayed(_heavyOpCooldown);
          } else {
            AppLogger.debug(
              'Delegating to _performGenericUpsert...',
              tag: 'Sync_Trace',
            );
            await _performGenericUpsert(
              db: db,
              collection: collection,
              action: action,
              data: syncData,
            );
            AppLogger.debug(
              '_performGenericUpsert completed.',
              tag: 'Sync_Trace',
            );
          }

          AppLogger.debug(
            'Entering writeTxn for post-push sync mark...',
            tag: 'Sync_Trace',
          );

          final keyForMark = collection == 'units'
              ? (syncData['name'] ?? id)?.toString()
              : id?.toString();

          dynamic entityToMark;
          if (keyForMark != null && keyForMark.trim().isNotEmpty) {
            AppLogger.debug(
              'Calling _getEntitySafely for entity to mark...',
              tag: 'Sync_Trace',
            );
            entityToMark = await _getEntitySafely(collection, keyForMark);
            AppLogger.debug('Finished _getEntitySafely.', tag: 'Sync_Trace');
          }

          AppLogger.debug(
            'Entering writeTxn for post-push sync mark...',
            tag: 'Sync_Trace',
          );
          await _dbService.db.writeTxn(() async {
            await _markLocalEntitySyncedAfterQueuePush(
              collection: collection,
              action: action,
              id: id,
              payload: syncData,
              entity: entityToMark,
            );
            await _dbService.syncQueue.delete(item.entity.isarId);
          });
          AppLogger.debug('Exited writeTxn successfully.', tag: 'Sync_Trace');
          processed++;
          try {
            await _clearResolvedSyncConflictAlerts(
              collection: collection,
              action: action,
            );
          } catch (clearError) {
            AppLogger.warning(
              'Failed to clear resolved sync alerts: $clearError',
              tag: 'Sync',
            );
          }
        } catch (e) {
          AppLogger.debug(
            'Caught error during item processing: $e',
            tag: 'Sync_Trace',
          );
          var updatedMeta = OutboxCodec.markFailure(meta, e);
          final now = DateTime.now();
          final collection = item.entity.collection;
          final action = item.entity.action;
          final permissionDenied = _isPermissionDeniedError(e);
          if (permissionDenied && collection == 'sales_voucher_posts') {
            final maxAttempts =
                (updatedMeta['maxAttempts'] as num?)?.toInt() ??
                OutboxCodec.defaultMaxAttempts;
            updatedMeta = {
              ...updatedMeta,
              'attemptCount': maxAttempts,
              'maxAttempts': maxAttempts,
              'permanentFailure': true,
              'nextRetryAt': null,
            };
          }
          final isPermanent = OutboxCodec.isPermanentFailure(updatedMeta);
          if (isPermanent && collection == 'sales' && action == 'add') {
            try {
              await _salesService.compensatePermanentAddFailure(
                syncData,
                error: e,
              );
            } catch (compensationError) {
              AppLogger.error(
                'Failed local compensation for permanent sales/add failure',
                error: compensationError,
                tag: 'Sync',
              );
            }
          }
          final syncAlertId = _buildSyncConflictAlertId(
            collection: collection,
            action: action,
            permissionDenied: permissionDenied,
          );
          final scopeToken = _syncConflictScopeToken(collection, action);
          final scopeRelatedId = _syncConflictScopeRelatedId(
            collection,
            action,
          );
          final alertMessage = _buildSyncConflictAlertMessage(
            collection: collection,
            action: action,
            isPermanent: isPermanent,
            permissionDenied: permissionDenied,
            attemptCount: (updatedMeta['attemptCount'] as num?)?.toInt() ?? 0,
            error: e,
          );

          AppLogger.debug(
            'Entering writeTxn for error handling...',
            tag: 'Sync_Trace',
          );
          await _dbService.db.writeTxn(() async {
            final allAlerts = await _dbService.alerts.where().findAll();
            AlertEntity? scopedAlert;
            for (final existing in allAlerts) {
              if (existing.alertId == syncAlertId) {
                scopedAlert = existing;
                continue;
              }
              final sameScope =
                  existing.title == 'Sync Conflict' &&
                  (existing.relatedId == scopeRelatedId ||
                      existing.message.contains(scopeToken));
              if (sameScope) {
                await _dbService.alerts.delete(existing.isarId);
              }
            }

            item.entity
              ..dataJson = OutboxCodec.encodeEnvelope(
                payload: syncData,
                existingMeta: updatedMeta,
                now: now,
                resetRetryState: false,
              )
              ..updatedAt = now
              ..syncStatus = isPermanent
                  ? SyncStatus.conflict
                  : SyncStatus.pending;
            await _dbService.syncQueue.put(item.entity);

            final alert = scopedAlert ?? AlertEntity();
            await _dbService.alerts.put(
              alert
                ..id = syncAlertId
                ..alertId = syncAlertId
                ..title = 'Sync Conflict'
                ..message = alertMessage
                ..severity = isPermanent
                    ? AlertSeverity.critical
                    : AlertSeverity.warning
                ..type = AlertType.other
                ..relatedId = scopeRelatedId
                ..metadataJson = null
                ..createdAt = scopedAlert?.createdAt ?? now
                ..updatedAt = now
                ..isRead = false,
            );
          });

          AppLogger.warning(
            isPermanent
                ? 'Queue Item Failed (Permanent): ${item.entity.id}'
                : 'Queue Item Failed (Retention): ${item.entity.id}',
            tag: 'Sync',
          );

          if (isPermanent) {
            _markSyncIssue(
              'sync_queue',
              'Permanent failure for ${item.entity.collection}/${item.entity.action} (id: ${item.entity.id})',
            );
          }
          failed++;
        }
      }

      AppLogger.success(
        'Sync Queue Processed: $processed success, $failed failed, '
        '$skippedBackoff delayed, $skippedForeign foreign, '
        '$skippedPermanent permanent.',
        tag: 'Sync',
      );
      if (failed > 0) {
        _markSyncIssue('sync_queue', '$failed queue item(s) retained');
      }
      success = failed == 0;
    } catch (e) {
      AppLogger.error('Queue Processing Error', error: e, tag: 'Sync');
      error = e.toString();
    } finally {
      stopwatch.stop();
      await _recordMetric(
        entityType: 'queue',
        operation: SyncOperation.push,
        recordCount: processed,
        durationMs: stopwatch.elapsedMilliseconds,
        success: success,
        errorMessage: error,
      );
      await _updatePendingCount();
    }
  }

  Future<void> _dedupeExistingSyncConflictAlerts() async {
    await _dbService.db.writeTxn(() async {
      final alerts = await _dbService.alerts.where().findAll();
      final latestByScope = <String, AlertEntity>{};
      final toDelete = <Id>{};

      for (final alert in alerts) {
        if (alert.title != 'Sync Conflict') continue;
        final scopeKey = _syncScopeKeyFromAlert(alert);
        if (scopeKey == null) continue;

        final existing = latestByScope[scopeKey];
        if (existing == null) {
          latestByScope[scopeKey] = alert;
          continue;
        }

        final currentStamp = alert.updatedAt.millisecondsSinceEpoch;
        final existingStamp = existing.updatedAt.millisecondsSinceEpoch;
        if (currentStamp >= existingStamp) {
          toDelete.add(existing.isarId);
          latestByScope[scopeKey] = alert;
        } else {
          toDelete.add(alert.isarId);
        }
      }

      for (final id in toDelete) {
        await _dbService.alerts.delete(id);
      }
    });
  }

  String? _syncScopeKeyFromAlert(AlertEntity alert) {
    final related = alert.relatedId?.trim();
    if (related != null && related.startsWith('sync_scope_')) {
      return related;
    }

    final match = RegExp(
      r'([A-Za-z0-9_]+ \[[A-Za-z0-9_]+\])',
    ).firstMatch(alert.message);
    if (match == null) return null;
    return 'legacy_${match.group(1)!.toLowerCase()}';
  }

  Future<void> _clearResolvedSyncConflictAlerts({
    required String collection,
    required String action,
  }) async {
    final remainingQueue = await _dbService.syncQueue.where().findAll();
    final stillPendingForScope = remainingQueue.any(
      (item) => item.collection == collection && item.action == action,
    );
    if (stillPendingForScope) {
      return;
    }

    final scopeToken = _syncConflictScopeToken(collection, action);
    final scopeRelatedId = _syncConflictScopeRelatedId(collection, action);
    await _dbService.db.writeTxn(() async {
      final alerts = await _dbService.alerts.where().findAll();
      for (final alert in alerts) {
        final isScopedSyncConflict =
            alert.title == 'Sync Conflict' &&
            (alert.relatedId == scopeRelatedId ||
                alert.message.contains(scopeToken));
        if (!isScopedSyncConflict) continue;
        await _dbService.alerts.delete(alert.isarId);
      }
    });
  }

  bool _isPermissionDeniedError(Object error) {
    final normalized = error.toString().toLowerCase();
    return normalized.contains('permission-denied') ||
        normalized.contains('missing or insufficient permissions');
  }

  bool _shouldProcessQueueItemForCurrentSession(
    _QueueWorkItem item,
    firebase_auth.User authUser,
  ) {
    // Special handling for opening stock entries - allow any authenticated user to process
    if (item.entity.collection == 'opening_stock_entries' || 
        item.entity.collection == 'inventory_commands') {
      return true;
    }
    
    final ownerKeys = _extractQueueOwnerKeys(item);
    if (ownerKeys.isEmpty) return true;
    final sessionKeys = _currentSessionActorKeys(authUser);
    if (sessionKeys.isEmpty) return true;
    return ownerKeys.any(sessionKeys.contains);
  }

  Set<String> _extractQueueOwnerKeys(_QueueWorkItem item) {
    final ownerKeys = <String>{};

    void addKey(dynamic raw) {
      final normalized = _normalizeQueueActorKey(raw);
      if (normalized != null) {
        ownerKeys.add(normalized);
      }
    }

    addKey(item.meta[OutboxCodec.actorIdMetaField]);
    addKey(item.meta[OutboxCodec.actorUidMetaField]);
    addKey(item.meta[OutboxCodec.actorEmailMetaField]);
    if (ownerKeys.isNotEmpty) {
      return ownerKeys;
    }

    if (item.entity.collection == 'dispatches' && item.entity.action == 'add') {
      addKey(item.data['createdBy']);
      addKey(item.data['createdByEmail']);
    }
    return ownerKeys;
  }

  Set<String> _currentSessionActorKeys(firebase_auth.User authUser) {
    final keys = <String>{};

    void addKey(String? raw) {
      final normalized = _normalizeQueueActorKey(raw);
      if (normalized != null) {
        keys.add(normalized);
      }
    }

    addKey(authUser.uid);
    addKey(authUser.email);
    return keys;
  }

  String? _normalizeQueueActorKey(dynamic raw) {
    final value = raw?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value.toLowerCase();
  }

  String _syncConflictScopeToken(String collection, String action) {
    return '$collection [$action]';
  }

  String _syncConflictScopeRelatedId(String collection, String action) {
    return 'sync_scope_${_normalizeAlertToken(collection)}_${_normalizeAlertToken(action)}';
  }

  String _buildSyncConflictAlertId({
    required String collection,
    required String action,
    required bool permissionDenied,
  }) {
    final base =
        'sync_conflict_${_normalizeAlertToken(collection)}_${_normalizeAlertToken(action)}';
    return permissionDenied ? '${base}_permission_denied' : base;
  }

  String _buildSyncConflictAlertMessage({
    required String collection,
    required String action,
    required bool isPermanent,
    required bool permissionDenied,
    required int attemptCount,
    required Object error,
  }) {
    final scope = _syncConflictScopeToken(collection, action);
    if (permissionDenied) {
      if (isPermanent) {
        return 'Cloud sync blocked for $scope after $attemptCount attempts. Permission denied on server rules. Please review Firestore access for this role.';
      }
      return 'Cloud sync blocked for $scope. Permission denied on server rules; retry queued.';
    }
    final shortError = _shortError(error);
    if (isPermanent) {
      return 'Permanent outbox failure for $scope after $attemptCount attempts. Last error: $shortError';
    }
    return 'Failed to sync $scope. Retry queued. Error: $shortError';
  }

  String _shortError(Object error) {
    final raw = error.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (raw.length <= 180) return raw;
    return '${raw.substring(0, 180)}...';
  }

  String _normalizeAlertToken(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return 'unknown';
    return normalized.replaceAll(RegExp(r'[^a-z0-9_\-]'), '_');
  }

  Future<void> _performGenericUpsert({
    required firestore.FirebaseFirestore db,
    required String collection,
    required String action,
    required Map<String, dynamic> data,
  }) async {
    final docId = _resolveDocIdForCollection(collection, data);
    final payload = Map<String, dynamic>.from(data);
    payload.remove('id');

    switch (action) {
      case 'delete':
        if (docId == null || docId.trim().isEmpty) {
          throw Exception('Delete payload missing document id for $collection');
        }
        await db.collection(collection).doc(docId).set({
          'isDeleted': true,
          'updatedAt': payload['updatedAt'] ?? DateTime.now().toIso8601String(),
        }, firestore.SetOptions(merge: true));
        return;
      case 'add':
      case 'set':
      case 'update':
        if (docId == null || docId.trim().isEmpty) {
          throw Exception(
            'Deterministic id required for $collection [$action] payload',
          );
        }
        await db
            .collection(collection)
            .doc(docId)
            .set(payload, firestore.SetOptions(merge: true));
        return;
      default:
        throw Exception('Unsupported queue action: $action');
    }
  }

  String? _resolveDocIdForCollection(
    String collection,
    Map<String, dynamic> data,
  ) {
    final explicitId = data['id']?.toString().trim();
    if (explicitId != null && explicitId.isNotEmpty) return explicitId;
    if (collection == 'units') {
      final name = data['name']?.toString().trim();
      if (name != null && name.isNotEmpty) return name;
    }
    return null;
  }

  Map<String, dynamic> _applyIdempotencyForCriticalMutation({
    required String collection,
    required String action,
    required Map<String, dynamic> payload,
    required Map<String, dynamic> meta,
    required String queueId,
  }) {
    final requiresIdempotency =
        (collection == 'payments' && action == 'add') ||
        (collection == 'returns' && action == 'approve') ||
        (collection == 'detailed_production_logs' && action == 'add') ||
        (collection == 'sales' && (action == 'add' || action == 'edit')) ||
        (collection == 'stock_movements' && action == 'add') ||
        (collection == 'department_stocks' &&
            (action == 'issue_to_department' ||
                action == 'return_from_department')) ||
        (collection == 'dispatches' && action == 'add');
    if (!requiresIdempotency) {
      return payload;
    }
    final existingPayloadKey = OutboxCodec.readIdempotencyKey(payload);
    if (existingPayloadKey != null) {
      return payload;
    }
    if ((collection == 'sales' && action == 'edit') ||
        (collection == 'department_stocks' &&
            (action == 'issue_to_department' ||
                action == 'return_from_department'))) {
      final commandKey = _buildDeterministicCommandKey(
        collection: collection,
        action: action,
        payload: payload,
        queueId: queueId,
      );
      return <String, dynamic>{
        ...payload,
        OutboxCodec.idempotencyKeyField: commandKey,
      };
    }
    return OutboxCodec.ensureCommandPayload(
      collection: collection,
      action: action,
      payload: payload,
      existingMeta: meta,
      queueId: queueId,
    );
  }

  String _buildDeterministicCommandKey({
    required String collection,
    required String action,
    required Map<String, dynamic> payload,
    required String queueId,
  }) {
    final normalizedPayload = Map<String, dynamic>.from(payload)
      ..remove(OutboxCodec.idempotencyKeyField);
    final payloadDigest = fastHash(jsonEncode(normalizedPayload)).toString();
    return '${_normalizeAlertToken(collection)}_${_normalizeAlertToken(action)}_${_normalizeAlertToken(queueId)}_$payloadDigest';
  }

  void _assertDeterministicMutationId({
    required String collection,
    required String action,
    required Map<String, dynamic> payload,
  }) {
    if (!_requiresDeterministicId(collection, action)) {
      return;
    }
    final id = _resolveDocIdForCollection(collection, payload);
    if (id == null || id.trim().isEmpty) {
      throw Exception(
        'Deterministic id required for $collection [$action] payload',
      );
    }
  }

  bool _requiresDeterministicId(String collection, String action) {
    if (action == 'delete') return true;
    return collection == 'sales' ||
        collection == 'payments' ||
        collection == 'returns' ||
        collection == 'bhatti_batches' ||
        collection == 'cutting_batches' ||
        collection == 'wastage_logs' ||
        collection == 'stock_movements' ||
        collection == 'department_stocks' ||
        collection == 'dispatches' ||
        collection == 'stock_ledger';
  }

  Future<void> _markLocalEntitySyncedAfterQueuePush({
    required String collection,
    required String action,
    required String? id,
    required Map<String, dynamic> payload,
    required dynamic entity,
  }) async {
    if (entity == null) return;

    final now = DateTime.now();
    final key = collection == 'units'
        ? (payload['name'] ?? id)?.toString()
        : id?.toString();

    if (_isConflictGuardedCollection(collection) &&
        entity.syncStatus == SyncStatus.conflict) {
      return;
    }

    entity.syncStatus = SyncStatus.synced;
    entity.updatedAt = now;

    final isDelete = action == 'delete' || payload['isDeleted'] == true;
    if (isDelete && _supportsSoftDeleteFlag(collection)) {
      entity.isDeleted = true;
    }

    AppLogger.debug(
      'Calling _putEntity for $collection:$key',
      tag: 'Sync_Trace',
    );
    await _putEntity(collection, entity);
    AppLogger.debug(
      'Successfully put entity for $collection:$key',
      tag: 'Sync_Trace',
    );
  }

  bool _isConflictGuardedCollection(String collection) {
    switch (collection) {
      case 'customers':
      case 'dealers':
      case 'attendances':
      case 'payroll_records':
      case 'sales_targets':
      case 'units':
      case 'product_categories':
      case 'product_types':
      case 'leave_requests':
      case 'advances':
      case 'performance_reviews':
      case 'employee_documents':
      case 'employees':
      case 'users':
      case 'custom_roles':
      case 'products':
      case 'duty_sessions':
      case 'route_sessions':
      case 'customer_visits':
      case 'opening_stock_entries':
      case 'stock_ledger':
      case 'dispatches':
      case 'routes':
      case 'vehicles':
      case 'diesel_logs':
      case 'route_orders':
      case 'tanks':
      case 'tank_transactions':
      case 'tank_lots':
      case 'bhatti_entries':
      case 'production_entries':
      case 'stock_movements':
      case 'department_stocks':
      case 'detailed_production_logs':
      case 'schemes':
      case 'holidays':
      case 'vehicle_maintenance_logs':
      case 'tyre_logs':
      case 'tyre_items':
      case 'vehicle_issues':
      case 'bhatti_batches':
      case 'cutting_batches':
      case 'wastage_logs':
        return true;
      default:
        return false;
    }
  }

  bool _supportsSoftDeleteFlag(String collection) {
    switch (collection) {
      case 'attendances':
      case 'sales_targets':
      case 'units':
      case 'product_categories':
      case 'product_types':
      case 'leave_requests':
      case 'advances':
      case 'performance_reviews':
      case 'employee_documents':
      case 'employees':
      case 'custom_roles':
      case 'products':
      case 'routes':
      case 'vehicles':
      case 'diesel_logs':
      case 'tanks':
        return true;
      default:
        return false;
    }
  }

  Future<void> _putEntity(String collection, dynamic entity) async {
    switch (collection) {
      case 'sales':
        await _dbService.sales.put(entity);
        return;
      case 'payments':
        await _dbService.payments.put(entity);
        return;
      case 'returns':
        await _dbService.returns.put(entity);
        return;
      case 'delivery_trips':
        await _dbService.trips.put(entity);
        return;
      case 'dispatches':
        await _dbService.dispatches.put(entity);
        return;
      case 'customers':
        await _dbService.customers.put(entity);
        return;
      case 'dealers':
        await _dbService.dealers.put(entity);
        return;
      case 'accounts':
        await _dbService.accounts.put(entity);
        return;
      case 'vouchers':
        await _dbService.vouchers.put(entity);
        return;
      case 'voucher_entries':
        await _dbService.voucherEntries.put(entity);
        return;
      case 'attendances':
        await _dbService.attendances.put(entity);
        return;
      case 'payroll_records':
        await _dbService.payrollRecords.put(entity);
        return;
      case 'sales_targets':
        await _dbService.salesTargets.put(entity);
        return;
      case 'units':
        await _dbService.units.put(entity);
        return;
      case 'product_categories':
        await _dbService.categories.put(entity);
        return;
      case 'product_types':
        await _dbService.productTypes.put(entity);
        return;
      case 'leave_requests':
        await _dbService.leaveRequests.put(entity);
        return;
      case 'advances':
        await _dbService.advances.put(entity);
        return;
      case 'performance_reviews':
        await _dbService.performanceReviews.put(entity);
        return;
      case 'employee_documents':
        await _dbService.employeeDocuments.put(entity);
        return;
      case 'employees':
        await _dbService.employees.put(entity);
        return;
      case 'users':
        await _dbService.users.put(entity);
        return;
      case 'custom_roles':
        await _dbService.customRoles.put(entity);
        return;
      case 'products':
        await _dbService.products.put(entity);
        return;
      case 'duty_sessions':
        await _dbService.dutySessions.put(entity);
        return;
      case 'route_sessions':
        await _dbService.routeSessions.put(entity);
        return;
      case 'customer_visits':
        await _dbService.customerVisits.put(entity);
        return;
      case 'opening_stock_entries':
        await _dbService.openingStockEntries.put(entity);
        return;
      case 'stock_ledger':
        await _dbService.stockLedger.put(entity);
        return;
      case 'routes':
        await _dbService.routes.put(entity);
        return;
      case 'vehicles':
        await _dbService.vehicles.put(entity);
        return;
      case 'diesel_logs':
        await _dbService.dieselLogs.put(entity);
        return;
      case 'route_orders':
        await _dbService.routeOrders.put(entity);
        return;
      case 'tanks':
        await _dbService.tanks.put(entity);
        return;
      case 'tank_transactions':
        await _dbService.tankTransactions.put(entity);
        return;
      case 'tank_lots':
        await _dbService.tankLots.put(entity);
        return;
      case 'bhatti_entries':
        await _dbService.bhattiEntries.put(entity);
        return;
      case 'production_entries':
        await _dbService.productionEntries.put(entity);
        return;
      case 'stock_movements':
        await _dbService.stockMovements.put(entity);
        return;
      case 'department_stocks':
        await _dbService.departmentStocks.put(entity);
        return;
      case 'bhatti_batches':
        await _dbService.bhattiBatches.put(entity);
        return;
      case 'cutting_batches':
        await _dbService.cuttingBatches.put(entity);
        return;
      case 'wastage_logs':
        await _dbService.wastageLogs.put(entity);
        return;
      case 'detailed_production_logs':
        await _dbService.detailedProductionLogs.put(entity);
        return;
      case 'schemes':
        await _dbService.schemes.put(entity);
        return;
      case 'holidays':
        await _dbService.holidays.put(entity);
        return;
      case 'vehicle_maintenance_logs':
        await _dbService.maintenanceLogs.put(entity);
        return;
      case 'tyre_logs':
        await _dbService.tyreLogs.put(entity);
        return;
      case 'tyre_items':
        await _dbService.tyreStocks.put(entity);
        return;
      case 'vehicle_issues':
        await _dbService.vehicleIssues.put(entity);
        return;
      default:
        return;
    }
  }

  Future<dynamic> _getEntitySafely(String collection, String id) async {
    switch (collection) {
      case 'sales':
        return await _dbService.sales.filter().idEqualTo(id).findFirst();
      case 'payments':
        return await _dbService.payments.filter().idEqualTo(id).findFirst();
      case 'returns':
        return await _dbService.returns.filter().idEqualTo(id).findFirst();
      case 'delivery_trips':
        return await _dbService.trips.filter().idEqualTo(id).findFirst();
      case 'dispatches':
        return await _dbService.dispatches.filter().idEqualTo(id).findFirst();
      case 'customers':
        return await _dbService.customers.filter().idEqualTo(id).findFirst();
      case 'dealers':
        return await _dbService.dealers.filter().idEqualTo(id).findFirst();
      case 'accounts':
        return await _dbService.accounts.filter().idEqualTo(id).findFirst();
      case 'vouchers':
        return await _dbService.vouchers.filter().idEqualTo(id).findFirst();
      case 'voucher_entries':
        return await _dbService.voucherEntries
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'attendances':
        return await _dbService.attendances.filter().idEqualTo(id).findFirst();
      case 'payroll_records':
        return await _dbService.payrollRecords
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'sales_targets':
        return await _dbService.salesTargets.filter().idEqualTo(id).findFirst();
      case 'units':
        return await _dbService.units.filter().idEqualTo(id).findFirst();
      case 'product_categories':
        return await _dbService.categories.filter().idEqualTo(id).findFirst();
      case 'product_types':
        return await _dbService.productTypes.filter().idEqualTo(id).findFirst();
      case 'leave_requests':
        return await _dbService.leaveRequests
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'advances':
        return await _dbService.advances.filter().idEqualTo(id).findFirst();
      case 'performance_reviews':
        return await _dbService.performanceReviews
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'employee_documents':
        return await _dbService.employeeDocuments
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'employees':
        return await _dbService.employees.filter().idEqualTo(id).findFirst();
      case 'users':
        return await _dbService.users.filter().idEqualTo(id).findFirst();
      case 'custom_roles':
        return await _dbService.customRoles.filter().idEqualTo(id).findFirst();
      case 'products':
        return await _dbService.products.filter().idEqualTo(id).findFirst();
      case 'duty_sessions':
        return await _dbService.dutySessions.filter().idEqualTo(id).findFirst();
      case 'route_sessions':
        return await _dbService.routeSessions
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'customer_visits':
        return await _dbService.customerVisits
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'opening_stock_entries':
        return await _dbService.openingStockEntries
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'stock_ledger':
        return await _dbService.stockLedger.filter().idEqualTo(id).findFirst();
      case 'routes':
        return await _dbService.routes.filter().idEqualTo(id).findFirst();
      case 'vehicles':
        return await _dbService.vehicles.filter().idEqualTo(id).findFirst();
      case 'diesel_logs':
        return await _dbService.dieselLogs.filter().idEqualTo(id).findFirst();
      case 'route_orders':
        return await _dbService.routeOrders.filter().idEqualTo(id).findFirst();
      case 'tanks':
        return await _dbService.tanks.filter().idEqualTo(id).findFirst();
      case 'tank_transactions':
        return await _dbService.tankTransactions
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'tank_lots':
        return await TankLotEntityQueryWhere(
          _dbService.tankLots.where(),
        ).idEqualTo(id).findFirst();
      case 'bhatti_entries':
        return await _dbService.bhattiEntries
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'production_entries':
        return await _dbService.productionEntries
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'stock_movements':
        return await _dbService.stockMovements
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'department_stocks':
        return await _dbService.departmentStocks
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'bhatti_batches':
        return await _dbService.bhattiBatches
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'cutting_batches':
        return await _dbService.cuttingBatches
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'wastage_logs':
        return await _dbService.wastageLogs.filter().idEqualTo(id).findFirst();
      case 'detailed_production_logs':
        return await _dbService.detailedProductionLogs
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'schemes':
        return await _dbService.schemes.filter().idEqualTo(id).findFirst();
      case 'holidays':
        return await _dbService.holidays.filter().idEqualTo(id).findFirst();
      case 'vehicle_maintenance_logs':
        return await _dbService.maintenanceLogs
            .filter()
            .idEqualTo(id)
            .findFirst();
      case 'tyre_logs':
        return await _dbService.tyreLogs.filter().idEqualTo(id).findFirst();
      case 'tyre_items':
        return await _dbService.tyreStocks.filter().idEqualTo(id).findFirst();
      case 'vehicle_issues':
        return await _dbService.vehicleIssues
            .filter()
            .idEqualTo(id)
            .findFirst();
      default:
        return null;
    }
  }
}

class _QueueWorkItem {
  final SyncQueueEntity entity;
  final Map<String, dynamic> data;
  final Map<String, dynamic> meta;

  const _QueueWorkItem({
    required this.entity,
    required this.data,
    required this.meta,
  });

  factory _QueueWorkItem.from(SyncQueueEntity entity) {
    final decoded = OutboxCodec.decode(
      entity.dataJson,
      fallbackQueuedAt: entity.createdAt,
    );
    return _QueueWorkItem(
      entity: entity,
      data: decoded.payload,
      meta: decoded.meta,
    );
  }
}
