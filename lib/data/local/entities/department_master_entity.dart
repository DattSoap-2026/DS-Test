import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'department_master_entity.g.dart';

@Collection()
class DepartmentMasterEntity extends BaseEntity {
  late String departmentId;

  @Index(unique: true, replace: true)
  late String departmentCode;

  @Index(caseSensitive: false)
  late String departmentName;

  @Index(caseSensitive: false)
  late String departmentType;

  String? sourceWarehouseId;
  bool isProductionDepartment = true;
  bool isActive = true;

  /// Converts this entity into a sync-safe json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'departmentId': departmentId,
      'departmentCode': departmentCode,
      'departmentName': departmentName,
      'departmentType': departmentType,
      'sourceWarehouseId': sourceWarehouseId,
      'isProductionDepartment': isProductionDepartment,
      'isActive': isActive,
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
  static DepartmentMasterEntity fromJson(Map<String, dynamic> json) {
    return DepartmentMasterEntity()
      ..id = parseString(json['id'])
      ..departmentId = parseString(json['departmentId'])
      ..departmentCode = parseString(json['departmentCode'])
      ..departmentName = parseString(json['departmentName'])
      ..departmentType = parseString(json['departmentType'])
      ..sourceWarehouseId = parseString(json['sourceWarehouseId'], fallback: '')
      ..isProductionDepartment = parseBool(
        json['isProductionDepartment'],
        fallback: true,
      )
      ..isActive = parseBool(json['isActive'], fallback: true)
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
