import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'tank_transaction_entity.g.dart';

@Collection()
class TankTransactionEntity extends BaseEntity {
  @Index()
  late String tankId;

  late String tankName;
  late String type;
  late double quantity;
  late double previousStock;
  late double newStock;
  late String materialId;
  late String materialName;
  late String referenceId;
  late String referenceType;
  late String operatorId;
  late String operatorName;
  String? lotId;

  @Index()
  late DateTime timestamp;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'tankId': tankId,
      'tankName': tankName,
      'type': type,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'materialId': materialId,
      'materialName': materialName,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'lotId': lotId,
      'timestamp': timestamp.toIso8601String(),
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

  Map<String, dynamic> toDomainMap() => toJson();

  static TankTransactionEntity fromJson(Map<String, dynamic> json) {
    return TankTransactionEntity()
      ..id = parseString(json['id'])
      ..tankId = parseString(json['tankId'])
      ..tankName = parseString(json['tankName'])
      ..type = parseString(json['type'])
      ..quantity = parseDouble(json['quantity'])
      ..previousStock = parseDouble(json['previousStock'])
      ..newStock = parseDouble(json['newStock'])
      ..materialId = parseString(json['materialId'])
      ..materialName = parseString(json['materialName'])
      ..referenceId = parseString(json['referenceId'])
      ..referenceType = parseString(json['referenceType'])
      ..operatorId = parseString(json['operatorId'])
      ..operatorName = parseString(json['operatorName'])
      ..lotId = parseString(json['lotId'], fallback: '')
      ..timestamp = parseDate(
        json['timestamp'] ?? json['occurredAt'] ?? json['lastModified'],
      )
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }
}
