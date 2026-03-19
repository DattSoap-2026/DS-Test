import 'dart:async';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../services/database_service.dart';
import '../local/base_entity.dart';
import '../local/entities/task_entity.dart';

class TaskRepository {
  TaskRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService =
           connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  static const Uuid _uuid = Uuid();

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  Future<void> saveTask(TaskEntity task) async {
    final id = _ensureId(task);
    final existing = await _dbService.tasks.getById(id);
    final createdAt =
        existing?.createdAt ?? task.createdAt ?? _parseCreatedAt(task);

    task
      ..id = id
      ..title = _normalizeText(task.title, fallback: 'Untitled Task')
      ..description = _nullableText(task.description)
      ..status = _normalizeStatus(task.status)
      ..priority = _normalizePriority(task.priority)
      ..assignedToId = _nullableText(task.assignedToId)
      ..assignedToName = _nullableText(task.assignedToName)
      ..createdById = _nullableText(task.createdById)
      ..createdByName = _nullableText(task.createdByName)
      ..createdAt = createdAt
      ..createdAtStr = createdAt.toIso8601String();

    await _saveEntity(
      entity: task,
      existing: existing,
      collectionName: CollectionRegistry.tasks,
      payload: task.toJson(),
      persist: () async {
        await _dbService.tasks.put(task);
      },
    );
  }

  Future<List<TaskEntity>> getAllTasks() async {
    final tasks = await _dbService.tasks
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortTasks(tasks);
  }

  Future<List<TaskEntity>> getTasksByAssignee(String assignedToId) async {
    final tasks = await _dbService.tasks
        .filter()
        .assignedToIdEqualTo(assignedToId.trim())
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortTasks(tasks);
  }

  Future<List<TaskEntity>> getTasksByCreator(String createdById) async {
    final tasks = await _dbService.tasks
        .filter()
        .createdByIdEqualTo(createdById.trim())
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortTasks(tasks);
  }

  Future<List<TaskEntity>> getPendingTasks(String userId) async {
    final tasks = await getTasksByAssignee(userId);
    return tasks
        .where((task) => !_isCompleted(task.status))
        .toList(growable: false);
  }

  Future<List<TaskEntity>> getBlockingTasks() async {
    final tasks = await _dbService.tasks
        .filter()
        .isBlockingEqualTo(true)
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortTasks(
      tasks.where((task) => !_isCompleted(task.status)).toList(growable: false),
    );
  }

  Future<List<TaskEntity>> getOverdueTasks() async {
    final now = DateTime.now();
    final tasks = await _dbService.tasks
        .filter()
        .dueDateLessThan(now)
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortTasks(
      tasks.where((task) => !_isCompleted(task.status)).toList(growable: false),
    );
  }

  Stream<List<TaskEntity>> watchTasksByAssignee(String userId) {
    return _dbService.tasks
        .filter()
        .assignedToIdEqualTo(userId.trim())
        .and()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map(_sortTasks);
  }

  Stream<List<TaskEntity>> watchAllTasks() {
    return _dbService.tasks
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map(_sortTasks);
  }

  Future<void> completeTask(String id) async {
    final task = await _findTask(id);
    if (task == null || task.isDeleted) {
      return;
    }

    task.status = 'Completed';
    await _saveEntity(
      entity: task,
      existing: task,
      collectionName: CollectionRegistry.tasks,
      payload: task.toJson(),
      persist: () async {
        await _dbService.tasks.put(task);
      },
    );
  }

  Future<void> markTaskViewed(String id) async {
    final task = await _findTask(id);
    if (task == null || task.isDeleted) {
      return;
    }

    task.viewedAt = DateTime.now();
    if (_statusKey(task.status) == 'assigned') {
      task.status = 'Viewed';
    }

    await _saveEntity(
      entity: task,
      existing: task,
      collectionName: CollectionRegistry.tasks,
      payload: task.toJson(),
      persist: () async {
        await _dbService.tasks.put(task);
      },
    );
  }

  Future<void> deleteTask(String id) async {
    final task = await _findTask(id);
    if (task == null || task.isDeleted) {
      return;
    }

    await _softDeleteEntity(
      entity: task,
      collectionName: CollectionRegistry.tasks,
      payloadBuilder: task.toJson,
      persist: () async {
        await _dbService.tasks.put(task);
      },
    );
  }

  Future<TaskEntity?> _findTask(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      return null;
    }
    final byId = await _dbService.tasks.getById(normalizedId);
    if (byId != null) {
      return byId;
    }
    return _dbService.tasks
        .filter()
        .idEqualTo(normalizedId)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<void> _saveEntity({
    required BaseEntity entity,
    required BaseEntity? existing,
    required String collectionName,
    required Map<String, dynamic> payload,
    required Future<void> Function() persist,
  }) async {
    final deviceId = await _deviceIdService.getDeviceId();
    final now = DateTime.now();
    _applySyncStamp(entity, existing: existing, deviceId: deviceId, now: now);
    await _dbService.db.writeTxn(() async {
      await persist();
    });
    await _enqueue(
      collectionName,
      entity.id,
      existing == null ? 'create' : 'update',
      payload,
    );
    await _syncIfOnline();
  }

  Future<void> _softDeleteEntity({
    required BaseEntity entity,
    required String collectionName,
    required Map<String, dynamic> Function() payloadBuilder,
    required Future<void> Function() persist,
  }) async {
    entity
      ..isDeleted = true
      ..deletedAt = DateTime.now();

    final deviceId = await _deviceIdService.getDeviceId();
    _applyDeletedStamp(entity, deviceId: deviceId, now: DateTime.now());
    await _dbService.db.writeTxn(() async {
      await persist();
    });
    await _enqueue(collectionName, entity.id, 'delete', payloadBuilder());
    await _syncIfOnline();
  }

  void _applySyncStamp(
    BaseEntity entity, {
    required BaseEntity? existing,
    required String deviceId,
    required DateTime now,
  }) {
    entity
      ..updatedAt = now
      ..deletedAt = entity.isDeleted ? entity.deletedAt : null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = deviceId;
  }

  void _applyDeletedStamp(
    BaseEntity entity, {
    required String deviceId,
    required DateTime now,
  }) {
    entity
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = deviceId;
  }

  Future<void> _enqueue(
    String collectionName,
    String documentId,
    String operation,
    Map<String, dynamic> payload,
  ) {
    return _syncQueueService.addToQueue(
      collectionName: collectionName,
      documentId: documentId,
      operation: operation,
      payload: payload,
    );
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  String _ensureId(BaseEntity entity) {
    final current = entity.id.trim();
    if (current.isNotEmpty) {
      return current;
    }
    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
  }

  DateTime _parseCreatedAt(TaskEntity task) {
    return task.createdAt ??
        DateTime.tryParse(task.createdAtStr ?? '') ??
        DateTime.now();
  }

  String _normalizeText(String? value, {String fallback = ''}) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? fallback : normalized;
  }

  String? _nullableText(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  String _normalizeStatus(String? value) {
    final normalized = _statusKey(value);
    switch (normalized) {
      case 'completed':
        return 'Completed';
      case 'viewed':
        return 'Viewed';
      case 'in progress':
      case 'inprogress':
        return 'In Progress';
      case 'assigned':
      default:
        return 'Assigned';
    }
  }

  String _normalizePriority(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    switch (normalized) {
      case 'low':
        return 'Low';
      case 'high':
        return 'High';
      case 'medium':
      default:
        return 'Medium';
    }
  }

  String _statusKey(String? value) {
    return (value ?? '').trim().toLowerCase();
  }

  bool _isCompleted(String? value) {
    return _statusKey(value) == 'completed';
  }

  List<TaskEntity> _sortTasks(List<TaskEntity> tasks) {
    tasks.sort((left, right) {
      final leftDue = left.dueDate;
      final rightDue = right.dueDate;
      if (leftDue == null && rightDue == null) {
        final leftCreated = left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final rightCreated =
            right.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return rightCreated.compareTo(leftCreated);
      }
      if (leftDue == null) {
        return 1;
      }
      if (rightDue == null) {
        return -1;
      }
      final dueCompare = leftDue.compareTo(rightDue);
      if (dueCompare != 0) {
        return dueCompare;
      }
      final leftCreated = left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final rightCreated =
          right.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return rightCreated.compareTo(leftCreated);
    });
    return tasks;
  }
}
