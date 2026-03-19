import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'category_entity.g.dart';

@Collection()
class CategoryEntity extends BaseEntity {
  @Index()
  late String name;

  @Index()
  late String itemType;

  late String createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'itemType': itemType,
      'createdAt': createdAt,
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'isSynced': isSynced,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  static CategoryEntity fromJson(Map<String, dynamic> json) {
    return CategoryEntity()
      ..id = json['id']?.toString() ?? ''
      ..name = json['name']?.toString() ?? ''
      ..itemType = json['itemType']?.toString() ?? ''
      ..createdAt =
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String()
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
