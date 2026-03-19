import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';
import '../../../services/bhatti_service.dart';

part 'department_stock_entity.g.dart';

@Collection()
class DepartmentStockEntity extends BaseEntity {
  @Index()
  late String departmentName;

  @Index()
  late String productId;

  late String productName;

  late double stock;

  late String unit;

  /// Converts this entity into a sync-safe json map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departmentName': departmentName,
      'productId': productId,
      'productName': productName,
      'stock': stock,
      'unit': unit,
      'syncStatus': syncStatus.name,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastModified': updatedAt.toIso8601String(),
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  Map<String, dynamic> toFirebaseJson() => toJson();

  DepartmentStock toDomain() {
    return DepartmentStock(
      id: id,
      departmentName: departmentName,
      productId: productId,
      productName: productName,
      stock: stock,
      unit: unit,
    );
  }

  static DepartmentStockEntity fromFirebaseJson(Map<String, dynamic> json) {
    return fromJson(json);
  }

  /// Builds an entity from a sync-safe json map.
  static DepartmentStockEntity fromJson(Map<String, dynamic> json) {
    return DepartmentStockEntity()
      ..id = parseString(
        json['id'],
        fallback:
            '${parseString(json['departmentName'])}_${parseString(json['productId'])}',
      )
      ..departmentName = parseString(json['departmentName'])
      ..productId = parseString(json['productId'])
      ..productName = parseString(json['productName'], fallback: 'Unknown')
      ..stock = parseDouble(json['stock'])
      ..unit = parseString(json['unit'], fallback: 'Unit')
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
