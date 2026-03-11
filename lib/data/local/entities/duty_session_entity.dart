import 'dart:convert';
import 'package:isar/isar.dart';
import '../base_entity.dart';
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
}
