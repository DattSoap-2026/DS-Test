import 'package:isar/isar.dart';
import '../base_entity.dart';

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

  Map<String, dynamic> toFirebaseJson() {
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
      'cycleDistance': cycleDistance,
      'cycleFuelUsed': cycleFuelUsed,
      'cycleEfficiency': cycleEfficiency,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static DieselLogEntity fromFirebaseJson(Map<String, dynamic> json) {
    return DieselLogEntity()
      ..id = json['id'] as String
      ..vehicleId = json['vehicleId'] as String
      ..vehicleNumber = json['vehicleNumber'] as String
      ..driverName = json['driverName'] as String?
      ..fillDate = DateTime.parse(json['fillDate'] as String)
      ..liters = (json['liters'] as num).toDouble()
      ..rate = (json['rate'] as num).toDouble()
      ..totalCost = (json['totalCost'] as num).toDouble()
      ..odometerReading = (json['odometerReading'] as num).toDouble()
      ..tankFull = json['tankFull'] as bool? ?? false
      ..cycleDistance = (json['cycleDistance'] as num?)?.toDouble()
      ..cycleFuelUsed = (json['cycleFuelUsed'] as num?)?.toDouble()
      ..cycleEfficiency = (json['cycleEfficiency'] as num?)?.toDouble()
      ..status = json['status'] as String?
      ..createdAt =
          json['createdAt'] as String? ?? DateTime.now().toIso8601String()
      ..updatedAt = DateTime.tryParse(
            (json['updatedAt'] ?? json['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
  }
}
