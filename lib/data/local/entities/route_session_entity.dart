import 'package:isar/isar.dart';

import '../../../services/visit_service.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

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
  late String status;

  late double totalDistance;
  late int plannedStops;
  late int completedStops;
  late int skippedStops;
  late double totalSales;
  late double totalCollection;
  late String createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'routeId': routeId,
      'routeName': routeName,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'totalDistance': totalDistance,
      'plannedStops': plannedStops,
      'completedStops': completedStops,
      'skippedStops': skippedStops,
      'totalSales': totalSales,
      'totalCollection': totalCollection,
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

  static RouteSessionEntity fromJson(Map<String, dynamic> json) {
    return RouteSessionEntity()
      ..id = parseString(json['id'])
      ..salesmanId = parseString(json['salesmanId'])
      ..salesmanName = parseString(json['salesmanName'])
      ..routeId = parseString(json['routeId'])
      ..routeName = parseString(json['routeName'])
      ..date = parseString(json['date'])
      ..startTime = parseString(json['startTime'])
      ..endTime = parseString(json['endTime'], fallback: '')
      ..status = parseString(json['status'], fallback: 'active')
      ..totalDistance = parseDouble(json['totalDistance'])
      ..plannedStops = parseInt(json['plannedStops'])
      ..completedStops = parseInt(json['completedStops'])
      ..skippedStops = parseInt(json['skippedStops'])
      ..totalSales = parseDouble(json['totalSales'])
      ..totalCollection = parseDouble(json['totalCollection'])
      ..createdAt = parseString(json['createdAt'])
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }

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
      ..updatedAt = parseDate(session.updatedAt)
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false;
  }
}
