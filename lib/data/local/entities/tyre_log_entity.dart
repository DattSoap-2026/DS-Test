import 'dart:convert';

import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'tyre_log_entity.g.dart';

@Collection()
class TyreLogEntity extends BaseEntity {
  @Index()
  late String vehicleId;
  late String vehicleNumber;
  late DateTime installationDate;
  late String reason;

  double totalCost = 0;

  List<TyreLogItemEntity>? items;

  late String createdAt;

  Map<String, dynamic> toJson() {
    final serializedItems =
        items?.map((item) => item.toJson()).toList(growable: false) ??
        const <Map<String, dynamic>>[];
    return {
      'id': id,
      'vehicleId': vehicleId,
      'vehicleNumber': vehicleNumber,
      'installationDate': installationDate.toIso8601String(),
      'reason': reason,
      'totalCost': totalCost,
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

  static TyreLogEntity fromJson(Map<String, dynamic> json) {
    return TyreLogEntity()
      ..id = parseString(json['id'])
      ..vehicleId = parseString(json['vehicleId'])
      ..vehicleNumber = parseString(json['vehicleNumber'])
      ..installationDate = parseDate(json['installationDate'])
      ..reason = parseString(json['reason'])
      ..totalCost = parseDouble(json['totalCost'])
      ..items = parseMapList(json['items'])
          .map(TyreLogItemEntity.fromJson)
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
class TyreLogItemEntity {
  String? tyrePosition;
  String? newTyreType; // New, Remolded
  String? tyreItemId;
  String? tyreBrand;
  String? tyreModel;
  String? tyreNumber;
  double cost = 0;

  String? oldTyreDisposition;
  String? oldTyreBrand;
  String? oldTyreNumber;

  Map<String, dynamic> toJson() {
    return {
      'tyrePosition': tyrePosition,
      'newTyreType': newTyreType,
      'tyreItemId': tyreItemId,
      'tyreBrand': tyreBrand,
      'tyreModel': tyreModel,
      'tyreNumber': tyreNumber,
      'cost': cost,
      'oldTyreDisposition': oldTyreDisposition,
      'oldTyreBrand': oldTyreBrand,
      'oldTyreNumber': oldTyreNumber,
    };
  }

  static TyreLogItemEntity fromJson(Map<String, dynamic> json) {
    return TyreLogItemEntity()
      ..tyrePosition = json['tyrePosition']?.toString()
      ..newTyreType = json['newTyreType']?.toString()
      ..tyreItemId = json['tyreItemId']?.toString()
      ..tyreBrand = json['tyreBrand']?.toString()
      ..tyreModel = json['tyreModel']?.toString()
      ..tyreNumber = json['tyreNumber']?.toString()
      ..cost = parseDouble(json['cost'])
      ..oldTyreDisposition = json['oldTyreDisposition']?.toString()
      ..oldTyreBrand = json['oldTyreBrand']?.toString()
      ..oldTyreNumber = json['oldTyreNumber']?.toString();
  }
}
