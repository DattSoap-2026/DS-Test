import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'attendance_entity.g.dart';

@Collection()
class AttendanceEntity extends BaseEntity {
  @Index()
  late String employeeId;

  @Index()
  late String date; // YYYY-MM-DD format

  String? checkInTime; // ISO8601
  String? checkOutTime; // ISO8601

  @Index()
  late String status; // 'Present', 'Absent', 'Late', 'HalfDay', 'OnLeave'

  double? checkInLatitude;
  double? checkInLongitude;
  double? checkOutLatitude;
  double? checkOutLongitude;

  String? remarks;
  bool isManualEntry = false;
  bool isOvertime = false;
  DateTime? markedAt;
  bool isCorrected = false;

  double? overtimeHours;
  String? auditLog; // JSON list of audit entries
}
