import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../../../services/visit_service.dart';

part 'route_session_entity.g.dart';

@Collection()
class RouteSessionEntity extends BaseEntity {
  @Index()
  late String salesmanId;

  late String salesmanName;

  @Index()
  late String routeId;

  late String routeName;

  @Index()
  late String date;

  late String startTime;

  String? endTime;

  @Index()
  late String status; // 'active', 'completed'

  late double totalDistance;
  late int plannedStops;
  late int completedStops;
  late int skippedStops;
  late double totalSales;
  late double totalCollection;

  late String createdAt;

  // Convert to domain model
  RouteSession toDomain() {
    return RouteSession(
      id: id,
      salesmanId: salesmanId,
      salesmanName: salesmanName,
      routeId: routeId,
      routeName: routeName,
      date: date,
      startTime: startTime,
      endTime: endTime,
      status: status,
      totalDistance: totalDistance,
      plannedStops: plannedStops,
      completedStops: completedStops,
      skippedStops: skippedStops,
      totalSales: totalSales,
      totalCollection: totalCollection,
      createdAt: createdAt,
      updatedAt: updatedAt.toIso8601String(),
    );
  }

  // Create from domain model
  static RouteSessionEntity fromDomain(RouteSession session) {
    return RouteSessionEntity()
      ..id = session.id
      ..salesmanId = session.salesmanId
      ..salesmanName = session.salesmanName
      ..routeId = session.routeId
      ..routeName = session.routeName
      ..date = session.date
      ..startTime = session.startTime
      ..endTime = session.endTime
      ..status = session.status
      ..totalDistance = session.totalDistance
      ..plannedStops = session.plannedStops
      ..completedStops = session.completedStops
      ..skippedStops = session.skippedStops
      ..totalSales = session.totalSales
      ..totalCollection = session.totalCollection
      ..createdAt = session.createdAt
      ..updatedAt = session.updatedAt.isNotEmpty
          ? DateTime.parse(session.updatedAt)
          : DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
  }
}
