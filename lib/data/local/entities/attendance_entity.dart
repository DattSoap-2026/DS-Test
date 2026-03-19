import 'dart:convert';

import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'employeeId': employeeId,
      'date': date,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'status': status,
      'checkInLatitude': checkInLatitude,
      'checkInLongitude': checkInLongitude,
      'checkOutLatitude': checkOutLatitude,
      'checkOutLongitude': checkOutLongitude,
      'remarks': remarks,
      'isManualEntry': isManualEntry,
      'isOvertime': isOvertime,
      'markedAt': markedAt?.toIso8601String(),
      'isCorrected': isCorrected,
      'overtimeHours': overtimeHours,
      'auditLog': auditLog,
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

  static AttendanceEntity fromJson(Map<String, dynamic> json) {
    final rawAuditLog = json['auditLog'];

    return AttendanceEntity()
      ..id = parseString(json['id'])
      ..employeeId = parseString(json['employeeId'])
      ..date = parseDate(json['date']).toIso8601String().split('T').first
      ..checkInTime = parseString(json['checkInTime']).isEmpty
          ? null
          : parseString(json['checkInTime'])
      ..checkOutTime = parseString(json['checkOutTime']).isEmpty
          ? null
          : parseString(json['checkOutTime'])
      ..status = parseString(json['status'], fallback: 'Absent')
      ..checkInLatitude = json['checkInLatitude'] == null
          ? null
          : parseDouble(json['checkInLatitude'])
      ..checkInLongitude = json['checkInLongitude'] == null
          ? null
          : parseDouble(json['checkInLongitude'])
      ..checkOutLatitude = json['checkOutLatitude'] == null
          ? null
          : parseDouble(json['checkOutLatitude'])
      ..checkOutLongitude = json['checkOutLongitude'] == null
          ? null
          : parseDouble(json['checkOutLongitude'])
      ..remarks = parseString(json['remarks']).isEmpty
          ? null
          : parseString(json['remarks'])
      ..isManualEntry = parseBool(json['isManualEntry'])
      ..isOvertime = parseBool(json['isOvertime'])
      ..markedAt = parseDateOrNull(json['markedAt'])
      ..isCorrected = parseBool(json['isCorrected'])
      ..overtimeHours = json['overtimeHours'] == null
          ? null
          : parseDouble(json['overtimeHours'])
      ..auditLog = rawAuditLog == null
          ? null
          : rawAuditLog is String
          ? rawAuditLog
          : jsonEncode(rawAuditLog)
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
