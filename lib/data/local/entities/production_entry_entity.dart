import 'dart:convert';

import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'production_entry_entity.g.dart';

/// Represents a production item in a daily entry.
@Embedded()
class ProductionItemEntity {
  late String productId;
  late String productName;
  late String batchNumber;
  late int totalBatchQuantity;
  late String unit;
  late double costPerUnit;
  late double totalBatchCost;
  String? notes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'productId': productId,
      'productName': productName,
      'batchNumber': batchNumber,
      'totalBatchQuantity': totalBatchQuantity,
      'unit': unit,
      'costPerUnit': costPerUnit,
      'totalBatchCost': totalBatchCost,
      'notes': notes,
    };
  }

  Map<String, dynamic> toFirebaseJson() => toJson();

  static ProductionItemEntity fromJson(Map<String, dynamic> json) {
    return ProductionItemEntity()
      ..productId = parseString(json['productId'])
      ..productName = parseString(json['productName'])
      ..batchNumber = parseString(json['batchNumber'])
      ..totalBatchQuantity = parseInt(json['totalBatchQuantity'])
      ..unit = parseString(json['unit'], fallback: 'Pcs')
      ..costPerUnit = parseDouble(json['costPerUnit'])
      ..totalBatchCost = parseDouble(json['totalBatchCost'])
      ..notes = parseString(json['notes'], fallback: '');
  }

  static ProductionItemEntity fromFirebaseJson(Map<String, dynamic> json) {
    return fromJson(json);
  }
}

/// Represents a daily production supervisor entry.
@Collection()
class ProductionDailyEntryEntity extends BaseEntity {
  @Index()
  late DateTime date;

  late String departmentCode;
  late String departmentName;
  String? teamCode;
  late List<ProductionItemEntity> items;
  late String createdBy;
  late String createdByName;
  late DateTime createdAt;
  String? notes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date.toIso8601String(),
      'departmentCode': departmentCode,
      'departmentName': departmentName,
      'teamCode': teamCode,
      'items': jsonEncode(items.map((item) => item.toJson()).toList()),
      'createdBy': createdBy,
      'createdByName': createdByName,
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
      'notes': notes,
    };
  }

  Map<String, dynamic> toFirebaseJson() {
    return <String, dynamic>{
      'id': id,
      'date': date.toIso8601String(),
      'departmentCode': departmentCode,
      'departmentName': departmentName,
      'teamCode': teamCode,
      'items': items.map((item) => item.toJson()).toList(),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
      'notes': notes,
    };
  }

  static ProductionDailyEntryEntity fromJson(Map<String, dynamic> json) {
    final itemList = parseJsonList(json['items'])
        .whereType<Map>()
        .map((item) => ProductionItemEntity.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    return ProductionDailyEntryEntity()
      ..id = parseString(json['id'])
      ..date = parseDate(json['date'])
      ..departmentCode = parseString(json['departmentCode'])
      ..departmentName = parseString(json['departmentName'])
      ..teamCode = parseString(json['teamCode'], fallback: '')
      ..items = itemList
      ..createdBy = parseString(json['createdBy'])
      ..createdByName = parseString(json['createdByName'])
      ..createdAt = parseDate(json['createdAt'])
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId'])
      ..notes = parseString(json['notes'], fallback: '');
  }

  static ProductionDailyEntryEntity fromFirebaseJson(Map<String, dynamic> json) {
    return fromJson(<String, dynamic>{
      ...json,
      'items': json['items'] is String
          ? json['items']
          : jsonEncode((json['items'] as List?) ?? const <dynamic>[]),
      'syncStatus': SyncStatus.synced.name,
      'isSynced': true,
      'lastSynced': DateTime.now().toIso8601String(),
    });
  }
}
