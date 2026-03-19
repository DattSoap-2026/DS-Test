import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'entityId': entityId,
      'entityType': entityType,
      'localData': localData,
      'serverData': serverData,
      'conflictDate': conflictDate.toIso8601String(),
      'resolved': resolved,
      'resolutionStrategy': resolutionStrategy.name,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt?.toIso8601String(),
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

  static ConflictEntity fromJson(Map<String, dynamic> json) {
    return ConflictEntity()
      ..id = parseString(json['id'])
      ..entityId = parseString(json['entityId'])
      ..entityType = parseString(json['entityType'])
      ..localData = parseString(json['localData'])
      ..serverData = parseString(json['serverData'])
      ..conflictDate = parseDate(json['conflictDate'])
      ..resolved = parseBool(json['resolved'])
      ..resolutionStrategy = _parseResolutionStrategy(
        json['resolutionStrategy'],
      )
      ..resolvedBy = _nullableString(json['resolvedBy'])
      ..resolvedAt = parseDateOrNull(json['resolvedAt'])
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
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

  static ResolutionStrategy _parseResolutionStrategy(dynamic value) {
    final normalized = parseString(
      value,
      fallback: ResolutionStrategy.pending.name,
    ).trim().toLowerCase().replaceFirst('resolutionstrategy.', '');
    for (final candidate in ResolutionStrategy.values) {
      if (candidate.name.toLowerCase() == normalized) {
        return candidate;
      }
    }
    return ResolutionStrategy.pending;
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
