import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'inventory_location_entity.g.dart';

@Collection()
class InventoryLocationEntity extends BaseEntity {
  static const String warehouseType = 'warehouse';
  static const String departmentType = 'department';
  static const String salesmanVanType = 'salesman_van';
  static const String virtualType = 'virtual';

  @Index(caseSensitive: false)
  late String type;

  @Index(caseSensitive: false)
  late String name;

  @Index(unique: true, replace: true)
  late String code;

  @Index()
  String? parentLocationId;

  @Index()
  String? ownerUserUid;

  bool isActive = true;
  bool isPrimaryMainWarehouse = false;

  /// Converts this entity into a sync-safe json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'name': name,
      'code': code,
      'parentLocationId': parentLocationId,
      'ownerUserUid': ownerUserUid,
      'isActive': isActive,
      'isPrimaryMainWarehouse': isPrimaryMainWarehouse,
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
  static InventoryLocationEntity fromJson(Map<String, dynamic> json) {
    return InventoryLocationEntity()
      ..id = parseString(json['id'])
      ..type = parseString(json['type'])
      ..name = parseString(json['name'])
      ..code = parseString(json['code'])
      ..parentLocationId = parseString(json['parentLocationId'], fallback: '')
      ..ownerUserUid = parseString(json['ownerUserUid'], fallback: '')
      ..isActive = parseBool(json['isActive'], fallback: true)
      ..isPrimaryMainWarehouse = parseBool(
        json['isPrimaryMainWarehouse'],
      )
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
