import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'production_target_entity.g.dart';

@Collection()
class ProductionTargetEntity extends BaseEntity {
  @Index()
  late String productId;

  late String productName;

  @Index()
  late String targetDate;

  late int targetQuantity;
  late int achievedQuantity;
  late String status;
  late DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'productId': productId,
      'productName': productName,
      'targetDate': targetDate,
      'targetQuantity': targetQuantity,
      'achievedQuantity': achievedQuantity,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
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

  Map<String, dynamic> toFirebaseJson() => toJson();

  static ProductionTargetEntity fromJson(Map<String, dynamic> json) {
    return ProductionTargetEntity()
      ..id = parseString(json['id'])
      ..productId = parseString(json['productId'])
      ..productName = parseString(json['productName'])
      ..targetDate = parseString(json['targetDate'])
      ..targetQuantity = parseInt(json['targetQuantity'])
      ..achievedQuantity = parseInt(json['achievedQuantity'])
      ..status = parseString(json['status'], fallback: 'active')
      ..createdAt = parseDate(json['createdAt'])
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }

  static ProductionTargetEntity fromFirebaseJson(Map<String, dynamic> json) {
    return fromJson(<String, dynamic>{
      ...json,
      'syncStatus': SyncStatus.synced.name,
      'isSynced': true,
      'lastSynced': DateTime.now().toIso8601String(),
    });
  }
}
