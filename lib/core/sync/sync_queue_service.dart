import 'dart:convert';

import 'package:isar/isar.dart';

import '../../features/inventory/models/sync_queue.dart';
import '../database/isar_service.dart';
import '../utils/sync_logger.dart';

/// Manages the durable Isar-backed sync queue.
class SyncQueueService {
  SyncQueueService._internal();

  static final SyncQueueService instance = SyncQueueService._internal();

  static const int defaultMaxRetryLimit = 5;

  final IsarService _isarService = IsarService.instance;

  /// Adds a sync operation to the durable queue with deduplication.
  Future<void> addToQueue({
    required String collectionName,
    required String documentId,
    required String operation,
    required Object? payload,
  }) async {
    try {
      final normalizedCollection = collectionName.trim();
      final normalizedDocumentId = documentId.trim();
      if (normalizedCollection.isEmpty || normalizedDocumentId.isEmpty) {
        return;
      }

      final existing = await _isarService.syncQueues
          .filter()
          .queueKeyEqualTo('$normalizedCollection::$normalizedDocumentId')
          .findFirst();

      final queueItem = SyncQueue()
        ..id = existing?.id ?? Isar.autoIncrement
        ..collectionName = normalizedCollection
        ..documentId = normalizedDocumentId
        ..operation = operation.trim().isEmpty ? 'update' : operation.trim()
        ..payload = _encodePayload(payload)
        ..retryCount = 0
        ..maxRetries = existing?.maxRetries ?? defaultMaxRetryLimit
        ..createdAt = existing?.createdAt ?? DateTime.now()
        ..lastAttemptAt = null
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

  /// Returns queue entries that are still eligible for retry.
  Future<List<SyncQueue>> getPendingQueue() async {
    try {
      final items = await _isarService.syncQueues
          .filter()
          .isFailedEqualTo(false)
          .sortByCreatedAt()
          .findAll();
      return items
          .where((item) => item.retryCount < item.maxRetries)
          .toList(growable: false);
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to load pending sync queue items',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      return const <SyncQueue>[];
    }
  }

  /// Returns all queue entries, including permanently failed ones.
  Future<List<SyncQueue>> getAllQueueItems() async {
    try {
      return await _isarService.syncQueues.where().findAll();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to load all sync queue items',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      return const <SyncQueue>[];
    }
  }

  /// Returns queue entries that exhausted their retry budget.
  Future<List<SyncQueue>> getFailedQueue() async {
    try {
      return await _isarService.syncQueues
          .filter()
          .isFailedEqualTo(true)
          .sortByCreatedAt()
          .findAll();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to load failed sync queue items',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      return const <SyncQueue>[];
    }
  }

  /// Returns the count of pending queue entries.
  Future<int> getPendingCount({String? collectionName}) async {
    final pending = await getPendingQueue();
    if (collectionName == null || collectionName.trim().isEmpty) {
      return pending.length;
    }
    final normalized = collectionName.trim();
    return pending.where((item) => item.collectionName == normalized).length;
  }

  /// Returns whether a queue entry exists for the collection/document pair.
  Future<bool> hasPendingItem({
    required String collectionName,
    required String documentId,
  }) async {
    final normalizedCollection = collectionName.trim();
    final normalizedDocumentId = documentId.trim();
    if (normalizedCollection.isEmpty || normalizedDocumentId.isEmpty) {
      return false;
    }

    try {
      final existing = await _isarService.syncQueues
          .filter()
          .collectionNameEqualTo(normalizedCollection)
          .documentIdEqualTo(normalizedDocumentId)
          .findFirst();
      return existing != null;
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to check pending sync queue item',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      return false;
    }
  }

  /// Returns a queue entry for a specific collection/document pair.
  Future<SyncQueue?> getQueueItem({
    required String collectionName,
    required String documentId,
  }) async {
    final normalizedCollection = collectionName.trim();
    final normalizedDocumentId = documentId.trim();
    if (normalizedCollection.isEmpty || normalizedDocumentId.isEmpty) {
      return null;
    }

    try {
      return await _isarService.syncQueues
          .filter()
          .collectionNameEqualTo(normalizedCollection)
          .documentIdEqualTo(normalizedDocumentId)
          .findFirst();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to load sync queue item',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      return null;
    }
  }

  /// Deletes a processed queue item.
  Future<void> markProcessed(Id id) async {
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

  /// Deletes a queue item by collection/document pair.
  Future<void> removeFromQueue({
    required String collectionName,
    required String documentId,
  }) async {
    final normalizedCollection = collectionName.trim();
    final normalizedDocumentId = documentId.trim();
    if (normalizedCollection.isEmpty || normalizedDocumentId.isEmpty) {
      return;
    }

    try {
      final existing = await _isarService.syncQueues
          .filter()
          .collectionNameEqualTo(normalizedCollection)
          .documentIdEqualTo(normalizedDocumentId)
          .findFirst();
      if (existing == null) {
        return;
      }

      await _isarService.isar.writeTxn(() async {
        await _isarService.syncQueues.delete(existing.id);
      });
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to delete sync queue item',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// Increments retry count and marks permanent failures after the limit.
  Future<void> incrementRetry(Id id) async {
    try {
      final current = await _isarService.syncQueues.get(id);
      if (current == null) {
        return;
      }

      final updatedRetryCount = current.retryCount + 1;
      final shouldFail = updatedRetryCount >= current.maxRetries;
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
          'Sync queue item ${current.collectionName}/${current.documentId} reached max retries.',
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

  /// Forces a queue item into a failed terminal state.
  Future<void> markFailed(Id id) async {
    try {
      final current = await _isarService.syncQueues.get(id);
      if (current == null) {
        return;
      }

      await _isarService.isar.writeTxn(() async {
        await _isarService.syncQueues.put(
          current.copyWith(
            retryCount: current.maxRetries,
            isFailed: true,
            lastAttemptAt: DateTime.now(),
          ),
        );
      });
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to mark queue item as failed',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// Resets a failed queue item back to a retryable state.
  Future<void> resetRetry({
    required String collectionName,
    required String documentId,
  }) async {
    try {
      final current = await getQueueItem(
        collectionName: collectionName,
        documentId: documentId,
      );
      if (current == null) {
        return;
      }

      await _isarService.isar.writeTxn(() async {
        await _isarService.syncQueues.put(
          current.copyWith(retryCount: 0, lastAttemptAt: null, isFailed: false),
        );
      });
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to reset sync queue retry state',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// Clears the durable queue.
  Future<void> clearQueue() async {
    try {
      await _isarService.isar.writeTxn(() async {
        await _isarService.syncQueues.clear();
      });
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to clear sync queue',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// Deletes failed items older than [retention].
  Future<void> clearOldFailed({
    Duration retention = const Duration(days: 7),
  }) async {
    try {
      final cutoff = DateTime.now().subtract(retention);
      final stale = await _isarService.syncQueues
          .filter()
          .isFailedEqualTo(true)
          .createdAtLessThan(cutoff)
          .findAll();
      if (stale.isEmpty) {
        return;
      }
      await _isarService.isar.writeTxn(() async {
        await _isarService.syncQueues.deleteAll(
          stale.map((item) => item.id).toList(growable: false),
        );
      });
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to clean old failed sync queue items',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// Compatibility alias for the legacy inventory pilot code path.
  Future<List<SyncQueue>> getAllPending() => getPendingQueue();

  /// Compatibility alias for the legacy inventory pilot code path.
  Future<void> markAsProcessed(Id id) => markProcessed(id);

  /// Compatibility alias for the legacy inventory pilot code path.
  Future<void> deleteOldProcessed({
    Duration retention = const Duration(days: 30),
  }) async {
    await clearOldFailed(retention: retention);
  }

  String _encodePayload(Object? payload) {
    if (payload == null) {
      return jsonEncode(const <String, dynamic>{});
    }
    if (payload is String) {
      return payload;
    }
    return jsonEncode(payload);
  }
}
