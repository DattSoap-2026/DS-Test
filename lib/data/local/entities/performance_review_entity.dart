import 'package:isar/isar.dart';
import '../base_entity.dart';

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
}
