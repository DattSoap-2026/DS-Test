import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'leave_request_entity.g.dart';

@Collection()
class LeaveRequestEntity extends BaseEntity {
  @Index()
  late String employeeId;

  @Index()
  late String leaveType; // 'Sick', 'Casual', 'Earned', 'Unpaid'

  late String startDate; // ISO8601
  late String endDate;
  late int totalDays;

  String? reason;

  @Index()
  late String status; // 'Pending', 'Approved', 'Rejected', 'Cancelled'

  String? approvedBy;
  String? approvedAt;
  String? rejectionReason;

  late String requestedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'employeeId': employeeId,
      'leaveType': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'totalDays': totalDays,
      'reason': reason,
      'status': status,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt,
      'rejectionReason': rejectionReason,
      'requestedAt': requestedAt,
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

  static LeaveRequestEntity fromJson(Map<String, dynamic> json) {
    final approvedBy = parseString(json['approvedBy']);
    final reason = parseString(json['reason']);
    final rejectionReason = parseString(json['rejectionReason']);
    final approvedAt = parseDateOrNull(json['approvedAt']);
    final requestedAt = parseDateOrNull(json['requestedAt']) ?? DateTime.now();

    return LeaveRequestEntity()
      ..id = parseString(json['id'])
      ..employeeId = parseString(json['employeeId'])
      ..leaveType = parseString(json['leaveType'])
      ..startDate = parseDate(json['startDate']).toIso8601String()
      ..endDate = parseDate(json['endDate']).toIso8601String()
      ..totalDays = ((json['totalDays'] as num?) ?? 0).toDouble().round()
      ..reason = reason.isEmpty ? null : reason
      ..status = parseString(json['status'], fallback: 'Pending')
      ..approvedBy = approvedBy.isEmpty ? null : approvedBy
      ..approvedAt = approvedAt?.toIso8601String()
      ..rejectionReason = rejectionReason.isEmpty ? null : rejectionReason
      ..requestedAt = requestedAt.toIso8601String()
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
