enum VehicleDocumentType { insurance, puc, permit, fitness }

extension VehicleDocumentTypeX on VehicleDocumentType {
  String get label {
    switch (this) {
      case VehicleDocumentType.insurance:
        return 'Insurance';
      case VehicleDocumentType.puc:
        return 'PUC';
      case VehicleDocumentType.permit:
        return 'Permit';
      case VehicleDocumentType.fitness:
        return 'Fitness';
    }
  }
}

enum VehicleExpiryStatus { expired, critical, upcoming, ok, noData }

extension VehicleExpiryStatusX on VehicleExpiryStatus {
  String get label {
    switch (this) {
      case VehicleExpiryStatus.expired:
        return 'Expired';
      case VehicleExpiryStatus.critical:
        return 'Critical';
      case VehicleExpiryStatus.upcoming:
        return 'Upcoming';
      case VehicleExpiryStatus.ok:
        return 'OK';
      case VehicleExpiryStatus.noData:
        return 'No Data';
    }
  }

  int get sortOrder {
    switch (this) {
      case VehicleExpiryStatus.expired:
        return 0;
      case VehicleExpiryStatus.critical:
        return 1;
      case VehicleExpiryStatus.upcoming:
        return 2;
      case VehicleExpiryStatus.ok:
        return 3;
      case VehicleExpiryStatus.noData:
        return 4;
    }
  }
}

class VehicleExpiryStatusClassifier {
  static const int criticalWindowDays = 15;
  static const int upcomingWindowDays = 30;

  static int? daysUntil(DateTime? expiryDate, {DateTime? referenceDate}) {
    if (expiryDate == null) return null;

    final today = _toLocalDate((referenceDate ?? DateTime.now()).toLocal());
    final expiryLocalDate = _toLocalDate(expiryDate.toLocal());
    return expiryLocalDate.difference(today).inDays;
  }

  static VehicleExpiryStatus classify(
    DateTime? expiryDate, {
    DateTime? referenceDate,
  }) {
    final remainingDays = daysUntil(expiryDate, referenceDate: referenceDate);
    if (remainingDays == null) return VehicleExpiryStatus.noData;
    if (remainingDays < 0) return VehicleExpiryStatus.expired;
    if (remainingDays <= criticalWindowDays) return VehicleExpiryStatus.critical;
    if (remainingDays <= upcomingWindowDays) return VehicleExpiryStatus.upcoming;
    return VehicleExpiryStatus.ok;
  }

  static DateTime _toLocalDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

class VehicleExpiryReportRow {
  final String vehicleId;
  final String vehicleNumber;
  final String vehicleName;
  final String vehicleType;
  final VehicleDocumentType documentType;
  final DateTime? expiryDate;
  final VehicleExpiryStatus status;
  final int? daysRemaining;

  const VehicleExpiryReportRow({
    required this.vehicleId,
    required this.vehicleNumber,
    required this.vehicleName,
    required this.vehicleType,
    required this.documentType,
    required this.expiryDate,
    required this.status,
    required this.daysRemaining,
  });
}

class VehicleExpiryReportQuery {
  final VehicleDocumentType? documentType;
  final VehicleExpiryStatus? status;
  final String? vehicleId;
  final bool includeNoData;
  final DateTime? asOfDate;

  const VehicleExpiryReportQuery({
    this.documentType,
    this.status,
    this.vehicleId,
    this.includeNoData = true,
    this.asOfDate,
  });
}

class VehicleExpiryReportData {
  final DateTime generatedAt;
  final DateTime asOfDate;
  final List<VehicleExpiryReportRow> rows;
  final Map<VehicleExpiryStatus, int> statusCounts;

  const VehicleExpiryReportData({
    required this.generatedAt,
    required this.asOfDate,
    required this.rows,
    required this.statusCounts,
  });

  int get totalRows => rows.length;
}
