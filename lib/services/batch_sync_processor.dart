import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:isar/isar.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'dart:convert';

/// Minimal Batch Sync Processor - Processes queue until empty
class BatchSyncProcessor {
  final Isar _isar;
  final firestore.FirebaseFirestore _firestore;
  static const int batchSize = 20;

  BatchSyncProcessor(this._isar, this._firestore);

  /// Process queue until empty (Outbox=0, Errors=0)
  Future<BatchSyncResult> processUntilEmpty() async {
    int totalProcessed = 0;
    int totalFailed = 0;
    final stopwatch = Stopwatch()..start();

    while (true) {
      final result = await _processBatch();
      totalProcessed += result.processed;
      totalFailed += result.failed;

      if (result.isComplete) break;
      if (result.processed == 0) break; // No progress, stop
    }

    stopwatch.stop();
    return BatchSyncResult(
      processed: totalProcessed,
      failed: totalFailed,
      durationMs: stopwatch.elapsedMilliseconds,
      isComplete: totalFailed == 0,
    );
  }

  Future<BatchSyncResult> _processBatch() async {
    final stopwatch = Stopwatch()..start();
    int processed = 0;
    int failed = 0;

    try {
      final allItems = await _isar.syncQueueEntitys.where().findAll();
      final pendingItems = allItems
          .where((item) => item.syncStatus == SyncStatus.pending)
          .take(batchSize)
          .toList();

      if (pendingItems.isEmpty) {
        return BatchSyncResult(
          processed: 0,
          failed: 0,
          durationMs: stopwatch.elapsedMilliseconds,
          isComplete: true,
        );
      }

      // Group by collection for batch writes
      final byCollection = <String, List<SyncQueueEntity>>{};
      for (final item in pendingItems) {
        byCollection.putIfAbsent(item.collection, () => []).add(item);
      }

      // Process each collection batch
      for (final entry in byCollection.entries) {
        final collection = entry.key;
        final items = entry.value;

        try {
          final batch = _firestore.batch();
          final toDelete = <Id>[];

          for (final item in items) {
            try {
              final data = jsonDecode(item.dataJson) as Map<String, dynamic>;
              final docId = data['id']?.toString();

              if (docId == null || docId.isEmpty) {
                failed++;
                continue;
              }

              final payload = Map<String, dynamic>.from(data)..remove('id');
              final docRef = _firestore.collection(collection).doc(docId);

              if (item.action == 'delete') {
                batch.set(
                  docRef,
                  {
                    'isDeleted': true,
                    'updatedAt': DateTime.now().toIso8601String(),
                  },
                  firestore.SetOptions(merge: true),
                );
              } else {
                batch.set(docRef, payload, firestore.SetOptions(merge: true));
              }

              toDelete.add(item.isarId);
            } catch (e) {
              failed++;
            }
          }

          // Commit batch
          await batch.commit();

          // Delete processed items
          await _isar.writeTxn(() async {
            for (final isarId in toDelete) {
              await _isar.syncQueueEntitys.delete(isarId);
              processed++;
            }
          });
        } catch (e) {
          failed += items.length;
        }
      }

      stopwatch.stop();
      return BatchSyncResult(
        processed: processed,
        failed: failed,
        durationMs: stopwatch.elapsedMilliseconds,
        isComplete: false,
      );
    } catch (e) {
      stopwatch.stop();
      return BatchSyncResult(
        processed: processed,
        failed: failed,
        durationMs: stopwatch.elapsedMilliseconds,
        isComplete: false,
        error: e.toString(),
      );
    }
  }
}

class BatchSyncResult {
  final int processed;
  final int failed;
  final int durationMs;
  final bool isComplete;
  final String? error;

  BatchSyncResult({
    required this.processed,
    required this.failed,
    required this.durationMs,
    required this.isComplete,
    this.error,
  });

  bool get hasErrors => failed > 0 || error != null;

  @override
  String toString() =>
      'Processed: $processed | Failed: $failed | Duration: ${durationMs}ms';
}
