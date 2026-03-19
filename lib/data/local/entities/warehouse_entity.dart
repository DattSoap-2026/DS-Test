import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'warehouse_entity.g.dart';

@Collection()
class WarehouseEntity extends BaseEntity {
  @Index(unique: true, replace: true)
  String get firebaseId => id;
  set firebaseId(String value) => id = value;

  @Index()
  late String name;

  @Index(unique: true, replace: true)
  late String code;

  @Index()
  String type = 'main';

  String? address;
  String? managerId;
  String? managerName;
  bool isActive = true;
  bool isPrimary = false;
  String? notes;
  DateTime? createdAt;
  String? createdBy;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'name': name,
      'code': code,
      'type': type,
      'address': address,
      'managerId': managerId,
      'managerName': managerName,
      'isActive': isActive,
      'isPrimary': isPrimary,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'isSynced': isSynced,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
      'syncStatus': syncStatus.name,
    };
  }

  static WarehouseEntity fromJson(Map<String, dynamic> json) {
    return WarehouseEntity()
      ..id = parseString(json['id'])
      ..name = parseString(json['name'])
      ..code = parseString(json['code'])
      ..type = parseString(json['type'], fallback: 'main')
      ..address = json['address']?.toString()
      ..managerId = json['managerId']?.toString()
      ..managerName = json['managerName']?.toString()
      ..isActive = json['isActive'] == true
      ..isPrimary = json['isPrimary'] == true
      ..notes = json['notes']?.toString()
      ..createdAt = parseDateOrNull(json['createdAt'])
      ..createdBy = json['createdBy']?.toString()
      ..updatedAt = parseDate(json['updatedAt'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..isDeleted = json['isDeleted'] == true
      ..isSynced = json['isSynced'] == true
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId'])
      ..syncStatus = parseSyncStatus(json['syncStatus']);
  }
}
