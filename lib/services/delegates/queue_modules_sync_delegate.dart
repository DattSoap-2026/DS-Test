import 'package:isar/isar.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/utils/app_logger.dart';

class QueueModulesSyncDelegate {
  final DatabaseService _dbService;

  QueueModulesSyncDelegate({required DatabaseService dbService})
    : _dbService = dbService;

  static const Set<String> _queueOnlyCollections = <String>{
    'approvals',
    'schemes',
    'purchase_orders',
    'formulas',
    'tasks',
    'task_history',
    'settings',
    'public_settings',
  };

  Future<void> orchestrateQueueOnlyModules() async {
    final queueCollections = _queueOnlyCollections.toList(growable: false);
    final queueItems = await _dbService.syncQueue
        .filter()
        .anyOf(
          queueCollections,
          (q, String collection) => q.collectionEqualTo(collection),
        )
        .findAll();
    final pendingByCollection = <String, int>{};
    for (final item in queueItems) {
      final collection = item.collection;
      if (!_queueOnlyCollections.contains(collection)) {
        continue;
      }
      pendingByCollection[collection] = (pendingByCollection[collection] ?? 0) + 1;
    }

    if (pendingByCollection.isEmpty) {
      AppLogger.info('Queue-only modules orchestration: no pending items.', tag: 'Sync');
      return;
    }

    final parts = pendingByCollection.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .toList(growable: false);
    AppLogger.info(
      'Queue-only modules orchestration: pending ${parts.join(', ')}',
      tag: 'Sync',
    );
  }
}
