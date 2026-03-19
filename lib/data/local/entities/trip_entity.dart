import 'dart:convert';

import 'package:isar/isar.dart';

import 'package:flutter_app/services/dispatch_service.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'trip_entity.g.dart';

@Collection()
class TripEntity extends BaseEntity {
  @Index()
  late String tripId;

  late String vehicleNumber;
  late String driverName;
  String? driverPhone;
  List<String>? salesIds;

  @Index()
  late String status;

  late String createdAt;
  String? startedAt;
  String? completedAt;
  String? notes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'tripId': tripId,
      'vehicleNumber': vehicleNumber,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'salesIds': jsonEncode(salesIds ?? const <String>[]),
      'status': status,
      'createdAt': createdAt,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'notes': notes,
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

  static TripEntity fromJson(Map<String, dynamic> json) {
    return TripEntity()
      ..id = parseString(json['id'])
      ..tripId = parseString(json['tripId'])
      ..vehicleNumber = parseString(json['vehicleNumber'])
      ..driverName = parseString(json['driverName'])
      ..driverPhone = parseString(json['driverPhone'], fallback: '')
      ..salesIds = parseStringList(json['salesIds'])
      ..status = parseString(json['status'], fallback: 'pending')
      ..createdAt = parseString(json['createdAt'])
      ..startedAt = parseString(json['startedAt'], fallback: '')
      ..completedAt = parseString(json['completedAt'], fallback: '')
      ..notes = parseString(json['notes'], fallback: '')
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }

  DeliveryTrip toDomain() {
    return DeliveryTrip(
      id: id,
      tripId: tripId,
      vehicleNumber: vehicleNumber,
      driverName: driverName,
      driverPhone: driverPhone,
      salesIds: salesIds ?? const <String>[],
      status: status,
      createdAt: createdAt,
      startedAt: startedAt,
      completedAt: completedAt,
      notes: notes,
    );
  }
}
