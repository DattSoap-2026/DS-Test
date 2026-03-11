import 'package:isar/isar.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/data/local/base_entity.dart';

/// Minimal Sync Stabilization - Ensures Outbox=0, Errors=0
class SyncStabilizationService {
  final Isar _isar;

  SyncStabilizationService(this._isar);

  /// Verify sync completion
  Future<SyncCompletionStatus> verifySyncCompletion() async {
    final allItems = await _isar.syncQueueEntitys.where().findAll();

    int pending = 0;
    int conflicts = 0;

    for (final item in allItems) {
      if (item.syncStatus == SyncStatus.pending) pending++;
      if (item.syncStatus == SyncStatus.conflict) conflicts++;
    }

    final total = pending + conflicts;

    return SyncCompletionStatus(
      outboxCount: total,
      pendingCount: pending,
      errorCount: conflicts,
      isComplete: total == 0,
    );
  }

  /// Clean completed items
  Future<int> cleanCompletedItems() async {
    final allItems = await _isar.syncQueueEntitys.where().findAll();
    int deleted = 0;

    await _isar.writeTxn(() async {
      for (final item in allItems) {
        if (item.syncStatus == SyncStatus.synced) {
          await _isar.syncQueueEntitys.delete(item.isarId);
          deleted++;
        }
      }
    });

    return deleted;
  }

  /// Auto-resolve stuck items (>7 days)
  Future<int> autoResolveStuckItems() async {
    final now = DateTime.now();
    final allItems = await _isar.syncQueueEntitys.where().findAll();
    int resolved = 0;

    await _isar.writeTxn(() async {
      for (final item in allItems) {
        if (item.syncStatus != SyncStatus.pending) continue;

        final age = now.difference(item.createdAt);
        if (age.inDays >= 7) {
          await _isar.syncQueueEntitys.delete(item.isarId);
          resolved++;
        }
      }
    });

    return resolved;
  }

  /// Get pending summary
  Future<Map<String, int>> getPendingSummary() async {
    final allItems = await _isar.syncQueueEntitys.where().findAll();
    final summary = <String, int>{};

    for (final item in allItems) {
      if (item.syncStatus == SyncStatus.pending) {
        summary[item.collection] = (summary[item.collection] ?? 0) + 1;
      }
    }

    return summary;
  }
}

class SyncCompletionStatus {
  final int outboxCount;
  final int pendingCount;
  final int errorCount;
  final bool isComplete;

  SyncCompletionStatus({
    required this.outboxCount,
    required this.pendingCount,
    required this.errorCount,
    required this.isComplete,
  });

  @override
  String toString() =>
      'Outbox: $outboxCount | Pending: $pendingCount | Errors: $errorCount';
}
