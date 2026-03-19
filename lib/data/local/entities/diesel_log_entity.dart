import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'diesel_log_entity.g.dart';

@Collection()
class DieselLogEntity extends BaseEntity {
  @Index()
  late String vehicleId;
  late String vehicleNumber;

  String? driverName;

  @Index()
  late DateTime fillDate;

  late double liters;
  late double rate;
  late double totalCost;
  late double odometerReading;

  bool tankFull = false;

  String? journeyFrom;
  String? journeyTo;

  double? cycleDistance;
  double? cycleFuelUsed;
  double? cycleEfficiency;

  double? penaltyAmount;
  String? status; // PENDING, GOOD_AVERAGE, LOW_AVERAGE

  bool penaltyOverridden = false;
  String? overrideReason;
  String? overriddenBy;
  double? originalPenaltyAmount;

  String? createdBy;
  late String createdAt;

  // Legacy/Extra
  double? distance;
  String? notes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'vehicleNumber': vehicleNumber,
      'driverName': driverName,
      'fillDate': fillDate.toIso8601String(),
      'liters': liters,
      'rate': rate,
      'totalCost': totalCost,
      'odometerReading': odometerReading,
      'tankFull': tankFull,
      'journeyFrom': journeyFrom,
      'journeyTo': journeyTo,
      'cycleDistance': cycleDistance,
      'cycleFuelUsed': cycleFuelUsed,
      'cycleEfficiency': cycleEfficiency,
      'penaltyAmount': penaltyAmount,
      'status': status,
      'penaltyOverridden': penaltyOverridden,
      'overrideReason': overrideReason,
      'overriddenBy': overriddenBy,
      'originalPenaltyAmount': originalPenaltyAmount,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'distance': distance,
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

  Map<String, dynamic> toFirebaseJson() {
    return toJson();
  }

  static DieselLogEntity fromJson(Map<String, dynamic> json) {
    return DieselLogEntity()
      ..id = parseString(json['id'])
      ..vehicleId = parseString(json['vehicleId'])
      ..vehicleNumber = parseString(json['vehicleNumber'])
      ..driverName = json['driverName']?.toString()
      ..fillDate = parseDate(json['fillDate'])
      ..liters = parseDouble(json['liters'])
      ..rate = parseDouble(json['rate'])
      ..totalCost = parseDouble(json['totalCost'])
      ..odometerReading = parseDouble(json['odometerReading'])
      ..tankFull = parseBool(json['tankFull'])
      ..journeyFrom = json['journeyFrom']?.toString()
      ..journeyTo = json['journeyTo']?.toString()
      ..cycleDistance = json['cycleDistance'] == null
          ? null
          : parseDouble(json['cycleDistance'])
      ..cycleFuelUsed = json['cycleFuelUsed'] == null
          ? null
          : parseDouble(json['cycleFuelUsed'])
      ..cycleEfficiency = json['cycleEfficiency'] == null
          ? null
          : parseDouble(json['cycleEfficiency'])
      ..penaltyAmount = json['penaltyAmount'] == null
          ? null
          : parseDouble(json['penaltyAmount'])
      ..status = json['status']?.toString()
      ..penaltyOverridden = parseBool(json['penaltyOverridden'])
      ..overrideReason = json['overrideReason']?.toString()
      ..overriddenBy = json['overriddenBy']?.toString()
      ..originalPenaltyAmount = json['originalPenaltyAmount'] == null
          ? null
          : parseDouble(json['originalPenaltyAmount'])
      ..createdBy = json['createdBy']?.toString()
      ..createdAt = parseString(
        json['createdAt'],
        fallback: DateTime.now().toIso8601String(),
      )
      ..distance = json['distance'] == null ? null : parseDouble(json['distance'])
      ..notes = json['notes']?.toString()
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }

  static DieselLogEntity fromFirebaseJson(Map<String, dynamic> json) {
    return DieselLogEntity.fromJson(json)
      ..syncStatus = SyncStatus.synced
      ..isSynced = true
      ..isDeleted = false;
  }
}
