import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'sync_metric_entity.g.dart';

enum SyncOperation { push, pull }

@Collection()
class SyncMetricEntity extends BaseEntity {
  @Index(unique: true)
  late String metricId;

  late DateTime timestamp;

  @Index()
  late String userId;

  late String entityType;

  @Enumerated(EnumType.ordinal)
  late SyncOperation operation;

  late int recordCount;

  /// Duration in milliseconds
  late int duration;

  late bool success;

  String? errorMessage;

  late DateTime createdAt;

  // Domain conversion methods
  SyncMetric toDomain() {
    return SyncMetric(
      metricId: metricId,
      timestamp: timestamp,
      userId: userId,
      entityType: entityType,
      operation: operation,
      recordCount: recordCount,
      duration: duration,
      success: success,
      errorMessage: errorMessage,
      syncStatus: syncStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static SyncMetricEntity fromDomain(SyncMetric metric) {
    return SyncMetricEntity()
      ..id = metric.metricId
      ..metricId = metric.metricId
      ..timestamp = metric.timestamp
      ..userId = metric.userId
      ..entityType = metric.entityType
      ..operation = metric.operation
      ..recordCount = metric.recordCount
      ..duration = metric.duration
      ..success = metric.success
      ..errorMessage = metric.errorMessage
      ..syncStatus = metric.syncStatus
      ..createdAt = metric.createdAt
      ..updatedAt = metric.updatedAt;
  }
}

class SyncMetric {
  final String metricId;
  final DateTime timestamp;
  final String userId;
  final String entityType;
  final SyncOperation operation;
  final int recordCount;
  final int duration;
  final bool success;
  final String? errorMessage;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  SyncMetric({
    required this.metricId,
    required this.timestamp,
    required this.userId,
    required this.entityType,
    required this.operation,
    required this.recordCount,
    required this.duration,
    required this.success,
    this.errorMessage,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'metricId': metricId,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'entityType': entityType,
      'operation': operation.name,
      'recordCount': recordCount,
      'duration': duration,
      'success': success,
      'errorMessage': errorMessage,
      'syncStatus': syncStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SyncMetric.fromJson(Map<String, dynamic> json) {
    return SyncMetric(
      metricId: json['metricId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
      entityType: json['entityType'] as String,
      operation: SyncOperation.values.firstWhere(
        (e) => e.name == json['operation'],
      ),
      recordCount: json['recordCount'] as int,
      duration: json['duration'] as int,
      success: json['success'] as bool,
      errorMessage: json['errorMessage'] as String?,
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == json['syncStatus'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
