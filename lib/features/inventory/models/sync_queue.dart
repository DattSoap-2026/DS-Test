import 'package:isar/isar.dart';

part 'sync_queue.g.dart';

/// Durable outbox record for pending sync operations.
@Collection()
class SyncQueue {
  SyncQueue();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String get queueKey => '$collectionName::$documentId';

  late String collectionName;
  late String documentId;
  late String operation;
  late String payload;
  int retryCount = 0;
  int maxRetries = 5;
  DateTime createdAt = DateTime.now();
  DateTime? lastAttemptAt;
  bool isFailed = false;

  /// Returns a copy with updated values.
  SyncQueue copyWith({
    Id? id,
    String? collectionName,
    String? documentId,
    String? operation,
    String? payload,
    int? retryCount,
    int? maxRetries,
    DateTime? createdAt,
    DateTime? lastAttemptAt,
    bool? isFailed,
  }) {
    return SyncQueue()
      ..id = id ?? this.id
      ..collectionName = collectionName ?? this.collectionName
      ..documentId = documentId ?? this.documentId
      ..operation = operation ?? this.operation
      ..payload = payload ?? this.payload
      ..retryCount = retryCount ?? this.retryCount
      ..maxRetries = maxRetries ?? this.maxRetries
      ..createdAt = createdAt ?? this.createdAt
      ..lastAttemptAt = lastAttemptAt ?? this.lastAttemptAt
      ..isFailed = isFailed ?? this.isFailed;
  }
}
