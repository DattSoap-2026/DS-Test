import 'package:flutter/foundation.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

class SyncAnalyticsService {
  final DatabaseService _dbService;
  final _uuid = const Uuid();

  SyncAnalyticsService(this._dbService);

  /// Records a single sync operation metric
  Future<void> recordSyncMetric({
    required String userId,
    required String entityType,
    required SyncOperation operation,
    required int recordCount,
    required int durationMs,
    required bool success,
    String? errorMessage,
  }) async {
    try {
      final metric = SyncMetric(
        metricId: _uuid.v4(),
        timestamp: DateTime.now(),
        userId: userId,
        entityType: entityType,
        operation: operation,
        recordCount: recordCount,
        duration: durationMs,
        success: success,
        errorMessage: errorMessage,
        syncStatus:
            SyncStatus.synced, // System metrics don't need cloud sync usually
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _dbService.db.writeTxn(() async {
        await _dbService.syncMetrics.put(SyncMetricEntity.fromDomain(metric));
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error recording sync metric: $e');
      }
    }
  }

  /// Gets aggregated stats for a date range
  Future<Map<String, dynamic>> getSyncSummary(
    DateTime start,
    DateTime end,
  ) async {
    final metrics = await _dbService.syncMetrics
        .filter()
        .timestampBetween(start, end)
        .findAll();

    int totalPush = 0;
    int totalPull = 0;
    int successCount = 0;
    int failureCount = 0;
    int totalRecords = 0;
    double totalDuration = 0;

    for (final m in metrics) {
      if (m.operation == SyncOperation.push) {
        totalPush++;
      } else {
        totalPull++;
      }

      if (m.success) {
        successCount++;
      } else {
        failureCount++;
      }

      totalRecords += m.recordCount;
      totalDuration += m.duration;
    }

    return {
      'totalOperations': metrics.length,
      'totalPush': totalPush,
      'totalPull': totalPull,
      'successRate': metrics.isEmpty
          ? 0.0
          : (successCount / metrics.length) * 100,
      'failureCount': failureCount,
      'totalRecordsSynced': totalRecords,
      'avgDurationMs': metrics.isEmpty
          ? 0
          : (totalDuration / metrics.length).round(),
      'metrics': metrics,
    };
  }

  /// Gets failed sync operations
  Future<List<SyncMetricEntity>> getRecentFailures({int limit = 20}) async {
    return await _dbService.syncMetrics
        .filter()
        .successEqualTo(false)
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
  }

  /// Aggregates sync counts by entity type
  Future<Map<String, int>> getSyncCountByEntity(
    DateTime start,
    DateTime end,
  ) async {
    final metrics = await _dbService.syncMetrics
        .filter()
        .timestampBetween(start, end)
        .findAll();

    final counts = <String, int>{};
    for (final m in metrics) {
      counts[m.entityType] = (counts[m.entityType] ?? 0) + 1;
    }
    return counts;
  }

  /// Cleans up old metrics (e.g., older than 30 days)
  Future<void> cleanupOldMetrics({int daysToKeep = 30}) async {
    final cutOff = DateTime.now().subtract(Duration(days: daysToKeep));
    await _dbService.db.writeTxn(() async {
      await _dbService.syncMetrics
          .filter()
          .timestampLessThan(cutOff)
          .deleteAll();
    });
  }
}
