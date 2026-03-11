import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/sync_stabilization_service.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:isar/isar.dart';

void main() {
  late Isar isar;
  late SyncStabilizationService service;

  setUp(() async {
    isar = await Isar.open(
      [SyncQueueEntitySchema],
      directory: '',
      name: 'test_sync_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    service = SyncStabilizationService(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('Sync Completion Verification', () {
    test('Empty queue returns complete status', () async {
      final status = await service.verifySyncCompletion();

      expect(status.isComplete, true);
      expect(status.outboxCount, 0);
      expect(status.errorCount, 0);
    });

    test('Pending items show in outbox count', () async {
      await isar.writeTxn(() async {
        await isar.syncQueueEntitys.put(
          SyncQueueEntity()
            ..id = 'test_1'
            ..collection = 'sales'
            ..action = 'add'
            ..dataJson = '{}'
            ..syncStatus = SyncStatus.pending
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
        );
      });

      final status = await service.verifySyncCompletion();

      expect(status.isComplete, false);
      expect(status.outboxCount, 1);
      expect(status.pendingCount, 1);
    });

    test('Conflict items show in error count', () async {
      await isar.writeTxn(() async {
        await isar.syncQueueEntitys.put(
          SyncQueueEntity()
            ..id = 'test_conflict'
            ..collection = 'sales'
            ..action = 'add'
            ..dataJson = '{}'
            ..syncStatus = SyncStatus.conflict
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
        );
      });

      final status = await service.verifySyncCompletion();

      expect(status.isComplete, false);
      expect(status.errorCount, 1);
    });
  });

  group('Cleanup Operations', () {
    test('Cleans completed items', () async {
      await isar.writeTxn(() async {
        await isar.syncQueueEntitys.put(
          SyncQueueEntity()
            ..id = 'completed_1'
            ..collection = 'sales'
            ..action = 'add'
            ..dataJson = '{}'
            ..syncStatus = SyncStatus.synced
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
        );
      });

      final deleted = await service.cleanCompletedItems();

      expect(deleted, 1);
      
      final remaining = await isar.syncQueueEntitys.count();
      expect(remaining, 0);
    });

    test('Auto-resolves stuck items (>7 days)', () async {
      final oldDate = DateTime.now().subtract(Duration(days: 8));
      
      await isar.writeTxn(() async {
        await isar.syncQueueEntitys.put(
          SyncQueueEntity()
            ..id = 'stuck_1'
            ..collection = 'sales'
            ..action = 'add'
            ..dataJson = '{}'
            ..syncStatus = SyncStatus.pending
            ..createdAt = oldDate
            ..updatedAt = oldDate,
        );
      });

      final resolved = await service.autoResolveStuckItems();

      expect(resolved, 1);
      
      final remaining = await isar.syncQueueEntitys.count();
      expect(remaining, 0);
    });

    test('Does not delete recent pending items', () async {
      await isar.writeTxn(() async {
        await isar.syncQueueEntitys.put(
          SyncQueueEntity()
            ..id = 'recent_1'
            ..collection = 'sales'
            ..action = 'add'
            ..dataJson = '{}'
            ..syncStatus = SyncStatus.pending
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
        );
      });

      final resolved = await service.autoResolveStuckItems();

      expect(resolved, 0);
      
      final remaining = await isar.syncQueueEntitys.count();
      expect(remaining, 1);
    });
  });

  group('Pending Summary', () {
    test('Groups pending items by collection', () async {
      await isar.writeTxn(() async {
        await isar.syncQueueEntitys.putAll([
          SyncQueueEntity()
            ..id = 'sales_1'
            ..collection = 'sales'
            ..action = 'add'
            ..dataJson = '{}'
            ..syncStatus = SyncStatus.pending
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
          SyncQueueEntity()
            ..id = 'sales_2'
            ..collection = 'sales'
            ..action = 'add'
            ..dataJson = '{}'
            ..syncStatus = SyncStatus.pending
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
          SyncQueueEntity()
            ..id = 'dispatch_1'
            ..collection = 'dispatches'
            ..action = 'add'
            ..dataJson = '{}'
            ..syncStatus = SyncStatus.pending
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
        ]);
      });

      final summary = await service.getPendingSummary();

      expect(summary['sales'], 2);
      expect(summary['dispatches'], 1);
    });
  });
}
