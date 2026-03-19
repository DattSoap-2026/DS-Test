import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/sync/collection_registry.dart';
import '../../../data/local/entities/alert_entity.dart';
import '../../../data/local/entities/conflict_entity.dart';
import '../../../data/local/entities/task_entity.dart';
import '../../../data/repositories/alerts_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../services/database_service.dart';

export '../../../data/repositories/alerts_repository.dart';
export '../../../data/repositories/task_repository.dart';

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepository(
    DatabaseService.instance,
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(
    DatabaseService.instance,
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

final unreadAlertsProvider = StreamProvider<List<AlertEntity>>((ref) {
  return ref.watch(alertsRepositoryProvider).watchUnreadAlerts();
});

final allAlertsProvider = StreamProvider<List<AlertEntity>>((ref) {
  return ref.watch(alertsRepositoryProvider).watchAllAlerts();
});

final unresolvedConflictsProvider = StreamProvider<List<ConflictEntity>>((ref) {
  return ref.watch(alertsRepositoryProvider).watchUnresolvedConflicts();
});

final pendingTasksProvider =
    StreamProvider.family<List<TaskEntity>, String>((ref, userId) {
      return ref.watch(taskRepositoryProvider).watchTasksByAssignee(userId).map(
        (tasks) => tasks
            .where(
              (task) => (task.status ?? '').trim().toLowerCase() != 'completed',
            )
            .toList(growable: false),
      );
    });

final blockingTasksProvider = StreamProvider<List<TaskEntity>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAllTasks().map(
    (tasks) => tasks
        .where(
          (task) =>
              task.isBlocking &&
              (task.status ?? '').trim().toLowerCase() != 'completed',
        )
        .toList(growable: false),
  );
});

final overdueTasksProvider = StreamProvider<List<TaskEntity>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAllTasks().map((tasks) {
    final now = DateTime.now();
    return tasks
        .where(
          (task) =>
              task.dueDate != null &&
              task.dueDate!.isBefore(now) &&
              (task.status ?? '').trim().toLowerCase() != 'completed',
        )
        .toList(growable: false);
  });
});

final pendingAlertsSyncCountProvider = FutureProvider<int>((ref) async {
  final queueService = ref.read(syncQueueServiceProvider);
  var total = 0;
  for (final collection in <String>[
    CollectionRegistry.alerts,
    CollectionRegistry.tasks,
    CollectionRegistry.syncMetrics,
  ]) {
    total += await queueService.getPendingCount(collectionName: collection);
  }
  return total;
});
