import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'stock_balance_entity.g.dart';

@Collection()
class StockBalanceEntity extends BaseEntity {
  static String composeId(String locationId, String productId) {
    return '${locationId.trim()}_${productId.trim()}';
  }

  @Index()
  late String locationId;

  @Index()
  late String productId;

  double quantity = 0.0;

  /// Converts this entity into a sync-safe json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'locationId': locationId,
      'productId': productId,
      'quantity': quantity,
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
  static StockBalanceEntity fromJson(Map<String, dynamic> json) {
    return StockBalanceEntity()
      ..id = parseString(
        json['id'],
        fallback: composeId(
          parseString(json['locationId']),
          parseString(json['productId']),
        ),
      )
      ..locationId = parseString(json['locationId'])
      ..productId = parseString(json['productId'])
      ..quantity = parseDouble(json['quantity'])
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
