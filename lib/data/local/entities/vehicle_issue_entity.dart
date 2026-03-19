import 'dart:convert';

import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'vehicle_issue_entity.g.dart';

@Collection()
class VehicleIssueEntity extends BaseEntity {
  @Index()
  late String vehicleId;
  late String vehicleNumber;
  late String reportedBy; // Driver or User ID
  late DateTime reportedDate;
  late String description;

  String priority = 'Medium'; // Low, Medium, High, Critical
  String status = 'Open'; // Open, In Progress, Resolved, Closed

  String? resolutionNotes;
  DateTime? resolvedDate;

  List<String>? images;

  late String createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'vehicleNumber': vehicleNumber,
      'reportedBy': reportedBy,
      'reportedDate': reportedDate.toIso8601String(),
      'description': description,
      'priority': priority,
      'status': status,
      'resolutionNotes': resolutionNotes,
      'resolvedDate': resolvedDate?.toIso8601String(),
      'images': jsonEncode(images ?? const <String>[]),
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

  static VehicleIssueEntity fromJson(Map<String, dynamic> json) {
    return VehicleIssueEntity()
      ..id = parseString(json['id'])
      ..vehicleId = parseString(json['vehicleId'])
      ..vehicleNumber = parseString(json['vehicleNumber'])
      ..reportedBy = parseString(json['reportedBy'])
      ..reportedDate = parseDate(json['reportedDate'])
      ..description = parseString(json['description'])
      ..priority = parseString(json['priority'], fallback: 'Medium')
      ..status = parseString(json['status'], fallback: 'Open')
      ..resolutionNotes = json['resolutionNotes']?.toString()
      ..resolvedDate = parseDateOrNull(json['resolvedDate'])
      ..images = parseStringList(json['images']) ?? const <String>[]
      ..createdAt = parseString(
        json['createdAt'],
        fallback: DateTime.now().toIso8601String(),
      )
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
