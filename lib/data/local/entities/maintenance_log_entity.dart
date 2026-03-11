import 'package:isar/isar.dart';
import '../base_entity.dart';

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
}

@Embedded()
class MaintenanceItemEntity {
  String? partName;
  String? description;
  double quantity = 0;
  double price = 0;
}
