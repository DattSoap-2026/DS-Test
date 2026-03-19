import 'dart:convert';

import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'detailed_production_log_entity.g.dart';

@Embedded()
class ProductionMaterialItem {
  ProductionMaterialItem();

  late String productId;
  late String name;
  late double quantity;
  String? unit;
  late String movementType;

  factory ProductionMaterialItem.fromJson(Map<String, dynamic> json) {
    return ProductionMaterialItem()
      ..productId = parseString(json['productId'] ?? json['materialId'])
      ..name = parseString(
        json['name'] ?? json['materialName'] ?? json['productName'],
      )
      ..quantity = parseDouble(json['quantity'])
      ..unit = parseString(json['unit'], fallback: '')
      ..movementType = parseString(json['movementType'], fallback: 'out');
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'movementType': movementType,
    };
  }
}

@Collection()
class DetailedProductionLogEntity extends BaseEntity {
  @Index()
  late String batchNumber;

  @Index()
  late String productId;

  late String productName;
  late int totalBatchQuantity;
  late String unit;
  late String supervisorId;
  late String supervisorName;
  String? issueId;
  late double totalBatchCost;
  late double costPerUnit;
  late DateTime createdAt;
  late List<ProductionMaterialItem> semiFinishedGoodsUsed;
  late List<ProductionMaterialItem> packagingMaterialsUsed;
  late List<ProductionMaterialItem> additionalRawMaterialsUsed;
  ProductionMaterialItem? cuttingWastage;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'batchNumber': batchNumber,
      'productId': productId,
      'productName': productName,
      'totalBatchQuantity': totalBatchQuantity,
      'unit': unit,
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
      'issueId': issueId,
      'totalBatchCost': totalBatchCost,
      'costPerUnit': costPerUnit,
      'createdAt': createdAt.toIso8601String(),
      'semiFinishedGoodsUsed': jsonEncode(
        semiFinishedGoodsUsed.map((item) => item.toJson()).toList(),
      ),
      'packagingMaterialsUsed': jsonEncode(
        packagingMaterialsUsed.map((item) => item.toJson()).toList(),
      ),
      'additionalRawMaterialsUsed': jsonEncode(
        additionalRawMaterialsUsed.map((item) => item.toJson()).toList(),
      ),
      'cuttingWastage': cuttingWastage == null
          ? null
          : jsonEncode(cuttingWastage!.toJson()),
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

  Map<String, dynamic> toFirebaseJson() {
    return <String, dynamic>{
      'id': id,
      'batchNumber': batchNumber,
      'productId': productId,
      'productName': productName,
      'totalBatchQuantity': totalBatchQuantity,
      'unit': unit,
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
      'issueId': issueId,
      'totalBatchCost': totalBatchCost,
      'costPerUnit': costPerUnit,
      'createdAt': createdAt.toIso8601String(),
      'semiFinishedGoodsUsed': semiFinishedGoodsUsed
          .map((item) => item.toJson())
          .toList(),
      'packagingMaterialsUsed': packagingMaterialsUsed
          .map((item) => item.toJson())
          .toList(),
      'additionalRawMaterialsUsed': additionalRawMaterialsUsed
          .map((item) => item.toJson())
          .toList(),
      'cuttingWastage': cuttingWastage?.toJson(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  static DetailedProductionLogEntity fromJson(Map<String, dynamic> json) {
    final semiFinished = parseJsonList(json['semiFinishedGoodsUsed'])
        .whereType<Map>()
        .map((item) => ProductionMaterialItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    final packaging = parseJsonList(json['packagingMaterialsUsed'])
        .whereType<Map>()
        .map((item) => ProductionMaterialItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    final rawMaterials = parseJsonList(json['additionalRawMaterialsUsed'])
        .whereType<Map>()
        .map((item) => ProductionMaterialItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    final wastageJson = parseJsonMap(json['cuttingWastage']);

    return DetailedProductionLogEntity()
      ..id = parseString(json['id'])
      ..batchNumber = parseString(json['batchNumber'])
      ..productId = parseString(json['productId'])
      ..productName = parseString(json['productName'])
      ..totalBatchQuantity = parseInt(json['totalBatchQuantity'])
      ..unit = parseString(json['unit'])
      ..supervisorId = parseString(json['supervisorId'])
      ..supervisorName = parseString(json['supervisorName'])
      ..issueId = parseString(json['issueId'], fallback: '')
      ..totalBatchCost = parseDouble(json['totalBatchCost'])
      ..costPerUnit = parseDouble(json['costPerUnit'])
      ..createdAt = parseDate(json['createdAt'])
      ..semiFinishedGoodsUsed = semiFinished
      ..packagingMaterialsUsed = packaging
      ..additionalRawMaterialsUsed = rawMaterials
      ..cuttingWastage = wastageJson == null
          ? null
          : ProductionMaterialItem.fromJson(wastageJson)
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }

  static DetailedProductionLogEntity fromFirebaseJson(Map<String, dynamic> json) {
    return fromJson(<String, dynamic>{
      ...json,
      'semiFinishedGoodsUsed': json['semiFinishedGoodsUsed'] is String
          ? json['semiFinishedGoodsUsed']
          : jsonEncode((json['semiFinishedGoodsUsed'] as List?) ?? const <dynamic>[]),
      'packagingMaterialsUsed': json['packagingMaterialsUsed'] is String
          ? json['packagingMaterialsUsed']
          : jsonEncode((json['packagingMaterialsUsed'] as List?) ?? const <dynamic>[]),
      'additionalRawMaterialsUsed': json['additionalRawMaterialsUsed'] is String
          ? json['additionalRawMaterialsUsed']
          : jsonEncode((json['additionalRawMaterialsUsed'] as List?) ?? const <dynamic>[]),
      'cuttingWastage': json['cuttingWastage'] is String
          ? json['cuttingWastage']
          : jsonEncode(json['cuttingWastage']),
      'syncStatus': SyncStatus.synced.name,
      'isSynced': true,
      'lastSynced': DateTime.now().toIso8601String(),
    });
  }
}
