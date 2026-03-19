import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'fuel_purchase_entity.g.dart';

@Collection()
class FuelPurchaseEntity extends BaseEntity {
  @Index()
  late String vehicleId;

  late String vehicleNumber;
  String? driverName;
  double liters = 0;
  double rate = 0;
  double totalCost = 0;
  String? fuelType;
  String? stationName;
  String? billNumber;
  String? paymentMode;
  DateTime? purchaseDate;
  double? odometerReading;
  String? createdBy;
  DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'vehicleNumber': vehicleNumber,
      'driverName': driverName,
      'liters': liters,
      'rate': rate,
      'totalCost': totalCost,
      'fuelType': fuelType,
      'stationName': stationName,
      'billNumber': billNumber,
      'paymentMode': paymentMode,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'odometerReading': odometerReading,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
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

  static FuelPurchaseEntity fromJson(Map<String, dynamic> json) {
    return FuelPurchaseEntity()
      ..id = parseString(json['id'])
      ..vehicleId = parseString(json['vehicleId'])
      ..vehicleNumber = parseString(json['vehicleNumber'])
      ..driverName = json['driverName']?.toString()
      ..liters = parseDouble(json['liters'])
      ..rate = parseDouble(json['rate'])
      ..totalCost = parseDouble(json['totalCost'])
      ..fuelType = json['fuelType']?.toString()
      ..stationName = json['stationName']?.toString()
      ..billNumber = json['billNumber']?.toString()
      ..paymentMode = json['paymentMode']?.toString()
      ..purchaseDate = parseDateOrNull(json['purchaseDate'])
      ..odometerReading = json['odometerReading'] == null
          ? null
          : parseDouble(json['odometerReading'])
      ..createdBy = json['createdBy']?.toString()
      ..createdAt = parseDateOrNull(json['createdAt'])
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
