import 'dart:convert';
import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';
import '../../../../services/duty_service.dart';

part 'duty_session_entity.g.dart';

@Collection()
class DutySessionEntity extends BaseEntity {
  @Index()
  late String userId;

  String? employeeId;
  late String userName;
  late String userRole; // 'Driver' | 'Salesman'

  @Index()
  late String status; // 'active', 'completed', 'auto_closed', 'onroute_after_duty'

  @Index()
  late String date;

  late String loginTime;
  late double loginLatitude;
  late double loginLongitude;
  late bool gpsEnabled;
  late List<String> alerts; // JSON strings of DutyAlert
  late String createdAt;

  // Optional / End Data
  String? logoutTime;
  double? logoutLatitude;
  double? logoutLongitude;
  double? totalDistanceKm;
  String? vehicleId;
  String? vehicleNumber;
  String? routeName;
  double? startOdometer;
  double? endOdometer;
  bool? gpsAutoOff;
  int? overtimeMinutes;
  bool? isOvertime;
  String? autoStopReason;
  // Advanced tracking fields
  double? baseLatitude;
  double? baseLongitude;
  String? dutyEndTime;

  Map<String, dynamic> toJson() {
    final serializedAlerts = alerts
        .map((entry) => parseJsonMap(entry) ?? {'raw': entry})
        .toList(growable: false);
    return {
      'id': id,
      'userId': userId,
      'employeeId': employeeId,
      'userName': userName,
      'userRole': userRole,
      'status': status,
      'date': date,
      'loginTime': loginTime,
      'loginLatitude': loginLatitude,
      'loginLongitude': loginLongitude,
      'gpsEnabled': gpsEnabled,
      'alerts': jsonEncode(serializedAlerts),
      'createdAt': createdAt,
      'logoutTime': logoutTime,
      'logoutLatitude': logoutLatitude,
      'logoutLongitude': logoutLongitude,
      'totalDistanceKm': totalDistanceKm,
      'vehicleId': vehicleId,
      'vehicleNumber': vehicleNumber,
      'routeName': routeName,
      'startOdometer': startOdometer,
      'endOdometer': endOdometer,
      'gpsAutoOff': gpsAutoOff,
      'overtimeMinutes': overtimeMinutes,
      'isOvertime': isOvertime,
      'autoStopReason': autoStopReason,
      'baseLatitude': baseLatitude,
      'baseLongitude': baseLongitude,
      'dutyEndTime': dutyEndTime,
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

  static DutySessionEntity fromJson(Map<String, dynamic> json) {
    return DutySessionEntity()
      ..id = parseString(json['id'])
      ..userId = parseString(json['userId'])
      ..employeeId = json['employeeId']?.toString()
      ..userName = parseString(json['userName'])
      ..userRole = parseString(json['userRole'])
      ..status = parseString(json['status'])
      ..date = parseString(json['date'])
      ..loginTime = parseString(json['loginTime'])
      ..loginLatitude = parseDouble(json['loginLatitude'])
      ..loginLongitude = parseDouble(json['loginLongitude'])
      ..gpsEnabled = parseBool(json['gpsEnabled'])
      ..alerts = _parseAlerts(json['alerts'])
      ..createdAt = parseString(
        json['createdAt'],
        fallback: DateTime.now().toIso8601String(),
      )
      ..logoutTime = json['logoutTime']?.toString()
      ..logoutLatitude = json['logoutLatitude'] == null
          ? null
          : parseDouble(json['logoutLatitude'])
      ..logoutLongitude = json['logoutLongitude'] == null
          ? null
          : parseDouble(json['logoutLongitude'])
      ..totalDistanceKm = json['totalDistanceKm'] == null
          ? null
          : parseDouble(json['totalDistanceKm'])
      ..vehicleId = json['vehicleId']?.toString()
      ..vehicleNumber = json['vehicleNumber']?.toString()
      ..routeName = json['routeName']?.toString()
      ..startOdometer = json['startOdometer'] == null
          ? null
          : parseDouble(json['startOdometer'])
      ..endOdometer = json['endOdometer'] == null
          ? null
          : parseDouble(json['endOdometer'])
      ..gpsAutoOff = json['gpsAutoOff'] == null
          ? null
          : parseBool(json['gpsAutoOff'])
      ..overtimeMinutes = json['overtimeMinutes'] == null
          ? null
          : parseInt(json['overtimeMinutes'])
      ..isOvertime = json['isOvertime'] == null
          ? null
          : parseBool(json['isOvertime'])
      ..autoStopReason = json['autoStopReason']?.toString()
      ..baseLatitude = json['baseLatitude'] == null
          ? null
          : parseDouble(json['baseLatitude'])
      ..baseLongitude = json['baseLongitude'] == null
          ? null
          : parseDouble(json['baseLongitude'])
      ..dutyEndTime = json['dutyEndTime']?.toString()
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }

  DutySession toDomain() {
    return DutySession(
      id: id,
      userId: userId,
      employeeId: employeeId,
      userName: userName,
      userRole: userRole,
      status: status,
      date: date,
      loginTime: loginTime,
      loginLatitude: loginLatitude,
      loginLongitude: loginLongitude,
      gpsEnabled: gpsEnabled,
      alerts: alerts.map((a) => DutyAlert.fromJson(jsonDecode(a))).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt.toIso8601String(),
      logoutTime: logoutTime,
      logoutLatitude: logoutLatitude,
      logoutLongitude: logoutLongitude,
      totalDistanceKm: totalDistanceKm,
      vehicleId: vehicleId,
      vehicleNumber: vehicleNumber,
      routeName: routeName,
      startOdometer: startOdometer,
      endOdometer: endOdometer,
      gpsAutoOff: gpsAutoOff,
      overtimeMinutes: overtimeMinutes,
      isOvertime: isOvertime,
      autoStopReason: autoStopReason,
      baseLatitude: baseLatitude,
      baseLongitude: baseLongitude,
      dutyEndTime: dutyEndTime,
    );
  }

  static DutySessionEntity fromDomain(DutySession model) {
    final entity = DutySessionEntity()
      ..id = model.id
      ..userId = model.userId
      ..employeeId = model.employeeId
      ..userName = model.userName
      ..userRole = model.userRole
      ..status = model.status
      ..date = model.date
      ..loginTime = model.loginTime
      ..loginLatitude = model.loginLatitude
      ..loginLongitude = model.loginLongitude
      ..gpsEnabled = model.gpsEnabled
      ..alerts = model.alerts.map((a) => jsonEncode(a.toJson())).toList()
      ..createdAt = model.createdAt
      ..logoutTime = model.logoutTime
      ..logoutLatitude = model.logoutLatitude
      ..logoutLongitude = model.logoutLongitude
      ..totalDistanceKm = model.totalDistanceKm
      ..vehicleId = model.vehicleId
      ..vehicleNumber = model.vehicleNumber
      ..routeName = model.routeName
      ..startOdometer = model.startOdometer
      ..endOdometer = model.endOdometer
      ..gpsAutoOff = model.gpsAutoOff
      ..overtimeMinutes = model.overtimeMinutes
      ..isOvertime = model.isOvertime
      ..autoStopReason = model.autoStopReason
      ..baseLatitude = model.baseLatitude
      ..baseLongitude = model.baseLongitude
      ..dutyEndTime = model.dutyEndTime
      ..updatedAt = DateTime.parse(model.updatedAt);

    // Set sync status defaults if new (handled by caller typically)
    return entity;
  }

  static List<String> _parseAlerts(dynamic value) {
    return parseMapList(value)
        .map((item) => jsonEncode(item))
        .toList(growable: false);
  }
}
