import 'package:isar/isar.dart';
import '../base_entity.dart';

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

  Map<String, dynamic> toFirebaseJson() {
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
      if (purchaseDate != null) 'purchaseDate': purchaseDate!.toIso8601String(),
      if (insuranceStartDate != null)
        'insuranceStartDate': insuranceStartDate!.toIso8601String(),
      if (pucExpiryDate != null)
        'pucExpiryDate': pucExpiryDate!.toIso8601String(),
      if (insuranceExpiryDate != null)
        'insuranceExpiryDate': insuranceExpiryDate!.toIso8601String(),
      if (permitExpiryDate != null)
        'permitExpiryDate': permitExpiryDate!.toIso8601String(),
      if (fitnessExpiryDate != null)
        'fitnessExpiryDate': fitnessExpiryDate!.toIso8601String(),
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
    };
  }

  static VehicleEntity fromFirebaseJson(Map<String, dynamic> json) {
    // Generate ID if missing (for new vehicles)
    final id =
        json['id'] as String? ??
        'v_${DateTime.now().millisecondsSinceEpoch}_${(json['number'] ?? '').toString().hashCode.abs()}';

    return VehicleEntity()
      ..id = id
      ..name = json['name'] as String? ?? ''
      ..number = json['number'] as String? ?? ''
      ..type = json['type'] as String? ?? 'Truck'
      ..status = json['status'] as String? ?? 'active'
      ..currentOdometer = (json['currentOdometer'] as num?)?.toDouble() ?? 0
      ..totalDistance = (json['totalDistance'] as num?)?.toDouble() ?? 0
      ..totalMaintenanceCost =
          (json['totalMaintenanceCost'] as num?)?.toDouble() ?? 0
      ..totalDieselCost = (json['totalDieselCost'] as num?)?.toDouble() ?? 0
      ..totalTyreCost = (json['totalTyreCost'] as num?)?.toDouble() ?? 0
      ..totalFuelConsumed = (json['totalFuelConsumed'] as num?)?.toDouble() ?? 0
      ..costPerKm = (json['costPerKm'] as num?)?.toDouble() ?? 0
      ..purchaseDate = json['purchaseDate'] != null
          ? DateTime.tryParse(json['purchaseDate'] as String)
          : null
      ..insuranceStartDate = json['insuranceStartDate'] != null
          ? DateTime.tryParse(json['insuranceStartDate'] as String)
          : null
      ..pucExpiryDate = json['pucExpiryDate'] != null
          ? DateTime.tryParse(json['pucExpiryDate'] as String)
          : null
      ..insuranceExpiryDate = json['insuranceExpiryDate'] != null
          ? DateTime.tryParse(json['insuranceExpiryDate'] as String)
          : null
      ..permitExpiryDate = json['permitExpiryDate'] != null
          ? DateTime.tryParse(json['permitExpiryDate'] as String)
          : null
      ..fitnessExpiryDate = json['fitnessExpiryDate'] != null
          ? DateTime.tryParse(json['fitnessExpiryDate'] as String)
          : null
      ..createdAt =
          json['createdAt'] as String? ?? DateTime.now().toIso8601String()
      ..lastDieselFill = json['lastDieselFill'] as String?
      ..capacity = (json['capacity'] as num?)?.toDouble()
      ..minAverage = (json['minAverage'] as num?)?.toDouble() ?? 0.0
      ..maxAverage = (json['maxAverage'] as num?)?.toDouble() ?? 0.0
      ..model = json['model'] as String?
      ..serialNumber = json['serialNumber'] as String?
      ..fuelType = json['fuelType'] as String?
      ..tyreSize = json['tyreSize'] as String?
      ..insuranceProvider = json['insuranceProvider'] as String?
      ..policyNumber = json['policyNumber'] as String?
      ..pucNumber = json['pucNumber'] as String?
      ..permitNumber = json['permitNumber'] as String?
      ..rcNumber = json['rcNumber'] as String?
      ..updatedAt = DateTime.parse(
        json['updatedAt'] as String? ??
            json['createdAt'] as String? ??
            DateTime.now().toIso8601String(),
      )
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
  }
}
