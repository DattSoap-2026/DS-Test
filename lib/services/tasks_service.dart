import '../data/local/entities/task_entity.dart';
import '../data/repositories/task_repository.dart';
import '../models/types/task_types.dart';
import 'base_service.dart';
import 'database_service.dart';

class TasksService extends BaseService {
  TasksService(
    super.firebase, [
    DatabaseService? dbService,
    TaskRepository? taskRepository,
  ]) : _dbService = dbService ?? DatabaseService.instance,
       _taskRepository =
           taskRepository ??
           TaskRepository(dbService ?? DatabaseService.instance);

  final DatabaseService _dbService;
  final TaskRepository _taskRepository;

  Future<List<Task>> getAllTasks() async {
    try {
      final taskEntities = await _taskRepository.getAllTasks();
      return taskEntities.map((entity) => entity.toTask()).toList(growable: false);
    } catch (e) {
      handleError(e, 'getAllTasks');
      return [];
    }
  }

  Future<List<Task>> getTasksForUser(String userId) async {
    try {
      final taskEntities = await _taskRepository.getTasksByAssignee(userId);
      return taskEntities.map((entity) => entity.toTask()).toList(growable: false);
    } catch (e) {
      handleError(e, 'getTasksForUser');
      return [];
    }
  }

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
      final now = DateTime.now();
      final task = TaskEntity()
        ..title = title.trim()
        ..description = description.trim()
        ..priority = priority.value
        ..status = TaskStatus.assigned.value
        ..dueDate = DateTime.tryParse(dueDate)
        ..createdById = createdBy.id.trim()
        ..createdByName = createdBy.name.trim()
        ..assignedToId = assignedTo.id.trim()
        ..assignedToName = assignedTo.name.trim()
        ..isBlocking = isBlocking
        ..createdAt = now
        ..createdAtStr = now.toIso8601String()
        ..updatedAt = now
        ..notificationSent = false;

      await _taskRepository.saveTask(task);
      return task.id;
    } catch (e) {
      handleError(e, 'createTask');
      return null;
    }
  }

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
      final task = await _loadTaskEntity(id);
      if (task == null) {
        return false;
      }

      if (title != null) {
        task.title = title.trim();
      }
      if (description != null) {
        task.description = description.trim();
      }
      if (priority != null) {
        task.priority = priority.value;
      }
      if (status != null) {
        task.status = status.value;
      }
      if (dueDate != null) {
        task.dueDate = DateTime.tryParse(dueDate);
      }
      if (assignedTo != null) {
        task.assignedToId = assignedTo.id.trim();
        task.assignedToName = assignedTo.name.trim();
      }

      await _taskRepository.saveTask(task);
      return true;
    } catch (e) {
      handleError(e, 'updateTask');
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      await _taskRepository.deleteTask(id);
      return true;
    } catch (e) {
      handleError(e, 'deleteTask');
      return false;
    }
  }

  Future<Task?> getTask(String id) async {
    try {
      final taskEntity = await _loadTaskEntity(id);
      if (taskEntity == null || taskEntity.isDeleted) {
        return null;
      }
      return taskEntity.toTask();
    } catch (e) {
      handleError(e, 'getTask');
      return null;
    }
  }

  Stream<List<Task>> getTasksStream() {
    return _taskRepository.watchAllTasks().map(
      (tasks) => tasks.map((entity) => entity.toTask()).toList(growable: false),
    );
  }

  Stream<List<Task>> getTasksForUserStream(String userId) {
    if (userId.trim().isEmpty) {
      return Stream<List<Task>>.value(const <Task>[]);
    }

    return _taskRepository.watchTasksByAssignee(userId).map(
      (tasks) => tasks.map((entity) => entity.toTask()).toList(growable: false),
    );
  }

  Stream<int> getUnreadTaskCount(String userId) {
    if (userId.trim().isEmpty) {
      return Stream<int>.value(0);
    }

    return _taskRepository.watchTasksByAssignee(userId).map((tasks) {
      return tasks.where((task) => _statusKey(task.status) == 'assigned').length;
    });
  }

  Future<bool> markTaskAsViewed(String taskId) async {
    try {
      await _taskRepository.markTaskViewed(taskId);
      return true;
    } catch (e) {
      handleError(e, 'markTaskAsViewed');
      return false;
    }
  }

  Future<bool> markNotificationSent(String taskId) async {
    try {
      final task = await _loadTaskEntity(taskId);
      if (task == null) {
        return false;
      }

      task.notificationSent = true;
      await _taskRepository.saveTask(task);
      return true;
    } catch (e) {
      handleError(e, 'markNotificationSent');
      return false;
    }
  }

  Future<bool> markNotificationRead(String taskId) async {
    try {
      final task = await _loadTaskEntity(taskId);
      if (task == null) {
        return false;
      }

      task.notificationReadAt = DateTime.now();
      await _taskRepository.saveTask(task);
      return true;
    } catch (e) {
      handleError(e, 'markNotificationRead');
      return false;
    }
  }

  Stream<List<Task>> getBlockingTasksStream(String userId) {
    if (userId.trim().isEmpty) {
      return Stream<List<Task>>.value(const <Task>[]);
    }

    return _taskRepository.watchTasksByAssignee(userId).map((tasks) {
      return tasks
          .where(
            (task) => task.isBlocking && _statusKey(task.status) != 'completed',
          )
          .map((entity) => entity.toTask())
          .toList(growable: false);
    });
  }

  Future<TaskEntity?> _loadTaskEntity(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      return null;
    }
    return _dbService.tasks.getById(normalizedId);
  }

  String _statusKey(String? value) {
    return (value ?? '').trim().toLowerCase();
  }
}
