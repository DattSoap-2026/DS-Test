import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../../../services/bhatti_service.dart';

part 'bhatti_batch_entity.g.dart';

@Embedded()
class ConsumedItem {
  String? materialId;
  String? name;
  double? quantity;
  String? unit;
  double? cost;

  ConsumedItem();

  factory ConsumedItem.fromJson(Map<String, dynamic> json) {
    return ConsumedItem()
      ..materialId =
          json['materialId'] as String? ?? json['rawMaterialId'] as String?
      ..name = json['name'] as String?
      ..quantity = (json['quantity'] as num?)?.toDouble()
      ..unit = json['unit'] as String?
      ..cost = (json['cost'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'cost': cost,
    };
  }
}

@Embedded()
class TankConsumptionItem {
  String? tankId;
  String? tankName;
  String? materialId;
  double? quantity;
  List<LotConsumptionItem>? lots;

  TankConsumptionItem();

  factory TankConsumptionItem.fromJson(Map<String, dynamic> json) {
    return TankConsumptionItem()
      ..tankId = json['tankId'] as String?
      ..tankName = json['tankName'] as String?
      ..materialId = json['materialId'] as String?
      ..quantity = (json['quantity'] as num?)?.toDouble()
      ..lots = (json['lots'] as List?)
          ?.map(
            (e) => LotConsumptionItem.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'tankId': tankId,
      'tankName': tankName,
      'materialId': materialId,
      'quantity': quantity,
      'lots': lots?.map((e) => e.toJson()).toList(),
    };
  }
}

@Embedded()
class LotConsumptionItem {
  String? lotId;
  double? quantity;
  double? cost;

  LotConsumptionItem();

  factory LotConsumptionItem.fromJson(Map<String, dynamic> json) {
    return LotConsumptionItem()
      ..lotId = json['lotId'] as String?
      ..quantity = (json['quantity'] as num?)?.toDouble()
      ..cost = (json['cost'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {'lotId': lotId, 'quantity': quantity, 'cost': cost};
  }
}

@Collection()
class BhattiBatchEntity extends BaseEntity {
  @Index()
  late String bhattiName;

  @Index()
  late String batchNumber;

  @Index()
  late String targetProductId;

  late String targetProductName;

  late int batchCount;

  late int outputBoxes;

  late String supervisorId;

  late String supervisorName;

  @Index()
  late String status; // 'cooking', 'completed'

  late List<ConsumedItem> rawMaterialsConsumed;

  late List<TankConsumptionItem> tankConsumptions;

  late double totalBatchCost;

  late double costPerBox;

  String? issueId;

  late DateTime createdAt;

  Map<String, dynamic> toFirebaseJson() {
    return {
      'id': id,
      'bhattiName': bhattiName,
      'batchNumber': batchNumber,
      'targetProductId': targetProductId,
      'targetProductName': targetProductName,
      'batchCount': batchCount,
      'outputBoxes': outputBoxes,
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
      'status': status,
      'rawMaterialsConsumed': rawMaterialsConsumed
          .map((e) => e.toJson())
          .toList(),
      'tankConsumptions': tankConsumptions.map((e) => e.toJson()).toList(),
      'totalBatchCost': totalBatchCost,
      'costPerBox': costPerBox,
      'issueId': issueId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  BhattiBatch toDomain() {
    return BhattiBatch(
      id: id,
      bhattiName: bhattiName,
      batchNumber: batchNumber,
      targetProductId: targetProductId,
      targetProductName: targetProductName,
      batchCount: batchCount,
      outputBoxes: outputBoxes,
      supervisorId: supervisorId,
      supervisorName: supervisorName,
      status: status,
      rawMaterialsConsumed: rawMaterialsConsumed
          .map((e) => e.toJson())
          .toList(),
      tankConsumptions: tankConsumptions.map((e) => e.toJson()).toList(),
      totalBatchCost: totalBatchCost,
      costPerBox: costPerBox,
      issueId: issueId ?? '',
      createdAt: createdAt.toIso8601String(),
      updatedAt: updatedAt.toIso8601String(),
    );
  }

  static BhattiBatchEntity fromFirebaseJson(Map<String, dynamic> json) {
    final entity = BhattiBatchEntity()
      ..id = json['id'] as String
      ..bhattiName = json['bhattiName'] as String
      ..batchNumber = json['batchNumber'] as String
      ..targetProductId = json['targetProductId'] as String
      ..targetProductName = json['targetProductName'] as String? ?? 'Unknown'
      ..batchCount = (json['batchCount'] as num).toInt()
      ..outputBoxes = (json['outputBoxes'] as num?)?.toInt() ?? 0
      ..supervisorId = json['supervisorId'] as String
      ..supervisorName = json['supervisorName'] as String? ?? 'Unknown'
      ..status = json['status'] as String? ?? 'cooking'
      ..rawMaterialsConsumed = (json['rawMaterialsConsumed'] as List? ?? [])
          .map((e) => ConsumedItem.fromJson(Map<String, dynamic>.from(e)))
          .toList()
      ..tankConsumptions = (json['tankConsumptions'] as List? ?? [])
          .map(
            (e) => TankConsumptionItem.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList()
      ..totalBatchCost = (json['totalBatchCost'] as num?)?.toDouble() ?? 0.0
      ..costPerBox = (json['costPerBox'] as num?)?.toDouble() ?? 0.0
      ..issueId = json['issueId'] as String?
      ..createdAt = DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      )
      ..updatedAt = DateTime.parse(
        json['updatedAt'] as String? ??
            json['createdAt'] as String? ??
            DateTime.now().toIso8601String(),
      )
      ..isDeleted = json['isDeleted'] == true
      ..deletedAt = DateTime.tryParse(json['deletedAt']?.toString() ?? '');

    return entity;
  }
}
