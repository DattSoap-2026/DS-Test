// Task Management Types

enum TaskPriority {
  low,
  medium,
  high;

  String get value {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  static TaskPriority fromString(String value) {
    switch (value) {
      case 'Low':
        return TaskPriority.low;
      case 'Medium':
        return TaskPriority.medium;
      case 'High':
        return TaskPriority.high;
      default:
        throw ArgumentError('Invalid TaskPriority: $value');
    }
  }
}

enum TaskStatus {
  assigned,
  viewed,
  inProgress,
  completed;

  String get value {
    switch (this) {
      case TaskStatus.assigned:
        return 'Assigned';
      case TaskStatus.viewed:
        return 'Viewed';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  static TaskStatus fromString(String value) {
    switch (value) {
      case 'Assigned':
        return TaskStatus.assigned;
      case 'Viewed':
        return TaskStatus.viewed;
      case 'In Progress':
        return TaskStatus.inProgress;
      case 'Completed':
        return TaskStatus.completed;
      // Legacy support for old status values
      case 'To Do':
        return TaskStatus.assigned;
      case 'Done':
        return TaskStatus.completed;
      default:
        throw ArgumentError('Invalid TaskStatus: $value');
    }
  }

  // Helper to check if task is unread
  bool get isUnread => this == TaskStatus.assigned;
}

class TaskUser {
  final String id;
  final String name;

  TaskUser({required this.id, required this.name});

  factory TaskUser.fromJson(Map<String, dynamic> json) {
    return TaskUser(id: json['id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final String dueDate;
  final String createdAt;
  final String updatedAt;
  final TaskUser createdBy;
  final TaskUser assignedTo;
  final String? viewedAt;
  final bool notificationSent;
  final String? notificationReadAt;
  final bool isBlocking;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.assignedTo,
    this.viewedAt,
    this.notificationSent = false,
    this.notificationReadAt,
    this.isBlocking = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: TaskPriority.fromString(json['priority'] ?? 'Medium'),
      status: TaskStatus.fromString(json['status'] ?? 'Assigned'),
      dueDate: json['dueDate'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      createdBy: TaskUser.fromJson(json['createdBy'] ?? {'id': '', 'name': ''}),
      assignedTo: TaskUser.fromJson(
        json['assignedTo'] ?? {'id': '', 'name': ''},
      ),
      viewedAt: json['viewedAt'],
      notificationSent: json['notificationSent'] ?? false,
      notificationReadAt: json['notificationReadAt'],
      isBlocking: json['isBlocking'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.value,
      'status': status.value,
      'dueDate': dueDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy.toJson(),
      'assignedTo': assignedTo.toJson(),
      'viewedAt': viewedAt,
      'notificationSent': notificationSent,
      'notificationReadAt': notificationReadAt,
      'isBlocking': isBlocking,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    String? dueDate,
    String? createdAt,
    String? updatedAt,
    TaskUser? createdBy,
    TaskUser? assignedTo,
    String? viewedAt,
    bool? notificationSent,
    String? notificationReadAt,
    bool? isBlocking,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      viewedAt: viewedAt ?? this.viewedAt,
      notificationSent: notificationSent ?? this.notificationSent,
      notificationReadAt: notificationReadAt ?? this.notificationReadAt,
      isBlocking: isBlocking ?? this.isBlocking,
    );
  }

  // Helper to check if task is unread for current user
  bool isUnreadFor(String userId) {
    return assignedTo.id == userId && status == TaskStatus.assigned;
  }

  // Helper to mark task as viewed
  Task markAsViewed() {
    if (status == TaskStatus.assigned) {
      return copyWith(
        status: TaskStatus.viewed,
        viewedAt: DateTime.now().toIso8601String(),
      );
    }
    return this;
  }

  // Helper to check if task is currently blocking user navigation
  bool get isActivelyBlocking => isBlocking && status != TaskStatus.completed;
}
