import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'custom_role_entity.g.dart';

@Collection()
class CustomRoleEntity extends BaseEntity {
  @Index()
  late String name;

  String? description;

  late String permissionsJson;

  late bool isActive;

  late DateTime createdAt;

  String? createdBy;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissionsJson': permissionsJson,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'isSynced': isSynced,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  static CustomRoleEntity fromJson(Map<String, dynamic> json) {
    return CustomRoleEntity()
      ..id = json['id']?.toString() ?? ''
      ..name = json['name']?.toString() ?? ''
      ..description = json['description']?.toString()
      ..permissionsJson = json['permissionsJson']?.toString() ?? '[]'
      ..isActive = json['isActive'] != false
      ..createdAt =
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now()
      ..createdBy = json['createdBy']?.toString()
      ..updatedAt =
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now()
      ..deletedAt = DateTime.tryParse(json['deletedAt']?.toString() ?? '')
      ..isDeleted = json['isDeleted'] == true
      ..isSynced = json['isSynced'] == true
      ..lastSynced = DateTime.tryParse(json['lastSynced']?.toString() ?? '')
      ..version = (json['version'] as num? ?? 1).toInt()
      ..deviceId = json['deviceId']?.toString() ?? '';
  }
}
