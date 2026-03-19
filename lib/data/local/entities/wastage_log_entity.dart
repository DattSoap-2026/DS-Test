import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'wastage_log_entity.g.dart';

@Collection()
class WastageLogEntity extends BaseEntity {
  @Index()
  late String returnedTo;

  @Index()
  late String productId;

  late String productName;
  late double quantity;
  late String unit;
  late String reason;
  late String reportedBy;
  late DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'returnedTo': returnedTo,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'reason': reason,
      'reportedBy': reportedBy,
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

  static WastageLogEntity fromJson(Map<String, dynamic> json) {
    return WastageLogEntity()
      ..id = parseString(json['id'])
      ..returnedTo = parseString(json['returnedTo'])
      ..productId = parseString(json['productId'])
      ..productName = parseString(json['productName'])
      ..quantity = parseDouble(json['quantity'])
      ..unit = parseString(json['unit'], fallback: 'Unit')
      ..reason = parseString(json['reason'])
      ..reportedBy = parseString(json['reportedBy'])
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

  static WastageLogEntity fromFirebaseJson(Map<String, dynamic> json) {
    return fromJson(<String, dynamic>{
      ...json,
      'syncStatus': SyncStatus.synced.name,
      'isSynced': true,
      'lastSynced': DateTime.now().toIso8601String(),
    });
  }
}
