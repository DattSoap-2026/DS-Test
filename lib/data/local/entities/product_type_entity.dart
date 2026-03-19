import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'product_type_entity.g.dart';

@Collection()
class ProductTypeEntity extends BaseEntity {
  @Index(unique: true, replace: true)
  late String name;

  String? description;
  String? iconName;
  String? color;
  List<String>? tabs;
  String? defaultUom;
  double? defaultGst;
  String? skuPrefix;
  String? displayUnit;
  late String createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'color': color,
      'tabs': tabs,
      'defaultUom': defaultUom,
      'defaultGst': defaultGst,
      'skuPrefix': skuPrefix,
      'displayUnit': displayUnit,
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

  static ProductTypeEntity fromJson(Map<String, dynamic> json) {
    return ProductTypeEntity()
      ..id = json['id']?.toString() ?? ''
      ..name = json['name']?.toString() ?? ''
      ..description = json['description']?.toString()
      ..iconName = json['iconName']?.toString()
      ..color = json['color']?.toString()
      ..tabs = (json['tabs'] as List?)?.map((item) => item.toString()).toList()
      ..defaultUom = json['defaultUom']?.toString()
      ..defaultGst = (json['defaultGst'] as num?)?.toDouble()
      ..skuPrefix = json['skuPrefix']?.toString()
      ..displayUnit = json['displayUnit']?.toString()
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
