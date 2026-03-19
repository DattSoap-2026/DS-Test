import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'inventory_command_entity.g.dart';

@Collection()
class InventoryCommandEntity extends BaseEntity {
  @Index(unique: true, replace: true)
  String get commandId => id;
  set commandId(String value) => id = value;

  @Index(caseSensitive: false)
  late String commandType;

  late String payload;

  @Index()
  late String actorUid;

  String? actorLegacyAppUserId;

  late DateTime createdAt;

  bool appliedLocally = false;
  bool appliedRemotely = false;
  String? retryMeta;

  /// Converts this entity into a sync-safe json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'commandId': commandId,
      'commandType': commandType,
      'payload': payload,
      'actorUid': actorUid,
      'actorLegacyAppUserId': actorLegacyAppUserId,
      'createdAt': createdAt.toIso8601String(),
      'appliedLocally': appliedLocally,
      'appliedRemotely': appliedRemotely,
      'retryMeta': retryMeta,
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

  /// Builds an entity from a sync-safe json map.
  static InventoryCommandEntity fromJson(Map<String, dynamic> json) {
    return InventoryCommandEntity()
      ..id = parseString(json['id'] ?? json['commandId'])
      ..commandType = parseString(json['commandType'])
      ..payload = parseString(json['payload'], fallback: '{}')
      ..actorUid = parseString(json['actorUid'])
      ..actorLegacyAppUserId = parseString(
        json['actorLegacyAppUserId'],
        fallback: '',
      )
      ..createdAt = parseDate(json['createdAt'])
      ..appliedLocally = parseBool(json['appliedLocally'])
      ..appliedRemotely = parseBool(json['appliedRemotely'])
      ..retryMeta = parseString(json['retryMeta'], fallback: '')
      ..updatedAt = parseDate(
        json['updatedAt'] ?? json['lastModified'],
      )
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId'], fallback: '');
  }
}
