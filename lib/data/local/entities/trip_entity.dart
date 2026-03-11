import 'package:isar/isar.dart';
import '../base_entity.dart';
import 'package:flutter_app/services/dispatch_service.dart';

part 'trip_entity.g.dart';

@Collection()
class TripEntity extends BaseEntity {
  @Index()
  late String tripId; // Display ID e.g. TRIP-123456

  late String vehicleNumber;
  late String driverName;
  String? driverPhone;

  List<String>? salesIds;

  @Index()
  late String status; // 'pending', 'in_progress', 'completed'

  late String createdAt;
  String? startedAt;
  String? completedAt;
  String? notes;

  DeliveryTrip toDomain() {
    return DeliveryTrip(
      id: id,
      tripId: tripId,
      vehicleNumber: vehicleNumber,
      driverName: driverName,
      driverPhone: driverPhone,
      salesIds: salesIds ?? [],
      status: status,
      createdAt: createdAt,
      startedAt: startedAt,
      completedAt: completedAt,
      notes: notes,
    );
  }
}
