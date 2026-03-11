import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import 'base_service.dart';
import 'database_service.dart';
import 'outbox_codec.dart';

const taskHistoryCollection = 'task_history';

class TaskHistoryEntry {
  final String id;
  final String taskId;
  final String taskTitle;
  final String fromStatus;
  final String toStatus;
  final String changedById;
  final String changedByName;
  final String timestamp;

  TaskHistoryEntry({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.fromStatus,
    required this.toStatus,
    required this.changedById,
    required this.changedByName,
    required this.timestamp,
  });

  factory TaskHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TaskHistoryEntry(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      taskTitle: json['taskTitle'] as String,
      fromStatus: json['fromStatus'] as String,
      toStatus: json['toStatus'] as String,
      changedById: (json['changedBy'] as Map<String, dynamic>)['id'] as String,
      changedByName:
          (json['changedBy'] as Map<String, dynamic>)['name'] as String,
      timestamp: json['timestamp'] as String,
    );
  }
}

class AddTaskHistoryPayload {
  final String taskId;
  final String taskTitle;
  final String fromStatus;
  final String toStatus;

  AddTaskHistoryPayload({
    required this.taskId,
    required this.taskTitle,
    required this.fromStatus,
    required this.toStatus,
  });
}

class TaskHistoryService extends BaseService {
  final DatabaseService _dbService;

  TaskHistoryService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

  Future<String> _enqueueOutbox(
    Map<String, dynamic> payload, {
    required String action,
  }) async {
    final queueId = OutboxCodec.buildQueueId(
      taskHistoryCollection,
      payload,
      explicitRecordKey: payload['id']?.toString(),
    );
    final existing = await _dbService.syncQueue.getById(queueId);
    final now = DateTime.now();
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;

    final queueEntity = SyncQueueEntity()
      ..id = queueId
      ..collection = taskHistoryCollection
      ..action = action
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: payload,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: true,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.put(queueEntity);
    });
    return queueId;
  }

  Future<void> _dequeueOutbox(String queueId) async {
    final existing = await _dbService.syncQueue.getById(queueId);
    if (existing == null) return;
    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.delete(existing.isarId);
    });
  }

  Future<void> _performImmediateWrite(
    FirebaseFirestore firestore,
    String action,
    Map<String, dynamic> payload,
  ) async {
    final id = payload['id']?.toString();
    if (id == null || id.trim().isEmpty) {
      throw Exception('Task history payload missing id for action: $action');
    }
    final remotePayload = Map<String, dynamic>.from(payload)..remove('id');
    await firestore
        .collection(taskHistoryCollection)
        .doc(id)
        .set(remotePayload, SetOptions(merge: true));
  }

  Future<bool> addTaskHistory(AddTaskHistoryPayload payload) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final firestore = db;
      final entryData = <String, dynamic>{
        'id': 'task_history_${DateTime.now().microsecondsSinceEpoch}',
        'taskId': payload.taskId,
        'taskTitle': payload.taskTitle,
        'fromStatus': payload.fromStatus,
        'toStatus': payload.toStatus,
        'changedBy': {'id': user.uid, 'name': user.displayName ?? 'Unknown'},
        'timestamp': DateTime.now().toIso8601String(),
      };

      final queueId = await _enqueueOutbox(entryData, action: 'set');
      if (firestore != null) {
        try {
          await _performImmediateWrite(firestore, 'set', entryData);
          await _dequeueOutbox(queueId);
        } catch (_) {
          // Keep queued outbox entry for retry.
        }
      }

      return true;
    } catch (e) {
      handleError(e, 'addTaskHistory');
      return false;
    }
  }

  Future<List<TaskHistoryEntry>> getTaskHistory({
    String? taskId,
    int? limit,
  }) async {
    try {
      final firestore = db;
      if (firestore == null) return [];

      Query<Map<String, dynamic>> q = firestore
          .collection(taskHistoryCollection)
          .orderBy('timestamp', descending: true);

      if (taskId != null) {
        q = q.where('taskId', isEqualTo: taskId);
      }

      if (limit != null) {
        q = q.limit(limit);
      }

      final snapshot = await q.get();
      return snapshot.docs
          .map(
            (doc) => TaskHistoryEntry.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      handleError(e, 'getTaskHistory');
      return [];
    }
  }
}
