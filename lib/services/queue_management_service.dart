import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/data/local/entities/alert_entity.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/models/types/alert_types.dart';
import 'package:flutter_app/utils/app_logger.dart';

class QueueManagementService {
  final DatabaseService _dbService;

  QueueManagementService(this._dbService);

  /// Check for stuck items and create alerts
  Future<void> checkStuckItems() async {
    final now = DateTime.now();
    final allItems = await _dbService.db.syncQueueEntitys.where().findAll();
    final stuckItems = allItems.where((item) {
      if (item.syncStatus != SyncStatus.pending) return false;
      final age = now.difference(item.createdAt);
      final retryCount = _getRetryCount(item);
      return age.inDays > 7 || retryCount > 20;
    }).toList();
    if (stuckItems.isNotEmpty) {
      await _createStuckItemAlert(stuckItems.length);
    }
  }

  int _getRetryCount(SyncQueueEntity item) {
    try {
      final decoded = jsonDecode(item.dataJson);
      return (decoded['_meta']?['retryCount'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _createStuckItemAlert(int count) async {
    final alertId = 'stuck_queue_${DateTime.now().millisecondsSinceEpoch}';
    
    await _dbService.db.writeTxn(() async {
      await _dbService.alerts.put(
        AlertEntity()
          ..id = alertId
          ..alertId = alertId
          ..title = 'Sync Queue Issues'
          ..message = '$count items stuck in sync queue. Admin action required.'
          ..severity = AlertSeverity.critical
          ..type = AlertType.criticalStock
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..isRead = false,
      );
    });

    AppLogger.warning('Created alert for $count stuck queue items', tag: 'Queue');
  }

  Future<List<Map<String, dynamic>>> getStuckItems() async {
    final now = DateTime.now();
    final allItems = await _dbService.db.syncQueueEntitys.where().findAll();
    final result = <Map<String, dynamic>>[];
    
    for (final item in allItems) {
      if (item.syncStatus != SyncStatus.pending) continue;
      final age = now.difference(item.createdAt);
      final retryCount = _getRetryCount(item);
      
      if (age.inDays > 7 || retryCount > 20) {
        result.add({
          'id': item.id,
          'collection': item.collection,
          'action': item.action,
          'age_days': age.inDays,
          'retry_count': retryCount,
          'created_at': item.createdAt,
          'error': _getLastError(item),
        });
      }
    }

    return result;
  }

  String? _getLastError(SyncQueueEntity item) {
    try {
      final decoded = jsonDecode(item.dataJson);
      return decoded['_meta']?['lastError']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteStuckItem(String itemId) async {
    await _dbService.db.writeTxn(() async {
      final item = _dbService.syncQueue.getByIdSync(itemId);
      if (item != null) {
        await _dbService.syncQueue.delete(item.isarId);
        AppLogger.info('Deleted stuck queue item: $itemId', tag: 'Queue');
      }
    });
  }

  Future<Map<String, int>> getPendingSummary() async {
    final allItems = await _dbService.db.syncQueueEntitys.where().findAll();

    final summary = <String, int>{};
    for (final item in allItems) {
      if (item.syncStatus != SyncStatus.pending) continue;
      summary[item.collection] = (summary[item.collection] ?? 0) + 1;
    }

    return summary;
  }
}
