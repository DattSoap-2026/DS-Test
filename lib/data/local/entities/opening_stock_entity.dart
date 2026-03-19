import 'package:isar/isar.dart';
import '../../../models/inventory/opening_stock_entry.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'opening_stock_entity.g.dart';

@Collection()
class OpeningStockEntity extends BaseEntity {
  @Index()
  late String productId;

  late String productType;

  @Index()
  late String warehouseId;

  late double quantity;
  late String unit;

  double? openingRate;
  String? batchNumber;

  @Index()
  late DateTime entryDate;

  late String reason; // Default: "OPENING_STOCK"

  @Index()
  late String createdBy;

  late DateTime createdAt;

  /// Converts this entity into a sync-safe json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'productId': productId,
      'productType': productType,
      'warehouseId': warehouseId,
      'quantity': quantity,
      'unit': unit,
      'openingRate': openingRate,
      'batchNumber': batchNumber,
      'entryDate': entryDate.toIso8601String(),
      'reason': reason,
      'createdBy': createdBy,
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

  /// Builds an entity from a sync-safe json map.
  static OpeningStockEntity fromJson(Map<String, dynamic> json) {
    return OpeningStockEntity()
      ..id = parseString(json['id'])
      ..productId = parseString(json['productId'])
      ..productType = parseString(json['productType'])
      ..warehouseId = parseString(json['warehouseId'])
      ..quantity = parseDouble(json['quantity'])
      ..unit = parseString(json['unit'])
      ..openingRate = json['openingRate'] == null
          ? null
          : parseDouble(json['openingRate'])
      ..batchNumber = parseString(json['batchNumber'], fallback: '')
      ..entryDate = parseDate(json['entryDate'])
      ..reason = parseString(json['reason'])
      ..createdBy = parseString(json['createdBy'])
      ..createdAt = parseDate(json['createdAt'])
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

  OpeningStockEntry toDomain() {
    return OpeningStockEntry(
      id: id,
      productId: productId,
      productType: productType,
      warehouseId: warehouseId,
      quantity: quantity,
      unit: unit,
      openingRate: openingRate,
      batchNumber: batchNumber,
      entryDate: entryDate,
      reason: reason,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  static OpeningStockEntity fromDomain(OpeningStockEntry domain) {
    return OpeningStockEntity()
      ..id = domain.id
      ..productId = domain.productId
      ..productType = domain.productType
      ..warehouseId = domain.warehouseId
      ..quantity = domain.quantity
      ..unit = domain.unit
      ..openingRate = domain.openingRate
      ..batchNumber = domain.batchNumber
      ..entryDate = domain.entryDate
      ..reason = domain.reason
      ..createdBy = domain.createdBy
      ..createdAt = domain.createdAt
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced;
  }
}
