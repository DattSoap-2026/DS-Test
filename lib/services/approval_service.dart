import 'offline_first_service.dart';

const approvalsCollection = 'approvals';

/// Approval types supported by the system
enum ApprovalType {
  stockAdjustment('stock_adjustment'),
  payment('payment'),
  discount('discount'),
  returnApproval('return_approval');

  final String value;
  const ApprovalType(this.value);
}

/// Approval status lifecycle
enum ApprovalStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  autoApproved('auto_approved'); // For auto-approve mode

  final String value;
  const ApprovalStatus(this.value);
}

/// Approval request model
class ApprovalRequest {
  final String id;
  final ApprovalType type;
  final ApprovalStatus status;
  final String requestedBy;
  final String requestedByName;
  final String requestedAt;
  final Map<String, dynamic> details;
  final String? approvedBy;
  final String? approvedByName;
  final String? approvedAt;
  final String? rejectedBy;
  final String? rejectedByName;
  final String? rejectedAt;
  final String? rejectionReason;

  ApprovalRequest({
    required this.id,
    required this.type,
    required this.status,
    required this.requestedBy,
    required this.requestedByName,
    required this.requestedAt,
    required this.details,
    this.approvedBy,
    this.approvedByName,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedByName,
    this.rejectedAt,
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.value,
    'status': status.value,
    'requestedBy': requestedBy,
    'requestedByName': requestedByName,
    'requestedAt': requestedAt,
    'details': details,
    'approvedBy': approvedBy,
    'approvedByName': approvedByName,
    'approvedAt': approvedAt,
    'rejectedBy': rejectedBy,
    'rejectedByName': rejectedByName,
    'rejectedAt': rejectedAt,
    'rejectionReason': rejectionReason,
  };
}

/// Service for managing approval workflows
///
/// Features:
/// - Offline-first with local storage
/// - Auto-approve mode (default: enabled)
/// - Full audit trail
/// - Future-ready for UI integration
class ApprovalService extends OfflineFirstService {
  ApprovalService(super.firebase);

  @override
  String get localStorageKey => 'local_approvals';

  /// Auto-approve mode flag
  /// When true, all requests are auto-approved immediately
  /// When false, requests go to pending state for manual review
  bool autoApproveEnabled = true;

  /// Create approval request
  ///
  /// If autoApproveEnabled = true, request is auto-approved
  /// If autoApproveEnabled = false, request goes to pending state
  ///
  /// Returns: (approvalId, isAutoApproved)
  Future<(String, bool)> createApprovalRequest({
    required ApprovalType type,
    required String requestedBy,
    required String requestedByName,
    required Map<String, dynamic> details,
  }) async {
    final approvalId = generateId();
    final now = getCurrentTimestamp();

    final approval = {
      'id': approvalId,
      'type': type.value,
      'status': autoApproveEnabled
          ? ApprovalStatus.autoApproved.value
          : ApprovalStatus.pending.value,
      'requestedBy': requestedBy,
      'requestedByName': requestedByName,
      'requestedAt': now,
      'details': details,
    };

    // If auto-approve enabled, mark as approved
    if (autoApproveEnabled) {
      approval['approvedBy'] = 'system';
      approval['approvedByName'] = 'Auto-Approved';
      approval['approvedAt'] = now;
    }

    await addToLocal(addTimestamps(approval));
    await syncToFirebase('add', approval, collectionName: approvalsCollection);

    return (approvalId, autoApproveEnabled);
  }

  /// Approve a pending request
  Future<void> approveRequest({
    required String approvalId,
    required String approverId,
    required String approverName,
  }) async {
    final approval = await findInLocal(approvalId);
    if (approval == null) {
      throw Exception('Approval request not found: $approvalId');
    }

    if (approval['status'] != ApprovalStatus.pending.value) {
      throw Exception(
        'Cannot approve: Request is already ${approval['status']}',
      );
    }

    final updates = {
      'id': approvalId,
      'status': ApprovalStatus.approved.value,
      'approvedBy': approverId,
      'approvedByName': approverName,
      'approvedAt': getCurrentTimestamp(),
    };

    await updateInLocal(approvalId, addTimestamps(updates, isNew: false));
    await syncToFirebase(
      'update',
      updates,
      collectionName: approvalsCollection,
    );
  }

  /// Reject a pending request
  Future<void> rejectRequest({
    required String approvalId,
    required String rejectorId,
    required String rejectorName,
    String? reason,
  }) async {
    final approval = await findInLocal(approvalId);
    if (approval == null) {
      throw Exception('Approval request not found: $approvalId');
    }

    if (approval['status'] != ApprovalStatus.pending.value) {
      throw Exception(
        'Cannot reject: Request is already ${approval['status']}',
      );
    }

    final updates = {
      'id': approvalId,
      'status': ApprovalStatus.rejected.value,
      'rejectedBy': rejectorId,
      'rejectedByName': rejectorName,
      'rejectedAt': getCurrentTimestamp(),
      'rejectionReason': reason,
    };

    await updateInLocal(approvalId, addTimestamps(updates, isNew: false));
    await syncToFirebase(
      'update',
      updates,
      collectionName: approvalsCollection,
    );
  }

  /// Get all pending approvals (for UI when implemented)
  Future<List<Map<String, dynamic>>> getPendingApprovals() async {
    final all = await loadFromLocal();
    return all
        .where((a) => a['status'] == ApprovalStatus.pending.value)
        .toList();
  }

  /// Get approval by ID
  Future<Map<String, dynamic>?> getApproval(String id) async {
    return await findInLocal(id);
  }

  /// Get approvals by type
  Future<List<Map<String, dynamic>>> getApprovalsByType(
    ApprovalType type,
  ) async {
    final all = await loadFromLocal();
    return all.where((a) => a['type'] == type.value).toList();
  }

  /// Check if an approval is approved (including auto-approved)
  Future<bool> isApproved(String approvalId) async {
    final approval = await findInLocal(approvalId);
    if (approval == null) return false;

    return approval['status'] == ApprovalStatus.approved.value ||
        approval['status'] == ApprovalStatus.autoApproved.value;
  }

  /// Enable manual approval mode (disable auto-approve)
  /// Call this when approval UI is ready
  void enableManualApprovalMode() {
    autoApproveEnabled = false;
  }

  /// Enable auto-approve mode (default)
  void enableAutoApprovalMode() {
    autoApproveEnabled = true;
  }
}
