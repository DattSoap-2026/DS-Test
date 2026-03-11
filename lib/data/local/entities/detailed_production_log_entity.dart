import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'detailed_production_log_entity.g.dart';

@Embedded()
class ProductionMaterialItem {
  ProductionMaterialItem();

  late String productId; // or materialId
  late String name; // materialName or productName
  late double quantity;
  late String? unit; // Optional unit
  late String movementType; // usually 'out'

  factory ProductionMaterialItem.fromJson(Map<String, dynamic> json) {
    return ProductionMaterialItem()
      ..productId = json['productId'] as String? ?? json['materialId'] as String
      ..name =
          json['name'] as String? ??
          json['materialName'] as String? ??
          json['productName'] as String
      ..quantity = (json['quantity'] as num).toDouble()
      ..unit = json['unit'] as String?
      ..movementType = json['movementType'] as String? ?? 'out';
  }

  Map<String, dynamic> toJson() {
    return {
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

  late String? issueId;

  late double totalBatchCost;

  late double costPerUnit;

  late DateTime createdAt;

  late List<ProductionMaterialItem> semiFinishedGoodsUsed;

  late List<ProductionMaterialItem> packagingMaterialsUsed;

  late List<ProductionMaterialItem> additionalRawMaterialsUsed;

  // Cutting wastage is a single item usually, but we can store it as embedded
  late ProductionMaterialItem? cuttingWastage;

  Map<String, dynamic> toFirebaseJson() {
    return {
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
      'updatedAt': updatedAt.toIso8601String(),
      'semiFinishedGoodsUsed': semiFinishedGoodsUsed
          .map((e) => e.toJson())
          .toList(),
      'packagingMaterialsUsed': packagingMaterialsUsed
          .map((e) => e.toJson())
          .toList(),
      'additionalRawMaterialsUsed': additionalRawMaterialsUsed
          .map((e) => e.toJson())
          .toList(),
      'cuttingWastage': cuttingWastage?.toJson(),
    };
  }

  static DetailedProductionLogEntity fromFirebaseJson(
    Map<String, dynamic> json,
  ) {
    return DetailedProductionLogEntity()
      ..id = json['id'] as String
      ..batchNumber = json['batchNumber'] as String
      ..productId = json['productId'] as String
      ..productName = json['productName'] as String
      ..totalBatchQuantity = (json['totalBatchQuantity'] as num).toInt()
      ..unit = json['unit'] as String? ?? ''
      ..supervisorId = json['supervisorId'] as String
      ..supervisorName = json['supervisorName'] as String
      ..issueId = json['issueId'] as String?
      ..totalBatchCost = (json['totalBatchCost'] as num?)?.toDouble() ?? 0.0
      ..costPerUnit = (json['costPerUnit'] as num?)?.toDouble() ?? 0.0
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..updatedAt = DateTime.parse(
        json['updatedAt'] as String? ?? json['createdAt'] as String,
      )
      ..semiFinishedGoodsUsed =
          (json['semiFinishedGoodsUsed'] as List?)
              ?.map(
                (e) => ProductionMaterialItem.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          []
      ..packagingMaterialsUsed =
          (json['packagingMaterialsUsed'] as List?)
              ?.map(
                (e) => ProductionMaterialItem.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          []
      ..additionalRawMaterialsUsed =
          (json['additionalRawMaterialsUsed'] as List?)
              ?.map(
                (e) => ProductionMaterialItem.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          []
      ..cuttingWastage = json['cuttingWastage'] != null
          ? ProductionMaterialItem.fromJson(
              Map<String, dynamic>.from(json['cuttingWastage']),
            )
          : null
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
  }
}
