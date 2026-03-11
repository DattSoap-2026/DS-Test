class PerformanceReview {
  final String id;
  final String employeeId;
  final String reviewerId;
  final String reviewPeriod;
  final DateTime reviewDate;
  final int? qualityScore;
  final int? productivityScore;
  final int? attendanceScore;
  final int? teamworkScore;
  final int? initiativeScore;
  final double? overallRating;
  final String? strengths;
  final String? improvements;
  final String? goals;
  final String? employeeComments;
  final String? managerComments;
  final String status;

  String? employeeName;
  String? reviewerName;

  PerformanceReview({
    required this.id,
    required this.employeeId,
    required this.reviewerId,
    required this.reviewPeriod,
    required this.reviewDate,
    this.qualityScore,
    this.productivityScore,
    this.attendanceScore,
    this.teamworkScore,
    this.initiativeScore,
    this.overallRating,
    this.strengths,
    this.improvements,
    this.goals,
    this.employeeComments,
    this.managerComments,
    required this.status,
    this.employeeName,
    this.reviewerName,
  });

  double calculateOverallRating() {
    final scores = [
      qualityScore,
      productivityScore,
      attendanceScore,
      teamworkScore,
      initiativeScore,
    ].whereType<int>().toList();

    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  String get ratingLabel {
    final rating = overallRating ?? calculateOverallRating();
    if (rating >= 4.5) return 'Outstanding';
    if (rating >= 3.5) return 'Exceeds Expectations';
    if (rating >= 2.5) return 'Meets Expectations';
    if (rating >= 1.5) return 'Needs Improvement';
    return 'Unsatisfactory';
  }
}

class ReviewScore {
  final String category;
  final int score;
  final int maxScore;

  ReviewScore({required this.category, required this.score, this.maxScore = 5});

  double get percentage => (score / maxScore) * 100;
}
