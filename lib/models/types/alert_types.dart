enum AlertType {
  criticalStock,
  attendanceLate,
  attendanceMissed,
  dispatchReceived,
  paymentPending,
  systemUpdate,
  vehicleExpiry,
  other,
}

enum AlertSeverity { info, warning, critical }

class SystemAlert {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final AlertSeverity severity;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId; // e.g. productId, employeeId, saleId
  final Map<String, dynamic>? metadata;

  SystemAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    this.isRead = false,
    required this.createdAt,
    this.relatedId,
    this.metadata,
  });

  factory SystemAlert.fromJson(Map<String, dynamic> json) {
    return SystemAlert(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: AlertType.values.firstWhere((e) => e.toString() == json['type']),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.toString() == json['severity'],
      ),
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      relatedId: json['relatedId'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'severity': severity.toString(),
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'relatedId': relatedId,
      'metadata': metadata,
    };
  }
}
