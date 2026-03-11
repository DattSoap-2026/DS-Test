enum AuditAction {
  create,
  update,
  delete,
  sync,
  login,
  logout,
  stockAdjustment,
  dispatch,
  payment,
  other,
}

class AuditLog {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final AuditAction action;
  final String collectionName;
  final String documentId;
  final Map<String, dynamic>? changes;
  final String? notes;
  final DateTime createdAt;
  final String? ipAddress;
  final String? deviceInfo;

  AuditLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.collectionName,
    required this.documentId,
    this.changes,
    this.notes,
    required this.createdAt,
    this.ipAddress,
    this.deviceInfo,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userRole: json['userRole'],
      action: AuditAction.values.firstWhere(
        (e) => e.toString().split('.').last == json['action'],
      ),
      collectionName: json['collectionName'],
      documentId: json['documentId'],
      changes: json['changes'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      ipAddress: json['ipAddress'],
      deviceInfo: json['deviceInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'action': action.toString().split('.').last,
      'collectionName': collectionName,
      'documentId': documentId,
      'changes': changes,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'ipAddress': ipAddress,
      'deviceInfo': deviceInfo,
    };
  }
}
