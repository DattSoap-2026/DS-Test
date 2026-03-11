import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'conflict_entity.g.dart';

enum ResolutionStrategy { pending, useLocal, useServer, manualMerge }

@Collection()
class ConflictEntity extends BaseEntity {
  @Index()
  late String entityId;

  @Index()
  late String entityType;

  late String localData; // JSON
  late String serverData; // JSON

  late DateTime conflictDate;

  bool resolved = false;

  @Enumerated(EnumType.ordinal)
  ResolutionStrategy resolutionStrategy = ResolutionStrategy.pending;

  String? resolvedBy;
  DateTime? resolvedAt;

  // Domain conversion methods
  Conflict toDomain() {
    return Conflict(
      id: id,
      entityId: entityId,
      entityType: entityType,
      localData: localData,
      serverData: serverData,
      conflictDate: conflictDate,
      resolved: resolved,
      resolutionStrategy: resolutionStrategy,
      resolvedBy: resolvedBy,
      resolvedAt: resolvedAt,
      syncStatus: syncStatus,
      updatedAt: updatedAt,
    );
  }

  static ConflictEntity fromDomain(Conflict conflict) {
    return ConflictEntity()
      ..id = conflict.id
      ..entityId = conflict.entityId
      ..entityType = conflict.entityType
      ..localData = conflict.localData
      ..serverData = conflict.serverData
      ..conflictDate = conflict.conflictDate
      ..resolved = conflict.resolved
      ..resolutionStrategy = conflict.resolutionStrategy
      ..resolvedBy = conflict.resolvedBy
      ..resolvedAt = conflict.resolvedAt
      ..syncStatus = conflict.syncStatus
      ..updatedAt = conflict.updatedAt;
  }
}

class Conflict {
  final String id;
  final String entityId;
  final String entityType;
  final String localData;
  final String serverData;
  final DateTime conflictDate;
  final bool resolved;
  final ResolutionStrategy resolutionStrategy;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final SyncStatus syncStatus;
  final DateTime updatedAt;

  Conflict({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.localData,
    required this.serverData,
    required this.conflictDate,
    required this.resolved,
    this.resolutionStrategy = ResolutionStrategy.pending,
    this.resolvedBy,
    this.resolvedAt,
    required this.syncStatus,
    required this.updatedAt,
  });
}
