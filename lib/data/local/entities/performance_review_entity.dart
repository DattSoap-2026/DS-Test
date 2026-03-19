import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'performance_review_entity.g.dart';

@Collection()
class PerformanceReviewEntity extends BaseEntity {
  @Index()
  late String employeeId;

  @Index()
  late String reviewerId; // Manager who conducted review

  @Index()
  late String reviewPeriod; // e.g., "Q1-2026", "2025-Annual"

  late String reviewDate; // ISO8601

  // Rating scores (1-5 scale)
  int? qualityScore;
  int? productivityScore;
  int? attendanceScore;
  int? teamworkScore;
  int? initiativeScore;

  double? overallRating; // Calculated average

  String? strengths;
  String? improvements;
  String? goals;
  String? employeeComments;
  String? managerComments;

  @Index()
  late String status; // 'Draft', 'Submitted', 'Acknowledged'

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'employeeId': employeeId,
      'reviewerId': reviewerId,
      'reviewPeriod': reviewPeriod,
      'reviewDate': reviewDate,
      'qualityScore': qualityScore,
      'productivityScore': productivityScore,
      'attendanceScore': attendanceScore,
      'teamworkScore': teamworkScore,
      'initiativeScore': initiativeScore,
      'overallRating': overallRating,
      'strengths': strengths,
      'improvements': improvements,
      'goals': goals,
      'employeeComments': employeeComments,
      'managerComments': managerComments,
      'status': status,
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

  static PerformanceReviewEntity fromJson(Map<String, dynamic> json) {
    final strengths = parseString(json['strengths']);
    final improvements = parseString(json['improvements']);
    final goals = parseString(json['goals']);
    final employeeComments = parseString(json['employeeComments']);
    final managerComments = parseString(json['managerComments']);

    return PerformanceReviewEntity()
      ..id = parseString(json['id'])
      ..employeeId = parseString(json['employeeId'])
      ..reviewerId = parseString(json['reviewerId'])
      ..reviewPeriod = parseString(json['reviewPeriod'])
      ..reviewDate = parseDate(json['reviewDate']).toIso8601String()
      ..qualityScore = json['qualityScore'] == null
          ? null
          : parseInt(json['qualityScore'])
      ..productivityScore = json['productivityScore'] == null
          ? null
          : parseInt(json['productivityScore'])
      ..attendanceScore = json['attendanceScore'] == null
          ? null
          : parseInt(json['attendanceScore'])
      ..teamworkScore = json['teamworkScore'] == null
          ? null
          : parseInt(json['teamworkScore'])
      ..initiativeScore = json['initiativeScore'] == null
          ? null
          : parseInt(json['initiativeScore'])
      ..overallRating = json['overallRating'] == null
          ? null
          : parseDouble(json['overallRating'])
      ..strengths = strengths.isEmpty ? null : strengths
      ..improvements = improvements.isEmpty ? null : improvements
      ..goals = goals.isEmpty ? null : goals
      ..employeeComments = employeeComments.isEmpty ? null : employeeComments
      ..managerComments = managerComments.isEmpty ? null : managerComments
      ..status = parseString(json['status'], fallback: 'Draft')
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
