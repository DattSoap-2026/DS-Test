import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../../../services/schemes_service.dart';

part 'scheme_entity.g.dart';

@Collection()
class SchemeEntity extends BaseEntity {
  @Index()
  late String name;

  String? description;
  late String type; // 'buy_x_get_y_free'

  @Index()
  late String status; // 'active', 'inactive'

  late DateTime validFrom;
  late DateTime validTo;

  late String buyProductId;
  late int buyQuantity;

  late String getProductId;
  late int getQuantity;

  late DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'status': status,
      'validFrom': validFrom.toIso8601String(),
      'validTo': validTo.toIso8601String(),
      'buyProductId': buyProductId,
      'buyQuantity': buyQuantity,
      'getProductId': getProductId,
      'getQuantity': getQuantity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'isSynced': isSynced,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  static SchemeEntity fromJson(Map<String, dynamic> json) {
    return SchemeEntity()
      ..id = json['id']?.toString() ?? ''
      ..name = json['name']?.toString() ?? ''
      ..description = json['description']?.toString()
      ..type = json['type']?.toString() ?? 'buy_x_get_y_free'
      ..status = json['status']?.toString() ?? 'active'
      ..validFrom =
          DateTime.tryParse(json['validFrom']?.toString() ?? '') ??
          DateTime.now()
      ..validTo =
          DateTime.tryParse(json['validTo']?.toString() ?? '') ??
          DateTime.now()
      ..buyProductId = json['buyProductId']?.toString() ?? ''
      ..buyQuantity = (json['buyQuantity'] as num? ?? 0).toInt()
      ..getProductId = json['getProductId']?.toString() ?? ''
      ..getQuantity = (json['getQuantity'] as num? ?? 0).toInt()
      ..createdAt =
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now()
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

  // Domain Mapper
  Scheme toDomain() {
    return Scheme(
      id: id,
      name: name,
      description: description ?? '',
      type: type,
      status: status,
      validFrom: validFrom.toIso8601String(),
      validTo: validTo.toIso8601String(),
      buyProductId: buyProductId,
      buyQuantity: buyQuantity,
      getProductId: getProductId,
      getQuantity: getQuantity,
      createdAt: createdAt.toIso8601String(),
    );
  }
}
