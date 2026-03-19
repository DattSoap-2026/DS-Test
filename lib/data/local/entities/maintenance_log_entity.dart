import 'dart:convert';

import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'maintenance_log_entity.g.dart';

@Collection()
class MaintenanceLogEntity extends BaseEntity {
  @Index()
  late String vehicleId;
  late String vehicleNumber;
  late DateTime serviceDate;
  DateTime? nextServiceDate;

  double? odometerReading;
  String? mechanicName;

  late String vendor;
  late String description;
  late String type; // 'Regular', 'Breakdown', 'Repair'

  double totalCost = 0;
  double? labourCost;
  double? partsCost;

  String? billNumber;
  String? paymentMode;

  List<String>? attachments;

  // Embedded Items
  List<MaintenanceItemEntity>? items;

  late String createdAt;

  Map<String, dynamic> toJson() {
    final serializedItems =
        items?.map((item) => item.toJson()).toList(growable: false) ??
        const <Map<String, dynamic>>[];
    return {
      'id': id,
      'vehicleId': vehicleId,
      'vehicleNumber': vehicleNumber,
      'serviceDate': serviceDate.toIso8601String(),
      'nextServiceDate': nextServiceDate?.toIso8601String(),
      'odometerReading': odometerReading,
      'mechanicName': mechanicName,
      'vendor': vendor,
      'description': description,
      'type': type,
      'totalCost': totalCost,
      'labourCost': labourCost,
      'partsCost': partsCost,
      'billNumber': billNumber,
      'paymentMode': paymentMode,
      'attachments': jsonEncode(attachments ?? const <String>[]),
      'items': jsonEncode(serializedItems),
      'createdAt': createdAt,
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

  static MaintenanceLogEntity fromJson(Map<String, dynamic> json) {
    return MaintenanceLogEntity()
      ..id = parseString(json['id'])
      ..vehicleId = parseString(json['vehicleId'])
      ..vehicleNumber = parseString(json['vehicleNumber'])
      ..serviceDate = parseDate(json['serviceDate'])
      ..nextServiceDate = parseDateOrNull(json['nextServiceDate'])
      ..odometerReading = json['odometerReading'] == null
          ? null
          : parseDouble(json['odometerReading'])
      ..mechanicName = json['mechanicName']?.toString()
      ..vendor = parseString(json['vendor'])
      ..description = parseString(json['description'])
      ..type = parseString(json['type'])
      ..totalCost = parseDouble(json['totalCost'])
      ..labourCost = json['labourCost'] == null
          ? null
          : parseDouble(json['labourCost'])
      ..partsCost = json['partsCost'] == null
          ? null
          : parseDouble(json['partsCost'])
      ..billNumber = json['billNumber']?.toString()
      ..paymentMode = json['paymentMode']?.toString()
      ..attachments = parseStringList(json['attachments']) ?? const <String>[]
      ..items = parseMapList(json['items'])
          .map(MaintenanceItemEntity.fromJson)
          .toList(growable: false)
      ..createdAt = parseString(
        json['createdAt'],
        fallback: DateTime.now().toIso8601String(),
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

@Embedded()
class MaintenanceItemEntity {
  String? partName;
  String? description;
  double quantity = 0;
  double price = 0;

  Map<String, dynamic> toJson() {
    return {
      'partName': partName,
      'description': description,
      'quantity': quantity,
      'price': price,
    };
  }

  static MaintenanceItemEntity fromJson(Map<String, dynamic> json) {
    return MaintenanceItemEntity()
      ..partName = json['partName']?.toString()
      ..description = json['description']?.toString()
      ..quantity = parseDouble(json['quantity'])
      ..price = parseDouble(json['price']);
  }
}
