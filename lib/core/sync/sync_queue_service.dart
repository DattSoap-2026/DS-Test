import 'dart:convert';

import 'package:isar/isar.dart';

import '../../features/inventory/models/sync_queue.dart';
import '../database/isar_service.dart';
import '../utils/sync_logger.dart';

/// Manages the durable Isar-backed sync queue.
class SyncQueueService {
  SyncQueueService._internal();

  static final SyncQueueService instance = SyncQueueService._internal();

  static const int maxRetryLimit = 5;

  final IsarService _isarService = IsarService.instance;

  /// Adds or replaces a queue entry for a document.
  Future<void> addToQueue({
    required String collectionName,
    required String documentId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final existing = await _isarService.syncQueues
          .filter()
          .queueKeyEqualTo('$collectionName::$documentId')
          .findFirst();

      final queueItem = SyncQueue()
        ..id = existing?.id ?? Isar.autoIncrement
        ..collectionName = collectionName
        ..documentId = documentId
        ..operation = operation
        ..payload = jsonEncode(payload)
        ..retryCount = existing?.retryCount ?? 0
        ..createdAt = existing?.createdAt ?? DateTime.now()
        ..lastAttemptAt = existing?.lastAttemptAt
        ..isFailed = false;

      await _isarService.isar.writeTxn(() async {
        await _isarService.syncQueues.put(queueItem);
      });
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to add item to sync queue',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// Returns all pending queue items that have not failed.
  Future<List<SyncQueue>> getAllPending() async {
    try {
      return _isarService.syncQueues
          .filter()
          .isFailedEqualTo(false)
          .sortByCreatedAt()
          .findAll();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to load pending sync queue items',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      return <SyncQueue>[];
    }
  }

  /// Deletes a processed queue item.
  Future<void> markAsProcessed(Id id) async {
    try {
      await _isarService.isar.writeTxn(() async {
        await _isarService.syncQueues.delete(id);
      });
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to mark queue item as processed',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// Increments retry count and marks permanent failures after the max limit.
  Future<void> incrementRetry(Id id) async {
    try {
      final current = await _isarService.syncQueues.get(id);
      if (current == null) {
        return;
      }

      final updatedRetryCount = current.retryCount + 1;
      final shouldFail = updatedRetryCount >= maxRetryLimit;
      final updated = current.copyWith(
        retryCount: updatedRetryCount,
        lastAttemptAt: DateTime.now(),
        isFailed: shouldFail,
      );

      await _isarService.isar.writeTxn(() async {
        await _isarService.syncQueues.put(updated);
      });

      if (shouldFail) {
        SyncLogger.instance.w(
          'Sync queue item ${current.documentId} reached max retries and was marked failed.',
          time: DateTime.now(),
        );
      }
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to increment queue retry count',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// Deletes failed or stale processed queue items older than [retention].
  Future<void> deleteOldProcessed({
    Duration retention = const Duration(days: 30),
  }) async {
    try {
      final cutoff = DateTime.now().subtract(retention);
      final stale = await _isarService.syncQueues
          .filter()
          .createdAtLessThan(cutoff)
          .findAll();
      if (stale.isEmpty) {
        return;
      }
      await _isarService.isar.writeTxn(() async {
        await _isarService.syncQueues.deleteAll(
          stale.map((item) => item.id).toList(),
        );
      });
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to clean processed sync queue items',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }
}
