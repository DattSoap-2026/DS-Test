import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'vehicle_entity.g.dart';

@Collection()
class VehicleEntity extends BaseEntity {
  late String name;

  @Index(unique: true)
  late String number;

  late String type;

  late String status;

  double currentOdometer = 0;
  double totalDistance = 0;
  double totalMaintenanceCost = 0;
  double totalDieselCost = 0;
  double totalTyreCost = 0;
  double totalFuelConsumed = 0; // Added for accurate mileage (Liters)
  double costPerKm = 0;

  DateTime? purchaseDate;
  DateTime? insuranceStartDate;
  DateTime? pucExpiryDate;
  DateTime? insuranceExpiryDate;
  DateTime? permitExpiryDate;
  DateTime? fitnessExpiryDate;

  late String createdAt;
  String? lastDieselFill;
  double? capacity;
  double minAverage = 0.0;
  double maxAverage = 0.0;
  String? model;
  String? serialNumber;
  String? fuelType;
  String? tyreSize;
  String? insuranceProvider;
  String? policyNumber;
  String? pucNumber;
  String? permitNumber;
  String? rcNumber;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'type': type,
      'status': status,
      'currentOdometer': currentOdometer,
      'totalDistance': totalDistance,
      'totalMaintenanceCost': totalMaintenanceCost,
      'totalDieselCost': totalDieselCost,
      'totalTyreCost': totalTyreCost,
      'totalFuelConsumed': totalFuelConsumed,
      'costPerKm': costPerKm,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'insuranceStartDate': insuranceStartDate?.toIso8601String(),
      'pucExpiryDate': pucExpiryDate?.toIso8601String(),
      'insuranceExpiryDate': insuranceExpiryDate?.toIso8601String(),
      'permitExpiryDate': permitExpiryDate?.toIso8601String(),
      'fitnessExpiryDate': fitnessExpiryDate?.toIso8601String(),
      'createdAt': createdAt,
      'lastDieselFill': lastDieselFill,
      'capacity': capacity,
      'minAverage': minAverage,
      'maxAverage': maxAverage,
      'model': model,
      'serialNumber': serialNumber,
      'fuelType': fuelType,
      'tyreSize': tyreSize,
      'insuranceProvider': insuranceProvider,
      'policyNumber': policyNumber,
      'pucNumber': pucNumber,
      'permitNumber': permitNumber,
      'rcNumber': rcNumber,
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

  static VehicleEntity fromJson(Map<String, dynamic> json) {
    return VehicleEntity()
      ..id = parseString(json['id'])
      ..name = parseString(json['name'])
      ..number = parseString(json['number'])
      ..type = parseString(json['type'], fallback: 'Truck')
      ..status = parseString(json['status'], fallback: 'active')
      ..currentOdometer = parseDouble(json['currentOdometer'])
      ..totalDistance = parseDouble(json['totalDistance'])
      ..totalMaintenanceCost = parseDouble(json['totalMaintenanceCost'])
      ..totalDieselCost = parseDouble(json['totalDieselCost'])
      ..totalTyreCost = parseDouble(json['totalTyreCost'])
      ..totalFuelConsumed = parseDouble(json['totalFuelConsumed'])
      ..costPerKm = parseDouble(json['costPerKm'])
      ..purchaseDate = parseDateOrNull(json['purchaseDate'])
      ..insuranceStartDate = parseDateOrNull(json['insuranceStartDate'])
      ..pucExpiryDate = parseDateOrNull(json['pucExpiryDate'])
      ..insuranceExpiryDate = parseDateOrNull(json['insuranceExpiryDate'])
      ..permitExpiryDate = parseDateOrNull(json['permitExpiryDate'])
      ..fitnessExpiryDate = parseDateOrNull(json['fitnessExpiryDate'])
      ..createdAt = parseString(
        json['createdAt'],
        fallback: DateTime.now().toIso8601String(),
      )
      ..lastDieselFill = json['lastDieselFill']?.toString()
      ..capacity = json['capacity'] == null ? null : parseDouble(json['capacity'])
      ..minAverage = parseDouble(json['minAverage'])
      ..maxAverage = parseDouble(json['maxAverage'])
      ..model = json['model']?.toString()
      ..serialNumber = json['serialNumber']?.toString()
      ..fuelType = json['fuelType']?.toString()
      ..tyreSize = json['tyreSize']?.toString()
      ..insuranceProvider = json['insuranceProvider']?.toString()
      ..policyNumber = json['policyNumber']?.toString()
      ..pucNumber = json['pucNumber']?.toString()
      ..permitNumber = json['permitNumber']?.toString()
      ..rcNumber = json['rcNumber']?.toString()
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }

  static VehicleEntity fromFirebaseJson(Map<String, dynamic> json) {
    final payload = Map<String, dynamic>.from(json);
    payload['id'] = parseString(
      json['id'],
      fallback:
          'v_${DateTime.now().millisecondsSinceEpoch}_${(json['number'] ?? '').toString().hashCode.abs()}',
    );
    return VehicleEntity.fromJson(payload)
      ..syncStatus = SyncStatus.synced
      ..isSynced = true
      ..isDeleted = false;
  }
}
