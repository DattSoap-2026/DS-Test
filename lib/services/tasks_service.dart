import 'package:isar/isar.dart';
import '../models/types/task_types.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import '../data/local/entities/task_entity.dart';
import 'base_service.dart';
import 'database_service.dart';
import 'outbox_codec.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'notification_service.dart';

const String tasksCollection = 'tasks';

class TasksService extends BaseService {
  final DatabaseService _dbService;

  TasksService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

  Future<String> _enqueueOutbox(
    Map<String, dynamic> payload, {
    required String action,
  }) async {
    final queueId = OutboxCodec.buildQueueId(
      tasksCollection,
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
      ..collection = tasksCollection
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
      throw Exception('Task payload missing id for action: $action');
    }

    final docRef = firestore.collection(tasksCollection).doc(id);
    final remotePayload = Map<String, dynamic>.from(payload)..remove('id');

    switch (action) {
      case 'add':
      case 'set':
      case 'update':
        await docRef.set(remotePayload, SetOptions(merge: true));
        return;
      case 'delete':
        await docRef.delete();
        return;
      default:
        throw Exception('Unsupported task write action: $action');
    }
  }

  Future<void> _queueTaskWrite({
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final normalizedPayload = Map<String, dynamic>.from(payload);

    // Save locally first
    final isDeleted = normalizedPayload['isDeleted'] == true;
    final id = normalizedPayload['id'] as String?;
    if (id != null) {
      await _dbService.db.writeTxn(() async {
        if (isDeleted) {
          final isarId = fastHash(id);
          await _dbService.tasks.delete(isarId);
        } else {
          // It's an update/set, fetch existing to merge if necessary, or just create new
          final existing = await _dbService.tasks.get(fastHash(id));

          final task = Task.fromJson({
            if (existing != null) ...existing.toTask().toJson(),
            ...normalizedPayload,
          });

          final entity = TaskEntity.fromTask(task);
          await _dbService.tasks.put(entity);
        }
      });
    }

    // Queue for sync
    final queueId = await _enqueueOutbox(normalizedPayload, action: action);

    final firestore = db;
    if (firestore == null) return;

    try {
      await _performImmediateWrite(firestore, action, normalizedPayload);
      await _dequeueOutbox(queueId);
    } catch (_) {
      // Keep durable outbox entry for SyncManager retry.
    }
  }

  // Get all tasks (one-time pull locally)
  Future<List<Task>> getAllTasks() async {
    try {
      final taskEntities = await _dbService.tasks
          .where()
          .filter()
          .isDeletedEqualTo(false) // Filter by entity's isDeleted property
          .findAll();

      final tasks = taskEntities.map((e) => e.toTask()).toList();
      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      return tasks;
    } catch (e) {
      handleError(e, 'getAllTasks');
      return [];
    }
  }

  // Get tasks for a specific user locally
  Future<List<Task>> getTasksForUser(String userId) async {
    try {
      final taskEntities = await _dbService.tasks
          .where()
          .filter()
          .assignedToIdEqualTo(userId)
          .and()
          .isDeletedEqualTo(false)
          .findAll();

      final tasks = taskEntities.map((e) => e.toTask()).toList();
      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      return tasks;
    } catch (e) {
      handleError(e, 'getTasksForUser');
      return [];
    }
  }

  // Create task
  Future<String?> createTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required String dueDate,
    required TaskUser createdBy,
    required TaskUser assignedTo,
    bool isBlocking = false,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final taskId = const Uuid().v4();
      final taskData = {
        'id': taskId,
        'title': title.trim(),
        'description': description.trim(),
        'priority': priority.value,
        'status': TaskStatus.assigned.value,
        'dueDate': dueDate,
        'createdBy': createdBy.toJson(),
        'assignedTo': assignedTo.toJson(),
        'isBlocking': isBlocking,
        'isDeleted': false,
        'createdAt': now,
        'updatedAt': now,
      };

      await _queueTaskWrite(action: 'set', payload: taskData);

      await NotificationService().publishNotificationEvent(
        title: 'New Task Assigned',
        body: '${createdBy.name} assigned: ${title.trim()}',
        eventType: 'task_assigned',
        targetUserIds: {assignedTo.id},
        data: {
          'taskId': taskId,
          'status': TaskStatus.assigned.value,
          'priority': priority.value,
        },
        route: '/dashboard/tasks',
        forceSound: true,
      );
      await markNotificationSent(taskId);
      return taskId;
    } catch (e) {
      handleError(e, 'createTask');
      return null;
    }
  }

  // Update task
  Future<bool> updateTask({
    required String id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    String? dueDate,
    TaskUser? assignedTo,
  }) async {
    try {
      final updates = <String, dynamic>{
        'id': id,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (title != null) updates['title'] = title.trim();
      if (description != null) updates['description'] = description.trim();
      if (priority != null) updates['priority'] = priority.value;
      if (status != null) updates['status'] = status.value;
      if (dueDate != null) updates['dueDate'] = dueDate;
      if (assignedTo != null) updates['assignedTo'] = assignedTo.toJson();

      String? notifyUserId = assignedTo?.id;
      String? notifyUserName = assignedTo?.name;

      // Need to retrieve before writing updates in case we need old values
      TaskEntity? oldTask;
      if ((notifyUserId == null || notifyUserId.isEmpty) &&
          (status != null || title != null || description != null)) {
        oldTask = await _dbService.tasks.get(fastHash(id));
        if (oldTask != null) {
          notifyUserId = oldTask.assignedToId;
          notifyUserName = oldTask.assignedToName;
        }
      }

      await _queueTaskWrite(action: 'update', payload: updates);

      if (notifyUserId != null && notifyUserId.trim().isNotEmpty) {
        final statusLabel = status?.value;
        final eventType = assignedTo != null
            ? 'task_reassigned'
            : 'task_updated';
        final titleText = assignedTo != null ? 'Task Assigned' : 'Task Updated';
        final bodyText = assignedTo != null
            ? 'Task assigned to ${notifyUserName ?? 'you'}'
            : 'Task status updated${statusLabel != null ? ': $statusLabel' : ''}';

        await NotificationService().publishNotificationEvent(
          title: titleText,
          body: bodyText,
          eventType: eventType,
          targetUserIds: {notifyUserId.trim()},
          data: {'taskId': id, if (statusLabel != null) 'status': statusLabel},
          route: '/dashboard/tasks',
          forceSound: true,
        );
      }
      return true;
    } catch (e) {
      handleError(e, 'updateTask');
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String id) async {
    try {
      await _queueTaskWrite(
        action: 'update',
        payload: {
          'id': id,
          'isDeleted': true,
          'deletedAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      return true;
    } catch (e) {
      handleError(e, 'deleteTask');
      return false;
    }
  }

  // Get single task directly from Isar
  Future<Task?> getTask(String id) async {
    try {
      final isarId = fastHash(id);
      final taskEntity = await _dbService.tasks.get(isarId);

      if (taskEntity == null || taskEntity.isDeleted == true) {
        return null;
      }

      return taskEntity.toTask();
    } catch (e) {
      handleError(e, 'getTask');
      return null;
    }
  }

  // Real-time stream for all tasks (now purely from Isar)
  Stream<List<Task>> getTasksStream() async* {
    yield await getAllTasks(); // emit initial data quickly

    await for (final _ in _dbService.tasks.watchLazy()) {
      yield await getAllTasks();
    }
  }

  // Real-time stream for tasks assigned to a specific user (purely from Isar)
  Stream<List<Task>> getTasksForUserStream(String userId) async* {
    if (userId.trim().isEmpty) {
      yield const <Task>[];
      return;
    }

    yield await getTasksForUser(userId);

    await for (final _ in _dbService.tasks.watchLazy()) {
      yield await getTasksForUser(userId);
    }
  }

  // Get unread task count for a user (for badge)
  Stream<int> getUnreadTaskCount(String userId) async* {
    if (userId.trim().isEmpty) {
      yield 0;
      return;
    }

    Future<int> fetchUnreadCount() async {
      return await _dbService.tasks
          .where()
          .filter()
          .assignedToIdEqualTo(userId)
          .and()
          .statusEqualTo(TaskStatus.assigned.value)
          .and()
          .isDeletedEqualTo(false) // Filter logically deleted
          .count();
    }

    yield await fetchUnreadCount();

    await for (final _ in _dbService.tasks.watchLazy()) {
      yield await fetchUnreadCount();
    }
  }

  // Mark task as viewed (changes status from assigned to viewed)
  Future<bool> markTaskAsViewed(String taskId) async {
    try {
      await _queueTaskWrite(
        action: 'update',
        payload: {
          'id': taskId,
          'status': TaskStatus.viewed.value,
          'viewedAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      return true;
    } catch (e) {
      handleError(e, 'markTaskAsViewed');
      return false;
    }
  }

  // Mark notification as sent
  Future<bool> markNotificationSent(String taskId) async {
    try {
      await _queueTaskWrite(
        action: 'update',
        payload: {
          'id': taskId,
          'notificationSent': true,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      return true;
    } catch (e) {
      handleError(e, 'markNotificationSent');
      return false;
    }
  }

  // Mark notification as read
  Future<bool> markNotificationRead(String taskId) async {
    try {
      await _queueTaskWrite(
        action: 'update',
        payload: {
          'id': taskId,
          'notificationReadAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      return true;
    } catch (e) {
      handleError(e, 'markNotificationRead');
      return false;
    }
  }

  // Get active blocking tasks for a user (for TaskGuard) locally
  Stream<List<Task>> getBlockingTasksStream(String userId) async* {
    if (userId.trim().isEmpty) {
      yield const <Task>[];
      return;
    }

    Future<List<Task>> fetchBlockingTasks() async {
      final taskEntities = await _dbService.tasks
          .where()
          .filter()
          .assignedToIdEqualTo(userId)
          .and()
          .isBlockingEqualTo(true)
          .and()
          .isDeletedEqualTo(false)
          .findAll();

      return taskEntities
          .map((e) => e.toTask())
          .where((task) => task.isActivelyBlocking)
          .toList();
    }

    yield await fetchBlockingTasks();

    await for (final _ in _dbService.tasks.watchLazy()) {
      yield await fetchBlockingTasks();
    }
  }
}
