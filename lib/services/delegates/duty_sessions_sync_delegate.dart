import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:isar/isar.dart';

import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/duty_session_entity.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/duty_service.dart';
import 'package:flutter_app/services/sync_common_utils.dart';
import 'package:flutter_app/utils/app_logger.dart';

class DutySessionsSyncDelegate {
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

  DutySessionsSyncDelegate({
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
  }) : _dbService = dbService,
       _utils = utils,
       _recordMetric = recordMetric;

  Future<void> syncDutySessions(
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
      final pendingSessions = await _dbService.dutySessions
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pendingSessions.isNotEmpty) {
        final chunks = _utils.chunkList(pendingSessions, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final session in chunk) {
            final domain = session.toDomain();
            final data = domain.toJson();
            final docRef = db
                .collection(CollectionRegistry.dutySessions)
                .doc(session.id);
            batch.set(docRef, data, firestore.SetOptions(merge: true));
          }
          await batch.commit();

          await _dbService.db.writeTxn(() async {
            final updatedSessions = <DutySessionEntity>[];
            for (final session in chunk) {
              session.syncStatus = SyncStatus.synced;
              updatedSessions.add(session);
            }
            if (updatedSessions.isNotEmpty) {
              await _dbService.dutySessions.putAll(updatedSessions);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing duty sessions', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _recordMetric(
        entityType: 'duty_sessions',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    // 2. PULL (Delta)
    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('duty_sessions');
      firestore.Query query = db.collection(CollectionRegistry.dutySessions);

      if (!user.isAdmin) {
        assert(
          firebaseUid != null && firebaseUid.isNotEmpty,
          'Firebase UID must be provided for salesman-filtered sync',
        );
        query = query.where('userId', isEqualTo: firebaseUid ?? user.id);
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
        final sessionsToPut = <DutySessionEntity>[];

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;

          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          try {
            final domainModel = DutySession.fromJson(data);
            final entity = DutySessionEntity.fromDomain(domainModel);
            entity.syncStatus = SyncStatus.synced;

            sessionsToPut.add(entity);
          } catch (e) {
            AppLogger.error(
              'Error parsing duty session ${doc.id}',
              error: e,
              tag: 'Sync',
            );
          }
        }
        if (sessionsToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.dutySessions.putAll(sessionsToPut);
          });
        }

        await _utils.setLastSyncTimestamp('duty_sessions', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Duty sync pull failed', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _recordMetric(
        entityType: 'duty_sessions',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }
}
