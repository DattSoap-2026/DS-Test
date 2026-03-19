import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../core/sync/sync_queue_service.dart';
import '../../../services/database_service.dart';
import '../../../data/local/entities/performance_review_entity.dart';
import '../../../data/local/base_entity.dart';
import '../models/performance_review_model.dart';

class PerformanceReviewService with ChangeNotifier {
  final DatabaseService _dbService;
  static const String _collection = 'performance_reviews';

  PerformanceReviewService(this._dbService);

  Future<void> _enqueueOutbox(
    Map<String, dynamic> payload, {
    String action = 'set',
  }) async {
    final documentId = payload['id']?.toString().trim() ?? '';
    if (documentId.isEmpty) {
      return;
    }
    await SyncQueueService.instance.addToQueue(
      collectionName: _collection,
      documentId: documentId,
      operation: action,
      payload: payload,
    );
  }

  Map<String, dynamic> _toSyncPayload(PerformanceReviewEntity entity) {
    return <String, dynamic>{
      'id': entity.id,
      'employeeId': entity.employeeId,
      'reviewerId': entity.reviewerId,
      'reviewPeriod': entity.reviewPeriod,
      'reviewDate': entity.reviewDate,
      'qualityScore': entity.qualityScore,
      'productivityScore': entity.productivityScore,
      'attendanceScore': entity.attendanceScore,
      'teamworkScore': entity.teamworkScore,
      'initiativeScore': entity.initiativeScore,
      'overallRating': entity.overallRating,
      'strengths': entity.strengths,
      'improvements': entity.improvements,
      'goals': entity.goals,
      'employeeComments': entity.employeeComments,
      'managerComments': entity.managerComments,
      'status': entity.status,
      'isDeleted': entity.isDeleted,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };
  }

  /// Create a new performance review
  Future<PerformanceReview> createReview({
    required String employeeId,
    required String reviewerId,
    required String reviewPeriod,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();

    final entity = PerformanceReviewEntity()
      ..id = id
      ..employeeId = employeeId
      ..reviewerId = reviewerId
      ..reviewPeriod = reviewPeriod
      ..reviewDate = now.toIso8601String()
      ..status = 'Draft'
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.performanceReviews.put(entity);
    });
    await _enqueueOutbox(_toSyncPayload(entity), action: 'set');

    notifyListeners();
    return _toDomain(entity);
  }

  /// Update scores for a review
  Future<void> updateScores({
    required String reviewId,
    int? qualityScore,
    int? productivityScore,
    int? attendanceScore,
    int? teamworkScore,
    int? initiativeScore,
    String? strengths,
    String? improvements,
    String? goals,
    String? managerComments,
  }) async {
    final entity = await _dbService.performanceReviews
        .filter()
        .idEqualTo(reviewId)
        .findFirst();
    if (entity == null) throw Exception('Review not found');

    entity
      ..qualityScore = qualityScore ?? entity.qualityScore
      ..productivityScore = productivityScore ?? entity.productivityScore
      ..attendanceScore = attendanceScore ?? entity.attendanceScore
      ..teamworkScore = teamworkScore ?? entity.teamworkScore
      ..initiativeScore = initiativeScore ?? entity.initiativeScore
      ..strengths = strengths ?? entity.strengths
      ..improvements = improvements ?? entity.improvements
      ..goals = goals ?? entity.goals
      ..managerComments = managerComments ?? entity.managerComments
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending;

    // Calculate overall rating
    final scores = [
      entity.qualityScore,
      entity.productivityScore,
      entity.attendanceScore,
      entity.teamworkScore,
      entity.initiativeScore,
    ].whereType<int>().toList();
    if (scores.isNotEmpty) {
      entity.overallRating = scores.reduce((a, b) => a + b) / scores.length;
    }

    await _dbService.db.writeTxn(() async {
      await _dbService.performanceReviews.put(entity);
    });
    await _enqueueOutbox(_toSyncPayload(entity), action: 'update');

    notifyListeners();
  }

  /// Submit review (changes status from Draft to Submitted)
  Future<void> submitReview(String reviewId) async {
    final entity = await _dbService.performanceReviews
        .filter()
        .idEqualTo(reviewId)
        .findFirst();
    if (entity == null) throw Exception('Review not found');

    entity
      ..status = 'Submitted'
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.performanceReviews.put(entity);
    });
    await _enqueueOutbox(_toSyncPayload(entity), action: 'update');

    notifyListeners();
  }

  /// Employee acknowledges review
  Future<void> acknowledgeReview(
    String reviewId,
    String employeeComments,
  ) async {
    final entity = await _dbService.performanceReviews
        .filter()
        .idEqualTo(reviewId)
        .findFirst();
    if (entity == null) throw Exception('Review not found');

    entity
      ..status = 'Acknowledged'
      ..employeeComments = employeeComments
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.performanceReviews.put(entity);
    });
    await _enqueueOutbox(_toSyncPayload(entity), action: 'update');

    notifyListeners();
  }

  /// Get reviews pending employee acknowledgment
  Future<List<PerformanceReview>> getPendingAcknowledgment(
    String employeeId,
  ) async {
    final entities = await _dbService.performanceReviews
        .filter()
        .employeeIdEqualTo(employeeId)
        .statusEqualTo('Submitted')
        .findAll();
    return entities.where((e) => !e.isDeleted).map(_toDomain).toList();
  }

  /// Get all reviews for an employee
  Future<List<PerformanceReview>> getEmployeeReviews(String employeeId) async {
    final entities = await _dbService.performanceReviews
        .filter()
        .employeeIdEqualTo(employeeId)
        .findAll();
    return entities.where((e) => !e.isDeleted).map(_toDomain).toList();
  }

  /// Get reviews created by a manager
  Future<List<PerformanceReview>> getReviewsByManager(String reviewerId) async {
    final entities = await _dbService.performanceReviews
        .filter()
        .reviewerIdEqualTo(reviewerId)
        .findAll();
    return entities.where((e) => !e.isDeleted).map(_toDomain).toList();
  }

  /// Returns reviews visible to current app user.
  ///
  /// Logic:
  /// - Employee-facing: reviews where employeeId == linked employee id.
  /// - Legacy fallback: reviews where employeeId == app user id.
  /// - Reviewer-facing: reviews created by current user (reviewerId == user id).
  Future<List<PerformanceReview>> getVisibleReviewsForUser({
    required String userId,
    String? linkedEmployeeId,
  }) async {
    final byId = <String, PerformanceReview>{};

    Future<void> addEmployeeReviews(String employeeId) async {
      if (employeeId.isEmpty) return;
      final items = await getEmployeeReviews(employeeId);
      for (final review in items) {
        byId[review.id] = review;
      }
    }

    if (linkedEmployeeId != null && linkedEmployeeId.isNotEmpty) {
      await addEmployeeReviews(linkedEmployeeId);
    }

    await addEmployeeReviews(userId);

    final managerReviews = await getReviewsByManager(userId);
    for (final review in managerReviews) {
      byId[review.id] = review;
    }

    final merged = byId.values.toList()
      ..sort((a, b) => b.reviewDate.compareTo(a.reviewDate));
    return merged;
  }

  /// Get draft reviews for a manager
  Future<List<PerformanceReview>> getDraftReviews(String reviewerId) async {
    final entities = await _dbService.performanceReviews
        .filter()
        .reviewerIdEqualTo(reviewerId)
        .statusEqualTo('Draft')
        .findAll();
    return entities.where((e) => !e.isDeleted).map(_toDomain).toList();
  }

  /// Get a single review by ID
  Future<PerformanceReview?> getReviewById(String id) async {
    final entity = await _dbService.performanceReviews
        .filter()
        .idEqualTo(id)
        .findFirst();
    if (entity == null || entity.isDeleted) return null;
    return _toDomain(entity);
  }

  PerformanceReview _toDomain(PerformanceReviewEntity e) {
    return PerformanceReview(
      id: e.id,
      employeeId: e.employeeId,
      reviewerId: e.reviewerId,
      reviewPeriod: e.reviewPeriod,
      reviewDate: DateTime.parse(e.reviewDate),
      qualityScore: e.qualityScore,
      productivityScore: e.productivityScore,
      attendanceScore: e.attendanceScore,
      teamworkScore: e.teamworkScore,
      initiativeScore: e.initiativeScore,
      overallRating: e.overallRating,
      strengths: e.strengths,
      improvements: e.improvements,
      goals: e.goals,
      employeeComments: e.employeeComments,
      managerComments: e.managerComments,
      status: e.status,
    );
  }
}
