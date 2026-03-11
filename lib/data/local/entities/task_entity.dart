import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../../../models/types/task_types.dart';

part 'task_entity.g.dart';

@collection
class TaskEntity extends BaseEntity {
  @Index()
  String? title;

  String? description;

  @Index()
  String? status;

  @Index()
  String? priority;

  @Index()
  String? dueDate;

  @Index()
  String? assignedToId;
  String? assignedToName;

  String? createdById;
  String? createdByName;

  @Index()
  bool? isBlocking;

  String? viewedAt;
  bool? notificationSent;
  String? notificationReadAt;

  String? createdAtStr;

  Task toTask() {
    return Task(
      id: id,
      title: title ?? '',
      description: description ?? '',
      priority: TaskPriority.fromString(priority ?? 'Medium'),
      status: TaskStatus.fromString(status ?? 'Assigned'),
      dueDate: dueDate ?? '',
      createdBy: TaskUser(id: createdById ?? '', name: createdByName ?? ''),
      assignedTo: TaskUser(id: assignedToId ?? '', name: assignedToName ?? ''),
      isBlocking: isBlocking ?? false,
      createdAt: createdAtStr ?? updatedAt.toIso8601String(),
      updatedAt: updatedAt.toIso8601String(),
      viewedAt: viewedAt,
      notificationSent: notificationSent ?? false,
      notificationReadAt: notificationReadAt,
    );
  }

  static TaskEntity fromTask(Task task) {
    return TaskEntity()
      ..id = task.id
      ..title = task.title
      ..description = task.description
      ..priority = task.priority.value
      ..status = task.status.value
      ..dueDate = task.dueDate
      ..createdById = task.createdBy.id
      ..createdByName = task.createdBy.name
      ..assignedToId = task.assignedTo.id
      ..assignedToName = task.assignedTo.name
      ..isBlocking = task.isBlocking
      ..viewedAt = task.viewedAt
      ..notificationSent = task.notificationSent
      ..notificationReadAt = task.notificationReadAt
      ..createdAtStr = task.createdAt
      ..updatedAt = DateTime.tryParse(task.updatedAt) ?? DateTime.now()
      ..isDeleted = false;
  }
}
