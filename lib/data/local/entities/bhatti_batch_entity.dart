import 'dart:convert';

import 'package:isar/isar.dart';

import '../../../services/bhatti_service.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

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
      ..materialId = parseString(
        json['materialId'] ?? json['rawMaterialId'],
        fallback: '',
      )
      ..name = parseString(json['name'], fallback: '')
      ..quantity = parseDouble(json['quantity'])
      ..unit = parseString(json['unit'], fallback: '')
      ..cost = parseDouble(json['cost']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
      ..tankId = parseString(json['tankId'], fallback: '')
      ..tankName = parseString(json['tankName'], fallback: '')
      ..materialId = parseString(json['materialId'], fallback: '')
      ..quantity = parseDouble(json['quantity'])
      ..lots = parseJsonList(json['lots'])
          .whereType<Map>()
          .map((item) => LotConsumptionItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'tankId': tankId,
      'tankName': tankName,
      'materialId': materialId,
      'quantity': quantity,
      'lots': lots?.map((item) => item.toJson()).toList(),
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
      ..lotId = parseString(json['lotId'], fallback: '')
      ..quantity = parseDouble(json['quantity'])
      ..cost = parseDouble(json['cost']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'lotId': lotId,
      'quantity': quantity,
      'cost': cost,
    };
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
  late String status;

  late List<ConsumedItem> rawMaterialsConsumed;
  late List<TankConsumptionItem> tankConsumptions;
  late double totalBatchCost;
  late double costPerBox;
  String? issueId;
  late DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
      'rawMaterialsConsumed': jsonEncode(
        rawMaterialsConsumed.map((item) => item.toJson()).toList(),
      ),
      'tankConsumptions': jsonEncode(
        tankConsumptions.map((item) => item.toJson()).toList(),
      ),
      'totalBatchCost': totalBatchCost,
      'costPerBox': costPerBox,
      'issueId': issueId,
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

  Map<String, dynamic> toFirebaseJson() {
    return <String, dynamic>{
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
          .map((item) => item.toJson())
          .toList(),
      'tankConsumptions': tankConsumptions
          .map((item) => item.toJson())
          .toList(),
      'totalBatchCost': totalBatchCost,
      'costPerBox': costPerBox,
      'issueId': issueId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
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
          .map((item) => item.toJson())
          .toList(),
      tankConsumptions: tankConsumptions.map((item) => item.toJson()).toList(),
      totalBatchCost: totalBatchCost,
      costPerBox: costPerBox,
      issueId: issueId ?? '',
      createdAt: createdAt.toIso8601String(),
      updatedAt: updatedAt.toIso8601String(),
    );
  }

  static BhattiBatchEntity fromJson(Map<String, dynamic> json) {
    return BhattiBatchEntity()
      ..id = parseString(json['id'])
      ..bhattiName = parseString(json['bhattiName'])
      ..batchNumber = parseString(json['batchNumber'])
      ..targetProductId = parseString(json['targetProductId'])
      ..targetProductName = parseString(json['targetProductName'])
      ..batchCount = parseInt(json['batchCount'])
      ..outputBoxes = parseInt(json['outputBoxes'])
      ..supervisorId = parseString(json['supervisorId'])
      ..supervisorName = parseString(json['supervisorName'])
      ..status = parseString(json['status'], fallback: 'cooking')
      ..rawMaterialsConsumed = parseJsonList(json['rawMaterialsConsumed'])
          .whereType<Map>()
          .map((item) => ConsumedItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false)
      ..tankConsumptions = parseJsonList(json['tankConsumptions'])
          .whereType<Map>()
          .map((item) => TankConsumptionItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false)
      ..totalBatchCost = parseDouble(json['totalBatchCost'])
      ..costPerBox = parseDouble(json['costPerBox'])
      ..issueId = parseString(json['issueId'], fallback: '')
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

  static BhattiBatchEntity fromFirebaseJson(Map<String, dynamic> json) {
    return fromJson(<String, dynamic>{
      ...json,
      'rawMaterialsConsumed': json['rawMaterialsConsumed'] is String
          ? json['rawMaterialsConsumed']
          : jsonEncode((json['rawMaterialsConsumed'] as List?) ?? const <dynamic>[]),
      'tankConsumptions': json['tankConsumptions'] is String
          ? json['tankConsumptions']
          : jsonEncode((json['tankConsumptions'] as List?) ?? const <dynamic>[]),
      'syncStatus': SyncStatus.synced.name,
      'isSynced': true,
      'lastSynced': DateTime.now().toIso8601String(),
    });
  }
}
