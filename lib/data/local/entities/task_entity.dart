import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';
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
  DateTime? dueDate;

  @Index()
  String? assignedToId;
  String? assignedToName;

  String? createdById;
  String? createdByName;

  @Index()
  bool isBlocking = false;

  DateTime? viewedAt;
  bool notificationSent = false;
  DateTime? notificationReadAt;

  DateTime? createdAt;
  String? createdAtStr;

  Task toTask() {
    final createdTimestamp =
        createdAt?.toIso8601String() ?? createdAtStr ?? updatedAt.toIso8601String();
    return Task(
      id: id,
      title: title ?? '',
      description: description ?? '',
      priority: TaskPriority.fromString(priority ?? 'Medium'),
      status: TaskStatus.fromString(status ?? 'Assigned'),
      dueDate: _formatDateOnly(dueDate),
      createdBy: TaskUser(id: createdById ?? '', name: createdByName ?? ''),
      assignedTo: TaskUser(id: assignedToId ?? '', name: assignedToName ?? ''),
      isBlocking: isBlocking,
      createdAt: createdTimestamp,
      updatedAt: updatedAt.toIso8601String(),
      viewedAt: viewedAt?.toIso8601String(),
      notificationSent: notificationSent,
      notificationReadAt: notificationReadAt?.toIso8601String(),
    );
  }

  static TaskEntity fromTask(Task task) {
    final createdAt = parseDateOrNull(task.createdAt);
    return TaskEntity()
      ..id = task.id
      ..title = task.title
      ..description = task.description
      ..priority = task.priority.value
      ..status = task.status.value
      ..dueDate = parseDateOrNull(task.dueDate)
      ..createdById = task.createdBy.id
      ..createdByName = task.createdBy.name
      ..assignedToId = task.assignedTo.id
      ..assignedToName = task.assignedTo.name
      ..isBlocking = task.isBlocking
      ..viewedAt = parseDateOrNull(task.viewedAt)
      ..notificationSent = task.notificationSent
      ..notificationReadAt = parseDateOrNull(task.notificationReadAt)
      ..createdAt = createdAt
      ..createdAtStr = createdAt?.toIso8601String() ?? task.createdAt
      ..updatedAt = DateTime.tryParse(task.updatedAt) ?? DateTime.now()
      ..isDeleted = false;
  }

  Map<String, dynamic> toJson() {
    final createdTimestamp =
        createdAt?.toIso8601String() ??
        parseDateOrNull(createdAtStr)?.toIso8601String();
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
      'createdById': createdById,
      'createdByName': createdByName,
      'createdBy': <String, dynamic>{
        'id': createdById ?? '',
        'name': createdByName ?? '',
      },
      'assignedTo': <String, dynamic>{
        'id': assignedToId ?? '',
        'name': assignedToName ?? '',
      },
      'isBlocking': isBlocking,
      'viewedAt': viewedAt?.toIso8601String(),
      'notificationSent': notificationSent,
      'notificationReadAt': notificationReadAt?.toIso8601String(),
      'createdAt': createdTimestamp,
      'createdAtStr': createdTimestamp,
      'updatedAt': updatedAt.toIso8601String(),
      'lastModified': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus.name,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  static TaskEntity fromJson(Map<String, dynamic> json) {
    final createdAt = parseDateOrNull(json['createdAt'] ?? json['createdAtStr']);
    final createdBy = parseJsonMap(json['createdBy']);
    final assignedTo = parseJsonMap(json['assignedTo']);

    return TaskEntity()
      ..id = parseString(json['id'])
      ..title = _nullableString(json['title'])
      ..description = _nullableString(json['description'])
      ..status = _nullableString(json['status'])
      ..priority = _nullableString(json['priority'])
      ..dueDate = parseDateOrNull(json['dueDate'])
      ..assignedToId = _nullableString(
        json['assignedToId'] ?? assignedTo?['id'],
      )
      ..assignedToName = _nullableString(
        json['assignedToName'] ?? assignedTo?['name'],
      )
      ..createdById = _nullableString(
        json['createdById'] ?? createdBy?['id'],
      )
      ..createdByName = _nullableString(
        json['createdByName'] ?? createdBy?['name'],
      )
      ..isBlocking = parseBool(json['isBlocking'])
      ..viewedAt = parseDateOrNull(json['viewedAt'])
      ..notificationSent = parseBool(json['notificationSent'])
      ..notificationReadAt = parseDateOrNull(json['notificationReadAt'])
      ..createdAt = createdAt
      ..createdAtStr = createdAt?.toIso8601String()
      ..updatedAt = parseDate(
        json['updatedAt'] ?? json['lastModified'] ?? json['createdAt'],
      )
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }

  static String? _nullableString(dynamic value) {
    final normalized = parseString(value).trim();
    return normalized.isEmpty ? null : normalized;
  }

  static String _formatDateOnly(DateTime? value) {
    if (value == null) {
      return '';
    }
    return DateTime(value.year, value.month, value.day)
        .toIso8601String()
        .split('T')
        .first;
  }
}
